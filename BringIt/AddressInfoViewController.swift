//
//  AddressInfoViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/15/16.
//  Copyright © 2016 Campus Enterprises. All rights reserved.
//

import UIKit
import DLRadioButton
import B68UIFloatLabelTextField
import IQKeyboardManagerSwift

class AddressInfoViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var address1TextField: B68UIFloatLabelTextField!
    @IBOutlet weak var address2TextField: B68UIFloatLabelTextField!
    @IBOutlet weak var cityTextField: B68UIFloatLabelTextField!
    @IBOutlet weak var zipTextField: B68UIFloatLabelTextField!
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    
    // Error messages
    @IBOutlet weak var invalidAddressLabel: UILabel!
    @IBOutlet weak var invalidCitylabel: UILabel!
    @IBOutlet weak var invalidZipLabel: UILabel!
    
    // Passed data
    var fullName = ""
    var email = ""
    var password = ""
    var phoneNumber = ""
    
    // Doing this and the two lines in viewDidLoad automatically handles all keyboard and textField problems!
    var returnKeyHandler : IQKeyboardReturnKeyHandler!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title
        self.title = "Address Info"
        
        // Set custom back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        returnKeyHandler = IQKeyboardReturnKeyHandler(controller: self)
        returnKeyHandler.lastTextFieldReturnKeyType = UIReturnKeyType.Done
        
        // Hide error messages
        invalidAddressLabel.hidden = true
        invalidCitylabel.hidden = true
        invalidZipLabel.hidden = true
        
        // Hide activity indicator
        myActivityIndicator.stopAnimating()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - IBActions
    @IBAction func continueButtonClicked(sender: UIButton) {
        // Show activity indicator
        myActivityIndicator.startAnimating()
        
        var canContinue = true
        
        if address1TextField.text!.isBlank {
            invalidAddressLabel.hidden = false
            canContinue = false
        } else {
            invalidAddressLabel.hidden = true
        }
        if cityTextField.text!.isBlank {
            invalidCitylabel.hidden = false
            canContinue = false
        } else {
            invalidCitylabel.hidden = true
        }
        if !zipTextField.text!.isZipCode {
            invalidZipLabel.hidden = false
            canContinue = false
        } else {
            invalidZipLabel.hidden = true
        }
        
        // Hide activity indicator
        myActivityIndicator.stopAnimating()
        
        if canContinue {
            
            // Hide error messages
            invalidAddressLabel.hidden = true
            invalidCitylabel.hidden = true
            invalidZipLabel.hidden = true
            
            // Reset canContinue variable
            canContinue = true
            
            performSegueWithIdentifier("toPaymentInfo", sender: self)
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "toPaymentInfo" {
            // Send initial data to next screen
            let VC = segue.destinationViewController as! PaymentInfoViewController
            
            VC.fullName = self.fullName
            VC.email = self.email
            VC.password = self.password
            VC.phoneNumber = self.phoneNumber
            //VC.campusLocation = (westRadioButton.selectedButton()?.currentTitle)!
            VC.address1 = address1TextField.text!
            if address2TextField.text!.isBlank {
                VC.address2 = ""
            } else {
                VC.address2 = address2TextField.text!
            }
            VC.city = cityTextField.text!
            VC.zip = zipTextField.text!
        }
    }
    

}
