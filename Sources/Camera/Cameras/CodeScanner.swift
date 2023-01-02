import SwiftUI

public struct CodeScanner: View {
    @StateObject var cameraViewModel: CameraViewModel
    let codeHandler: CodeHandler?

    public init(
        showDismissButton: Bool = true,
        showTorchButton: Bool = true,
        codeHandler: CodeHandler? = nil
    ) {
        self.codeHandler = codeHandler
        let cameraViewModel = CameraViewModel(
            mode: .scan,
            showDismissButton: showDismissButton,
            showFlashButton: false,
            showTorchButton: showTorchButton,
            showPhotoPickerButton: false,
            showCapturedImagesCount: false
        )
        _cameraViewModel = StateObject(wrappedValue: cameraViewModel)
    }
    
    public var body: some View {
        BaseCamera(codeHandler: codeHandler)
            .environmentObject(cameraViewModel)
    }
}
