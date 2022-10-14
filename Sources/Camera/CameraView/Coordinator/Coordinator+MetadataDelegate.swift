import AVFoundation
import SwiftUI
import SwiftUISugar
import SwiftHaptics

extension CameraView.Coordinator: AVCaptureMetadataOutputObjectsDelegate {
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection)
    {
        guard let metadataObject = metadataObjects.first,
              let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
              let stringValue = readableObject.stringValue,
              !didScanCode
        else {
            return
        }
        
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        Haptics.successFeedback()
        parent.codeHandler?(.success(stringValue))
        
        // make sure we only trigger scans once per use
        didScanCode = true
    }
    
    func didFail(reason: Camera.ScanError) {
        parent.codeHandler?(.failure(reason))
    }
}
