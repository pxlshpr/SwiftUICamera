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
    
    let scanResults = ScanResults()
    @State var boundingBox: CGRect? = nil
    
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
                    .frame(height: geometry.size.height - 108 + 27 + 7)
                    .offset(y: 54)
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
            shouldGetImageForScanResult: shouldGetImageForScanResult,
            imageForScanResult: handleImageForScanResult,
            didCaptureImage: didCaptureImage,
            didScanCode: nil
        )
        .environmentObject(viewModel)
    }
    
    @ViewBuilder
    var boxesLayer: some View {
        if let boundingBox {
            GeometryReader { geometry in
                boxLayer(boundingBox: boundingBox, inSize: geometry.size, color: .accentColor)
            }
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
    
    func shouldGetImageForScanResult(_ scanResult: ScanResult) -> Bool {
        if let bestCandidate = scanResults.bestCandidateAfterAdding(result: scanResult) {
//            print(bestCandidate.summaryDescription(withEmojiPrefix: "🥳`"))
            print("🥳 Best candidate box: \(bestCandidate.boundingBox)")
            boundingBox = bestCandidate.boundingBox
        } else {
            print("🥳 starting box: \(boundingBox)")
            boundingBox = scanResult.boundingBox
        }
        
        return false
    }
    
    func handleImageForScanResult(_ image: UIImage, scanResult: ScanResult) {
        scanResults.set(image, for: scanResult)
    }
    
}

class ScanResultSet: ObservableObject {
    let scanResult: ScanResult
    let date: Date = Date()
    var image: UIImage?
    init(scanResult: ScanResult, image: UIImage? = nil) {
        self.scanResult = scanResult
        self.image = image
    }
}

extension Array where Element == ScanResultSet {
    var sortedByNutrientsCount: [ScanResultSet] {
        sorted(by: { $0.scanResult.nutrientsCount > $1.scanResult.nutrientsCount })
    }
    
    var bestCandidate: ScanResult? {
        guard count >= 3, let withMostNutrients = sortedByNutrientsCount.first
        else {
            return nil
        }
        
        /// filter out only the results that has the same nutrient count as the one with the most
        let filtered = filter({ $0.scanResult.nutrientsCount == withMostNutrients.scanResult.nutrientsCount })
        
        var mostFrequentAmounts: [Attribute: Double] = [:]
        
        /// for each nutrient, save the modal value across all these filtered results
        for attribute in withMostNutrients.scanResult.nutrientAttributes {
            let doubles = filtered.map({$0.scanResult}).amounts(for: attribute)
            guard let mostFrequent = doubles.mostFrequent else { continue }
            mostFrequentAmounts[attribute] = mostFrequent
        }
        
        /// now sort the filtered results by the count of (how many nutrients in it match the modal results) and return the first one
        let sorted = filtered
            .sortedByMostMatchesToAmountsDict(mostFrequentAmounts)
            .sorted { $0.date > $1.date }
        
        /// return the one with the most matches
        return sorted.first?.scanResult
    }
}

class ScanResults: ObservableObject {
    var array: [ScanResultSet] = []
        
    func bestCandidateAfterAdding(result: ScanResult) -> ScanResult? {
        guard result.hasNutrients else { return nil }
        array.append(ScanResultSet(scanResult: result, image: nil))
        return bestCandidate
    }
    
    var bestCandidate: ScanResult? {
        array.bestCandidate
    }
    
    
    func set(_ image: UIImage, for scanResult: ScanResult) {
        array.first(where: { $0.scanResult.id == scanResult.id })?.image = image
    }
}
