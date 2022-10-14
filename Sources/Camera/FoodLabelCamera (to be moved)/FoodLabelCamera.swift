import SwiftUI
import AVKit
import SwiftHaptics
import FoodLabelScanner
import VisionSugar
import ActivityIndicatorView
import PrepUnits

public struct FoodLabelCamera: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject var cameraViewModel: CameraViewModel
    let didCaptureImage: CapturedImageHandler?
    let didScanFoodLabelHandler: ((ScanResult) -> ())?
    
    let scanResults = ScanResultSets()
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
        
        let cameraViewModel = CameraViewModel(
            showFlashButton: showFlashButton,
            showTorchButton: showTorchButton,
            showPhotoPickerButton: showPhotosPickerButton,
            showCapturedImagesCount: showCapturedImagesCount
        )
        _cameraViewModel = StateObject(wrappedValue: cameraViewModel)
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
        .onChange(of: cameraViewModel.shouldDismiss) { newValue in
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
            didScanCode: didScanCode,
            sampleBufferHandler: processSampleBuffer
        )
        .environmentObject(cameraViewModel)
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

    
    //MARK: - Processing Sample Buffer
    
    @State var scanTasks: [Task<ScanResult, Error>] = []
    @State var lastScanTime: CFAbsoluteTime = CFAbsoluteTimeGetCurrent()
    
    func processSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        Task {
            let timeElapsed = CFAbsoluteTimeGetCurrent() - lastScanTime
            guard timeElapsed > 0.5, scanTasks.count < 3 else { return }
            
            lastScanTime = CFAbsoluteTimeGetCurrent()
//            guard scanTask == nil else { return }
            let scanTask = Task {
                let scanResult = try await FoodLabelLiveScanner(sampleBuffer: sampleBuffer).scan()
                return scanResult
            }
            scanTasks.append(scanTask)
            
            var start = CFAbsoluteTimeGetCurrent()
            let scanResult = try await scanTask.value
            scanTasks.removeAll(where: { $0 == scanTask })
            
            let duration = (CFAbsoluteTimeGetCurrent()-start).rounded(toPlaces: 2)
            
            start = CFAbsoluteTimeGetCurrent()
            
            let image = sampleBuffer.image
            
            handleImageForScanResult(image, scanResult: scanResult)
//            parent.imageForScanResult?(image, scanResult)
        }
    }

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
                    
                    print("📳 Success")
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
}


func commonElementsInArrayUsingReduce(doublesArray: [Double]) -> (Double, Int) {
    let doublesArray = doublesArray.reduce(into: [:]) { (counts, doubles) in
        counts[doubles, default: 0] += 1
    }
    let element = doublesArray.sorted(by: {$0.value > $1.value}).first
    return (element?.key ?? 0, element?.value ?? 0)
}
