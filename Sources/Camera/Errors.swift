import Foundation

public extension Camera {
    enum ScanError: Error {
        case badInput, badOutput
    }
}

enum CameraError: Error {
    case couldNotCreateDevice
}

