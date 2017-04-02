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
import FBSDKLoginKit

class CameraViewController : UIViewController, AVCapturePhotoCaptureDelegate {
    
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var smileCounter: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    
    
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
        if !hasCaptured {
            session.startRunning()
        }
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
        
        hasCaptured = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //If the view loads and we're not logged in, open the login view
        if !loggedIn {
            let loginViewController = storyboard!.instantiateViewController(withIdentifier: "LoginViewController")
            DispatchQueue.main.async {self.showDetailViewController(loginViewController, sender: self)}
        }
    }
    
    var loggedIn : Bool {
        
        userID = FBSDKAccessToken.current()?.userID
        
        return userID != nil
    }
    
    @IBAction func takePhoto(_ sender: UIButton) {
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecJPEG])
        settings.isHighResolutionPhotoEnabled = true
        photoCapture.capturePhoto(with: settings, delegate: self)
        hasCaptured = true
    }
    
    let manager = AFHTTPSessionManager(baseURL: site)
    
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        let jpeg = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer!, previewPhotoSampleBuffer: nil)!
        
        self.capturedImageJPEG = jpeg
        
        view.layer.contents = UIImage(data: jpeg)!.cgImage!
        
        let client = MPOFaceServiceClient(subscriptionKey: "a154bd9a80564b6da75920a78c537d59")
        
        client?.detect(with: jpeg, returnFaceId: true, returnFaceLandmarks: true, returnFaceAttributes: [NSNumber(value: MPOFaceAttributeTypeSmile.rawValue)], completionBlock: { (faces, error) in
            if let faces = faces {
                
                let smiling = faces.filter {$0.attributes.smile.doubleValue > 0.5}
                
                self.numFaces = smiling.count
                
                self.smileCounter.text = "\(self.numFaces!) smiles!"
                
                //if no smiles, exit captured mode
                if smiling.count < 2 {
                    self.hasCaptured = false
                    
                    //show say cheese
                    self.sayCheese.isHidden = false
                }
                
                
            } else {
                print(error ?? "unknown error")
            }
        })
        
        
        
    }
    
    var capturedImageJPEG : Data!
    var numFaces : Int!
    
    @IBOutlet weak var sayCheese: UILabel!
    
    
    func makePost(privacy: String) {
        self.manager.post("/api/posts", parameters: nil, constructingBodyWith: {formData in
            formData.appendPart(withFileData: self.capturedImageJPEG, name: "file", fileName: "file", mimeType: "image/jpg")
            formData.appendPart(withForm: "0".data(using: .utf8)!, name: "num_faces")
            formData.appendPart(withForm: userID.data(using: .utf8)!, name: "uid")
            formData.appendPart(withForm: UUID().uuidString.data(using: .utf8)!, name: "uuid")
            formData.appendPart(withForm: privacy.data(using: .utf8)!, name: "privacy")
        }, success: { (_, _) in
            print("success :)")
        }) { (_, error) in
            print("failure :( error=\(error)")
        }
    }
    
    var hasCaptured : Bool = false {
        didSet {
            
            sayCheese.isHidden = true
            
            smileCounter.text = ""
            
            cancelButton.isHidden = !hasCaptured
            captureButton.isHidden = hasCaptured
            smileCounter.isHidden = !hasCaptured
            
            hasCaptured ? session.stopRunning() : session.startRunning()
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        hasCaptured = false
    }
    
    @IBAction func world(_ sender: Any) {
        if hasCaptured {
            makePost(privacy: "public")
            hasCaptured = false
        } else {
            masterPageViewController.move(to: 0)
        }
    }
    @IBAction func personal(_ sender: Any) {
        if hasCaptured {
            makePost(privacy: "private")
            hasCaptured = false
        } else {
            cameraPageViewController.move(to: 1)
        }
    }
}
