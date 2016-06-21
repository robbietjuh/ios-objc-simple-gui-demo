//
//  LoginViewController.swift
//  SocialWeatherTest
//
//  Created by Amar Tursic on 21/06/16.
//  Copyright © 2016 R. de Vries. All rights reserved.
//

import UIKit
import Alamofire
import M13Checkbox

class LoginViewController : UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var errorTextField: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var container: UIView = UIView()
    var loadingView: UIView = UIView()
    
    //-----------------------------------------------------
    //DONT FORGET TO FILL IN THE BASE URL!
    //-----------------------------------------------------
    var baseUrl: String = ""
    
    override func viewDidLoad() {
        continueButton.enabled = false
    }
    
    @IBAction func emailFieldChanged(sender: AnyObject) {
        if(self.emailField != ""){
            continueButton.enabled = true
        }
    }

    @IBAction func ContinueButtonPressed(sender: AnyObject) {
        authenticateLogin(emailField.text!)
    }
    
    func authenticateLogin(email:String){
        if(email != ""){
            //spinner draaien
            showActivityIndicator(self.view)
            
            //email sturen en kijken of authenticated
            Alamofire.request(.POST, baseUrl+"/api/user/register", parameters: ["email": email])
                .responseJSON { _, _, result in
                    print(result)
                    debugPrint(result)
            }
            
            //spinner stoppen
            hideActivityIndicator(self.view)
            
            continueButton.enabled = false
            
            requestSentView()
            //message returnen: wel/niet ingelogd
        } else {
            errorTextField.text = "Please fill in a correct e-mail."
        }
    }
    
    func requestSentView(){
        let checkbox = M13Checkbox(frame: CGRectMake(self.view.bounds.width / 2 - 60, self.view.bounds.height / 2 - 60, 120, 120))
        
        checkbox.tintColor = UIColor.whiteColor()
        checkbox.secondaryTintColor = UIColor.clearColor()
        checkbox.animationDuration = 0.4
        
        self.view.addSubview(checkbox)
        
        checkbox.setCheckState(.Checked, animated: true)
        
    }
    
    func showActivityIndicator(uiView: UIView) {
        container.frame = uiView.frame
        container.center = uiView.center
        container.backgroundColor = UIColorFromHex(0xffffff, alpha: 0.3)
        
        loadingView.frame = CGRectMake(0, 0, 80, 80)
        loadingView.center = uiView.center
        loadingView.backgroundColor = UIColorFromHex(0x444444, alpha: 0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        activityIndicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        activityIndicator.center = CGPointMake(loadingView.frame.size.width / 2, loadingView.frame.size.height / 2);
        
        loadingView.addSubview(activityIndicator)
        container.addSubview(loadingView)
        uiView.addSubview(container)
        activityIndicator.startAnimating()
    }
    
    func hideActivityIndicator(uiView: UIView) {
        activityIndicator.stopAnimating()
        container.removeFromSuperview()
    }
    
    func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
}