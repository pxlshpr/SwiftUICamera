import AVFoundation
import SwiftUI

extension CameraView {
    public class Coordinator: NSObject {
        var parent: CameraView
        var didScanCode = false
        
        init(parent: CameraView) {
            self.parent = parent
        }
    }
}
