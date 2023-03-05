import SwiftUI
import SwiftHaptics

struct CapturedPhotosOverlay: View {
    
    @EnvironmentObject var cameraModel: CameraModel
    
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
    
    @ViewBuilder
    var button: some View {
        if cameraModel.capturedImageCount > 0 {
            Button {
                cameraModel.tappedCapturedPhotos()
            } label: {
                Image(systemName: "\(cameraModel.capturedImageCount).circle.fill")
                    .symbolRenderingMode(.palette)
//                    .foregroundStyle(Color.black, Color(.systemGroupedBackground))
//                    .opacity(0.6)
                    .foregroundStyle(Color.white, Color(.systemFill))
                    .font(.system(size: 40))
                    .frame(width: 40, height: 40)
                    .padding(.bottom, 20)
                    .padding(.leading, 40)
                    .padding(.trailing, 9)
                    .background(Color.clear)
                    .contentShape(Rectangle())
            }
        }
    }
}

