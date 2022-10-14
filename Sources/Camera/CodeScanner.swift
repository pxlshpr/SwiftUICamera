import SwiftUI

public struct CodeScanner: View {
    @StateObject var cameraViewModel: CameraViewModel
    let didScanCode: ScannedCodeHandler?

    public init(showTorchButton: Bool = true, didScanCode: ScannedCodeHandler? = nil) {
        self.didScanCode = didScanCode
        let cameraViewModel = CameraViewModel(
            showFlashButton: false,
            showTorchButton: showTorchButton,
            showPhotoPickerButton: false,
            showCapturedImagesCount: false
        )
        _cameraViewModel = StateObject(wrappedValue: cameraViewModel)
    }
    
    public var body: some View {
        BaseCamera(didCaptureImage: nil, didScanCode: didScanCode)
            .environmentObject(cameraViewModel)
    }
}
