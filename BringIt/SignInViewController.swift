//
//  SignInViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/15/16.
//  Copyright © 2016 Campus Enterprises. All rights reserved.
//

import UIKit
import B68UIFloatLabelTextField
import IQKeyboardManagerSwift

class SignInViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var emailTextField: B68UIFloatLabelTextField!
    @IBOutlet weak var passwordTextField: B68UIFloatLabelTextField!
    @IBOutlet weak var loginErrorMessageLabel: UILabel!
    
    
    var returnKeyHandler : IQKeyboardReturnKeyHandler!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Automatically handle all keyboard and textField problems!
        returnKeyHandler = IQKeyboardReturnKeyHandler(controller: self)
        returnKeyHandler.lastTextFieldReturnKeyType = UIReturnKeyType.Done
        loginErrorMessageLabel.hidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        displayWalkthroughs()
    }
    
    // Sign in if credentials match with existing backend entry
    @IBAction func signInButtonClicked(sender: UIButton) {
        // CHAD!
        // Here's where you put your database sign in code! You should be able to access the email with emailTextField.text and password with passwordTextField.text
        
        // Say that you authenticate the user with a boolean called canLogin. If true, segue to next viewcontroller. If false, show error message with no segue.
        /* if canLogin {
                //SOME CODE
                loginErrorMessageLabel.hidden = true
                performSegueWithIdentifier("toHome", sender: self)
        } else {
                loginErrorMessageLabel.hidden = false
        } */
    }
    
    // Check if walkthrough has been shown, then show if needed
    func displayWalkthroughs() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let displayedWalkthrough = userDefaults.boolForKey("displayedWalkthrough")
        
        if !displayedWalkthrough {
            if let pageViewController = storyboard?.instantiateViewControllerWithIdentifier("PageViewController") {
                self.presentViewController(pageViewController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func rewindFromSignUp(segue: UIStoryboardSegue) {
    }
}
