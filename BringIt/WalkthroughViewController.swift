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
        getStartedButton.isHidden = (index == 2) ? false : true
        nextButton.isHidden = (index == 2) ? true : false
        comingSoonLabel.isHidden = (index == 1) ? false : true
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    // Set firstLaunch to false in UserDefaults - walkthrough has been shown
    @IBAction func startClicked(_ sender: AnyObject) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(true, forKey: "displayedWalkthrough")
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // Goes to next slide with button instead of swipe
    @IBAction func nextClicked(_ sender: AnyObject) {
        let pageViewController = self.parent as! PageViewController
        pageViewController.nextPageWithIndex(index)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
