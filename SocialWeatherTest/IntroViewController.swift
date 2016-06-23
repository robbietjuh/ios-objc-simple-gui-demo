//
//  IntroViewController.swift
//  SocialWeatherTest
//
//  Created by R. de Vries on 04-06-16.
//  Copyright © 2016 R. de Vries. All rights reserved.
//

import UIKit

class IntroViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    private var interactor:Interactor = Interactor()
    let delegate = UIApplication.sharedApplication().delegate as? AppDelegate
    
    // MARK: - View setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if (self.delegate!.getToken() != "") {
            return true
        }
        else {
            let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("TutorialViewController")
            self.presentViewController(controller, animated: true, completion: nil)
            return false
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destViewController = segue.destinationViewController as? DismissableViewController {
            // This is a transition to the PhotoViewController view, so we'll have to inject
            // ourselves as the transitioning delegate and the interactor as a shared interactor.
            // The key "TransitionToPhotoViewController" is set in the Storyboard.
            destViewController.transitioningDelegate = self
            destViewController.interactor = self.interactor
        }
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimator()
    }
    
    func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.interactor.hasStarted ? self.interactor : nil
    }
    
}