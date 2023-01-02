import SwiftUI
import AVKit
import SwiftHaptics

public struct BaseCamera: View {

    let didReceiveCapturedImage = NotificationCenter.default.publisher(for: .didCaptureImage)
    let couldNotCaptureImage = NotificationCenter.default.publisher(for: .didNotCaptureImage)

    @EnvironmentObject var cameraViewModel: CameraViewModel
    var imageHandler: ImageHandler?
    let codeHandler: CodeHandler?
    let sampleBufferHandler: SampleBufferHandler?

    public init(
        imageHandler: ImageHandler? = nil,
        codeHandler: CodeHandler? = nil,
        sampleBufferHandler: SampleBufferHandler? = nil
    ) {
        self.imageHandler = imageHandler
        self.codeHandler = codeHandler
        self.sampleBufferHandler = sampleBufferHandler
    }
    
    public var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
            cameraView
                .edgesIgnoringSafeArea(.all)
            if cameraViewModel.mode == .scan {
                if cameraViewModel.shouldShowScanOverlay {
                    ScanOverlay()
                }
            } else {
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
            if cameraViewModel.showDismissButton {
                DismissButtonOverlay()
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
            codeHandler: codeHandler,
            sampleBufferHandler: sampleBufferHandler
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
        
        imageHandler?(image)
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
