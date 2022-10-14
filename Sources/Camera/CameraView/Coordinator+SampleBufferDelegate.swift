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

extension CMSampleBuffer {
    /**
     Taken from [here](https://stackoverflow.com/a/40193359).
     
     It's also important to set the following when configuring the `AVCaptureVideoDataOutput` for the `AVCaptureSession` for this to work.
     ```
     videoOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as String) : NSNumber(value: kCVPixelFormatType_32BGRA as UInt32)]
     ```
     */
    var image: UIImage {
        /// Get a CMSampleBuffer's Core Video image buffer for the media data
        let  imageBuffer = CMSampleBufferGetImageBuffer(self)
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
