#ifndef FLUTTER_PLUGIN_SMART_VIDEO_INFO_PLUGIN_H_
#define FLUTTER_PLUGIN_SMART_VIDEO_INFO_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace smart_video_info {

class SmartVideoInfoPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  SmartVideoInfoPlugin();

  virtual ~SmartVideoInfoPlugin();

  // Disallow copy and assign.
  SmartVideoInfoPlugin(const SmartVideoInfoPlugin&) = delete;
  SmartVideoInfoPlugin& operator=(const SmartVideoInfoPlugin&) = delete;

 private:
  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace smart_video_info

// C-style registration function for Flutter
#ifdef __cplusplus
extern "C" {
#endif

#ifdef FLUTTER_PLUGIN_IMPL
#define FLUTTER_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FLUTTER_PLUGIN_EXPORT __declspec(dllimport)
#endif

FLUTTER_PLUGIN_EXPORT void SmartVideoInfoPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar);

#ifdef __cplusplus
}  // extern "C"
#endif

#endif  // FLUTTER_PLUGIN_SMART_VIDEO_INFO_PLUGIN_H_
