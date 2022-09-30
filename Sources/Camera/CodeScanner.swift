import SwiftUI

public struct CodeScanner: View {
    @StateObject var viewModel: ViewModel
    let didScanCode: ScannedCodeHandler?

    public init(showTorchButton: Bool = true, didScanCode: ScannedCodeHandler? = nil) {
        self.didScanCode = didScanCode
        let viewModel = ViewModel(
            showFlashButton: false,
            showTorchButton: showTorchButton,
            showPhotoPickerButton: false,
            showCapturedImagesCount: false
        )
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        BaseCamera(didCaptureImage: nil, didScanCode: didScanCode)
            .environmentObject(viewModel)
    }
}
