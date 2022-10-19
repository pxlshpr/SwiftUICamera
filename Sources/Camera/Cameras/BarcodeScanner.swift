import AVKit
import SwiftUI
import VisionSugar
import SwiftHaptics

public typealias RecognizedBarcodesHandler = ([RecognizedBarcode]) -> ()

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
        guard !didCallHandler else {
            print("🥸 didCallHandler so returning")
            return
        }

        print("🥸 didCallHandler == \(didCallHandler) so continuing")

        Task {
            /// Make sure we only do this once
            
            let barcodes = try await sampleBuffer.recognizedBarcodes()
            guard !barcodes.isEmpty else {
                return
            }
            
            await MainActor.run {
                
                guard !didCallHandler else {
                    print("🥸 didCallHandler so returning")
                    return
                }
                
                didCallHandler = true
                print("🥸 set didCallHandler to true")
                
                Haptics.successFeedback()
                barcodesHandler(barcodes)
                shouldDismiss = true
            }
        }
    }
}

