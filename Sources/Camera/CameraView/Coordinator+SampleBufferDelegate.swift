import AVFoundation
import FoodLabelScanner
import SwiftUI

extension CameraView.Coordinator: AVCaptureVideoDataOutputSampleBufferDelegate {
        
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        parent.sampleBufferHandler?(sampleBuffer)
        
//        Task {
//            let timeElapsed = CFAbsoluteTimeGetCurrent() - lastScanTime
//            guard timeElapsed > 0.5, scanTasks.count < 3 else { return }
//
//            lastScanTime = CFAbsoluteTimeGetCurrent()
////            guard scanTask == nil else { return }
//            let scanTask = Task {
//                let scanResult = try await FoodLabelLiveScanner(sampleBuffer: sampleBuffer).scan()
//                return scanResult
//            }
//            scanTasks.append(scanTask)
//
//            var start = CFAbsoluteTimeGetCurrent()
//            let scanResult = try await scanTask.value
//            scanTasks.removeAll(where: { $0 == scanTask })
//
//            let duration = (CFAbsoluteTimeGetCurrent()-start).rounded(toPlaces: 2)
//
//            start = CFAbsoluteTimeGetCurrent()
//
//            let image = sampleBuffer.image
//            print("🥂 Got image in \(duration)s")
//            parent.imageForScanResult?(image, scanResult)
//        }
    }
    
    public func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        print("🥶 dropped frames")
    }
}
