import SwiftUI
import SwiftHaptics

struct CapturedPhotosOverlay: View {
    
    @EnvironmentObject var viewModel: ViewModel
    
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
        if viewModel.capturedImageCount > 0 {
            Button {
                viewModel.tappedCapturedPhotos()
            } label: {
                Image(systemName: "\(viewModel.capturedImageCount).circle.fill")
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

