import SwiftUI
import AVKit
import Observation

import SwiftHaptics

@Observable public class CameraModel {
    let mode: CameraMode
    let showDismissButton: Bool
    let showFlashButton: Bool
    let showTorchButton: Bool
    let showPhotoPickerButton: Bool
    let showCapturedImagesCount: Bool
    
    let showCaptureAnimation: Bool

    var capturedImageCount: Int = 0
    var animateCameraViewShrinking = false
    var makeCameraViewTranslucent = false
    
    var config: CameraConfiguration = CameraConfiguration()
    
    public var shouldDismiss: Bool = false
    public var shouldShowScanOverlay: Bool = false

    public init(
        mode: CameraMode = .capture,
        showCaptureAnimation: Bool = true,
        shouldShowScanOverlay: Bool = true,
        showDismissButton: Bool,
        showFlashButton: Bool,
        showTorchButton: Bool,
        showPhotoPickerButton: Bool,
        showCapturedImagesCount: Bool
    ) {
        self.mode = mode
        self.showCaptureAnimation = showCaptureAnimation
        self.showFlashButton = showFlashButton
        self.showTorchButton = showTorchButton
        self.showPhotoPickerButton = showPhotoPickerButton
        self.showCapturedImagesCount = showCapturedImagesCount
        
        self.showDismissButton = showDismissButton
        self.shouldShowScanOverlay = shouldShowScanOverlay
    }
    
    func tappedDismiss() {
        shouldDismiss = true
    }
    
    func tappedCapture() {
        capturedImageCount += 1
        guard showCaptureAnimation else { return }
        
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

