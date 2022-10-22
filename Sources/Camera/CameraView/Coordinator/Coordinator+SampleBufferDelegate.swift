import AVFoundation
import SwiftUI

extension CameraView.Coordinator: AVCaptureVideoDataOutputSampleBufferDelegate {
        
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        parent.sampleBufferHandler?(sampleBuffer)
    }
    
    public func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        /// `CMSampleBuffers` would be dropped if we take too long in the `didOutput` delegate call. Catch those drop here.
    }
}
