import SwiftUI
import SwiftHaptics

struct TorchOverlay: View {
    
    @Bindable var cameraModel: CameraModel
    
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
            cameraModel.tappedTorchButton()
        } label: {
            CameraButtonLabel(
                systemImage: $cameraModel.config.torchMode.systemImage,
                isSelected: $cameraModel.config.torchMode.isSelected)
            
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
