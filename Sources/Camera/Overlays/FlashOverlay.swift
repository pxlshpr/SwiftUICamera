import SwiftUI
import SwiftHaptics

struct FlashOverlay: View {
    
    @EnvironmentObject var cameraModel: CameraModel
    
    var body: some View {
        VStack {
            HStack {
                button
                    .padding(.leading)
                Spacer()
            }
            Spacer()
        }
    }
    
    var button: some View {
        Menu {
            Button("On") {
                Haptics.feedback(style: .medium)
                withAnimation {
                    cameraModel.config.flashMode = .on
                }
            }
            Button("Off") {
                Haptics.feedback(style: .medium)
                withAnimation {
                    cameraModel.config.flashMode = .off
                }
            }
            Button("Auto") {
                Haptics.feedback(style: .medium)
                withAnimation {
                    cameraModel.config.flashMode = .auto
                }
            }
        } label: {
            CameraButtonLabel(
                systemImage: $cameraModel.config.flashMode.systemImage,
                backgroundColor: $cameraModel.config.flashMode.backgroundColor,
                isSelected: $cameraModel.config.flashMode.isSelected)
            
            .padding(.top, 20)
            .padding(.leading, 9)
            .padding(.trailing, 40)
            
            .background(Color.clear)
            .contentShape(Rectangle())
        } primaryAction: {
            cameraModel.tappedFlashButton()
        }
    }
}
