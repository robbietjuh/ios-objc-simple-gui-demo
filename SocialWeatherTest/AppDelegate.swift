//
//  AppDelegate.swift
//  SocialWeatherTest
//
//  Created by R. de Vries on 04-06-16.
//  Copyright © 2016 R. de Vries. All rights reserved.
//

import UIKit
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        return true
    }
    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        let fullUrl = url.absoluteString.componentsSeparatedByString("//")
        let token = fullUrl[1]

        SWApiClient.login(token) { result in
            switch result {
            case .Success(let json):
                let response = json as! NSDictionary
                if response.objectForKey("success") as! Bool {
                    let defaults = NSUserDefaults.standardUserDefaults()
                    defaults.setObject(response.objectForKey("data"), forKey: "userDetails")
                    
                    NSNotificationCenter.defaultCenter().postNotificationName("loginSucceedNotification", object: self)
                }
                else {
                    print("Token does not exist");
                }
                break
                
            case .Failure(_, _):
                print("failure")
            }
        }
        
        return true
    }
    
    /**
    *
    * Get the user details if saved
    */
    func getUserDetails() -> JSON{
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let userDetails = defaults.dictionaryForKey("userDetails") {
            return JSON(userDetails)
        }
        return nil
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

