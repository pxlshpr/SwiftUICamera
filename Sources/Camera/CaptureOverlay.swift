import SwiftUI

struct CaptureOverlay: View {
    
    var body: some View {
        VStack {
            Spacer()
            captureButton
            .padding(.bottom)
        }
    }
    
    var captureButton: some View {
        Button {
            NotificationCenter.default.post(name: Notification.Name("didTapCaptureButton"), object: nil)
//            tappedCapture()
        } label: {
            Image(systemName: "circle.inset.filled")
                .font(.system(size: 72))
                .foregroundColor(.white)
        }
        .buttonStyle(.borderless)
    }
}
