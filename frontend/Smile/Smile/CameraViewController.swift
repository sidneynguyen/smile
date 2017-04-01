//
//  CameraViewController.swift
//  Smile
//
//  Created by Luke Brody on 4/1/17.
//  Copyright © 2017 Luke Brody. All rights reserved.
//

import UIKit
import AVFoundation
import AFNetworking

class CameraViewController : UIViewController, AVCapturePhotoCaptureDelegate {
    
    let (session, photoCapture) : (AVCaptureSession, AVCapturePhotoOutput) = {
        let session = AVCaptureSession()
        
        let camera = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .front)
        
        let input = try! AVCaptureDeviceInput(device: camera)
        
        session.addInput(input)
        
        let output = AVCapturePhotoOutput()
        
        output.isHighResolutionCaptureEnabled = true
        
        session.addOutput(output)
        
        return (session, output)
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        session.startRunning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        session.stopRunning()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layer = AVCaptureVideoPreviewLayer(session: session)!
        view.layer.addSublayer(layer)
        
        layer.frame = view.layer.bounds
    }
    
    @IBAction func takePhoto(_ sender: UIButton) {
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecJPEG])
        settings.isHighResolutionPhotoEnabled = true
        photoCapture.capturePhoto(with: settings, delegate: self)
    }
    
    let manager = AFHTTPSessionManager(baseURL: site)
    
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        /*let imageBuffer = CMSampleBufferGetImageBuffer(photoSampleBuffer!)!
        let gpuImage = CIImage(cvImageBuffer: imageBuffer)
        let image = UIImage(ciImage: gpuImage)
        
        //do something with image
        let jpeg = UIImageJPEGRepresentation(image, 0.9)!*/
        
        let jpeg = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer!, previewPhotoSampleBuffer: nil)!
        
        manager.post("/api/posts", parameters: nil, constructingBodyWith: {formData in
            formData.appendPart(withFileData: jpeg, name: "file", fileName: "file", mimeType: "image/jpg")
            formData.appendPart(withForm: "0".data(using: .utf8)!, name: "num_faces")
            formData.appendPart(withForm: UUID().uuidString.data(using: .utf8)!, name: "uid")
            formData.appendPart(withForm: UUID().uuidString.data(using: .utf8)!, name: "uuid")
        }, success: { (_, _) in
            print("success :)")
        }) { (_, error) in
            print("failure :( error=\(error)")
        }
        
    }
    
}
