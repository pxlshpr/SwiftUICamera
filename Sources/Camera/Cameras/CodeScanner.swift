import SwiftUI

public struct CodeScanner: View {
    var cameraModel: CameraModel
    let codeHandler: CodeHandler?

    public init(
        showDismissButton: Bool = true,
        showTorchButton: Bool = true,
        codeHandler: CodeHandler? = nil
    ) {
        self.codeHandler = codeHandler
        self.cameraModel = CameraModel(
            mode: .scan,
            showDismissButton: showDismissButton,
            showFlashButton: false,
            showTorchButton: showTorchButton,
            showPhotoPickerButton: false,
            showCapturedImagesCount: false
        )
    }
    
    public var body: some View {
        BaseCamera(
            cameraModel: cameraModel,
            codeHandler: codeHandler
        )
    }
}
