import Flutter
import UIKit
import AVFoundation

public class SmartVideoInfoPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "smart_video_info", binaryMessenger: registrar.messenger())
        let instance = SmartVideoInfoPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getInfo":
            guard let args = call.arguments as? [String: Any],
                  let path = args["path"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Path is required", details: nil))
                return
            }
            getVideoMetadata(path: path, result: result)
            
        case "getBatch":
            guard let args = call.arguments as? [String: Any],
                  let paths = args["paths"] as? [String] else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Paths list is required", details: nil))
                return
            }
            getBatchMetadata(paths: paths, result: result)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func getVideoMetadata(path: String, result: @escaping FlutterResult) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let jsonString = try self.extractMetadata(path: path)
                DispatchQueue.main.async {
                    result(jsonString)
                }
            } catch {
                DispatchQueue.main.async {
                    result(FlutterError(code: "METADATA_ERROR", message: error.localizedDescription, details: nil))
                }
            }
        }
    }
    
    private func getBatchMetadata(paths: [String], result: @escaping FlutterResult) {
        DispatchQueue.global(qos: .userInitiated).async {
            var results: [String] = []
            
            for path in paths {
                do {
                    let jsonString = try self.extractMetadata(path: path)
                    results.append(jsonString)
                } catch {
                    DispatchQueue.main.async {
                        result(FlutterError(code: "METADATA_ERROR", message: error.localizedDescription, details: nil))
                    }
                    return
                }
            }
            
            DispatchQueue.main.async {
                result(results)
            }
        }
    }
    
    private func extractMetadata(path: String) throws -> String {
        let url = URL(fileURLWithPath: path)
        let asset = AVAsset(url: url)
        
        // Load tracks synchronously
        let tracks = try asset.loadTracks(withMediaType: .video)
        
        guard let videoTrack = tracks.first else {
            throw NSError(domain: "SmartVideoInfo", code: -1, userInfo: [NSLocalizedDescriptionKey: "No video track found"])
        }
        
        // Get video properties
        let size = videoTrack.naturalSize.applying(videoTrack.preferredTransform)
        let width = Int(abs(size.width))
        let height = Int(abs(size.height))
        let fps = videoTrack.nominalFrameRate
        let durationMs = Int(CMTimeGetSeconds(asset.duration) * 1000)
        
        // Get rotation
        let transform = videoTrack.preferredTransform
        let rotation = getRotationFromTransform(transform)
        
        // Get codec
        let formatDescriptions = videoTrack.formatDescriptions as! [CMFormatDescription]
        var codec = ""
        if let formatDescription = formatDescriptions.first {
            let codecType = CMFormatDescriptionGetMediaSubType(formatDescription)
            codec = fourCCToString(codecType)
        }
        
        // Get bitrate
        let bitrate = Int(videoTrack.estimatedDataRate)
        
        // Check for audio
        let audioTracks = try asset.loadTracks(withMediaType: .audio)
        let hasAudio = !audioTracks.isEmpty
        
        var audioCodec: String? = nil
        var sampleRate: Int? = nil
        var channels: Int? = nil
        
        if let audioTrack = audioTracks.first {
            let audioFormatDescriptions = audioTrack.formatDescriptions as! [CMFormatDescription]
            if let audioFormatDescription = audioFormatDescriptions.first {
                let audioCodecType = CMFormatDescriptionGetMediaSubType(audioFormatDescription)
                audioCodec = fourCCToString(audioCodecType)
                
                if let basicDescription = CMAudioFormatDescriptionGetStreamBasicDescription(audioFormatDescription) {
                    sampleRate = Int(basicDescription.pointee.mSampleRate)
                    channels = Int(basicDescription.pointee.mChannelsPerFrame)
                }
            }
        }
        
        // Check for subtitles
        let subtitleTracks = try asset.loadTracks(withMediaType: .subtitle)
        let hasSubtitles = !subtitleTracks.isEmpty
        
        // Get container format
        let container = url.pathExtension.lowercased()
        
        // Get total stream count
        let streamCount = asset.tracks.count
        
        // Build JSON response
        let data: [String: Any?] = [
            "width": width,
            "height": height,
            "duration": durationMs,
            "codec": codec,
            "bitrate": bitrate,
            "fps": Double(fps),
            "rotation": rotation,
            "container": container,
            "audioCodec": audioCodec,
            "sampleRate": sampleRate,
            "channels": channels,
            "hasAudio": hasAudio,
            "hasSubtitles": hasSubtitles,
            "streamCount": streamCount
        ]
        
        let json: [String: Any] = [
            "success": true,
            "data": data.compactMapValues { $0 }
        ]
        
        return try jsonToString(json)
    }
    
    private func getRotationFromTransform(_ transform: CGAffineTransform) -> Int {
        let angle = atan2(transform.b, transform.a)
        let degrees = Int(angle * 180 / .pi)
        
        // Normalize to 0, 90, 180, 270
        switch degrees {
        case 85...95:
            return 90
        case 175...185, -185...(-175):
            return 180
        case -95...(-85):
            return 270
        default:
            return 0
        }
    }
    
    private func fourCCToString(_ fourCC: FourCharCode) -> String {
        let bytes: [CChar] = [
            CChar((fourCC >> 24) & 0xff),
            CChar((fourCC >> 16) & 0xff),
            CChar((fourCC >> 8) & 0xff),
            CChar(fourCC & 0xff),
            0
        ]
        return String(cString: bytes).trimmingCharacters(in: .whitespaces)
    }
    
    private func jsonToString(_ dict: [String: Any]) throws -> String {
        let data = try JSONSerialization.data(withJSONObject: dict, options: [])
        guard let string = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "SmartVideoInfo", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode JSON"])
        }
        return string
    }
}
