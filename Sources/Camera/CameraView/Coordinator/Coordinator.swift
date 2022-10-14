import AVFoundation
import SwiftUI
import SwiftUISugar
import FoodLabelScanner

extension CameraView {
    public class Coordinator: NSObject {
        var parent: CameraView
        var didScanCode = false
        
        init(parent: CameraView) {
            self.parent = parent
        }
    }
}
