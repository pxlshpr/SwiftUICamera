import SwiftUI
import AVKit
import SwiftHaptics

public typealias ScannedCodeHandler = ((Result<String, Camera.ScanError>) -> Void)
public typealias CapturedImageHandler = ((UIImage) -> Void)

public struct Camera: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: ViewModel
    let didCaptureImage: CapturedImageHandler?
    
    public init(showFlashButton: Bool = true, showTorchButton: Bool = false, showPhotosPickerButton: Bool = false, showCapturedImagesCount: Bool = true, didCaptureImage: CapturedImageHandler? = nil) {
        self.didCaptureImage = didCaptureImage
        let viewModel = ViewModel(
            showFlashButton: showFlashButton,
            showTorchButton: showTorchButton,
            showPhotoPickerButton: showPhotosPickerButton,
            showCapturedImagesCount: showCapturedImagesCount
        )
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        BaseCamera(didCaptureImage: didCaptureImage, didScanCode: nil)
            .environmentObject(viewModel)
            .onChange(of: viewModel.shouldDismiss) { newValue in
                if newValue {
                    dismiss()
                }
            }
    }
}
