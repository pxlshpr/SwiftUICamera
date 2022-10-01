import SwiftUI
import SwiftHaptics

struct FlashOverlay: View {
    
    @EnvironmentObject var viewModel: ViewModel
    
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
                    viewModel.config.flashMode = .on
                }
            }
            Button("Off") {
                Haptics.feedback(style: .medium)
                withAnimation {
                    viewModel.config.flashMode = .off
                }
            }
            Button("Auto") {
                Haptics.feedback(style: .medium)
                withAnimation {
                    viewModel.config.flashMode = .auto
                }
            }
        } label: {
            CameraButtonLabel(
                systemImage: $viewModel.config.flashMode.systemImage,
                backgroundColor: $viewModel.config.flashMode.backgroundColor,
                isSelected: $viewModel.config.flashMode.isSelected)
            .padding(.top, 20)
            .padding(.leading, 9)
            .padding(.trailing, 40)
            .background(Color.clear)
            .contentShape(Rectangle())
        } primaryAction: {
            viewModel.tappedFlashButton()
        }
    }
}
