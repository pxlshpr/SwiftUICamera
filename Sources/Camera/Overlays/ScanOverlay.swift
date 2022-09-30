import SwiftUI
import SwiftHaptics
import AVKit

struct ScanOverlay: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    let animationSingleRunTime = 1.5
    @State var lineY: CGFloat = 0
    
    var body: some View {
        scannerOverlayView
    }
    
    var scannerOverlayView: some View {
        ZStack {
            GeometryReader { proxy in
                Group {
                    LinearGradient(gradient: Gradient(colors: [Color.accentColor.opacity(0.0), .accentColor, Color.accentColor.opacity(0.0)]), startPoint: .top, endPoint: .bottom)
                        .position(x: proxy.size.width/2.0, y: lineY)
                        .frame(width: proxy.size.width, height: 30)
                }
                .animation(Animation.easeInOut(duration: animationSingleRunTime).repeatForever(autoreverses: true), value: lineY)
                .onAppear {
                    lineY = lineY == 0 ? proxy.size.height : 0
                }
            }
//            barcodeButtonLayer
        }
    }
    
    var barcodeButtonLayer: some View {
        VStack {
            Spacer()
            HStack {
                global_button(action: {
                    presentationMode.wrappedValue.dismiss()
                } , image: "xmark.circle.fill", alwaysDarkShadow: true)
                Spacer()
                global_button(action: {
                    Haptics.feedback(style: .rigid)
                    //                    Haptics.shared.complexSuccess()
                    toggleTorch()
                }, image: "flashlight.on.fill", alwaysDarkShadow: true)
            }
            Spacer().frame(height: 30.0)
        }
        .padding()
    }
    
    func global_button(action: (() -> Void)? = nil, image: String, alwaysDarkShadow: Bool = false) -> some View {
        Group {
            if image.contains("circle.fill") {
                Button(action: { action?() }) {
                    Image(systemName: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 55, height: 55)
                        .foregroundColor(Color.accentColor)
                        .background(Color(.systemBackground))
                        .clipShape(Circle())
                        .shadow(color: alwaysDarkShadow ? Color.red : Color.blue, radius: 2, x: 0, y: 1)
    //                    .shadow(color: alwaysDarkShadow ? Color("ShadowDark") : Color("ShadowColor"), radius: 2, x: 0, y: 1)
                }
            } else {
                Button(action: { action?() }) {
                    ZStack {
                        Circle()
                            .frame(width: 55, height: 55)
                            .foregroundColor(Color.accentColor)
                            .clipShape(Circle())
                            .shadow(color: alwaysDarkShadow ? Color.red : Color.blue, radius: 2, x: 0, y: 1)
    //                        .shadow(color: alwaysDarkShadow ? Color("ShadowDark") : Color("ShadowColor"), radius: 2, x: 0, y: 1)
                        Image(systemName: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 28, height: 28)
                            .foregroundColor(Color(.systemBackground))
                    }
                }
                
            }
        }
    }
    
    func toggleTorch() {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                
                switch device.torchMode {
                case .on : device.torchMode = .off
                case .off : device.torchMode = .on
                default: device.torchMode = .on
                }
                
                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        } else {
            print("Torch is not available")
        }
    }
}
