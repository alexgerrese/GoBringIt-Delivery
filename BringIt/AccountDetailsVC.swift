//
//  AccountDetailsVC.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/16/17.
//  Copyright © 2017 Campus Enterprises. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import RealmSwift
import Moya

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
    
    let defaultButtonText = "Save and Create Account"
    
    let defaults = UserDefaults.standard // Initialize UserDefaults
    var returnKeyHandler: IQKeyboardReturnKeyHandler?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup UI
        setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupUI() {
        
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
        myActivityIndicator.isHidden = true
        
        // Set up custom back button
        setCustomBackButton()
        
        // Setup auto Next and Done buttons for keyboard
        returnKeyHandler = IQKeyboardReturnKeyHandler(controller: self)
        returnKeyHandler?.lastTextFieldReturnKeyType = UIReturnKeyType.done
    }
    
    @IBAction func continueButtonTapped(_ sender: UIButton) {
        
        // Check that all fields are filled and correctly formatted, else return
        if !checkFields() {
            return
        }
        
        // Animate activity indicator
        startAnimating(activityIndicator: myActivityIndicator, button: continueButton)
        
        // Setup Moya provider and send network request
        let provider = MoyaProvider<APICalls>()
        provider.request(.signUpUser(fullName: fullName.text!, email: emailAddress.text!, password: password.text!, phoneNumber: phoneNumber.text!)) { result in
            switch result {
            case let .success(moyaResponse):
                do {
                    
                    print("Status code: \(moyaResponse.statusCode)")
                    try moyaResponse.filterSuccessfulStatusCodes()
                    
                    let retrievedUser = try moyaResponse.mapJSON() as! [String: Any]
                    
                    print("Retrieved User: \(retrievedUser)")
                    
                    // Check response from backend
                    let successResponse = retrievedUser["success"] as? Int
                    if successResponse == 1 {
                        // Successfully received server response
                        
                        print("Successfully received server response")
                        
                        // Set up UserDefaults
                        self.defaults.set(true, forKey: "loggedIn")
                        
                        // Shorten user ID to 32 characters (database limitation)
                        let uid = (retrievedUser["uid"] as? String)!
                        let index = uid.index(uid.startIndex, offsetBy: 32)
                        
                        // Create new user
                        self.createNewUser(id: uid.substring(to: index), fullName: self.fullName.text!, emailAddress: self.emailAddress.text!, password: self.password.text!, phoneNumber: self.phoneNumber.text!)
                        
                        print("User created. About to dismiss.")
                        
                        // Rewind segue to Restaurants VC
                        self.dismiss(animated: true, completion: nil)
                        
                    } else if successResponse == 0 {
                        // User already exists
                        self.showError(button: self.continueButton, activityIndicator: self.myActivityIndicator, error: .userAlreadyExists)
                    }
                } catch {
                    // Miscellaneous network error
                    self.showError(button: self.continueButton, activityIndicator: self.myActivityIndicator, error: .networkError, defaultButtonText: self.defaultButtonText)
                }
            case .failure(_):
                // Connection failed
                self.showError(button: self.continueButton, activityIndicator: self.myActivityIndicator, error: .connectionFailed, defaultButtonText: self.defaultButtonText)
            }
        }
    }
    
    /*
     * Create new Realm User
     */
    func createNewUser(id: String, fullName: String, emailAddress: String, password: String, phoneNumber: String) {
        
        let realm = try! Realm() // Initialize Realm
        
        let newUser = User()
        newUser.isCurrent = true
        newUser.id = id
        newUser.fullName = fullName
        newUser.email = emailAddress
        newUser.phoneNumber = phoneNumber
        newUser.isFirstOrder = true
        
        try! realm.write() {
            realm.add(newUser)
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
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        checkFields()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkFields()
    }

}
