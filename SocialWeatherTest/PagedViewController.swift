//
//  PagedViewController.swift
//  SocialWeatherTest
//
//  Created by R. de Vries on 05-06-16.
//  Copyright © 2016 R. de Vries. All rights reserved.
//

import UIKit

class PagedViewController : UIPageViewController, UIPageViewControllerDataSource {
    
    var data = NSMutableArray()
    let introController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("IntroViewController")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PagedViewController.getPosts), name: "newUploadedImage", object: nil)
        
        // Set up the data source to be ourselves
        self.dataSource = self
        
        // Set up the intro view controller. Other view controllers will get added dynamically through the delegate
        self.introController.view.tag = 0
        setViewControllers([self.introController],
                           direction: .Forward,
                           animated: true,
                           completion: nil)
        
        self.getPosts()
        
    }
    
    func getPosts(){
        let defaults = NSUserDefaults.standardUserDefaults()
        let token = defaults.stringForKey("token")
        
        SWApiClient.getPosts(token) { result in
            switch result {
            case .Success(let json):
                let _posts = NSMutableArray()
                
                let response_root = json as! NSDictionary
                let response = response_root.objectForKey("data") as! NSDictionary
                
                // Get all components
                let users = response.objectForKey("users") as! NSDictionary
                let photos = response.objectForKey("photos") as! NSDictionary
                let posts = response.objectForKey("posts") as! NSArray
                let comments = response.objectForKey("comments") as! NSDictionary
                
                for post in posts {
                    // Fetch image url
                    let photo_id = "\(post.objectForKey("photo_id") as! Int)"
                    let photo_obj = photos.objectForKey(photo_id) as! NSDictionary
                    let photo_url = photo_obj.objectForKey("image") as! String
                    
                    // Fetch user
                    let user_id = "\(post.objectForKey("user_id") as! Int)"
                    let user_obj = users.objectForKey(user_id) as! NSDictionary
                    
                    // Fetch comments
                    var comment_objs = comments[photo_id] as? NSArray
                    if comment_objs == nil {
                        comment_objs = []
                    }
                    
                    print("Comments for \(photo_id): \(comment_objs) \(post)")
                    
                    // Put it together
                    let _post = NSMutableDictionary(dictionary: post as! [String : AnyObject])
                    _post.setObject(photo_url, forKey: "photo_url")
                    _post.setObject(user_obj, forKey: "user")
                    _post.setObject(comment_objs!, forKey: "comments")
                    _posts.addObject(_post)
                }
                
                self.data = _posts
                
                if(_posts.count > 0) {
                    self.fetchNextPicture(0)
                }
                
                break
                
            case .Failure(_, _):
                print("err!")
            }
        }
    }
    
    func fetchNextPicture(index: Int) {
        if index >= self.data.count {
            return
        }
        
        let url = NSURL(string: self.data.objectAtIndex(index)["photo_url"] as! String)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let data = NSData(contentsOfURL: url!)
            dispatch_async(dispatch_get_main_queue(), {
                print("Updating image data for index \(index)")
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "update_picture", object: nil))
                self.data.objectAtIndex(index).setObject(data!, forKey: "image")
                self.fetchNextPicture(index + 1)
            });
        }
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
        if index > self.data.count || index < 0 {
            return nil;
        }
        
        let nextData = self.data.objectAtIndex(index - 1)
        
        guard let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("PhotoViewController") as? PhotoViewController
            else {
                return nil
        }
        
        // Pass the retrieved data to that controller
        controller.data = nextData as? [String : AnyObject]
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