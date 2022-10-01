import AVFoundation
import SwiftUI
import SwiftUISugar

#if !targetEnvironment(simulator)
extension CameraView {
    public class Controller: UIViewController {
        var captureSession: AVCaptureSession!
        var previewLayer: AVCaptureVideoPreviewLayer!
        var delegate: Coordinator?
        
        let photoOutput = AVCapturePhotoOutput()
        let metadataOutput = AVCaptureMetadataOutput()
    }
}

struct CameraType {
    
}
struct CameraParameters {
    let deviceType: AVCaptureDevice.DeviceType
}

extension CameraView.Controller {
    override public func viewDidLoad() {
        super.viewDidLoad()
        

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didTapCaptureButton),
                                               name: Notification.Name("didTapCaptureButton"),
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateOrientation),
                                               name: Notification.Name("UIDeviceOrientationDidChangeNotification"),
                                               object: nil)
        
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            //        let input = try AVCaptureDeviceInput(device: captureDevice)

//            if videoCaptureDevice.is {
//                
//            }

            // Set the input device on the capture session.
            captureSession.addInput(videoInput)
            
            
            if false {
                // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
                captureSession.addOutput(metadataOutput)
                
                // Set delegate and use the default dispatch queue to execute the call back
                metadataOutput.setMetadataObjectsDelegate(delegate, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = delegate?.parent.codeTypes
                //            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            } else {
                captureSession.addOutput(photoOutput)
            }
            
        } catch {
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(previewLayer!)
        
        // Start video capture.
//            captureSession.startRunning()
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }

        //      if (captureSession.canAddInput(videoInput)) {
        //        captureSession.addInput(videoInput)
        //      } else {
        //        delegate?.didFail(reason: .badInput)
        //        return
        //      }
        //
        //      let metadataOutput = AVCaptureMetadataOutput()
        //
        //      if (captureSession.canAddOutput(metadataOutput)) {
        //        captureSession.addOutput(metadataOutput)
        //
        //        metadataOutput.setMetadataObjectsDelegate(delegate, queue: DispatchQueue.main)
        //        metadataOutput.metadataObjectTypes = delegate?.parent.codeTypes
        //      } else {
        //        delegate?.didFail(reason: .badOutput)
        //        return
        //      }
    }
    
    override public func viewWillLayoutSubviews() {
        previewLayer?.frame = view.layer.bounds
    }

    @objc func didTapCaptureButton() {
        guard let delegate else {
            fatalError("No delegate")
        }
        photoOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: delegate)
    }

    @objc func updateOrientation() {
        guard let orientation =
                keyWindow?.windowScene?.interfaceOrientation else {
            return
        }
        let previewConnection = captureSession.connections[1]
        previewConnection.videoOrientation = AVCaptureVideoOrientation(rawValue: orientation.rawValue) ?? .portrait
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //      previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        //      previewLayer.frame = view.layer.bounds
        //      previewLayer.videoGravity = .resizeAspectFill
        //      view.layer.addSublayer(previewLayer)
        //      updateOrientation()
        
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession?.isRunning == false) {
            DispatchQueue.global(qos: .background).async {
                self.captureSession.startRunning()
            }
        }
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            DispatchQueue.global(qos: .background).async {
                self.captureSession.stopRunning()
            }
        }
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override public var prefersStatusBarHidden: Bool {
        return true
    }
    
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
}

#endif
