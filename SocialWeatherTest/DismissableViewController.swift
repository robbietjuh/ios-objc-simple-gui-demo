//
//  DismissableViewController.swift
//  SocialWeatherTest
//
//  Created by R. de Vries on 05-06-16.
//  Copyright © 2016 R. de Vries. All rights reserved.
//

import UIKit

class DismissableViewController : UIViewController {
    
    var interactor:Interactor? = nil
    
    @IBAction func handleDismissablePanGesture(sender: UIPanGestureRecognizer!) {
        // Safely get the shared interactor
        guard let interactor = self.interactor else { return }
        
        // Percentage the user has to scroll in order to dismiss the view
        let releaseThreshold = CGFloat(0.3)
        
        // Calculate the percentage of screen real estate the user has 'pulled'
        let position = sender.translationInView(self.view)
        let movement = max(position.y / self.view.bounds.size.height, 0.0)
        let movementPercentage = min(movement, 1.0)
        
        if !interactor.hasStarted && position.y < 1 { return }
        
        // Switch states and handle accordingly
        switch sender.state {
        case .Began:
            interactor.hasStarted = true
            self.dismissViewControllerAnimated(true, completion: nil)
            
        case .Changed:
            interactor.shouldFinish = movementPercentage > releaseThreshold
            interactor.updateInteractiveTransition(movementPercentage)
            
        case .Cancelled:
            interactor.hasStarted = false
            interactor.cancelInteractiveTransition()
            
        case .Ended:
            interactor.hasStarted = false
            interactor.shouldFinish
                ? interactor.finishInteractiveTransition()
                : interactor.cancelInteractiveTransition()
            
        default:
            break
        }
    }
    
}