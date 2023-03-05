import SwiftUI
import AVKit
import SwiftHaptics

public typealias CodeHandler = ((Result<String, Camera.ScanError>) -> Void)
public typealias ImageHandler = ((UIImage) -> Void)

public struct Camera: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject var cameraModel: CameraModel
    let imageHandler: ImageHandler?
    
    public init(
        showDismissButton: Bool = true,
        showFlashButton: Bool = true,
        showTorchButton: Bool = false,
        showPhotosPickerButton: Bool = false,
        showCapturedImagesCount: Bool = true,
        showCaptureAnimation: Bool = false,
        imageHandler: ImageHandler? = nil
    ) {
        self.imageHandler = imageHandler
        let cameraModel = CameraModel(
            showCaptureAnimation: showCaptureAnimation,
            showDismissButton: showDismissButton,
            showFlashButton: showFlashButton,
            showTorchButton: showTorchButton,
            showPhotoPickerButton: showPhotosPickerButton,
            showCapturedImagesCount: showCapturedImagesCount
        )
        _cameraModel = StateObject(wrappedValue: cameraModel)
    }
    
    public var body: some View {
        BaseCamera(imageHandler: imageHandler)
            .environmentObject(cameraModel)
            .onChange(of: cameraModel.shouldDismiss) { newValue in
                if newValue {
                    dismiss()
                }
            }
    }
}
