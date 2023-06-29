import SwiftUI
import AVKit
import SwiftHaptics

public typealias CodeHandler = ((Result<String, Camera.ScanError>) -> Void)
public typealias ImageHandler = ((UIImage) -> Void)

public struct Camera: View {
    
    @Environment(\.dismiss) var dismiss
    var cameraModel: CameraModel
    let imageHandler: ImageHandler?
    
    public init(
        showDismissButton: Bool = true,
        showFlashButton: Bool = true,
        showTorchButton: Bool = false,
        showPhotosPickerButton: Bool = false,
        showCapturedImagesCount: Bool = false,
        showCaptureAnimation: Bool = false,
        imageHandler: ImageHandler? = nil
    ) {
        self.imageHandler = imageHandler
        self.cameraModel = CameraModel(
            showCaptureAnimation: showCaptureAnimation,
            showDismissButton: showDismissButton,
            showFlashButton: showFlashButton,
            showTorchButton: showTorchButton,
            showPhotoPickerButton: showPhotosPickerButton,
            showCapturedImagesCount: showCapturedImagesCount
        )
    }
    
    public var body: some View {
        BaseCamera(
            cameraModel: cameraModel,
            imageHandler: imageHandler
        )
        .onChange(of: cameraModel.shouldDismiss) { oldValue, newValue in
            if newValue {
                dismiss()
            }
        }
    }
}
