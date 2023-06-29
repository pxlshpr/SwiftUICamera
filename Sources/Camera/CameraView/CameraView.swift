import AVFoundation
import SwiftUI

public typealias SampleBufferHandler = (CMSampleBuffer) -> ()

public struct CameraView: UIViewControllerRepresentable {

    public let codeTypes: [AVMetadataObject.ObjectType]
    public var simulatedData = ""
    
    let sampleBufferHandler: SampleBufferHandler?
    let codeHandler: CodeHandler?

    @Binding var config: CameraConfiguration
    
    public init(
        config: Binding<CameraConfiguration>,
        codeTypes: [AVMetadataObject.ObjectType],
        simulatedData: String = "",
        codeHandler: CodeHandler? = nil,
        sampleBufferHandler: SampleBufferHandler? = nil
    ) {
        self.codeTypes = codeTypes
        self.simulatedData = simulatedData
        self.codeHandler = codeHandler
        self.sampleBufferHandler = sampleBufferHandler
        _config = config
    }
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    public func makeUIViewController(context: Context) -> CameraViewController {
        let viewController = CameraViewController(config: $config.wrappedValue)
        viewController.delegate = context.coordinator
        return viewController
    }
    
    public func updateUIViewController(_ controller: CameraViewController, context: Context) {
        if config != controller.config {
            controller.configUpdated(with: config)
        }
    }
}
