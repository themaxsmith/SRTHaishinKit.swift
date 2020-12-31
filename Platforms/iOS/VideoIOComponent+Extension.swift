import AVFoundation

extension VideoIOComponent {
    var zoomFactor: CGFloat {
        guard let device: AVCaptureDevice = (input as? AVCaptureDeviceInput)?.device else {
            return 0
        }
        return device.videoZoomFactor
    }

    func setZoomFactor(_ zoomFactor: CGFloat, ramping: Bool, withRate: Float) {
        guard let device: AVCaptureDevice = (input as? AVCaptureDeviceInput)?.device,
            1 <= zoomFactor && zoomFactor < device.activeFormat.videoMaxZoomFactor
            else { return }
        do {
            try device.lockForConfiguration()
            if ramping {
                device.ramp(toVideoZoomFactor: zoomFactor, withRate: withRate)
            } else {
                device.videoZoomFactor = zoomFactor
            }
            device.unlockForConfiguration()
        } catch let error as NSError {
            logger.error("while locking device for ramp: \(error)")
        }
    }


}

extension VideoIOComponent: ScreenCaptureOutputPixelBufferDelegate {
    // MARK: ScreenCaptureOutputPixelBufferDelegate
    func didSet(size: CGSize) {
        lockQueue.async {
            self.encoder.width = Int32(size.width)
            self.encoder.height = Int32(size.height)
        }
    }

    func output(pixelBuffer: CVPixelBuffer, withPresentationTime: CMTime) {
        if !effects.isEmpty {
            context?.render(effect(pixelBuffer, info: nil), to: pixelBuffer)
        }
        encoder.encodeImageBuffer(
            pixelBuffer,
            presentationTimeStamp: withPresentationTime,
            duration: CMTime.invalid
        )
        mixer?.recorder.appendPixelBuffer(pixelBuffer, withPresentationTime: withPresentationTime)
    }
}
