import AVFoundation
import SwiftUI
import SwiftUISugar

public struct CameraView: UIViewControllerRepresentable {

    public let codeTypes: [AVMetadataObject.ObjectType]
    public var simulatedData = ""
    public var completion: ScannedCodeHandler? = nil
    @Binding var config: CameraConfiguration
    
    public init(config: Binding<CameraConfiguration>, codeTypes: [AVMetadataObject.ObjectType], simulatedData: String = "", completion: ScannedCodeHandler? = nil) {
        self.codeTypes = codeTypes
        self.simulatedData = simulatedData
        self.completion = completion
        _config = config
    }
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    public func makeUIViewController(context: Context) -> Controller {
        let viewController = Controller(config: $config.wrappedValue)
        viewController.delegate = context.coordinator
        return viewController
    }
    
    public func updateUIViewController(_ controller: Controller, context: Context) {
        if config != controller.config {
            controller.configUpdated(with: config)
        }
    }
}
