//
//  CameraViewController.swift
//  SocialWeatherTest
//
//  Created by R. de Vries on 04-06-16.
//  Copyright © 2016 R. de Vries. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation
import M13Checkbox

class CameraViewController : DismissableViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var switchButton: UIButton!
    @IBOutlet weak var picture: UIImageView!
    
    @IBOutlet weak var weatherScrollView: UIScrollView!
    @IBOutlet weak var labelTemperature: UILabel!
    @IBOutlet weak var labelInstruction: UILabel!
    @IBOutlet weak var labelConditionsSunny: UILabel!
    @IBOutlet weak var labelConditionsCloudy: UILabel!
    @IBOutlet weak var labelConditionsRainy: UILabel!
    @IBOutlet weak var labelConditionsFoggy: UILabel!
    @IBOutlet weak var labelConditionsThunder: UILabel!
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    let delegate = UIApplication.sharedApplication().delegate as? AppDelegate
    
    // Initialize a location manager for GPS coords
    let locationManager = CLLocationManager()
    
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
    var location : CLLocationCoordinate2D?
    var imageData : NSData?
    let shutter = AVCaptureStillImageOutput()
    
    // MARK: - View setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add a gesture recognizer for dismissing the view
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(self.handleDismissablePanGesture(_:)))
        self.view.addGestureRecognizer(gesture)
        
        // Set up a gesture recognizer for making a photo
        let gesture2 = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.view.addGestureRecognizer(gesture2)
        
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
    }
    
    override func viewDidAppear(animated: Bool) {
        // We'll have to take care of privacy settings, so let's check wether any devices were found
        guard self.devices.count > 0 else {
            return self.dismissViewControllerWithMessage("No camera found", message: "We could not get access to a camera. Please check your privacy settings in the Settings app.")
        }
        
        // Get the current location. We cant' do this in the viewDidLoad method because of the way
        // permissions are handled by the location manager. We can adjust for privacy settings in the
        // didFailWithError method as listed way below this file.
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func dismissViewControllerWithMessage(title: String, message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (alert) in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        self.presentViewController(alert, animated: false, completion: nil)
    }
    
    // MARK: - GPS location handlers
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        // Something went wrong, probs because of privacy issues
        self.locationManager.delegate = nil
        self.dismissViewControllerWithMessage("Location issues", message: "We could not get your current location. Please check your privacy settings in the Settings app.")
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        // Stop updating the location
        self.locationManager.stopUpdatingLocation()
        
        // Save the location
        self.location = newLocation.coordinate
        
        // Check wether we're waiting for the photo to upload
        if self.currentStep == 2 {
            // We are. Just call the upload handler, it'll take care of the rest. 
            // Don't animate any of the labels and stuff in; if the upload process
            // takes shorter than the animation process, that can potentially result
            // in weird view behaviours.
            self.uploadPicture()
        }
        else {
            // Get the current weather
            OWMApiClient.currentWeatherByCoordinates(self.location!, success: { (city, temp) in
                // Put the city and weather details into the views
                self.labelConditionsSunny.text = "Sunny \(city)".uppercaseString
                self.labelConditionsCloudy.text = "Cloudy \(city)".uppercaseString
                self.labelConditionsRainy.text = "Rainy \(city)".uppercaseString
                self.labelConditionsFoggy.text = "Foggy \(city)".uppercaseString
                self.labelConditionsThunder.text = "Thunder \(city)".uppercaseString
                self.labelTemperature.text = "\(temp)°"
                
                // Show the views
                UIView.animateWithDuration(0.6, animations: {
                    self.labelTemperature.alpha = 1
                    self.weatherScrollView.alpha = 1
                })
            }) { (errorMessage) in
                self.dismissViewControllerWithMessage("Location issues", message: "We could not get the weather for your current location. \(errorMessage)")
            }
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
        guard let camera = devices[safe: nextCamera] as? AVCaptureDevice else {
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
        self.currentStep = self.currentStep + 1
        
        switch self.currentStep {
        case 1:
            // Try to safely get the output connection
            if(self.shutter.connections.count != 1) { return }
            guard let connection = self.shutter.connections[0] as? AVCaptureConnection else { return }
        
            // Now capture whatever is on that connection as an image
            self.shutter.captureStillImageAsynchronouslyFromConnection(connection) { (buffer: CMSampleBuffer!, error: NSError!) in
                self.imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
                let image = UIImage(data: self.imageData!)
            
                // And display it to the user
                self.picture.image = image
                self.picture.hidden = false
            }
        
            // Hide layers that we do not need now
            self.currentPreview.hidden = true
            self.switchButton.hidden = true
            
            // Update the instruction text
            self.labelInstruction.text = "Swipe to customize, tap to upload"
            
        case 2:
            // Animate fade-in for the blur view
            UIView.animateWithDuration(0.4, animations: {
                self.loadingView.hidden = false
                self.loadingView.alpha = 1
            }, completion: { (Bool) in
                // We don't want to do the uploading in this function, we want to hand it
                // off to another function. That is because of the speed of GPS. If GPS is
                // slow to respond, we want to wait for the GPS handler to complete. If it
                // completes, it'll call the same function. That way, we don't have to
                // have redundant pieces of code.
                self.uploadPicture()
            })
            
        default:
            self.currentStep = self.currentStep - 1
            NSLog("CameraViewController is in an unknown state (\(self.currentStep)).")
        }
    }
    
    func uploadPicture() {
        // Safely get the variables we need
        guard let location = self.location,
              let picture = self.imageData
              else {
                  return
              }
        
        let weatherType = self.weatherScrollView.contentOffset.x / self.weatherScrollView.frame.size.width
        
        // TODO: Send location, picture and weatherType to the remote api server.
        // The remote server will resolve the temperature and name of the place again
        // so we won't have to send that. Lat/lon will suffice.
        NSLog("Upload to server")
        SWApiClient.uploadImage((delegate?.getToken())!, image: picture, lat: location.latitude, lon: location.longitude, weather_type: weatherType){ result in
            switch result {
            case .Success(let json):
                let response = json as! NSDictionary
                if response.objectForKey("success") as! Bool {
                    print(response)
                }
                else {
                    print("else")
                    print(response)
                }
                break
                
            case .Failure(_, _):
                print("fail")
            }
        }
        
    
        // Show an animated checkbox on completion
        UIView.animateWithDuration(0.4, animations: {
            self.activityIndicator.alpha = 0
        }) { (Bool) in
            self.activityIndicator.stopAnimating()
            
            let checkbox = M13Checkbox(frame: CGRectMake(self.view.bounds.width / 2 - 60, self.view.bounds.height / 2 - 60, 120, 120))
            
            checkbox.tintColor = UIColor.whiteColor()
            checkbox.secondaryTintColor = UIColor.clearColor()
            checkbox.animationDuration = 0.4
            
            self.loadingView.addSubview(checkbox)
            
            checkbox.setCheckState(.Checked, animated: true)
            
            // Schedule a timer to finish the upload/animation
            NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(self.finishUploadPicture), userInfo: 0, repeats: false)
        }
    }
    
    func finishUploadPicture(timer: NSTimer) {
        // Dismiss the view
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
