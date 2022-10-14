import SwiftUI
import AVKit
import SwiftHaptics

public typealias CodeHandler = ((Result<String, Camera.ScanError>) -> Void)
public typealias ImageHandler = ((UIImage) -> Void)

public struct Camera: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject var cameraViewModel: CameraViewModel
    let imageHandler: ImageHandler?
    
    public init(
        showFlashButton: Bool = true,
        showTorchButton: Bool = false,
        showPhotosPickerButton: Bool = false,
        showCapturedImagesCount: Bool = true,
        imageHandler: ImageHandler? = nil
    ) {
        self.imageHandler = imageHandler
        let cameraViewModel = CameraViewModel(
            showFlashButton: showFlashButton,
            showTorchButton: showTorchButton,
            showPhotoPickerButton: showPhotosPickerButton,
            showCapturedImagesCount: showCapturedImagesCount
        )
        _cameraViewModel = StateObject(wrappedValue: cameraViewModel)
    }
    
    public var body: some View {
        BaseCamera(imageHandler: imageHandler)
            .environmentObject(cameraViewModel)
            .onChange(of: cameraViewModel.shouldDismiss) { newValue in
                if newValue {
                    dismiss()
                }
            }
    }
}
