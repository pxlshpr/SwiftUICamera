import SwiftUI
import AVKit
import SwiftHaptics

class ViewModel: ObservableObject {
    let showFlashButton: Bool
    let showTorchButton: Bool
    let showPhotoPickerButton: Bool
    let showCapturedImagesCount: Bool

    @Published var capturedImageCount: Int = 0
    
    @Published var animateCameraViewShrinking = false
    @Published var makeCameraViewTranslucent = false
    
    @Published var torchMode: AVCaptureDevice.TorchMode = .off {
        didSet {
            setDeviceTorchMode(to: torchMode)
        }
    }

    @Published var config: CameraConfiguration = CameraConfiguration()
    
    @Published var shouldDismiss: Bool = false

    init(showFlashButton: Bool, showTorchButton: Bool, showPhotoPickerButton: Bool, showCapturedImagesCount: Bool) {
        self.showFlashButton = showFlashButton
        self.showTorchButton = showTorchButton
        self.showPhotoPickerButton = showPhotoPickerButton
        self.showCapturedImagesCount = showCapturedImagesCount
    }
    
    func tappedCapture() {
        capturedImageCount += 1
        withAnimation(.easeInOut(duration: 0.4)) {
            animateCameraViewShrinking = true
            makeCameraViewTranslucent = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.animateCameraViewShrinking = false
            withAnimation(.easeInOut(duration: 0.2)) {
                self.makeCameraViewTranslucent = false
            }
        }
    }

    func tappedFlashButton() {
        Haptics.feedback(style: .medium)
        withAnimation(.interactiveSpring()) {
            if config.flashMode.isSelected {
                config.flashMode = .off
            } else {
                if config.flashMode == .off {
                    //TODO: Set this to the last selection the user made
                    config.flashMode = .auto
                }
            }
        }
    }
    
    func tappedTorchButton() {
        Haptics.feedback(style: .medium)
        withAnimation(.interactiveSpring()) {
            if torchMode.isSelected {
                torchMode = .off
            } else {
                if torchMode == .off {
                    //TODO: Set this to the last selection the user made
                    torchMode = .on
                }
            }
        }
    }
    
    func tappedCapturedPhotos() {
        shouldDismiss = true
    }
    
    func setDeviceTorchMode(to torchMode: AVCaptureDevice.TorchMode) {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else {
            return
        }
        do {
            try device.lockForConfiguration()
            device.torchMode = torchMode
            device.unlockForConfiguration()
        } catch {
            print(error)
        }
    }
}

