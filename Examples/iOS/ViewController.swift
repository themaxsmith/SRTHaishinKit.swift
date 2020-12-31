import UIKit

import SRTHaishinKit
import AVFoundation
import VideoToolbox
final class ViewController: UIViewController {
    
    
    func status(_ isConnected: Bool) {
     print("is Connected", isConnected)
    }
    
    @IBOutlet private weak var hkView: GLHKView?

    private var connection: SRTConnection!
    private var srtStream: SRTStream!

    private var currentPosition: AVCaptureDevice.Position = .back

    override func viewDidLoad() {
        super.viewDidLoad()

        connection = .init()
        srtStream = SRTStream(connection)
        srtStream.captureSettings = [
            "sessionPreset": AVCaptureSession.Preset.hd1920x1080.rawValue,
            "continuousAutofocus": true,
            "continuousExposure": true,
            "fps": 30, // def=30
        ]
      
        srtStream.videoSettings = [
            "width": 1920,
            "height": 1080,
            "profileLevel": kVTProfileLevel_H264_High_AutoLevel,
            "maxKeyFrameIntervalDuration": 2.0, // 2.0
            "bitrate": 5 * 1024, // Average

        ]
       
        
  
        
       //connection!.connect(URL(string: "srt://134.209.120.63:10080?streamid=#!::h=live/livestream,m=publish"))
   
    
         //   self.srtStream.videoSettings[.bitrate] = 1 * 1000000 // video output bitrate
      
    }

    override func viewWillAppear(_ animated: Bool) {
       // setupCamera()
        super.viewWillAppear(animated)
        srtStream.attachAudio(AVCaptureDevice.default(for: .audio)) { _ in
            // logger.warn(error.description)
        }
        srtStream.attachCamera(DeviceUtil.device(withPosition: currentPosition)) { _ in
            // logger.warn(error.description)
        }
     //   srtStream.attachCamera(nil)
        hkView?.attachStream(srtStream)
        
//        if #available(iOS 13.0, *) {
//            let timer = Timer.scheduledTimer(withTimeInterval:0.0333333, repeats: true) { timer in
//                self.runClock()
//            }
//        } else {
//            // Fallback on earlier versions
//        }
    }
    
  

    
    @IBOutlet weak var streamToggle: UIButton!
    //handle situations
    @IBAction func streamToggleBTN(_ sender: Any) {
        streamToggle.setTitle( !connection.connected ? "Stop Broadcast" : "Start Broadcast", for: .normal)
        
        if (!connection.connected){
            
        srtStream.publish("hoge")
        connection!.attachStream(srtStream)
            
         
         connection!.connect(URL(string: "srt://sf-1.ingest.seasoncast.com:1936?streamid=uplive.sls.com/live/event_fgWvEMOJfqH8?email=max@themaxsmith.com,key=r08f5S4yV0KM"))
        
            
        }else{
            srtStream.close()
            connection.close()
        }
        
        
    }
    
    
    //output camera data in class
    
    

    

       
}
extension CGImage {
    func getCVPixelBuffer() -> CVPixelBuffer? {
        let image = self
        let imageWidth = Int(image.width)
        let imageHeight = Int(image.height)
        
        let attributes : [NSObject:AnyObject] = [
            kCVPixelBufferCGImageCompatibilityKey : true as AnyObject,
            kCVPixelBufferCGBitmapContextCompatibilityKey : true as AnyObject
        ]
        
        var pxbuffer: CVPixelBuffer? = nil
        CVPixelBufferCreate(kCFAllocatorDefault,
                            imageWidth,
                            imageHeight,
                            kCVPixelFormatType_32ARGB,
                            attributes as CFDictionary?,
                            &pxbuffer)
        
        if let _pxbuffer = pxbuffer {
            let flags = CVPixelBufferLockFlags(rawValue: 0)
            CVPixelBufferLockBaseAddress(_pxbuffer, flags)
            let pxdata = CVPixelBufferGetBaseAddress(_pxbuffer)
            
            let rgbColorSpace = CGColorSpaceCreateDeviceRGB();
            let context = CGContext(data: pxdata,
                                    width: imageWidth,
                                    height: imageHeight,
                                    bitsPerComponent: 8,
                                    bytesPerRow: CVPixelBufferGetBytesPerRow(_pxbuffer),
                                    space: rgbColorSpace,
                                    bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
            
            if let _context = context {
                _context.draw(image, in: CGRect.init(x: 0, y: 0, width: imageWidth, height: imageHeight))
            }
            else {
                CVPixelBufferUnlockBaseAddress(_pxbuffer, flags);
                return nil
            }
            
            CVPixelBufferUnlockBaseAddress(_pxbuffer, flags);
            return _pxbuffer;
        }
        
        return nil
    }
}
