//
//  PhoneVerificationVC.swift
//  BringIt
//
//  Created by Joshua Young on 5/18/19.
//  Copyright © 2019 Campus Enterprises. All rights reserved.
//

import Foundation
import UIKit
import IQKeyboardManagerSwift
import RealmSwift
import Moya

class SendPhoneVerificationVC: UIViewController, UITextFieldDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var phoneNumberView: UIView!
    @IBOutlet weak var phoneNumber: UITextField!

    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    
    // MARK: - Variables
    
    let defaultButtonText = "Send Verification Code"
    
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
        phoneNumberView.layer.cornerRadius = Constants.cornerRadius
        continueButton.layer.cornerRadius = Constants.cornerRadius
        
        // Set up targets for text fields
        phoneNumber.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        myActivityIndicator.isHidden = true
        
        // Set up custom back button
        setCustomBackButton()
        
        // Setup auto Next and Done buttons for keyboard
        returnKeyHandler = IQKeyboardReturnKeyHandler(controller: self)
        returnKeyHandler?.lastTextFieldReturnKeyType = UIReturnKeyType.done
    }
    
    /*
     * Check that all fields are filled and correctly formatted, else return
     */
    func checkFields() -> Bool {
        if phoneNumber.text == "" {
            showError(button: continueButton, error: .fieldEmpty)
            return false
        } else if !(phoneNumber.text?.isPhoneNumber)! {
            showError(button: continueButton, error: .invalidPhoneNumber)
            return false
        }
        
        hideError(button: continueButton, defaultButtonText: self.defaultButtonText)
        
        return true
    }
    
    @IBAction func verifyButtonTapped(_ sender: UIButton) {
        // Check that all fields are filled and correctly formatted, else return
        if !checkFields() {
            return
        }
        
        // Animate activity indicator
        startAnimating(activityIndicator: myActivityIndicator, button: continueButton)
        
        // Setup Moya provider and send network request
        let provider = MoyaProvider<CombinedAPICalls>()
        provider.request(.sendPhoneVerification(phoneNumber: phoneNumber.text!)) { result in
            switch result {
            case let .success(moyaResponse):
                do {
                    
                    print("Status code: \(moyaResponse.statusCode)")
                    try moyaResponse.filterSuccessfulStatusCodes()
                    
                    let response = try moyaResponse.mapJSON() as! [String: Any]
                    
                    print("Send Verification Response: \(response)")
                    
                    // Check response from backend
                    let successResponse = response["status"] as? String
                    if successResponse == "success" {
                        // Successfully received server response
                        print("Successfully received server response")
                        self.performSegue(withIdentifier: "toCheckVerificationVC", sender: self)
                        
                    } else {
                        // User already exists
                        self.showError(button: self.continueButton, error: .invalidPhoneNumber)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? CheckPhoneVerificationVC{
            destination.phoneNum = self.phoneNumber.text
        }
    }
    
}
