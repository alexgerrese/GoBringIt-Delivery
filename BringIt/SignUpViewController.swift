//
//  SignUpViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/15/16.
//  Copyright © 2016 Campus Enterprises. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    
    var screenMoved = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignInViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignInViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        // Hide keyboard when tapped around (Copy and paste this code into each viewController)
        self.hideKeyboardWhenTappedAround()
    }
    @IBAction func xButtonClicked(sender: UIBarButtonItem) {
        self.dismissKeyboard()
    }
    
    // MARK: - Keyboard Methods
    
    // Move the screen up with the keyboard so text fields aren't hidden
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            if !screenMoved {
                self.view.frame.origin.y -= keyboardSize.height
                screenMoved = true
            }
        }
    }
    
    // Move screen back down after
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y += keyboardSize.height
            screenMoved = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
