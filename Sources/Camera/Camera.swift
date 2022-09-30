import SwiftUI
import AVKit
import SwiftHaptics

public typealias ScanResultHandler = ((Result<String, Camera.ScanError>) -> Void)
public typealias CapturedImageHandler = ((UIImage) -> Void)

class ViewModel: ObservableObject {
    @Published var animateCameraViewShrinking = false
    @Published var makeCameraViewTranslucent = false
}

public struct Camera: View {
    let didCaptureImage: CapturedImageHandler?

    public init(didCaptureImage: CapturedImageHandler? = nil) {
        self.didCaptureImage = didCaptureImage
    }
    
    public var body: some View {
        BaseCamera(didCaptureImage: didCaptureImage, didScanCode: nil)
    }
}

public struct CodeScanner: View {
    let didScanCode: ScanResultHandler?

    public init(didScanCode: ScanResultHandler? = nil) {
        self.didScanCode = didScanCode
    }
    
    public var body: some View {
        BaseCamera(didCaptureImage: nil, didScanCode: didScanCode)
    }
}

public struct BaseCamera: View {
    
    let codeTypes: [AVMetadataObject.ObjectType] = [.upce, .code39, .code39Mod43, .ean13, .ean8, .code93, .code128, .pdf417, .qr, .aztec]

    let isCodeScanner: Bool
    
    var didScanCode: ScanResultHandler?
    var didCaptureImage: CapturedImageHandler?
    
    let didReceiveCapturedImage = NotificationCenter.default.publisher(for: .didCaptureImage)
    let couldNotCaptureImage = NotificationCenter.default.publisher(for: .didNotCaptureImage)
    
    @StateObject var viewModel = ViewModel()
    
    public init(didCaptureImage: CapturedImageHandler? = nil, didScanCode: ScanResultHandler? = nil) {
        self.didScanCode = didScanCode
        self.isCodeScanner = didScanCode != nil
        self.didCaptureImage = didCaptureImage
    }
    
    public var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
            cameraView
                .edgesIgnoringSafeArea(.all)
            if isCodeScanner {
                ScanOverlay()
            } else {
                CaptureOverlay()
                    .environmentObject(viewModel)
            }
        }
        .onReceive(didReceiveCapturedImage, perform: didReceiveCapturedImage)
        .onReceive(couldNotCaptureImage, perform: couldNotCaptureImage)
    }
    
    var cameraView: some View {
        CameraView(
            codeTypes: codeTypes,
            simulatedData: "Simulated\nDATA",
            completion: didScanCode
        )
        .scaleEffect(viewModel.animateCameraViewShrinking ? 0.01 : 1, anchor: .bottomTrailing)
        .padding(.bottom, viewModel.animateCameraViewShrinking ? 15 : 0)
        .padding(.trailing, viewModel.animateCameraViewShrinking ? 15 : 0)
        .opacity(viewModel.makeCameraViewTranslucent ? 0 : 1)
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
