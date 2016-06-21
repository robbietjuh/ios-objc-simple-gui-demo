//
//  LoginViewController.swift
//  SocialWeatherTest
//
//  Created by Amar Tursic on 21/06/16.
//  Copyright © 2016 R. de Vries. All rights reserved.
//

import UIKit
import M13Checkbox

class LoginViewController : UIViewController, UITextFieldDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        if(!emailTest.evaluateWithObject(textField.text)) {
            let alert = UIAlertController(title: "Invalid e-mail address",
                                          message: "Please enter a valid e-mail address to continue.",
                                          preferredStyle: .Alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
            return false
        }
        
        self.authenticateLogin(textField.text!)
        
        return false
    }
    
    func authenticateLogin(email:String){
        self.activityIndicator.startAnimating()
        self.skipButton.hidden = true
        self.emailField.enabled = false
        
        SWApiClient.register(email) { result in
            switch result {
            case .Success(let json):
                let response = json as! NSDictionary
                if response.objectForKey("success") as! Bool {
                    self.segueSuccessfulRegistration()
                }
                else {
                    self.activityIndicator.startAnimating()
                    self.skipButton.hidden = true
                    self.emailField.enabled = false
                    
                    let alert = UIAlertController(title: "Could not process your registration",
                                                  message: nil,
                                                  preferredStyle: .Alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                break
                
            case .Failure(_, _):
                self.activityIndicator.startAnimating()
                self.skipButton.hidden = true
                self.emailField.enabled = false
                
                let alert = UIAlertController(title: "Could not connect to the remote server",
                                              message: nil,
                                              preferredStyle: .Alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                
                break
            }
        }
    }
    
    func segueSuccessfulRegistration(){
        self.scrollView.scrollRectToVisible(CGRectMake(self.scrollView.frame.width, 0, self.scrollView.frame.width, self.scrollView.frame.height), animated: true)
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        let checkbox = M13Checkbox(frame: CGRectMake(self.view.bounds.width / 2 - 60, self.view.bounds.height / 2 - 100 - 60 - 20, 120, 120))
        
        checkbox.tintColor = UIColor.whiteColor()
        checkbox.secondaryTintColor = UIColor.clearColor()
        checkbox.animationDuration = 0.4
        
        self.view.addSubview(checkbox)
        
        checkbox.setCheckState(.Checked, animated: true)
    }
}