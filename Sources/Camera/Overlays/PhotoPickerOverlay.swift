import SwiftUI
import SwiftHaptics

struct PhotoPickerOverlay: View {
    
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                button
                    .padding(.trailing)
                Spacer()
            }
        }
    }
    
    var button: some View {
        Button {
//            viewModel.tappedPhotoPicker()
        } label: {
            CameraButtonLabel(
                systemImage: .constant("photo.fill.on.rectangle.fill"),
                isSelected: .constant(false))
            .padding(.vertical, 20)
            .padding(.leading, 9)
            .padding(.trailing, 40)
            .background(Color.clear)
            .contentShape(Rectangle())
        }
    }
}
