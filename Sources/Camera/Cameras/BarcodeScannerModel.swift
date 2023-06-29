import SwiftUI
import AVKit
import Observation

import SwiftHaptics

@Observable class BarcodeScannerModel {
    
    let barcodesHandler: RecognizedBarcodesHandler?
    let barcodesAndImageHandler: RecognizedBarcodesAndImageHandler?

    var shouldDismiss = false
    var didCallHandler = false

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

        Task { [weak sampleBuffer] in

            guard let sampleBuffer else { return }
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

