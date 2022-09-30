import SwiftUI

struct CameraButtonLabel: View {

    @Binding var systemImage: String
    var boundBackgroundColor: Binding<Color>?
    var boundForegroundColor: Binding<Color>?
    @Binding var renderingMode: Image.TemplateRenderingMode
    @Binding var isSelected: Bool
    
    init(
        systemImage: Binding<String>,
        renderingMode: Binding<Image.TemplateRenderingMode>? = nil,
        backgroundColor: Binding<Color>? = nil,
        foregroundColor: Binding<Color>? = nil,
        isSelected: Binding<Bool>
    ) {
        _systemImage = systemImage
        _isSelected = isSelected
        _renderingMode = renderingMode ?? .constant(.template)
        boundBackgroundColor = backgroundColor
        boundForegroundColor = foregroundColor
    }
    
    var body: some View {
        Image(systemName: systemImage)
            .renderingMode(renderingMode)
            .imageScale(.small)
            .font(.system(size: 25))
            .foregroundColor(foregroundColor)
            .frame(width: 40, height: 40)
            .background(
                Circle()
                    .foregroundColor(backgroundColor)
                    .opacity(isSelected ? 0.8 : 1.0)
            )
    }
    
    var foregroundColor: Color {
        if let boundForegroundColor {
            return boundForegroundColor.wrappedValue
        } else {
            return isSelected ? .black : .white
        }
    }
    
    var backgroundColor: Color {
        if let boundBackgroundColor {
            return boundBackgroundColor.wrappedValue
        } else {
            return isSelected ? Color(.systemGroupedBackground) : Color(.systemFill)
        }
    }
}
