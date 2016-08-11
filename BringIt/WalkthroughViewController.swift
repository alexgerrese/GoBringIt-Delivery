//
//  WalkthroughViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/14/16.
//  Copyright © 2016 Campus Enterprises. All rights reserved.
//

import UIKit

class WalkthroughViewController: UIViewController {
    
    // IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var walkthroughText: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var getStartedButton: UIButton!
    @IBOutlet weak var comingSoonLabel: UILabel!
    
    // Variables
    var index = 0
    var imageName = ""
    var descriptionText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up walkthrough screens
        walkthroughText.text = descriptionText
        imageView.image = UIImage(named: imageName)
        pageControl.currentPage = index
        
        // Hide and show buttons as needed
        getStartedButton.hidden = (index == 2) ? false : true
        nextButton.hidden = (index == 2) ? true : false
        comingSoonLabel.hidden = (index == 1) ? false : true
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // Set firstLaunch to false in UserDefaults - walkthrough has been shown
    @IBAction func startClicked(sender: AnyObject) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setBool(true, forKey: "displayedWalkthrough")
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Goes to next slide with button instead of swipe
    @IBAction func nextClicked(sender: AnyObject) {
        let pageViewController = self.parentViewController as! PageViewController
        pageViewController.nextPageWithIndex(index)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
