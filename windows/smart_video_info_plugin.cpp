#include "smart_video_info_plugin.h"

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <windows.h>
#include <mfapi.h>
#include <mfidl.h>
#include <mfreadwrite.h>
#include <propvarutil.h>
#include <shlwapi.h>

#include <memory>
#include <sstream>
#include <string>
#include <vector>

#pragma comment(lib, "mfplat.lib")
#pragma comment(lib, "mfreadwrite.lib")
#pragma comment(lib, "mfuuid.lib")
#pragma comment(lib, "shlwapi.lib")
#pragma comment(lib, "propsys.lib")

namespace smart_video_info {

namespace {

std::string WStringToString(const std::wstring& wstr) {
    if (wstr.empty()) return std::string();
    int size_needed = WideCharToMultiByte(CP_UTF8, 0, &wstr[0], (int)wstr.size(), NULL, 0, NULL, NULL);
    std::string strTo(size_needed, 0);
    WideCharToMultiByte(CP_UTF8, 0, &wstr[0], (int)wstr.size(), &strTo[0], size_needed, NULL, NULL);
    return strTo;
}

std::wstring StringToWString(const std::string& str) {
    if (str.empty()) return std::wstring();
    int size_needed = MultiByteToWideChar(CP_UTF8, 0, &str[0], (int)str.size(), NULL, 0);
    std::wstring wstrTo(size_needed, 0);
    MultiByteToWideChar(CP_UTF8, 0, &str[0], (int)str.size(), &wstrTo[0], size_needed);
    return wstrTo;
}

std::string GetFileExtension(const std::wstring& path) {
    const wchar_t* ext = PathFindExtensionW(path.c_str());
    if (ext && *ext == L'.') {
        return WStringToString(ext + 1);
    }
    return "";
}

std::string ExtractVideoMetadata(const std::string& path) {
    HRESULT hr = S_OK;
    
    // Initialize Media Foundation
    hr = MFStartup(MF_VERSION);
    if (FAILED(hr)) {
        return R"({"success":false,"error":"Failed to initialize Media Foundation"})";
    }

    IMFSourceReader* pReader = NULL;
    std::wstring wpath = StringToWString(path);
    
    hr = MFCreateSourceReaderFromURL(wpath.c_str(), NULL, &pReader);
    if (FAILED(hr)) {
        MFShutdown();
        return R"({"success":false,"error":"Failed to open video file"})";
    }

    // Get video stream info
    IMFMediaType* pType = NULL;
    hr = pReader->GetCurrentMediaType((DWORD)MF_SOURCE_READER_FIRST_VIDEO_STREAM, &pType);
    
    int width = 0, height = 0;
    double fps = 0.0;
    int bitrate = 0;
    int rotation = 0;
    std::string codec = "";
    
    if (SUCCEEDED(hr) && pType) {
        // Get resolution
        UINT32 w = 0, h = 0;
        MFGetAttributeSize(pType, MF_MT_FRAME_SIZE, &w, &h);
        width = w;
        height = h;
        
        // Get frame rate
        UINT32 numerator = 0, denominator = 1;
        MFGetAttributeRatio(pType, MF_MT_FRAME_RATE, &numerator, &denominator);
        if (denominator > 0) {
            fps = (double)numerator / denominator;
        }
        
        // Get bitrate
        UINT32 avgBitrate = 0;
        pType->GetUINT32(MF_MT_AVG_BITRATE, &avgBitrate);
        bitrate = avgBitrate;
        
        // Get codec (subtype GUID)
        GUID subtype = {0};
        if (SUCCEEDED(pType->GetGUID(MF_MT_SUBTYPE, &subtype))) {
            if (subtype == MFVideoFormat_H264) codec = "h264";
            else if (subtype == MFVideoFormat_H265) codec = "hevc";
            else if (subtype == MFVideoFormat_VP80) codec = "vp8";
            else if (subtype == MFVideoFormat_VP90) codec = "vp9";
            else if (subtype == MFVideoFormat_WMV3) codec = "wmv3";
            else if (subtype == MFVideoFormat_MPEG2) codec = "mpeg2";
            else codec = "unknown";
        }
        
        pType->Release();
    }
    
    // Get duration
    PROPVARIANT var;
    PropVariantInit(&var);
    int64_t durationMs = 0;
    
    hr = pReader->GetPresentationAttribute((DWORD)MF_SOURCE_READER_MEDIASOURCE, 
                                           MF_PD_DURATION, &var);
    if (SUCCEEDED(hr)) {
        LONGLONG duration100ns = var.hVal.QuadPart;
        durationMs = duration100ns / 10000; // Convert to milliseconds
        PropVariantClear(&var);
    }
    
    // Check for audio stream
    bool hasAudio = false;
    std::string audioCodec = "";
    int sampleRate = 0;
    int channels = 0;
    
    IMFMediaType* pAudioType = NULL;
    hr = pReader->GetCurrentMediaType((DWORD)MF_SOURCE_READER_FIRST_AUDIO_STREAM, &pAudioType);
    if (SUCCEEDED(hr) && pAudioType) {
        hasAudio = true;
        
        // Get audio codec
        GUID audioSubtype = {0};
        if (SUCCEEDED(pAudioType->GetGUID(MF_MT_SUBTYPE, &audioSubtype))) {
            if (audioSubtype == MFAudioFormat_AAC) audioCodec = "aac";
            else if (audioSubtype == MFAudioFormat_MP3) audioCodec = "mp3";
            else if (audioSubtype == MFAudioFormat_WMAudioV8) audioCodec = "wma";
            else if (audioSubtype == MFAudioFormat_PCM) audioCodec = "pcm";
            else audioCodec = "unknown";
        }
        
        // Get sample rate
        UINT32 sr = 0;
        pAudioType->GetUINT32(MF_MT_AUDIO_SAMPLES_PER_SECOND, &sr);
        sampleRate = sr;
        
        // Get channels
        UINT32 ch = 0;
        pAudioType->GetUINT32(MF_MT_AUDIO_NUM_CHANNELS, &ch);
        channels = ch;
        
        pAudioType->Release();
    }
    
    // Get container format
    std::string container = GetFileExtension(wpath);
    
    // Count streams
    int streamCount = 0;
    DWORD streamIndex = 0;
    while (true) {
        IMFMediaType* pStreamType = NULL;
        hr = pReader->GetCurrentMediaType(streamIndex, &pStreamType);
        if (FAILED(hr)) break;
        if (pStreamType) {
            streamCount++;
            pStreamType->Release();
        }
        streamIndex++;
    }
    
    pReader->Release();
    MFShutdown();
    
    // Build JSON response
    std::ostringstream json;
    json << R"({"success":true,"data":{)";
    json << R"("width":)" << width << ",";
    json << R"("height":)" << height << ",";
    json << R"("duration":)" << durationMs << ",";
    json << R"("codec":")" << codec << "\",";
    json << R"("bitrate":)" << bitrate << ",";
    json << R"("fps":)" << fps << ",";
    json << R"("rotation":)" << rotation << ",";
    json << R"("container":")" << container << "\",";
    
