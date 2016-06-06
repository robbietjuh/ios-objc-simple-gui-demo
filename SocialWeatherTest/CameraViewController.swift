//
//  CameraViewController.swift
//  SocialWeatherTest
//
//  Created by R. de Vries on 04-06-16.
//  Copyright © 2016 R. de Vries. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController : DismissableViewController {
    
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var switchButton: UIButton!
    @IBOutlet weak var picture: UIImageView!
    
    @IBOutlet weak var weatherScrollView: UIScrollView!
    
    // Set up a new AVCaptureSession instance
    let session = AVCaptureSession()
    
    // We want the user to be able to take a selfie too. In order to achieve that, we'll have
    // to request all device capture devices that can capture video (note: if you don't filter
    // the output from `devices()` you will also get the microphone back). Later on, we can check
    // the amount of cameras found in order to determine wether or not the user may be able
    // to also take a selfie.
    let devices = AVCaptureDevice.devices().filter{ $0.hasMediaType(AVMediaTypeVideo) }
    
    // These will hold the current states of the controller and devices
    var currentCamera : AVCaptureDevice?
    var currentDevice = -1
    var currentInput : AVCaptureInput?
    var currentPreview = AVCaptureVideoPreviewLayer()
    var currentStep = 0
    let shutter = AVCaptureStillImageOutput()
    
    // MARK: - View setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add a gesture recognizer for dismissing the view
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(self.handleDismissablePanGesture(_:)))
        self.view.addGestureRecognizer(gesture)
        
        
        // First, make sure we actually have access to capture devices
        guard self.devices.count > 0 else {
            return
        }
        
        // Create a new capture session in order to interact with the device cameras
        self.session.sessionPreset = AVCaptureSessionPresetHigh
        
        // Create a new StillImageOutput object in order to be able to capture an image
        self.shutter.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        self.session.addOutput(shutter)
        
        // Set up a preview layer
        self.currentPreview.session = self.session
        self.currentPreview.frame = self.view.layer.frame
        self.previewView.layer.addSublayer(self.currentPreview)
        self.session.startRunning()
        
        // Switch to the first camera
        self.switchCameras()
        
        let gesture2 = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.view.addGestureRecognizer(gesture2)
    }
    
    override func viewDidAppear(animated: Bool) {
        // We'll have to take care of privacy settings, so let's check wether any devices were found
        guard self.devices.count > 0 else {
            let alert = UIAlertController(title: "No camera found",
                                          message: "We could not get access to a camera. Please check your privacy settings in the Settings app.",
                                          preferredStyle: .Alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: {(alert) in
                self.dismissViewControllerAnimated(true, completion: nil)
            }))
            
            self.presentViewController(alert, animated: false, completion: nil)
            
            return
        }
    }
    
    // MARK: - Camera interaction
    
    @IBAction func switchCameras() -> Void {
        // Get the next camera index
        var nextCamera = self.currentDevice + 1
        if nextCamera >= devices.count {
            nextCamera = 0
        }
        
        // Request the camera instance from our devices array
        guard let camera = devices[nextCamera] as? AVCaptureDevice else {
            return
        }
        
        // Remove the current input, if any
        if self.currentInput != nil {
            self.session.removeInput(self.currentInput!)
        }
        
        // Set up a new input based on the camera that we found
        do {
            self.currentInput = try AVCaptureDeviceInput(device: camera)
            self.session.addInput(self.currentInput)
            self.currentDevice = nextCamera
        }
        catch _ {
            NSLog("Could not set up a new camera")
        }
    }
    
    func handleTap(action: AnyObject!) {
        // Make sure to be in the very first step of taking a photo
        guard self.currentStep == 0 else { return }
        self.currentStep = 1
        
        // Try to safely get the output connection
        if(self.shutter.connections.count != 1) { return }
        guard let connection = self.shutter.connections[0] as? AVCaptureConnection else { return }
        
        // Now capture whatever is on that connection as an image
        self.shutter.captureStillImageAsynchronouslyFromConnection(connection) { (buffer: CMSampleBuffer!, error: NSError!) in
            let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
            let image = UIImage(data: imageData)
            
            // And display it to the user
            self.picture.image = image
            self.picture.hidden = false
        }
        
        // Hide layers that we do not need now
        self.currentPreview.hidden = true
        self.switchButton.hidden = true
    }
    
}
