//
//  AccountDetailsVC.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/16/17.
//  Copyright © 2017 Campus Enterprises. All rights reserved.
//

import UIKit

class AccountDetailsVC: UIViewController, UITextFieldDelegate {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var fullNameView: UIView!
    @IBOutlet weak var fullName: UITextField!
    
    @IBOutlet weak var emailAddressView: UIView!
    @IBOutlet weak var emailAddress: UITextField!
    
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var phoneNumberView: UIView!
    @IBOutlet weak var phoneNumber: UITextField!
    
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    
    // MARK: - Variables
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup text field and button UI
        fullNameView.layer.cornerRadius = Constants.cornerRadius
        emailAddressView.layer.cornerRadius = Constants.cornerRadius
        passwordView.layer.cornerRadius = Constants.cornerRadius
        phoneNumberView.layer.cornerRadius = Constants.cornerRadius
        continueButton.layer.cornerRadius = Constants.cornerRadius
        myActivityIndicator.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func continueButtonTapped(_ sender: UIButton) {
        if checkFields() {
            performSegue(withIdentifier: "toPrimaryAddressVC", sender: self)
        }
    }
    
    // MARK: - TextField Delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == phoneNumber {
            return textField.formatPhoneNumber(textField: textField, string: string, range: range)
        }
        
        return false
    }
    
    /*
     * Check that all fields are filled and correctly formatted, else return
     */
    func checkFields() -> Bool {
        if (fullName.text?.isBlank)! {
            
        } else if (emailAddress.text?.isBlank)! {
            showError(button: continueButton, activityIndicator: myActivityIndicator, error: .fieldEmpty)
            return false
        } else if !(emailAddress.text?.isEmail)! {
            showError(button: continueButton, activityIndicator: myActivityIndicator, error: .invalidEmail)
            return false
        } else if (password.text?.isBlank)! {
            showError(button: continueButton, activityIndicator: myActivityIndicator, error: .fieldEmpty)
            return false
        } else if (phoneNumber.text?.isBlank)! {
            showError(button: continueButton, activityIndicator: myActivityIndicator, error: .fieldEmpty)
            return false
        } else if !(phoneNumber.text?.isPhoneNumber)! {
            showError(button: continueButton, activityIndicator: myActivityIndicator, error: .invalidPhoneNumber)
            return false
        }
        
        return true
    }
    
    // MARK: - TextField Delegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        hideError(button: continueButton, activityIndicator: myActivityIndicator, defaultButtonText: "Continue")
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkFields()
    }

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let addressVC = segue.destination as! PrimaryAddressVC
        addressVC.fullName = fullName.text!
        addressVC.emailAddress = emailAddress.text!
        addressVC.password = password.text!
        addressVC.phoneNumber = phoneNumber.text!
        
    }
    

}
