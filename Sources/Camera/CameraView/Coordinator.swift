import AVFoundation
import SwiftUI
import SwiftUISugar
import FoodLabelScanner

extension CameraView {
    public class Coordinator: NSObject {
        var parent: CameraView
        var codeFound = false
        
        var scanTask: Task<ScanResult, Error>? = nil

        init(parent: CameraView) {
            self.parent = parent
        }
    }
}

extension CameraView.Coordinator: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        Task {
            guard scanTask == nil else {
                return
            }
            
            self.scanTask = Task {
                let scanResult = try await FoodLabelLiveScanner(sampleBuffer: sampleBuffer).scan()
                return scanResult
            }
            
            let start = CFAbsoluteTimeGetCurrent()
            let scanResult = try await scanTask!.value
            let duration = (CFAbsoluteTimeGetCurrent()-start).rounded(toPlaces: 2)
            scanTask = nil
            
            print("🥂 Got result in \(duration)s")
            print(scanResult.summaryDescription(withEmojiPrefix: "🥂"))

            guard let shouldGetImageForScanResult = parent.shouldGetImageForScanResult,
                  shouldGetImageForScanResult(scanResult),
                  let imageForScanResult = parent.imageForScanResult
            else {
                return
            }
                    
            let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
            let cameraImage = CIImage(cvPixelBuffer: imageBuffer!)
            let image = UIImage(ciImage: cameraImage, scale: 1, orientation: .right)
            imageForScanResult(image, scanResult)
        }
    }
}
