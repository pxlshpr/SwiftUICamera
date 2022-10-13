import AVFoundation
import SwiftUI
import SwiftUISugar
import FoodLabelScanner

extension CameraView {
    public class CameraViewController: UIViewController {
        var captureSession: AVCaptureSession!
        var previewLayer: AVCaptureVideoPreviewLayer!
        
        var config: CameraConfiguration
        var delegate: Coordinator?
        
        var photoOutput = AVCapturePhotoOutput()
        var videoOutput = AVCaptureVideoDataOutput()
        
        init(config: CameraConfiguration, delegate: Coordinator? = nil) {
            self.config = config
            self.delegate = delegate
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }        
    }
}
