import SwiftUI
import SwiftHaptics
import AVKit

struct ConfigOverlay: View {
    
    @EnvironmentObject var cameraModel: CameraModel
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                configButton
                Spacer()
            }
            Spacer()
        }
    }
    
    var allDeviceTypes: [AVCaptureDevice.DeviceType] {
        [.builtInDualCamera, .builtInWideAngleCamera, .builtInDualWideCamera, .builtInTrueDepthCamera, .builtInTelephotoCamera, .builtInUltraWideCamera, .builtInTripleCamera, .builtInLiDARDepthCamera]
    }
    
    var deviceTypes: [AVCaptureDevice.DeviceType] {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: allDeviceTypes,
            mediaType: .video,
            position: .unspecified
        )
        return deviceDiscoverySession.devices.map { $0.deviceType }.uniqued()
    }
    
    var configButton: some View {
        Menu {
            ForEach(deviceTypes, id: \.self) { deviceType in
                Button {
                    cameraModel.config.deviceType = deviceType
                } label: {
                    if cameraModel.config.deviceType == deviceType {
                        Label(deviceType.description, systemImage: "checkmark")
                    } else {
                        Text(deviceType.description)
                    }
                }
            }
            Divider()
            ForEach([AVCaptureDevice.Position.back, AVCaptureDevice.Position.front], id: \.self) { position in
                Button {
                    cameraModel.config.position = position
                } label: {
                    if cameraModel.config.position == position {
                        Label(position == .front ? "Front" : "Back", systemImage: "checkmark")
                    } else {
                        Text(position == .front ? "Front" : "Back")
                    }
                }

            }
        } label: {
            CameraButtonLabel(
                systemImage: .constant("camera.fill.badge.ellipsis"),
                isSelected: .constant(false))
            .padding(.top, 20)
            .padding(.leading, 40)
            .padding(.trailing, 40)
            .background(Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.borderless)
    }
}

extension AVCaptureDevice.DeviceType {
    var description: String {
        rawValue.replacingFirstOccurrence(of: "AVCaptureDeviceType", with: "")
    }
}

import Foundation

extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}
