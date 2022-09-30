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
                    viewModel.flashMode = .on
                }
            }
            Button("Off") {
                Haptics.feedback(style: .medium)
                withAnimation {
                    viewModel.flashMode = .off
                }
            }
            Button("Auto") {
                Haptics.feedback(style: .medium)
                withAnimation {
                    viewModel.flashMode = .auto
                }
            }
        } label: {
            CameraButtonLabel(
                systemImage: $viewModel.flashMode.systemImage,
                backgroundColor: $viewModel.flashMode.backgroundColor,
                isSelected: $viewModel.flashMode.isSelected)
            .padding(.vertical, 20)
            .padding(.leading, 9)
            .padding(.trailing, 40)
            .background(Color.clear)
            .contentShape(Rectangle())
        } primaryAction: {
            viewModel.tappedFlashButton()
        }
    }
}
