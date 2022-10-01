import SwiftUI
import SwiftHaptics

struct TorchOverlay: View {
    
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                button
                    .padding(.trailing)
            }
            Spacer()
        }
    }
    
    var button: some View {
        Button {
            viewModel.tappedTorchButton()
        } label: {
            CameraButtonLabel(
                systemImage: $viewModel.torchMode.systemImage,
                isSelected: $viewModel.torchMode.isSelected)
            .padding(.top, 20)
            .padding(.leading, 40)
            .padding(.trailing, 9)
            .background(Color.clear)
            .contentShape(Rectangle())
        }
    }
}
