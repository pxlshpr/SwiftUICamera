import SwiftUI
import SwiftHaptics

struct TorchOverlay: View {
    
    @EnvironmentObject var cameraViewModel: CameraViewModel
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                button
                    .padding(.trailing)
            }
        }
    }
    
    var button: some View {
        Button {
            cameraViewModel.tappedTorchButton()
        } label: {
            CameraButtonLabel(
                systemImage: $cameraViewModel.config.torchMode.systemImage,
                isSelected: $cameraViewModel.config.torchMode.isSelected)
            
//            .padding(.top, 20)
//            .padding(.leading, 40)
//            .padding(.trailing, 9)

            .padding(.bottom, 20)
            .padding(.leading, 40)
            .padding(.trailing, 9)

            .background(Color.clear)
            .contentShape(Rectangle())
        }
    }
}
