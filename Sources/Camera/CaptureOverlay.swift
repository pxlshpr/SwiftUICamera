import SwiftUI
import SwiftHaptics

struct CaptureOverlay: View {
    
    @EnvironmentObject var viewModel: ViewModel
    
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
            viewModel.animateCapture()

            NotificationCenter.default.post(name: Notification.Name("didTapCaptureButton"), object: nil)
        } label: {
            Image(systemName: "circle.inset.filled")
                .font(.system(size: 72))
                .foregroundColor(.white)
        }
        .buttonStyle(.borderless)
    }
}

extension ViewModel {
    func animateCapture() {
        withAnimation(.easeInOut(duration: 0.4)) {
            animateCameraViewShrinking = true
            makeCameraViewTranslucent = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.animateCameraViewShrinking = false
            withAnimation(.easeInOut(duration: 0.2)) {
                self.makeCameraViewTranslucent = false
            }
        }
    }
}
