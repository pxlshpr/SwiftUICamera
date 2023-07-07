import AVFoundation
import SwiftUI

extension CameraView.Coordinator: AVCapturePhotoCaptureDelegate {
    
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        let result: Result<AVCapturePhoto, Error>
        if let error {
            result = .failure(error)
        } else {
            result = .success(photo)
        }

        switch result {
        case .success(let photo):
            guard let data = photo.fileDataRepresentation() else {
                cameraViewLogger.error("Error: no image data found")
                return
            }

            guard let rawImage = UIImage(data: data) else { return }
            let image: UIImage?
            switch UIDevice.current.orientation {
            case .portraitUpsideDown:
                image = rawImage.rotate(radians: .pi) /// 180 degrees

            case .landscapeLeft:
                image = rawImage.rotate(radians: -.pi/2) /// -90 degrees

            case .landscapeRight:
                image = rawImage.rotate(radians: .pi/2) /// 90 degrees

            default:
                image = rawImage
            }
            
            guard let image else { return }
            let userInfo = [Notification.CameraImagePickerKeys.image: image]
            NotificationCenter.default.post(name: .didCaptureImage, object: nil, userInfo: userInfo)
//                delegate.didCapture(image)
//                numberOfCapturedImages += 1
//                if numberOfCapturedImages == maxSelectionCount {
//                    dismiss()
//                }
        case .failure(let error):
            cameraViewLogger.error("Error: \(error.localizedDescription, privacy: .public)")
            let userInfo = [
                Notification.CameraImagePickerKeys.error: error,
            ]
            NotificationCenter.default.post(name: .didNotCaptureImage, object: nil, userInfo: userInfo)
        }
    }
}

extension UIImage {
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!

        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}
