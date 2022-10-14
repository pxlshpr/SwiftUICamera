import AVFoundation
import SwiftUI
import SwiftUISugar
import FoodLabelScanner

#if !targetEnvironment(simulator)
extension CameraView {
    public class CameraViewController: UIViewController {
        var captureSession: AVCaptureSession!
        var previewLayer: AVCaptureVideoPreviewLayer!
        
        var config: CameraConfiguration
        var delegate: Coordinator?
        
        var photoOutput = AVCapturePhotoOutput()
        var videoOutput = AVCaptureVideoDataOutput()
        var metadataOutput = AVCaptureMetadataOutput()
        
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
    func setupCaptureSession(for config: CameraConfiguration) throws {
        guard let delegate else { return }
        captureSession = AVCaptureSession()
        
        let input = try input(for: config)
        captureSession.addInput(input)
        
        if isSampling {
            videoOutput = AVCaptureVideoDataOutput()
            videoOutput.setSampleBufferDelegate(delegate, queue: .main)
            videoOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as String) : NSNumber(value: kCVPixelFormatType_32BGRA as UInt32)]
            captureSession.addOutput(videoOutput)
        } else if isCodeScanning {
            metadataOutput.setMetadataObjectsDelegate(delegate, queue: .main)
            metadataOutput.metadataObjectTypes = delegate.parent.codeTypes
            captureSession.addOutput(metadataOutput)
        } else {
            photoOutput = AVCapturePhotoOutput()
            captureSession.addOutput(photoOutput)
        }
    }
    
    var isCodeScanning: Bool {
        delegate?.parent.codeHandler != nil
    }
    
    var isSampling: Bool {
        delegate?.parent.sampleBufferHandler != nil
    }

    func device(for config: CameraConfiguration) -> AVCaptureDevice? {
//        AVCaptureDevice.default(for: .video)
        AVCaptureDevice.default(config.deviceType, for: .video, position: config.position) ?? .defaultCamera
    }
    
    func input(for config: CameraConfiguration) throws -> AVCaptureDeviceInput {
        guard let device = device(for: config) else {
//        guard let device = AVCaptureDevice.default(for: .video) else {
            throw CameraError.couldNotCreateDevice
        }
        
        if device.isFocusModeSupported(.autoFocus) {
            try! device.lockForConfiguration()
            device.focusMode = .autoFocus
            
            device.isSubjectAreaChangeMonitoringEnabled = true
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(subjectAreaDidChange),
                                                   name: NSNotification.Name.AVCaptureDeviceSubjectAreaDidChange,
                                                   object: nil)

            device.unlockForConfiguration()
        }
                
        let input: AVCaptureDeviceInput
        input = try AVCaptureDeviceInput(device: device)
        return input
    }
    
    /**
     We're doing what was [described here](https://stackoverflow.com/a/41548328).
     Initially setting to `autoFocus`.
     Then observing for the `AVCaptureDeviceSubjectAreaDidChange` notification, and setting the focus to `continuousAutoFocus` once that happens.
     Additionally, recognizing taps and switching back to `autoFocus` when that is triggered.
     */
    @objc func subjectAreaDidChange(notification: Notification) {
//        print("🤳 subjectAreaDidChange: changing to continuous autofocus")
        changeFocusMode(to: .continuousAutoFocus)
    }
    
    func changeFocusMode(to focusMode: AVCaptureDevice.FocusMode) {
        guard let device = device(for: config), device.isFocusModeSupported(focusMode) else {
            return
        }
        
        try! device.lockForConfiguration()
        device.focusMode = focusMode
        device.unlockForConfiguration()
    }
    
    var metadataOutput_legacy: AVCaptureMetadataOutput {
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
        //TODO: Is this needed?
//        updateOrientation()

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapPreview))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func didTapPreview(gesture: UITapGestureRecognizer) {
        changeFocusMode(to: .autoFocus)
    }
    
    func setDeviceTorchMode(to torchMode: AVCaptureDevice.TorchMode) {
        guard let device = device(for: config), device.hasTorch else {
            return
        }
        do {
            try device.lockForConfiguration()
            device.torchMode = torchMode
            device.unlockForConfiguration()
        } catch {
            print(error)
        }
    }

    //MARK: - Actions
    func configUpdated(with newConfig: CameraConfiguration) {
        if newConfig.deviceType != config.deviceType
            || newConfig.position != config.position
        {
            stopCaptureSession()
            setupCamera(for: newConfig)
        }
        
        if newConfig.torchMode != config.torchMode {
            setDeviceTorchMode(to: newConfig.torchMode)
        }
        self.config = newConfig
    }
    
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
