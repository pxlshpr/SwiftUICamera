//import SwiftUI
//import SwiftHaptics
//
//public struct NutrientPicker: View {
//
//    @State var goingUp = false
//    @State var goingUpAgain = false
//
//    @Binding var queuedAttributes: [QueueAttribute]
//    @Binding var didConfirmAllAttributes: Bool
//    @Binding var images: [UUID: UIImage]
//
//    @State var croppedImage: UIImage? = nil
//
//    var container: some View {
//        ZStack(alignment: .bottom) {
//            rows
//            .frame(maxWidth: .infinity)
//            .frame(height: containerHeight)
//            .edgesIgnoringSafeArea(.bottom)
//            .clipped()
//            .background(
//                .ultraThinMaterial
//            )
//        }
//    }
//
//    @State var currentIndex = 0
//
////    @State var rowsData = [
////        ("Carbohydrate", ["242.5 g", "24 g"]),
////        ("Energy", ["335 kcal", "725 kJ", "3335 kJ", "802 kJ"]),
////        ("Fat", ["25 g"]),
////        ("Carbohydrate", ["242.5 g", "24 g"]),
////        ("Energy", ["335 kcal", "725 kJ", "3335 kJ", "802 kJ"]),
////        ("Fat", ["25 g"]),
////        ("Carbohydrate", ["242.5 g", "24 g"]),
////        ("Energy", ["335 kcal", "725 kJ", "3335 kJ", "802 kJ"]),
////        ("Fat", ["25 g"]),
////        ("Carbohydrate", ["242.5 g", "24 g"]),
////        ("Energy", ["335 kcal", "725 kJ", "3335 kJ", "802 kJ"]),
////        ("Fat", ["25 g"]),
////        ("Carbohydrate", ["242.5 g", "24 g"]),
////        ("Energy", ["335 kcal", "725 kJ", "3335 kJ", "802 kJ"]),
////        ("Fat", ["25 g"]),
////        ("Carbohydrate", ["242.5 g", "24 g"]),
////        ("Energy", ["335 kcal", "725 kJ", "3335 kJ", "802 kJ"]),
////        ("Fat", ["25 g"]),
////    ]
//
//    let height: CGFloat = 80
//    let containerHeight: CGFloat = 200
//
//    var rows: some View {
//        LazyVStack(spacing: 0) {
//            ForEach(queuedAttributes.indices, id: \.self) { i in
//                row(for: queuedAttributes[i])
//                    .frame(height: height)
//                    .grayscale(currentIndex == i ? 0 : 1)
//                    .blur(radius: currentIndex == i ? 0 : 2)
//            }
//        }
//        .offset(y: offset)
//    }
//
//    var offset: CGFloat {
//        let start = ((Double(queuedAttributes.count) * height) - containerHeight) / 2
//        return start - (Double(currentIndex) * height)
//    }
//
//    var rows_legacy: some View {
//        LazyVStack(spacing: 0) {
//            row("Carbohydrate", buttons: ["242.5 g", "24 g"])
//                .frame(height: 60)
////                .background(.red)
//                .grayscale(goingUp ? 1 : 0)
//                .blur(radius: goingUp ? 2 : 0)
//            row("Energy", buttons: ["335 kcal", "725 kJ", "3335 kJ", "802 kJ"])
//                .frame(height: 60)
////                .background(.blue)
//                .grayscale(goingUp ? 0 : 1)
//                .blur(radius: goingUp ? 0 : 2)
//            row("Fat", buttons: ["25 g"])
//                .frame(height: 60)
////                .background(.pink)
//                .grayscale(goingUpAgain ? 0 : 1)
//                .blur(radius: goingUpAgain ? 0 : 2)
//                .grayscale(1)
//                .blur(radius: 2)
//            row("Fat", buttons: ["25 g"])
//                .frame(height: 60)
////                .background(.pink)
//                .grayscale(goingUpAgain ? 0 : 1)
//                .blur(radius: goingUpAgain ? 0 : 2)
//                .grayscale(1)
//                .blur(radius: 2)
//        }
//        .offset(y: goingUp ? -20 : (goingUpAgain ? -80 : 70))
//    }
//
//    func row(for queuedAttribute: QueueAttribute) -> some View {
//        HStack {
//            Text(queuedAttribute.attribute.description)
//                .padding(.vertical, 10)
//                .padding(.horizontal, 15)
//                .font(.title3)
//                .foregroundColor(Color.primary)
//                .padding(.leading)
//            ScrollView(.horizontal, showsIndicators: false) {
//                HStack {
//                    ForEach(queuedAttribute.valueTexts, id: \.self) { valueText in
//                        Button {
//                            Haptics.feedback(style: .rigid)
//                            withAnimation {
//                                currentIndex += 1
//                            }
//                            if currentIndex == queuedAttributes.count {
//                                didConfirmAllAttributes = true
//                            } else {
//                                guard let image = images.first?.value else {
//                                    return
//                                }
////                                Task {
////                                    let croppedImage = await image.cropped(boundingBox: valueText.text.boundingBox)
////                                    await MainActor.run {
////                                        withAnimation {
////                                            self.croppedImage = croppedImage
////                                        }
////                                    }
////                                }
//                            }
//                        } label: {
//                            Text(valueText.value.description)
//                                .foregroundColor(.white)
//                                .fontWeight(.semibold)
//                                .font(.title3)
//                                .padding(.vertical, 10)
//                                .padding(.horizontal, 15)
//                                .background(
//                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
//                                        .foregroundColor(Color.accentColor)
//                                )
//                        }
//                    }
//                }
//            }
//        }
//    }
//
//    func row(_ title: String, buttons: [String]) -> some View {
//        HStack {
//            Text(title)
//                .padding(.vertical, 10)
//                .padding(.horizontal, 15)
//                .font(.title3)
////                .foregroundColor(Color(.systemBackground))
//                .foregroundColor(Color.primary)
////                .background(
////                    RoundedRectangle(cornerRadius: 0, style: .continuous)
////                        .foregroundColor(Color(.systemFill))
////                )
//                .padding(.leading)
//            ScrollView(.horizontal, showsIndicators: false) {
//                HStack {
//                    ForEach(buttons, id: \.self) {
//                        button($0)
//                    }
//                }
//            }
//        }
//    }
//    public var body: some View {
//        ZStack {
//            VStack {
//                Spacer()
//                container
//            }
//            .edgesIgnoringSafeArea(.bottom)
//            if let croppedImage {
//                Image(uiImage: croppedImage)
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 200)
//            }
//        }
//    }
//
//    func button(_ string: String) -> some View {
//        Button {
//            Haptics.successFeedback()
//            withAnimation {
//                currentIndex += 1
//            }
//        } label: {
//            Text(string)
//                .foregroundColor(.white)
//                .fontWeight(.semibold)
//                .font(.title3)
//                .padding(.vertical, 10)
//                .padding(.horizontal, 15)
//                .background(
//                    RoundedRectangle(cornerRadius: 20, style: .continuous)
//                        .foregroundColor(Color.accentColor)
//                )
//        }
//    }
//}
//
//extension UIImage {
//    func cropped(boundingBox: CGRect) async -> UIImage? {
//        let cropRect = boundingBox.rectForSize(size)
//        let image = fixOrientationIfNeeded()
//        return cropImage(imageToCrop: image, toRect: cropRect)
//    }
//
//    func cropImage(imageToCrop: UIImage, toRect rect: CGRect) -> UIImage? {
//        guard let imageRef = imageToCrop.cgImage?.cropping(to: rect) else {
//            return nil
//        }
//        return UIImage(cgImage: imageRef)
//    }
//}
//
