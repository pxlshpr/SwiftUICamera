import AVFoundation
import SwiftUI
import SwiftUISugar

extension CameraView {
    public class Coordinator: NSObject {
        var parent: CameraView
        var codeFound = false
        
        init(parent: CameraView) {
            self.parent = parent
        }
    }
}

