//
//  PagedViewController.swift
//  SocialWeatherTest
//
//  Created by R. de Vries on 05-06-16.
//  Copyright © 2016 R. de Vries. All rights reserved.
//

import UIKit

class PagedViewController : UIPageViewController, UIPageViewControllerDataSource {
    
    var data = [["temp": 20], ["temp": 20], ["temp": 20], ["temp": 20], ["temp": 20], ["temp": 20]]
    let introController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("IntroViewController")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the data source to be ourselves
        self.dataSource = self
        
        // Set up the intro view controller. Other view controllers will get added dynamically through the delegate
        self.introController.view.tag = 0
        setViewControllers([self.introController],
                           direction: .Forward,
                           animated: true,
                           completion: nil)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let token = defaults.stringForKey("token")
        SWApiClient.getPosts(token) { result in
            switch result {
            case .Success(let json):
                let response = json as! NSDictionary
                print("\(response)")
                break 
                
            case .Failure(_, _):
                print("fail")
            }
        }
        
        // TODO: Do something with self.data here (fetch the data asap, maybe use some locally cached stuff first)
    }
    
    override func viewDidAppear(animated: Bool) {
        // Show the tutorial for the very first time. This should be moved
        // to the loading view in the future
        let defaults = NSUserDefaults.standardUserDefaults()
        if (defaults.objectForKey("firstLaunch") == nil) {
            let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("TutorialViewController")
            self.presentViewController(controller, animated: true, completion: nil)
            defaults.setObject("1", forKey: "firstLaunch")
        }
    }
    
    func controllerForIndex(index: Int) -> UIViewController? {
        // Check wether we have data for that view and if so, create the view controller
        guard let nextData = self.data[safe: index - 1],
              let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("PhotoViewController") as? PhotoViewController
              else {
            return nil
        }
        
        // Pass the retrieved data to that controller
        controller.data = nextData
        controller.view.tag = index
        
        // Return the controller
        return controller
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        // Return the next controller
        return self.controllerForIndex(viewController.view.tag + 1)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        // Return the IntroViewController if we're at page 0, otherwise fetch the previous controller
        return viewController.view.tag - 1 == 0
            ? self.introController
            : self.controllerForIndex(viewController.view.tag - 1)
    }
    
}
