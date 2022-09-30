import AVKit
import SwiftUI

extension AVCaptureDevice.FlashMode {
    var systemImage: String {
        get {
            switch self {
            case .off:
                return "bolt.slash.fill"
            case .on, .auto:
                return "bolt.fill"
            @unknown default:
                return "bolt.slash"
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
    
    var renderingMode: Image.TemplateRenderingMode {
        get {
            switch self {
            case .on:
                return .original
            case .off, .auto:
                return .template
            @unknown default:
                return .template
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
    
    var backgroundColor: Color {
        get {
            switch self {
            case .off:
                return Color(.systemFill)
            case .on:
                return Color.yellow
            case .auto:
                return Color(.systemGroupedBackground)
            @unknown default:
                return Color(.systemGroupedBackground)
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
