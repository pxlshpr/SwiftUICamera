import SwiftUI
import SwiftHaptics

struct CaptureOverlay: View {
    
    @EnvironmentObject var cameraModel: CameraModel
    
    var body: some View {
        VStack {
            Spacer()
            captureButton
                .padding(.bottom)
        }
    }
    
    var captureButton: some View {
        Button {
            Haptics.feedback(style: .rigid)
            cameraModel.tappedCapture()

            NotificationCenter.default.post(name: Notification.Name("didTapCaptureButton"), object: nil)
        } label: {
            Image(systemName: "circle.inset.filled")
                .font(.system(size: 72))
                .foregroundColor(.white)
        }
        .buttonStyle(.borderless)
    }
}
