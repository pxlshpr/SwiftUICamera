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

            guard let image = UIImage(data: data) else {
                return
            }
            let userInfo = [
                Notification.CameraImagePickerKeys.image: image,
            ]
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
