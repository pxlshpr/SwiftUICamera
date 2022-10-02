import AVKit

public struct CameraConfiguration: Equatable {
    var deviceType: AVCaptureDevice.DeviceType = .builtInDualCamera
    var position: AVCaptureDevice.Position = .back
    var flashMode: AVCaptureDevice.FlashMode = .off
    var torchMode: AVCaptureDevice.TorchMode = .off
}

