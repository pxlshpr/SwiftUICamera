import AVFoundation
import SwiftUI
import SwiftUISugar
import FoodLabelScanner

public struct CameraView: UIViewControllerRepresentable {

    public let codeTypes: [AVMetadataObject.ObjectType]
    public var simulatedData = ""
    
    public var completion: ScannedCodeHandler? = nil
    let shouldGetImageForScanResult: ((ScanResult) -> (Bool))?
    let imageForScanResult: ((UIImage, ScanResult) -> ())?

    @Binding var config: CameraConfiguration
    
    public init(
        config: Binding<CameraConfiguration>,
        codeTypes: [AVMetadataObject.ObjectType],
        simulatedData: String = "",
        shouldGetImageForScanResult: ((ScanResult) -> (Bool))? = nil,
        imageForScanResult: ((UIImage, ScanResult) -> ())? = nil,
        completion: ScannedCodeHandler? = nil
    ) {
        self.codeTypes = codeTypes
        self.simulatedData = simulatedData
        self.completion = completion
        self.shouldGetImageForScanResult = shouldGetImageForScanResult
        self.imageForScanResult = imageForScanResult
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
