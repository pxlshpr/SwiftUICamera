import SwiftUI
import SwiftHaptics

public struct NutrientPicker: View {
    
    @State var goingUp = false
    @State var goingUpAgain = false

    @Binding var queuedAttributes: [QueueAttribute]

    var container: some View {
        ZStack(alignment: .bottom) {
            rows
            .frame(maxWidth: .infinity)
            .frame(height: containerHeight)
            .edgesIgnoringSafeArea(.bottom)
            .clipped()
            .background(
                .ultraThinMaterial
            )
        }
    }
    
    @State var currentIndex = 0
    
//    @State var rowsData = [
//        ("Carbohydrate", ["242.5 g", "24 g"]),
//        ("Energy", ["335 kcal", "725 kJ", "3335 kJ", "802 kJ"]),
//        ("Fat", ["25 g"]),
//        ("Carbohydrate", ["242.5 g", "24 g"]),
//        ("Energy", ["335 kcal", "725 kJ", "3335 kJ", "802 kJ"]),
//        ("Fat", ["25 g"]),
//        ("Carbohydrate", ["242.5 g", "24 g"]),
//        ("Energy", ["335 kcal", "725 kJ", "3335 kJ", "802 kJ"]),
//        ("Fat", ["25 g"]),
//        ("Carbohydrate", ["242.5 g", "24 g"]),
//        ("Energy", ["335 kcal", "725 kJ", "3335 kJ", "802 kJ"]),
//        ("Fat", ["25 g"]),
//        ("Carbohydrate", ["242.5 g", "24 g"]),
//        ("Energy", ["335 kcal", "725 kJ", "3335 kJ", "802 kJ"]),
//        ("Fat", ["25 g"]),
//        ("Carbohydrate", ["242.5 g", "24 g"]),
//        ("Energy", ["335 kcal", "725 kJ", "3335 kJ", "802 kJ"]),
//        ("Fat", ["25 g"]),
//    ]

    let height: CGFloat = 60
    let containerHeight: CGFloat = 100
    
    var rows: some View {
        LazyVStack(spacing: 0) {
            ForEach(queuedAttributes.indices, id: \.self) { i in
                row(for: queuedAttributes[i])
                    .frame(height: height)
                    .grayscale(currentIndex == i ? 0 : 1)
                    .blur(radius: currentIndex == i ? 0 : 2)
            }
        }
        .offset(y: offset)
    }
    
    var offset: CGFloat {
        let start = ((Double(queuedAttributes.count) * height) - containerHeight) / 2
        return start - (Double(currentIndex) * height)
    }
    
    var rows_legacy: some View {
        LazyVStack(spacing: 0) {
            row("Carbohydrate", buttons: ["242.5 g", "24 g"])
                .frame(height: 60)
//                .background(.red)
                .grayscale(goingUp ? 1 : 0)
                .blur(radius: goingUp ? 2 : 0)
            row("Energy", buttons: ["335 kcal", "725 kJ", "3335 kJ", "802 kJ"])
                .frame(height: 60)
//                .background(.blue)
                .grayscale(goingUp ? 0 : 1)
                .blur(radius: goingUp ? 0 : 2)
            row("Fat", buttons: ["25 g"])
                .frame(height: 60)
//                .background(.pink)
                .grayscale(goingUpAgain ? 0 : 1)
                .blur(radius: goingUpAgain ? 0 : 2)
                .grayscale(1)
                .blur(radius: 2)
            row("Fat", buttons: ["25 g"])
                .frame(height: 60)
//                .background(.pink)
                .grayscale(goingUpAgain ? 0 : 1)
                .blur(radius: goingUpAgain ? 0 : 2)
                .grayscale(1)
                .blur(radius: 2)
        }
        .offset(y: goingUp ? -20 : (goingUpAgain ? -80 : 70))
    }
    
    func row(for queuedAttribute: QueueAttribute) -> some View {
        HStack {
            Text(queuedAttribute.attribute.description)
                .padding(.vertical, 10)
                .padding(.horizontal, 15)
                .font(.title3)
                .foregroundColor(Color.primary)
                .padding(.leading)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(queuedAttribute.values, id: \.self) { value in
                        Button {
                            Haptics.successFeedback()
                            withAnimation {
                                currentIndex += 1
                            }
                        } label: {
                            Text(value.description)
                                .foregroundColor(.white)
                                .fontWeight(.semibold)
                                .font(.title3)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 15)
                                .background(
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .foregroundColor(Color.accentColor)
                                )
                        }
                    }
                }
            }
        }
    }
    func row(_ title: String, buttons: [String]) -> some View {
        HStack {
            Text(title)
                .padding(.vertical, 10)
                .padding(.horizontal, 15)
                .font(.title3)
//                .foregroundColor(Color(.systemBackground))
                .foregroundColor(Color.primary)
//                .background(
//                    RoundedRectangle(cornerRadius: 0, style: .continuous)
//                        .foregroundColor(Color(.systemFill))
//                )
                .padding(.leading)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(buttons, id: \.self) {
                        button($0)
                    }
                }
            }
        }
    }
    public var body: some View {
        VStack {
            Spacer()
            container
        }
        .edgesIgnoringSafeArea(.bottom)
    }
    
    func button(_ string: String) -> some View {
        Button {
            Haptics.successFeedback()
            withAnimation {
                currentIndex += 1
            }
        } label: {
            Text(string)
                .foregroundColor(.white)
                .fontWeight(.semibold)
                .font(.title3)
                .padding(.vertical, 10)
                .padding(.horizontal, 15)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .foregroundColor(Color.accentColor)
                )
        }
    }
}
