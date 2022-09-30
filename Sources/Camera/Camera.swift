import SwiftUI
import AVKit
import SwiftHaptics

public struct Camera: View {
    
    let codeTypes: [AVMetadataObject.ObjectType] = [.upce, .code39, .code39Mod43, .ean13, .ean8, .code93, .code128, .pdf417, .qr, .aztec]

    let isCodeScanner: Bool
    
    var didScanCode: ((Result<String, Camera.ScanError>) -> Void)?
    public init(didScanCode: ((Result<String, Camera.ScanError>) -> Void)? = nil) {
        self.didScanCode = didScanCode
        self.isCodeScanner = didScanCode != nil
    }
    
    public var body: some View {
        ZStack {
            scannerCameraView
                .edgesIgnoringSafeArea(.all)
            if isCodeScanner {
                ScanOverlay()
            }
        }
    }
    
    var scannerCameraView: some View {
        CameraView(
            codeTypes: codeTypes,
            simulatedData: "Simulated\nDATA",
            completion: didScanCode
        )
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
