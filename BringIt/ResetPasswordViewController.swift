//
//  ResetPasswordViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 7/23/16.
//  Copyright © 2016 Campus Enterprises. All rights reserved.
//

import UIKit
import B68UIFloatLabelTextField
import IQKeyboardManagerSwift

class ResetPasswordViewController: UIViewController {

    //MARK: - IBOutlets
    
    // Text fields
    @IBOutlet weak var currentPasswordTextField: B68UIFloatLabelTextField!
    @IBOutlet weak var newPassword1TextField: B68UIFloatLabelTextField!
    @IBOutlet weak var newPassword2TextField: B68UIFloatLabelTextField!
    
    // Alert messages
    @IBOutlet weak var currentPasswordErrorLabel: UILabel!
    @IBOutlet weak var newPasswordErrorLabel: UILabel!
    
    // Doing this and the two lines in ViewDidLoad automatically handles all keyboard and textField problems!
    var returnKeyHandler : IQKeyboardReturnKeyHandler!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title
        self.title = "Reset Password"
        
        // Set custom back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        returnKeyHandler = IQKeyboardReturnKeyHandler(controller: self)
        returnKeyHandler.lastTextFieldReturnKeyType = UIReturnKeyType.Done
        
        // Hide error messages
        currentPasswordErrorLabel.hidden = true
        newPasswordErrorLabel.hidden = true

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func resetPasswordButtonPressed(sender: UIButton) {
        
        var canContinue = false
        
        //TO-DO: CHAD! Please check if the current password the user entered matches the one on the db. If so, please replace it with the new one.
        let currentPassword = "" // Dummy variable for you Chad
        
        // CHAD: Write code hereee
        
        if currentPasswordTextField.text == currentPassword {
            currentPasswordErrorLabel.hidden = true
            if newPassword1TextField.text == newPassword2TextField.text {
                newPasswordErrorLabel.hidden = true
                
                // CHAD: Send the new password to the db here!
                
                canContinue = true
                
            } else {
                newPasswordErrorLabel.hidden = false
            }
        } else {
            currentPasswordErrorLabel.hidden = false
        }
        
        if canContinue {
            print("CAN CONTINUEEEEE")
            performSegueWithIdentifier("returnToContactInfo", sender: self)
        }
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
