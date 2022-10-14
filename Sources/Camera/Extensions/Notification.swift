import Foundation

extension Notification.Name {
    static var didCaptureImage: Notification.Name { return .init("didCaptureImage") }
    static var didNotCaptureImage: Notification.Name { return .init("didNotCaptureImage") }
}

extension Notification {
    struct CameraImagePickerKeys {
        static let error = "error"
        static let image = "image"
    }
}
