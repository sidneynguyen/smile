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
        layer.zPosition = -0.01
    }
    
    @IBAction func takePhoto(_ sender: UIButton) {
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecJPEG])
        settings.isHighResolutionPhotoEnabled = true
        photoCapture.capturePhoto(with: settings, delegate: self)
    }
    
    let manager = AFHTTPSessionManager(baseURL: site)
    
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        let jpeg = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer!, previewPhotoSampleBuffer: nil)!
        
        let client = MPOFaceServiceClient(subscriptionKey: "a154bd9a80564b6da75920a78c537d59")
        
        client?.detect(with: jpeg, returnFaceId: true, returnFaceLandmarks: true, returnFaceAttributes: [NSNumber(value: MPOFaceAttributeTypeSmile.rawValue)], completionBlock: { (faces, error) in
            if let faces = faces {
                
                print("Found \(faces.count) faces")
                
                self.manager.post("/api/posts", parameters: nil, constructingBodyWith: {formData in
                    formData.appendPart(withFileData: jpeg, name: "file", fileName: "file", mimeType: "image/jpg")
                    formData.appendPart(withForm: "0".data(using: .utf8)!, name: "num_faces")
                    formData.appendPart(withForm: UUID().uuidString.data(using: .utf8)!, name: "uid")
                    formData.appendPart(withForm: UUID().uuidString.data(using: .utf8)!, name: "uuid")
                }, success: { (_, _) in
                    print("success :)")
                }) { (_, error) in
                    print("failure :( error=\(error)")
                }
            } else {
                print(error ?? "unknown error")
            }
        })
        
        
        
    }
    
}
