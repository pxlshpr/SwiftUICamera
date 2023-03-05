import AVKit
import SwiftUI
import VisionSugar
import SwiftHaptics

public typealias RecognizedBarcodesHandler = ([RecognizedBarcode]) -> ()
public typealias RecognizedBarcodesAndImageHandler = ([RecognizedBarcode], UIImage) -> ()

public struct BarcodeScanner: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject var cameraModel: CameraModel
    @StateObject var model: BarcodeScannerModel

    public init(
        showDismissButton: Bool = true,
        showTorchButton: Bool = true,
        barcodesAndImageHandler: @escaping RecognizedBarcodesAndImageHandler
    ) {
        let cameraModel = CameraModel(
            mode: .scan,
            showDismissButton: showDismissButton,
            showFlashButton: false,
            showTorchButton: showTorchButton,
            showPhotoPickerButton: false,
            showCapturedImagesCount: false
        )
        _cameraModel = StateObject(wrappedValue: cameraModel)
        let model = BarcodeScannerModel(barcodesAndImageHandler: barcodesAndImageHandler)
        _model = StateObject(wrappedValue: model)
    }

    public init(
        showDismissButton: Bool = true,
        showTorchButton: Bool = true,
        barcodesHandler: @escaping RecognizedBarcodesHandler
    ) {
        let cameraModel = CameraModel(
            mode: .scan,
            showDismissButton: showDismissButton,
            showFlashButton: false,
            showTorchButton: showTorchButton,
            showPhotoPickerButton: false,
            showCapturedImagesCount: false
        )
        _cameraModel = StateObject(wrappedValue: cameraModel)
        let model = BarcodeScannerModel(barcodesHandler: barcodesHandler)
        _model = StateObject(wrappedValue: model)
    }

    public var body: some View {
        BaseCamera(sampleBufferHandler: model.processSampleBuffer)
            .environmentObject(cameraModel)
            .onChange(of: model.shouldDismiss) { newShouldDismiss in
                if newShouldDismiss {
                    dismiss()
                }
            }
            .onChange(of: cameraModel.shouldDismiss) { newShouldDismiss in
                if newShouldDismiss {
                    dismiss()
                }
            }
    }
}

class BarcodeScannerModel: ObservableObject {
    
    let barcodesHandler: RecognizedBarcodesHandler?
    let barcodesAndImageHandler: RecognizedBarcodesAndImageHandler?

    @Published var shouldDismiss = false
    @Published var didCallHandler = false

    init(barcodesHandler: @escaping RecognizedBarcodesHandler) {
        self.barcodesHandler = barcodesHandler
        self.barcodesAndImageHandler = nil
    }

    init(barcodesAndImageHandler: @escaping RecognizedBarcodesAndImageHandler) {
        self.barcodesAndImageHandler = barcodesAndImageHandler
        self.barcodesHandler = nil
    }

    func processSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        /// Check this flag before processing the sample buffer
        guard !didCallHandler else { return }

        Task {

            let barcodes = try await sampleBuffer.recognizedBarcodes()
            guard !barcodes.isEmpty else { return }

            /// Check it again within the task in case we had multiple queued up before setting it to `true`
            guard !didCallHandler else { return }

            await MainActor.run {
                didCallHandler = true
            }
            
            if let barcodesAndImageHandler {
                guard let image = sampleBuffer.image else {
                    //TODO: Throw error here instead
                    fatalError("Couldn't get image")
                }

                await MainActor.run {
                    Haptics.successFeedback()
                    barcodesAndImageHandler(barcodes, image)
                    shouldDismiss = true
                }
            } else if let barcodesHandler {
                await MainActor.run {
                    Haptics.successFeedback()
                    barcodesHandler(barcodes)
                    shouldDismiss = true
                }
            }

        }
    }
}

