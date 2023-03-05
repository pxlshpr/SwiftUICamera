import SwiftUI

public struct CodeScanner: View {
    @StateObject var cameraModel: CameraModel
    let codeHandler: CodeHandler?

    public init(
        showDismissButton: Bool = true,
        showTorchButton: Bool = true,
        codeHandler: CodeHandler? = nil
    ) {
        self.codeHandler = codeHandler
        let cameraModel = CameraModel(
            mode: .scan,
            showDismissButton: showDismissButton,
            showFlashButton: false,
            showTorchButton: showTorchButton,
            showPhotoPickerButton: false,
            showCapturedImagesCount: false
        )
        _cameraModel = StateObject(wrappedValue: cameraModel)
    }
    
    public var body: some View {
        BaseCamera(codeHandler: codeHandler)
            .environmentObject(cameraModel)
    }
}
