import SwiftUI
import AVKit

import VisionSugar
import SwiftHaptics

public typealias RecognizedBarcodesHandler = ([RecognizedBarcode]) -> ()
public typealias RecognizedBarcodesAndImageHandler = ([RecognizedBarcode], UIImage) -> ()

public struct BarcodeScanner: View {
    
    @Environment(\.dismiss) var dismiss
    
    var cameraModel: CameraModel
    var model: BarcodeScannerModel

    public init(
        showDismissButton: Bool = true,
        showTorchButton: Bool = true,
        barcodesAndImageHandler: @escaping RecognizedBarcodesAndImageHandler
    ) {
        self.cameraModel = CameraModel(
            mode: .scan,
            showDismissButton: showDismissButton,
            showFlashButton: false,
            showTorchButton: showTorchButton,
            showPhotoPickerButton: false,
            showCapturedImagesCount: false
        )
        
        self.model = BarcodeScannerModel(barcodesAndImageHandler: barcodesAndImageHandler)
    }

    public init(
        showDismissButton: Bool = true,
        showTorchButton: Bool = true,
        barcodesHandler: @escaping RecognizedBarcodesHandler
    ) {
        self.cameraModel = CameraModel(
            mode: .scan,
            showDismissButton: showDismissButton,
            showFlashButton: false,
            showTorchButton: showTorchButton,
            showPhotoPickerButton: false,
            showCapturedImagesCount: false
        )
        self.model = BarcodeScannerModel(barcodesHandler: barcodesHandler)
    }

    public var body: some View {
        BaseCamera(
            cameraModel: cameraModel,
            sampleBufferHandler: model.processSampleBuffer
        )
        .onChange(of: model.shouldDismiss) { oldValue, newValue in
            if newValue {
                dismiss()
            }
        }
        .onChange(of: cameraModel.shouldDismiss) { oldValue, newValue in
            if newValue {
                dismiss()
            }
        }
    }
}
