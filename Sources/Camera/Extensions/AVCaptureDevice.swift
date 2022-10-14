import AVKit

extension AVCaptureDevice {
    static var defaultCamera: AVCaptureDevice? {
        
        // Find the built-in Dual Camera, if it exists.
        if let device = Self.default(.builtInTripleCamera, for: .video, position: .back) {
            return device
        }

        if let device = Self.default(.builtInDualCamera, for: .video, position: .back) {
            return device
        }

        // Find the built-in Wide-Angle Camera, if it exists.
        if let device = Self.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return device
        }
        
        return nil
    }
}
