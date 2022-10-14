import AVFoundation
import SwiftUI
import SwiftUISugar
import FoodLabelScanner

extension CameraView {
    public class Coordinator: NSObject {
        var parent: CameraView
        var codeFound = false
        
        var scanTasks: [Task<ScanResult, Error>] = []
        var lastScanTime: CFAbsoluteTime = CFAbsoluteTimeGetCurrent()
        
        init(parent: CameraView) {
            self.parent = parent
        }
    }
}

extension CameraView.Coordinator: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        Task {
            let timeElapsed = CFAbsoluteTimeGetCurrent() - lastScanTime
            guard timeElapsed > 0.5, scanTasks.count < 3 else { return }
            
            lastScanTime = CFAbsoluteTimeGetCurrent()
//            guard scanTask == nil else { return }
            let scanTask = Task {
                let scanResult = try await FoodLabelLiveScanner(sampleBuffer: sampleBuffer).scan()
                return scanResult
            }
            scanTasks.append(scanTask)
            
            var start = CFAbsoluteTimeGetCurrent()
            let scanResult = try await scanTask.value
            scanTasks.removeAll(where: { $0 == scanTask })
            
            let duration = (CFAbsoluteTimeGetCurrent()-start).rounded(toPlaces: 2)
            
            print("🥂 Got result in \(duration)s")
//            print(scanResult.summaryDescription(withEmojiPrefix: "🥂"))
            
            start = CFAbsoluteTimeGetCurrent()
            
//            guard let shouldGetImageForScanResult = parent.shouldGetImageForScanResult,
//                  shouldGetImageForScanResult(scanResult),
//                  let imageForScanResult = parent.imageForScanResult
//            else {
//                return
//            }
//
            let image = imageFromSampleBuffer(sampleBuffer: sampleBuffer)
            print("🥂 Got image in \(duration)s")
            parent.imageForScanResult?(image, scanResult)
            //            if let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: nil) {
            //                let image = UIImage(data: imageData)
            //            }
            //
            //            let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
            //            let cameraImage = CIImage(cvPixelBuffer: imageBuffer!)
            //            let image = UIImage(ciImage: cameraImage, scale: 1, orientation: .right)
            //            imageForScanResult(image, scanResult)
        }
    }
    
    public func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        print("🥶 dropped frames")
    }
    
    func imageFromSampleBuffer(sampleBuffer : CMSampleBuffer) -> UIImage {
        /// Get a CMSampleBuffer's Core Video image buffer for the media data
        let  imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        /// Lock the base address of the pixel buffer
        CVPixelBufferLockBaseAddress(imageBuffer!, CVPixelBufferLockFlags.readOnly)
        
        
        /// Get the number of bytes per row for the pixel buffer
        let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer!)
        
        /// Get the number of bytes per row for the pixel buffer
        let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer!)
        /// Get the pixel buffer width and height
        let width = CVPixelBufferGetWidth(imageBuffer!)
        let height = CVPixelBufferGetHeight(imageBuffer!)
        
        /// Create a device-dependent RGB color space
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        /// Create a bitmap graphics context with the sample buffer data
        var bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Little.rawValue
        bitmapInfo |= CGImageAlphaInfo.premultipliedFirst.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
        //let bitmapInfo: UInt32 = CGBitmapInfo.alphaInfoMask.rawValue
        let context = CGContext.init(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
        /// Create a Quartz image from the pixel data in the bitmap graphics context
        let quartzImage = context?.makeImage()
        /// Unlock the pixel buffer
        CVPixelBufferUnlockBaseAddress(imageBuffer!, CVPixelBufferLockFlags.readOnly)
        
        /// Create an image object from the Quartz image
        let image = UIImage.init(cgImage: quartzImage!, scale: 1, orientation: .right)
        
        
        return (image);
    }
}