    if (hasAudio) {
        json << R"("audioCodec":")" << audioCodec << "\",";
        json << R"("sampleRate":)" << sampleRate << ",";
        json << R"("channels":)" << channels << ",";
    }
    
    json << R"("hasAudio":)" << (hasAudio ? "true" : "false") << ",";
    json << R"("hasSubtitles":false,)";
    json << R"("streamCount":)" << streamCount;
    json << "}}";
    
    return json.str();
}

}  // namespace

// static
void SmartVideoInfoPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "smart_video_info",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<SmartVideoInfoPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

SmartVideoInfoPlugin::SmartVideoInfoPlugin() {}

SmartVideoInfoPlugin::~SmartVideoInfoPlugin() {}

void SmartVideoInfoPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  
  if (method_call.method_name().compare("getInfo") == 0) {
    const auto* arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
    if (!arguments) {
      result->Error("INVALID_ARGUMENT", "Arguments must be a map");
      return;
    }
    
    auto path_it = arguments->find(flutter::EncodableValue("path"));
    if (path_it == arguments->end()) {
      result->Error("INVALID_ARGUMENT", "Path is required");
      return;
    }
    
    const auto* path = std::get_if<std::string>(&path_it->second);
    if (!path) {
      result->Error("INVALID_ARGUMENT", "Path must be a string");
      return;
    }
    
    std::string json = ExtractVideoMetadata(*path);
    result->Success(flutter::EncodableValue(json));
    
  } else if (method_call.method_name().compare("getBatch") == 0) {
    const auto* arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
    if (!arguments) {
      result->Error("INVALID_ARGUMENT", "Arguments must be a map");
      return;
    }
    
    auto paths_it = arguments->find(flutter::EncodableValue("paths"));
    if (paths_it == arguments->end()) {
      result->Error("INVALID_ARGUMENT", "Paths list is required");
      return;
    }
    
    const auto* paths = std::get_if<flutter::EncodableList>(&paths_it->second);
    if (!paths || paths->empty()) {
      result->Error("INVALID_ARGUMENT", "Paths must be a non-empty list");
      return;
    }
    
    flutter::EncodableList results;
    for (const auto& path_value : *paths) {
      const auto* path = std::get_if<std::string>(&path_value);
      if (path) {
        std::string json = ExtractVideoMetadata(*path);
        results.push_back(flutter::EncodableValue(json));
      }
    }
    
    result->Success(flutter::EncodableValue(results));
    
  } else {
    result->NotImplemented();
  }
}

}  // namespace smart_video_info
