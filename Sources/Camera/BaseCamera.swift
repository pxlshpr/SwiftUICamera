import SwiftUI
import AVKit
import SwiftHaptics

public struct BaseCamera: View {
    
    @EnvironmentObject var viewModel: ViewModel
    let codeTypes: [AVMetadataObject.ObjectType] = [.upce, .code39, .code39Mod43, .ean13, .ean8, .code93, .code128, .pdf417, .qr, .aztec]

    let isCodeScanner: Bool
    
    var didScanCode: ScannedCodeHandler?
    var didCaptureImage: CapturedImageHandler?
    
    let didReceiveCapturedImage = NotificationCenter.default.publisher(for: .didCaptureImage)
    let couldNotCaptureImage = NotificationCenter.default.publisher(for: .didNotCaptureImage)
    
    public init(didCaptureImage: CapturedImageHandler? = nil, didScanCode: ScannedCodeHandler? = nil) {
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
            if viewModel.showFlashButton {
                FlashOverlay()
                    .environmentObject(viewModel)
            }
            if viewModel.showTorchButton {
                TorchOverlay()
                    .environmentObject(viewModel)
            }
            if viewModel.showCapturedImagesCount {
                CapturedPhotosOverlay()
                    .environmentObject(viewModel)
            }
            if viewModel.showPhotoPickerButton {
                PhotoPickerOverlay()
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

import SwiftUI
import SwiftHaptics

struct CapturedPhotosOverlay: View {
    
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                button
                    .padding(.trailing)
            }
        }
    }
    
    @ViewBuilder
    var button: some View {
        if viewModel.capturedImageCount > 0 {
            Button {
                viewModel.tappedCapturedPhotos()
            } label: {
                Image(systemName: "\(viewModel.capturedImageCount).circle.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color.black, Color(.systemGroupedBackground))
                    .opacity(0.6)
                    .font(.system(size: 40))
                    .frame(width: 40, height: 40)
                    .padding(.vertical, 20)
                    .padding(.leading, 40)
                    .padding(.trailing, 9)
                    .background(Color.clear)
                    .contentShape(Rectangle())
            }
        }
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
