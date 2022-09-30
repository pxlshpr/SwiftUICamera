import SwiftUI
import AVKit
import SwiftHaptics

public typealias ScanResultHandler = ((Result<String, Camera.ScanError>) -> Void)
public typealias ImageHandler = ((UIImage) -> Void)

public struct Camera: View {
    
    let codeTypes: [AVMetadataObject.ObjectType] = [.upce, .code39, .code39Mod43, .ean13, .ean8, .code93, .code128, .pdf417, .qr, .aztec]

    let isCodeScanner: Bool
    
    var didScanCode: ScanResultHandler?
    var didCaptureImage: ImageHandler?
    
    let didReceiveCapturedImage = NotificationCenter.default.publisher(for: .didCaptureImage)
    let couldNotCaptureImage = NotificationCenter.default.publisher(for: .didNotCaptureImage)
    
    public init(didCaptureImage: ImageHandler? = nil, didScanCode: ScanResultHandler? = nil) {
        self.didScanCode = didScanCode
        self.isCodeScanner = didScanCode != nil
        self.didCaptureImage = didCaptureImage
    }
    
    public var body: some View {
        ZStack {
            scannerCameraView
                .edgesIgnoringSafeArea(.all)
            if isCodeScanner {
                ScanOverlay()
            } else {
                CaptureOverlay()
            }
        }
        .onReceive(didReceiveCapturedImage, perform: didReceiveCapturedImage)
        .onReceive(couldNotCaptureImage, perform: couldNotCaptureImage)
    }
    
    var scannerCameraView: some View {
        CameraView(
            codeTypes: codeTypes,
            simulatedData: "Simulated\nDATA",
            completion: didScanCode
        )
    }
    
    func didReceiveCapturedImage(notification: Notification) {
        guard let image = notification.userInfo?[Notification.CameraImagePickerKeys.image] as? UIImage else {
            return
        }
        
        didCaptureImage?(image)
//        DispatchQueue.main.async {
//            delegate.didCapture(image)
//            numberOfCapturedImages += 1
//            if numberOfCapturedImages == maxSelectionCount {
//                dismiss()
//            }
//        }
    }
    
    func couldNotCaptureImage(notification: Notification) {
        //TODO: Handle errors properly
        guard let error = notification.userInfo?[Notification.CameraImagePickerKeys.error] as? Error else {
            return
        }
        print(error.localizedDescription)
    }
}


struct CameraPreview: View {
    
    var body: some View {
        Camera()
    }
    
    func didScanCode(result: Result<String, Camera.ScanError>) {
    }
}

struct Camera_Previews: PreviewProvider {
    static var previews: some View {
        CameraPreview()
    }
}
