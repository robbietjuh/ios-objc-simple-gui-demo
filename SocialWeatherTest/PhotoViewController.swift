//
//  PhotoViewController.swift
//  SocialWeatherTest
//
//  Created by R. de Vries on 04-06-16.
//  Copyright © 2016 R. de Vries. All rights reserved.
//

import UIKit

class PhotoViewController: DismissableViewController, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var userDetailView: UIView!
    @IBOutlet weak var blurContainer: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    // MARK: - View setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the scroll view
        let baseFrame = self.view.frame.size
        let detailFrame = self.userDetailView.frame.size
        
        self.scrollView.contentSize = CGSizeMake(baseFrame.width, baseFrame.height * 2 - detailFrame.height)
        self.scrollView.tag = 1337
        self.scrollView.pagingEnabled = true
        self.scrollView.delegate = self
        self.scrollView.panGestureRecognizer.addTarget(self, action: #selector(PhotoViewController.handleDismissablePanGesture(_:)))
    }
    
    // MARK: - Scroll view delegate handlers
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // Make sure its the scrollView that we are processing events for.
        // We don't want to apply blur updates when the user scrolls the tableview,
        // so we assign a tag (1337) in viewDidLoad and check it here.
        if(scrollView.tag != 1337) {
            return
        }
        
        // Get the scroll position
        let offset = scrollView.contentOffset
        
        // Update the alpha layer of the blur container view
        let alpha = min(offset.y / 100.0, 1.0)
        self.blurContainer.alpha = alpha
    }
    
    override func handleDismissablePanGesture(sender: UIPanGestureRecognizer!) {
        // Require the scrollview to be at its top
        if(sender.view != self.scrollView || self.scrollView.contentOffset.y > 0) {
            return
        }
        
        super.handleDismissablePanGesture(sender)
    }
    
    // MARK: - Table view datasource handlers
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 20 : 0 // return 20 demo cells. TODO: have an actual data source handle this
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(indexPath.row == 0 ? "CreateCommentCell" : "CommentEntryCell", forIndexPath: indexPath)
        
        if(indexPath.row == 0 && cell.subviews.count != 5) {
            // The very first cell should be one that allows the user to comment on the photo.
            // Add the avater image (TODO: get the avatar from an actual data source)
            let avatarImageView = UIImageView(frame: CGRectMake(20, 10, 25, 25))
            avatarImageView.backgroundColor = UIColor.clearColor()
            avatarImageView.image = UIImage(named: "round-profile.png")
            cell.addSubview(avatarImageView)
        
            // Add the textfield with an opaque placeholder text (TODO: add a handler for pressing 'OK' on the keyboard)
            let placeholderColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.5)
            let textField = UITextField(frame: CGRectMake(60, 0, self.view.frame.size.width - 90, cell.frame.size.height))
            textField.textColor = UIColor.whiteColor()
            textField.attributedPlaceholder = NSAttributedString(string: "Tap here to comment...",
                attributes: [ NSForegroundColorAttributeName: placeholderColor ])
            cell.addSubview(textField)
        }
        
        else if(indexPath.row != 0) {
            // This is not the first cell so this should be an activity cell. We should hook this up
            // to an actual data source. Tip: use `indexPath.row` to get the index and relate that back
            // to an array of comments or so, to be able to fill these cells from an actual data source.
            cell.textLabel!.text = "I like your photos, Phil! \(indexPath.row)"
            cell.detailTextLabel!.text = "3h"
            
            // Add user profile picture
            let avatarImageView = UIImageView(frame: CGRectMake(20, 10, 25, 25))
            avatarImageView.backgroundColor = UIColor.clearColor()
            avatarImageView.image = UIImage(named: "avatar-phil-schiller.png")
            cell.addSubview(avatarImageView)
        }
        
        // Make sure the text in theses cells is white and that they don't have any solid background color
        cell.textLabel!.textColor = UIColor.whiteColor()
        cell.backgroundColor = UIColor.clearColor()
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
}
