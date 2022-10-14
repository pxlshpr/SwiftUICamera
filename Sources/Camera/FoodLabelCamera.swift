import SwiftUI
import AVKit
import SwiftHaptics
import FoodLabelScanner
import VisionSugar
import ActivityIndicatorView
import PrepUnits

public struct FoodLabelCamera: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: ViewModel
    let didCaptureImage: CapturedImageHandler?
    let didScanFoodLabelHandler: ((ScanResult) -> ())?
    
    let scanResults = ScanResults()
    @State var boundingBox: CGRect? = nil
    @State var haveBestCandidate = false
    
    @Binding var image: UIImage?
    @Binding var scanResult: ScanResult?

    public init(
        image: Binding<UIImage?>,
        scanResult: Binding<ScanResult?>,
        showFlashButton: Bool = false,
        showTorchButton: Bool = false,
        showPhotosPickerButton: Bool = false,
        showCapturedImagesCount: Bool = false,
        didScanFoodLabel: ((ScanResult) -> ())? = nil,
        didCaptureImage: CapturedImageHandler? = nil
    ) {
        _image = image
        _scanResult = scanResult
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
            imageForScanResult: handleImageForScanResult,
            didCaptureImage: didCaptureImage,
            didScanCode: didScanCode
        )
        .environmentObject(viewModel)
    }
    
    func didScanCode(_ result: Result<String, Camera.ScanError>) {
        
    }
    
    @ViewBuilder
    var boxesLayer: some View {
        if let boundingBox {
            GeometryReader { geometry in
                boxLayer(
                    boundingBox: boundingBox,
                    inSize: geometry.size,
                    color: haveBestCandidate ? .green : Color(.label)
                )
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
                .opacity(0.4)
                .opacity(0)
                .frame(width: boundingBox.rectForSize(size).width,
                       height: boundingBox.rectForSize(size).height)
            
                .overlay(
                    ActivityIndicatorView(isVisible: .constant(true), type: .arcs())
                        .frame(width: 50, height: 50)
//                        .frame(width: boundingBox.rectForSize(size).width, height: boundingBox.rectForSize(size).height)
                        .foregroundColor(.accentColor)
//                    RoundedRectangle(cornerRadius: 3)
//                        .stroke(color, lineWidth: 1)
//                        .opacity(0.8)
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
    
//    func shouldGetImageForScanResult_legacy(_ scanResult: ScanResult) -> Bool {
//    func shouldGetImageForScanResult(_ scanResult: ScanResult) -> Bool {
    func handleImageForScanResult(_ image: UIImage, scanResult: ScanResult) {
        if let bestCandidate = scanResults.bestCandidateAfterAdding(result: scanResult) {
            print("🥳 Best candidate, count: \(bestCandidate.count)")
            print(bestCandidate.scanResult.summaryDescription(withEmojiPrefix: "🥳`"))
            withAnimation {
                boundingBox = bestCandidate.scanResult.boundingBox
            }
            if !haveBestCandidate {
                withAnimation {
                    haveBestCandidate = true
                    self.image = image
                    self.scanResult = scanResult
                    
                    Haptics.successFeedback()
                    dismiss()
                }
            }
        } else {
            guard scanResult.boundingBox != .zero else {
                return
            }
            print("🥳 starting box: \(scanResult.boundingBox)")
            withAnimation {
                boundingBox = scanResult.boundingBox
            }
        }
        
//        return false
    }
    
//    func handleImageForScanResult_legacy(_ image: UIImage, scanResult: ScanResult) {
    func handleImageForScanResult_legacy(_ image: UIImage, scanResult: ScanResult) {
        scanResults.set(image, for: scanResult)
        self.image = image
        self.scanResult = scanResult
        
        Haptics.successFeedback()
        dismiss()
    }
    
}

class ScanResultSet: ObservableObject {
    var scanResult: ScanResult
    var date: Date = Date()
    var image: UIImage?
    
    /// How many times this has been repeated
    var count: Int
    
    init(scanResult: ScanResult, image: UIImage? = nil) {
        self.scanResult = scanResult
        self.image = image
        self.count = 0
    }
}

var mostFrequentAmounts: [Attribute: (Double, Int)] = [:]

func commonElementsInArrayUsingReduce(doublesArray: [Double]) -> (Double, Int) {
    let doublesArray = doublesArray.reduce(into: [:]) { (counts, doubles) in
        counts[doubles, default: 0] += 1
    }
    let element = doublesArray.sorted(by: {$0.value > $1.value}).first
    return (element?.key ?? 0, element?.value ?? 0)
}

extension Array where Element == ScanResultSet {
    var sortedByNutrientsCount: [ScanResultSet] {
        sorted(by: { $0.scanResult.nutrientsCount > $1.scanResult.nutrientsCount })
    }
    
    var bestCandidate: ScanResultSet? {
        guard count >= 3, let withMostNutrients = sortedByNutrientsCount.first
        else {
            return nil
        }
        
        /// filter out only the results that has the same nutrient count as the one with the most
//        let filtered = filter({ $0.scanResult.nutrientsCount == withMostNutrients.scanResult.nutrientsCount })
        let filtered = self
        
        /// for each nutrient, save the modal value across all these filtered results
        for attribute in withMostNutrients.scanResult.nutrientAttributes {
            
//            print("Getting doubles for \(attribute) in \(self.count)")
            
            let doubles = filtered.map({$0.scanResult}).amounts(for: attribute)
            Haptics.transientHaptic()
            print("🥶 Got \(doubles.count) doubles for \(attribute) \(self.count) array elements")

            let mostFrequentWithCount = commonElementsInArrayUsingReduce(doublesArray: doubles)
            
//            guard let mostFrequentWithCount = doubles.mostFrequentWithCount else {
//                continue
//            }
            mostFrequentAmounts[attribute] = mostFrequentWithCount
            print("🥶 Most frequent amounts for \(self.count) is now:")
            for key in mostFrequentAmounts.keys {
                print("🥶     \(key): \(mostFrequentAmounts[key]?.0 ?? 0) (\(mostFrequentAmounts[key]?.1 ?? 0) times)")
            }
            print("🥶  -----------------")
            print("🥶  ")
        }
        
        /// now sort the filtered results by the count of (how many nutrients in it match the modal results) and return the first one
        let sorted = filtered
            .sortedByMostMatchesToAmountsDict(mostFrequentAmounts)
            .sorted { $0.date > $1.date }
            .sorted { $0.count > $1.count }
        
        /// return the one with the most matches
        return sorted.first
    }
}

class ScanResults: ObservableObject {
    var array: [ScanResultSet] = []
        
    func bestCandidateAfterAdding(result: ScanResult) -> ScanResultSet? {
        guard result.hasNutrients else { return nil }
        
        /// If we have a `ScanResult` that matches this
//        if let index = array.firstIndex(where: { $0.scanResult.matches(result) }) {
//            let existing = array.remove(at: index)
//
//            /// Replace the scan result with the new one (so we always keep the latest copy)
//            existing.scanResult = result
//
//            /// Update the date
//            existing.date = Date()
//
//            /// Increase the count
//            existing.count += 1
//
//            array.append(existing)
//        } else {
            array.append(ScanResultSet(scanResult: result, image: nil))
        print("🥶 Array now has \(array.count)")
//        }
        return bestCandidate
    }
    
    var bestCandidate: ScanResultSet? {
        array.bestCandidate
    }
    
    
    func set(_ image: UIImage, for scanResult: ScanResult) {
        array.first(where: { $0.scanResult.id == scanResult.id })?.image = image
    }
}
