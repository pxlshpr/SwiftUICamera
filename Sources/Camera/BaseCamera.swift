import SwiftUI
import AVKit
import SwiftHaptics
import FoodLabelScanner

public struct BaseCamera: View {
    
    @EnvironmentObject var cameraViewModel: CameraViewModel
    let codeTypes: [AVMetadataObject.ObjectType] = [.upce, .code39, .code39Mod43, .ean13, .ean8, .code93, .code128, .pdf417, .qr, .aztec]

    let isCodeScanner: Bool
    
    var shouldGetImageForScanResult: ((ScanResult) -> (Bool))?
    var imageForScanResult: ((UIImage, ScanResult) -> ())?
    var didScanCode: ScannedCodeHandler?
    var didCaptureImage: CapturedImageHandler?
    
    let sampleBufferHandler: SampleBufferHandler?
    
    let didReceiveCapturedImage = NotificationCenter.default.publisher(for: .didCaptureImage)
    let couldNotCaptureImage = NotificationCenter.default.publisher(for: .didNotCaptureImage)
    
    public init(
        shouldGetImageForScanResult: ((ScanResult) -> (Bool))? = nil,
        imageForScanResult: ((UIImage, ScanResult) -> ())? = nil,
        didCaptureImage: CapturedImageHandler? = nil,
        didScanCode: ScannedCodeHandler? = nil,
        sampleBufferHandler: SampleBufferHandler? = nil
    ) {
        self.shouldGetImageForScanResult = shouldGetImageForScanResult
        self.imageForScanResult = imageForScanResult
        self.didScanCode = didScanCode
        self.isCodeScanner = didScanCode != nil
        self.didCaptureImage = didCaptureImage
        self.sampleBufferHandler = sampleBufferHandler
    }
    
    public var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
            cameraView
                .edgesIgnoringSafeArea(.all)
            if isCodeScanner {
                ScanOverlay()
            }
            else {
                CaptureOverlay()
                    .environmentObject(cameraViewModel)
            }
            if cameraViewModel.showFlashButton {
                FlashOverlay()
                    .environmentObject(cameraViewModel)
            }
            if cameraViewModel.showTorchButton {
                TorchOverlay()
                    .environmentObject(cameraViewModel)
            }
            if cameraViewModel.showCapturedImagesCount {
                CapturedPhotosOverlay()
                    .environmentObject(cameraViewModel)
            }
            if cameraViewModel.showPhotoPickerButton {
                PhotoPickerOverlay()
                    .environmentObject(cameraViewModel)
            }
        }
        .onReceive(didReceiveCapturedImage, perform: didReceiveCapturedImage)
        .onReceive(couldNotCaptureImage, perform: couldNotCaptureImage)
    }
    
    var cameraView: some View {
        CameraView(
            config: $cameraViewModel.config,
            codeTypes: codeTypes,
            simulatedData: "Simulated\nDATA",
            sampleBufferHandler: sampleBufferHandler,
            shouldGetImageForScanResult: shouldGetImageForScanResult,
            imageForScanResult: imageForScanResult,
            completion: didScanCode
        )
        .scaleEffect(cameraViewModel.animateCameraViewShrinking ? 0.01 : 1, anchor: .bottomTrailing)
        .padding(.bottom, cameraViewModel.animateCameraViewShrinking ? 15 : 0)
        .padding(.trailing, cameraViewModel.animateCameraViewShrinking ? 15 : 0)
        .opacity(cameraViewModel.makeCameraViewTranslucent ? 0 : 1)
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
        Camera(showFlashButton: true, showTorchButton: true) { image in
            
        }
    }
}

struct Camera_Previews: PreviewProvider {
    static var previews: some View {
        CameraPreview()
    }
}
