import SwiftUI
import SwiftHaptics

struct PhotoPickerOverlay: View {
    
    @EnvironmentObject var cameraViewModel: CameraViewModel
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                button
                    .padding(.leading)
                Spacer()
            }
        }
    }
    
    var button: some View {
        Button {
//            cameraViewModel.tappedPhotoPicker()
        } label: {
            CameraButtonLabel(
                systemImage: .constant("photo.fill.on.rectangle.fill"),
                isSelected: .constant(false))
            .padding(.bottom, 20)
            .padding(.leading, 9)
            .padding(.trailing, 40)
            .background(Color.clear)
            .contentShape(Rectangle())
        }
    }
}
