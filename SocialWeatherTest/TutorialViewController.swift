//
//  TutorialViewController.swift
//  SocialWeatherTest
//
//  Created by R. de Vries on 09-06-16.
//  Copyright © 2016 R. de Vries. All rights reserved.
//

import UIKit

class TutorialViewController : UIViewController, UIScrollViewDelegate {
    
    // These are variables for the live phone demo view
    @IBOutlet weak var phoneContainerView: UIView!
    @IBOutlet weak var phoneScrollView: UIScrollView!
    @IBOutlet weak var phoneTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var phoneView: UIView!
    
    @IBOutlet weak var contentScrollView: UIScrollView!
    
    private var demoController : PhotoViewController?
    
    override func viewDidLoad() {
        // Set up the phone scroll view so that it is scaled
        self.phoneScrollView.delegate = self
        self.phoneScrollView.minimumZoomScale = 0.1
        self.phoneScrollView.maximumZoomScale = 4.0
        self.phoneScrollView.tag = 1337
        self.phoneScrollView.zoomScale = 0.833333
        
        // Set up the content scroll view
        self.contentScrollView.tag = 420
        self.contentScrollView.contentSize = CGSizeMake(2800, 200)
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        // Only allow zooming on the phone container
        return scrollView.tag == 1337 ? self.phoneContainerView : nil
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // Calculate the offset percentage in the X axis
        let offset = scrollView.contentOffset.x
        let offsetPercentage = offset / self.view.bounds.width
        
        // Show the phone
        if offsetPercentage <= 1 {
            let offsetTop = self.view.bounds.height - (offsetPercentage * (self.view.bounds.height - 140))
            self.phoneTopConstraint.constant = offsetTop
        }
        
        // Scroll through the comments
        if offsetPercentage > 1 && offsetPercentage <= 2 {
            let contentOffset = min(offsetPercentage - 1, 1) * self.demoController!.userDetailView.frame.origin.y
            self.demoController!.scrollView.contentOffset = CGPointMake(0, contentOffset)
        }
        
        // Hide the comments
        if offsetPercentage > 2 && offsetPercentage <= 3 {
            let contentOffset = (1 - min(offsetPercentage - 2, 1)) * self.demoController!.userDetailView.frame.origin.y
            self.demoController!.scrollView.contentOffset = CGPointMake(0,contentOffset)
        }
        
        // Hide the phone
        if offsetPercentage > 3 {
            let offsetTop = ((offsetPercentage - 3) * (self.view.bounds.height - 140))
            self.phoneTopConstraint.constant = 140 + offsetTop
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Safely get the controller
        guard let controller = segue.destinationViewController as? PhotoViewController else {
            // This is not a PhotoViewController so it must be part of the tutorial fragments
            // We need to clear their background views here
            segue.destinationViewController.view.backgroundColor = UIColor.clearColor()
            return
        }
        
        // Save the demo controller into the local variables
        self.demoController = controller
    }
    
}