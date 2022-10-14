import AVKit

public extension CMSampleBuffer {
    
    var image: UIImage? {
        image()
    }
    
    func image(videoOrientation: AVCaptureVideoOrientation = .portrait) -> UIImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(self) else {
            return nil
        }
        
        let context = CIContext()
        var ciImage = CIImage(cvPixelBuffer: imageBuffer)
        
        let orientation: Int32
        switch videoOrientation {
        case .portrait:
            orientation = 6
        case .portraitUpsideDown:
            orientation = 8
        case .landscapeRight:
            orientation = 1
        case .landscapeLeft:
            orientation = 3
        @unknown default:
            orientation = 6
        }
        ciImage = ciImage.oriented(forExifOrientation: orientation)
        
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
}
