import AVFoundation
import SwiftUI
import SwiftUISugar

#if !targetEnvironment(simulator)
extension CameraView {
    public class CameraViewController: UIViewController {
        var captureSession: AVCaptureSession!
        var previewLayer: AVCaptureVideoPreviewLayer!
        
        var config: CameraConfiguration
        var delegate: Coordinator?
        
        var photoOutput = AVCapturePhotoOutput()
        
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

extension CameraView.CameraViewController {
    override public func viewDidLoad() {
        super.viewDidLoad()

        addNotifications()
        
        setupCamera(for: config)
    }
    
    override public func viewWillLayoutSubviews() {
        previewLayer?.frame = view.layer.bounds
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
    
    func setupCamera(for config: CameraConfiguration) {
        do {
            try setupCaptureSession(for: config)
        } catch {
            print(error)
        }
        setupView()
        startCaptureSession()
    }
    
    //MARK: - Session
    func configUpdated(with config: CameraConfiguration) {
        self.config = config
        
        if config.deviceType != config.deviceType
            || config.position != config.position
        {
            stopCaptureSession()
            setupCamera(for: config)
        }
    }

    func setupCaptureSession(for config: CameraConfiguration) throws {
        captureSession = AVCaptureSession()
        
        let input = try input(for: config)
        captureSession.addInput(input)
        
        if false {
            captureSession.addOutput(metadataOutput)
        } else {
            photoOutput = AVCapturePhotoOutput()
            captureSession.addOutput(photoOutput)
        }
    }

    func device(for config: CameraConfiguration) -> AVCaptureDevice? {
        AVCaptureDevice.default(config.deviceType, for: .video, position: config.position) ?? .defaultCamera
    }
    
    func input(for config: CameraConfiguration) throws -> AVCaptureDeviceInput {
        guard let device = device(for: config) else {
            throw CameraError.couldNotCreateDevice
        }
        
        if device.isFocusModeSupported(.continuousAutoFocus) {
            try! device.lockForConfiguration()
            device.focusMode = .continuousAutoFocus
            device.unlockForConfiguration()
        }
        
        let input: AVCaptureDeviceInput
        input = try AVCaptureDeviceInput(device: device)
        return input
    }
    
    var metadataOutput: AVCaptureMetadataOutput {
        let output = AVCaptureMetadataOutput()

        // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
//        captureSession.addOutput(metadataOutput)
        
        // Set delegate and use the default dispatch queue to execute the call back
        output.setMetadataObjectsDelegate(delegate, queue: DispatchQueue.main)
        output.metadataObjectTypes = delegate?.parent.codeTypes
        //            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
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
        return output
    }
    
    
    func startCaptureSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }
    func stopCaptureSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.stopRunning()
        }
    }
    
    
    //MARK: - Helpers
    func addNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didTapCaptureButton),
                                               name: Notification.Name("didTapCaptureButton"),
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateOrientation),
                                               name: Notification.Name("UIDeviceOrientationDidChangeNotification"),
                                               object: nil)
    }
    
    func setupView() {
        view.backgroundColor = UIColor.black
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(previewLayer!)
    }
    
    //MARK: - Actions
    
    @objc func didTapCaptureButton() {
        guard let delegate else {
            fatalError("No delegate")
        }
        let settings = AVCapturePhotoSettings()
        settings.flashMode = config.flashMode
        photoOutput.capturePhoto(with: settings, delegate: delegate)
    }

    @objc func updateOrientation() {
        guard let orientation =
                keyWindow?.windowScene?.interfaceOrientation else {
            return
        }
        let previewConnection = captureSession.connections[1]
        previewConnection.videoOrientation = AVCaptureVideoOrientation(rawValue: orientation.rawValue) ?? .portrait
    }
    
    override public var prefersStatusBarHidden: Bool {
        return true
    }
    
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
}

#endif

extension AVCaptureDevice {
    static var defaultCamera: AVCaptureDevice? {
        // Find the built-in Dual Camera, if it exists.
        if let device = Self.default(.builtInDualCamera, for: .video, position: .back) {
            return device
        }
        
        // Find the built-in Wide-Angle Camera, if it exists.
        if let device = Self.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return device
        }
        
        return nil
    }
}
