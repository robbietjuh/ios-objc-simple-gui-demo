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
        // Calculate the new offset from the top
        let offset = scrollView.contentOffset.x
        let offsetPercentage = offset / self.view.bounds.width
        let offsetTop = self.view.bounds.height - (min(offsetPercentage, 1) * (self.view.bounds.height - 140))

        self.phoneTopConstraint.constant = offsetTop
        
        // Calculate wether or not to scroll through the comments
        if offsetPercentage > 1 {
            let contentOffset = min(offsetPercentage - 1, 1) * self.demoController!.userDetailView.frame.origin.y
            self.demoController!.scrollView.contentOffset = CGPointMake(0, contentOffset)
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