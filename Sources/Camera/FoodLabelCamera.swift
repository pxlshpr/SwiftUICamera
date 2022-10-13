import SwiftUI
import AVKit
import SwiftHaptics
import FoodLabelScanner
import VisionSugar

public struct FoodLabelCamera: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: ViewModel
    let didCaptureImage: CapturedImageHandler?
    let didScanFoodLabelHandler: ((ScanResult) -> ())?
    
    @State var latestScanResult: ScanResult? = nil
    
    public init(
        showFlashButton: Bool = true,
        showTorchButton: Bool = false,
        showPhotosPickerButton: Bool = false,
        showCapturedImagesCount: Bool = true,
        didScanFoodLabel: ((ScanResult) -> ())? = nil,
        didCaptureImage: CapturedImageHandler? = nil
    ) {
        self.didCaptureImage = didCaptureImage
        self.didScanFoodLabelHandler = didScanFoodLabel
        
        let viewModel = ViewModel(
            showFlashButton: showFlashButton,
            showTorchButton: showTorchButton,
            showPhotoPickerButton: showPhotosPickerButton,
            showCapturedImagesCount: showCapturedImagesCount
        )
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        ZStack {
            cameraLayer
            GeometryReader { geometry in
                boxesLayer
                    .edgesIgnoringSafeArea(.bottom)
            }
        }
        .onChange(of: viewModel.shouldDismiss) { newValue in
            if newValue {
                dismiss()
            }
        }
    }
    
    //MARK: - Layers
    var cameraLayer: some View {
        BaseCamera(
            didScanFoodLabel: didScanFoodLabel,
            didCaptureImage: didCaptureImage,
            didScanCode: nil
        )
        .environmentObject(viewModel)
    }
    
    @ViewBuilder
    var boxesLayer: some View {
        if let latestScanResult {
            boxesLayer(for: latestScanResult)
        }
    }
    
    func boxesLayer(for scanResult: ScanResult) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                ForEach(scanResult.resultTexts, id: \.self) { text in
                    boxLayer(for: text, inSize: geometry.size)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    func boxLayer(for text: RecognizedText, inSize size: CGSize) -> some View {
        boxLayer(boundingBox: text.boundingBox, inSize: size, color: .accentColor)
    }
    
    func boxLayer(boundingBox: CGRect, inSize size: CGSize, color: Color) -> some View {
        var box: some View {
            RoundedRectangle(cornerRadius: 3)
                .foregroundStyle(
                    color.gradient.shadow(
                        .inner(color: .black, radius: 3)
                    )
                )
                .opacity(0.3)
                .frame(width: boundingBox.rectForSize(size).width,
                       height: boundingBox.rectForSize(size).height)
            
                .overlay(
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(color, lineWidth: 1)
                        .opacity(0.8)
                )
                .shadow(radius: 3, x: 0, y: 2)
        }
        
        return HStack {
            VStack(alignment: .leading) {
                box
                Spacer()
            }
            Spacer()
        }
        .offset(x: boundingBox.rectForSize(size).minX,
                y: boundingBox.rectForSize(size).minY)
    }

    
    //MARK: - Actions
    
    func didScanFoodLabel(_ scanResult: ScanResult) {
        withAnimation {
            latestScanResult = scanResult
        }
        didScanFoodLabelHandler?(scanResult)
    }
}

extension ScanResult {
    var resultTexts: [RecognizedText] {
        nutrientAttributeTexts
    }
    
    var nutrientAttributeTexts: [RecognizedText] {
        nutrients.rows.map { $0.attributeText.text }
    }
    
    var nutrientValueTexts: [RecognizedText] {
        nutrients.rows.map { $0.attributeText.text }
    }
}
