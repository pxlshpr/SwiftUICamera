import AVKit
import SwiftUI

extension AVCaptureDevice.TorchMode {
    var systemImage: String {
        get {
            switch self {
            case .off:
                return "flashlight.off.fill"
            case .on, .auto:
                return "flashlight.on.fill"
            @unknown default:
                return "flashlight.off.fill"
            }
        }
        /// Shouldn't be called. We're only use this to pass this as a read-only binding
        set {
            switch self {
            case .off:
                self = .off
            case .on:
                self = .on
            case .auto:
                self = .auto
            @unknown default:
                self = .off
            }
        }
    }

    var isSelected: Bool {
        get {
            switch self {
            case .on, .auto:
                return true
            case .off:
                return false
            @unknown default:
                return false
            }
        }
        /// Shouldn't be called. We're only use this to pass this as a read-only binding
        set {
            switch self {
            case .off:
                self = .off
            case .on:
                self = .on
            case .auto:
                self = .auto
            @unknown default:
                self = .off
            }
        }
    }
}
