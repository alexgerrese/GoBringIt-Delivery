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
    
    // MARK: - Variables
    
    let defaultButtonText = "Continue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title
        self.title = "Sign Up"

        // Setup text field and button UI
        fullNameView.layer.cornerRadius = Constants.cornerRadius
        emailAddressView.layer.cornerRadius = Constants.cornerRadius
        passwordView.layer.cornerRadius = Constants.cornerRadius
        phoneNumberView.layer.cornerRadius = Constants.cornerRadius
        continueButton.layer.cornerRadius = Constants.cornerRadius
        
        // Set up targets for text fields
        fullName.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        emailAddress.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        password.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        phoneNumber.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        // Set up custom back button
        setCustomBackButton()
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
    
    /*
     * Check that all fields are filled and correctly formatted, else return
     */
    func checkFields() -> Bool {
        if (fullName.text?.isBlank)! {
            showError(button: continueButton, error: .fieldEmpty)
            return false
        } else if (emailAddress.text?.isBlank)! {
            showError(button: continueButton, error: .fieldEmpty)
            return false
        } else if !(emailAddress.text?.isEmail)! {
            showError(button: continueButton, error: .invalidEmail)
            return false
        } else if (password.text?.isBlank)! {
            showError(button: continueButton, error: .fieldEmpty)
            return false
        } else if !(password.text?.isAcceptablePasswordLength)! {
            showError(button: continueButton, error: .unacceptablePasswordLength)
            print(password.text!.isAcceptablePasswordLength)
            return false
        } else if phoneNumber.text == "" {
            showError(button: continueButton, error: .fieldEmpty)
            return false
        } else if !(phoneNumber.text?.isPhoneNumber)! {
            showError(button: continueButton, error: .invalidPhoneNumber)
            return false
        }
        
        hideError(button: continueButton, defaultButtonText: self.defaultButtonText)
        
        return true
    }

    
    // MARK: - TextField Delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var result = true
        
        if textField == phoneNumber {
            result = textField.formatPhoneNumber(textField: textField, string: string, range: range)
        }
        
        checkFields()
        return result
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        checkFields()
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
