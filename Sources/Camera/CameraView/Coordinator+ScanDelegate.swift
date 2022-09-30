import AVFoundation
import SwiftUI
import SwiftUISugar

extension CameraView.Coordinator: AVCaptureMetadataOutputObjectsDelegate {
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            guard codeFound == false else { return }
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
            
            // make sure we only trigger scans once per use
            codeFound = true
        }
    }
    
    func found(code: String) {
        parent.completion?(.success(code))
    }
    
    func didFail(reason: Camera.ScanError) {
        parent.completion?(.failure(reason))
    }
}
