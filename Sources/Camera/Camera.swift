import SwiftUI
import AVKit
import SwiftHaptics

public typealias ScannedCodeHandler = ((Result<String, Camera.ScanError>) -> Void)
public typealias CapturedImageHandler = ((UIImage) -> Void)

public struct Camera: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject var cameraViewModel: CameraViewModel
    let didCaptureImage: CapturedImageHandler?
    
    public init(showFlashButton: Bool = true, showTorchButton: Bool = false, showPhotosPickerButton: Bool = false, showCapturedImagesCount: Bool = true, didCaptureImage: CapturedImageHandler? = nil) {
        self.didCaptureImage = didCaptureImage
        let cameraViewModel = CameraViewModel(
            showFlashButton: showFlashButton,
            showTorchButton: showTorchButton,
            showPhotoPickerButton: showPhotosPickerButton,
            showCapturedImagesCount: showCapturedImagesCount
        )
        _cameraViewModel = StateObject(wrappedValue: cameraViewModel)
    }
    
    public var body: some View {
        BaseCamera(didCaptureImage: didCaptureImage, didScanCode: nil)
            .environmentObject(cameraViewModel)
            .onChange(of: cameraViewModel.shouldDismiss) { newValue in
                if newValue {
                    dismiss()
                }
            }
    }
}
