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
            if config.torchMode.isSelected {
                config.torchMode = .off
            } else {
                if config.torchMode == .off {
                    //TODO: Set this to the last selection the user made
                    config.torchMode = .on
                }
            }
        }
    }
    
    func tappedCapturedPhotos() {
        shouldDismiss = true
    }
}

