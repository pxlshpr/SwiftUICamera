import AVKit
import SwiftUI
import VisionSugar
import SwiftHaptics

public typealias RecognizedBarcodesHandler = ([RecognizedBarcode], UIImage) -> ()

public struct BarcodeScanner: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject var cameraViewModel: CameraViewModel
    @StateObject var viewModel: BarcodeScannerViewModel

    public init(showTorchButton: Bool = true, barcodesHandler: @escaping RecognizedBarcodesHandler) {
        let cameraViewModel = CameraViewModel(
            mode: .scan,
            showFlashButton: false,
            showTorchButton: showTorchButton,
            showPhotoPickerButton: false,
            showCapturedImagesCount: false
        )
        _cameraViewModel = StateObject(wrappedValue: cameraViewModel)
        let viewModel = BarcodeScannerViewModel(barcodesHandler: barcodesHandler)
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        BaseCamera(sampleBufferHandler: viewModel.processSampleBuffer)
            .environmentObject(cameraViewModel)
            .onChange(of: viewModel.shouldDismiss) { newShouldDismiss in
                if newShouldDismiss {
                    dismiss()
                }
            }
    }
}

class BarcodeScannerViewModel: ObservableObject {
    
    let barcodesHandler: RecognizedBarcodesHandler
    @Published var shouldDismiss = false
    @Published var didCallHandler = false

    init(barcodesHandler: @escaping RecognizedBarcodesHandler) {
        self.barcodesHandler = barcodesHandler
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
            
            guard let image = sampleBuffer.image else {
                //TODO: Throw error here instead
                fatalError("Couldn't get image")
            }

            await MainActor.run {
                Haptics.successFeedback()
                barcodesHandler(barcodes, image)
                shouldDismiss = true
            }
        }
    }
}

