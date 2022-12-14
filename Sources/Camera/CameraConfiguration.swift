import AVKit

public struct CameraConfiguration: Equatable {
    var deviceType: AVCaptureDevice.DeviceType = .builtInTripleCamera
    var position: AVCaptureDevice.Position = .back
    var flashMode: AVCaptureDevice.FlashMode = .off
    var torchMode: AVCaptureDevice.TorchMode = .off
}

