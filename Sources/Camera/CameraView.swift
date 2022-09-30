import AVFoundation
import SwiftUI
import SwiftUISugar

public extension Camera {
    enum ScanError: Error {
        case badInput, badOutput
    }
}

public struct CameraView: UIViewControllerRepresentable {
    
    public class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var parent: CameraView
        var codeFound = false
        
        init(parent: CameraView) {
            self.parent = parent
        }
        
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
    
#if targetEnvironment(simulator)
    public class ScannerViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
        var delegate: ScannerCoordinator?
        override public func loadView() {
            view = UIView()
            view.isUserInteractionEnabled = true
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.numberOfLines = 0
            
            label.text = "You're running in the simulator, which means the camera isn't available. Tap anywhere to send back some simulated data."
            label.textAlignment = .center
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle("Or tap here to select a custom image", for: .normal)
            button.setTitleColor(UIColor.systemBlue, for: .normal)
            button.setTitleColor(UIColor.gray, for: .highlighted)
            button.addTarget(self, action: #selector(self.openGallery), for: .touchUpInside)
            
            let stackView = UIStackView()
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .vertical
            stackView.spacing = 50
            stackView.addArrangedSubview(label)
            stackView.addArrangedSubview(button)
            
            view.addSubview(stackView)
            
            NSLayoutConstraint.activate([
                button.heightAnchor.constraint(equalToConstant: 50),
                stackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
                stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
        }
        
        override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            guard let simulatedData = delegate?.parent.simulatedData else {
                print("Simulated Data Not Provided!")
                return
            }
            
            delegate?.found(code: simulatedData)
        }
        
    }
#else
    public class ScannerViewController: UIViewController {
        var captureSession: AVCaptureSession!
        var previewLayer: AVCaptureVideoPreviewLayer!
        var delegate: Coordinator?
        
        override public func viewDidLoad() {
            super.viewDidLoad()
            
            
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(updateOrientation),
                                                   name: Notification.Name("UIDeviceOrientationDidChangeNotification"),
                                                   object: nil)
            
            view.backgroundColor = UIColor.black
            captureSession = AVCaptureSession()
            
            guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
            let videoInput: AVCaptureDeviceInput
            
            do {
                videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
                // Get an instance of the AVCaptureDeviceInput class using the previous device object.
                //        let input = try AVCaptureDeviceInput(device: captureDevice)
                
                // Set the input device on the capture session.
                captureSession.addInput(videoInput)
                
                // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
                let captureMetadataOutput = AVCaptureMetadataOutput()
                captureSession.addOutput(captureMetadataOutput)
                
                // Set delegate and use the default dispatch queue to execute the call back
                captureMetadataOutput.setMetadataObjectsDelegate(delegate, queue: DispatchQueue.main)
                captureMetadataOutput.metadataObjectTypes = delegate?.parent.codeTypes
                //            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
                
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
    
    public let codeTypes: [AVMetadataObject.ObjectType]
    public var simulatedData = ""
    public var completion: ((Result<String, Camera.ScanError>) -> Void)? = nil
    
    public init(codeTypes: [AVMetadataObject.ObjectType], simulatedData: String = "", completion: ((Result<String, Camera.ScanError>) -> Void)? = nil) {
        self.codeTypes = codeTypes
        self.simulatedData = simulatedData
        self.completion = completion
    }
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    public func makeUIViewController(context: Context) -> ScannerViewController {
        let viewController = ScannerViewController()
        viewController.delegate = context.coordinator
        return viewController
    }
    
    public func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {
        
    }
}
