import SwiftUI
import SwiftHaptics

struct DismissButtonOverlay: View {
    
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
            Haptics.feedback(style: .soft)
            cameraViewModel.tappedDismiss()
        } label: {
            CameraButtonLabel(
                systemImage: .constant("chevron.down"),
                isSelected: .constant(false))
            .padding(.bottom, 20)
            .padding(.leading, 9)
            .padding(.trailing, 40)
            .background(Color.clear)
            .contentShape(Rectangle())
        }
    }
}
