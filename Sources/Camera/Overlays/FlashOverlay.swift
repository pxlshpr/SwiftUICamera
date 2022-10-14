import SwiftUI
import SwiftHaptics

struct FlashOverlay: View {
    
    @EnvironmentObject var cameraViewModel: CameraViewModel
    
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
                    cameraViewModel.config.flashMode = .on
                }
            }
            Button("Off") {
                Haptics.feedback(style: .medium)
                withAnimation {
                    cameraViewModel.config.flashMode = .off
                }
            }
            Button("Auto") {
                Haptics.feedback(style: .medium)
                withAnimation {
                    cameraViewModel.config.flashMode = .auto
                }
            }
        } label: {
            CameraButtonLabel(
                systemImage: $cameraViewModel.config.flashMode.systemImage,
                backgroundColor: $cameraViewModel.config.flashMode.backgroundColor,
                isSelected: $cameraViewModel.config.flashMode.isSelected)
            .padding(.top, 20)
            .padding(.leading, 9)
            .padding(.trailing, 40)
            .background(Color.clear)
            .contentShape(Rectangle())
        } primaryAction: {
            cameraViewModel.tappedFlashButton()
        }
    }
}
