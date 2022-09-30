import AVFoundation
import SwiftUI
import SwiftUISugar

public struct CameraView: UIViewControllerRepresentable {

    public let codeTypes: [AVMetadataObject.ObjectType]
    public var simulatedData = ""
    public var completion: ScanResultHandler? = nil
    
    public init(codeTypes: [AVMetadataObject.ObjectType], simulatedData: String = "", completion: ScanResultHandler? = nil) {
        self.codeTypes = codeTypes
        self.simulatedData = simulatedData
        self.completion = completion
    }
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    public func makeUIViewController(context: Context) -> Controller {
        let viewController = Controller()
        viewController.delegate = context.coordinator
        return viewController
    }
    
    public func updateUIViewController(_ uiViewController: Controller, context: Context) {
        
    }
}
