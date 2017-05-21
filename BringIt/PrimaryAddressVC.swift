//
//  PrimaryAddressVC.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/16/17.
//  Copyright © 2017 Campus Enterprises. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Stripe
import Alamofire
import Moya
import RealmSwift

class PrimaryAddressVC: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var campusView: UIView!
    @IBOutlet weak var campus: UITextField!
    
    @IBOutlet weak var streetAddressView: UIView!
    @IBOutlet weak var streetAddress: UITextField!
    
    @IBOutlet weak var roomNumberView: UIView!
    @IBOutlet weak var roomNumber: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    
    // MARK: - Passed Variables
    
    let defaultButtonText = "Save and continue"
    var returnKeyHandler: IQKeyboardReturnKeyHandler?
    
    var fullName = ""
    var emailAddress = ""
    var password = ""
    var phoneNumber = ""
    
    // MARK: - Variables
    
    let defaults = UserDefaults.standard // Initialize UserDefaults
    let realm = try! Realm() // Initialize Realm

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title
        self.title = "Sign Up"

        // Setup text field and button UI
        campusView.layer.cornerRadius = Constants.cornerRadius
        streetAddressView.layer.cornerRadius = Constants.cornerRadius
        roomNumberView.layer.cornerRadius = Constants.cornerRadius
        saveButton.layer.cornerRadius = Constants.cornerRadius
        myActivityIndicator.isHidden = true
        
        // Set up targets for text fields
        campus.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        streetAddress.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        roomNumber.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        // Setup auto Next and Done buttons for keyboard
        returnKeyHandler = IQKeyboardReturnKeyHandler(controller: self)
        returnKeyHandler?.lastTextFieldReturnKeyType = UIReturnKeyType.done
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        
        // Check that all fields are filled and correctly formatted, else return
        if !checkFields() {
            return
        }
        
        // Animate activity indicator
        startAnimating(activityIndicator: myActivityIndicator, button: saveButton)
        
        // Setup Moya provider and send network request
        let provider = MoyaProvider<APICalls>()
        provider.request(.signUpUser(fullName: fullName, email: emailAddress, password: password, phoneNumber: phoneNumber, campus: campus.text!, streetAddress: streetAddress.text!, roomNumber: roomNumber.text!)) { result in
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
                        
                        // Create new user
                        self.createNewUser(id: (retrievedUser["uid"] as? String)!, fullName: self.fullName, emailAddress: self.emailAddress, password: self.password, phoneNumber: self.phoneNumber, campus: self.campus.text!, streetAddress: self.streetAddress.text!, roomNumber: self.roomNumber.text!)
                        
                        print("User created. About to dismiss.")
                        
                        // Rewind segue to Restaurants VC
                        self.dismiss(animated: true, completion: nil)
                        
                    } else if successResponse == 0 {
                        // User already exists
                        self.showError(button: self.saveButton, activityIndicator: self.myActivityIndicator, error: .userAlreadyExists)
                    }
                } catch {
                    // Miscellaneous network error
                    self.showError(button: self.saveButton, activityIndicator: self.myActivityIndicator, error: .networkError, defaultButtonText: self.defaultButtonText)
                }
            case .failure(_):
                // Connection failed
                self.showError(button: self.saveButton, activityIndicator: self.myActivityIndicator, error: .connectionFailed, defaultButtonText: self.defaultButtonText)
            }
        }
    }
    
    /*
     * Create new Realm User
     */
    func createNewUser(id: String, fullName: String, emailAddress: String, password: String, phoneNumber: String, campus: String, streetAddress: String, roomNumber: String) {
        
        let newUser = User()
        newUser.isCurrent = true
        newUser.id = id
        newUser.fullName = fullName
        newUser.email = emailAddress
        newUser.phoneNumber = phoneNumber
        newUser.isFirstOrder = true
        
        let newAddress = Address()
        newAddress.userID = newUser.id
        newAddress.campus = campus
        newAddress.streetAddress = streetAddress
        newAddress.roomNumber = roomNumber
        
        newUser.addresses.append(newAddress)
        
        try! self.realm.write() {
            self.realm.add(newUser)
        }
    }

    /*
     * Check that all fields are filled and correctly formatted, else return
     */
    func checkFields() -> Bool {
        if (campus.text?.isBlank)! {
            showError(button: saveButton, activityIndicator: myActivityIndicator, error: .fieldEmpty)
            return false
        } else if (streetAddress.text?.isBlank)! {
            showError(button: saveButton, activityIndicator: myActivityIndicator, error: .fieldEmpty)
            return false
        } else if (roomNumber.text?.isBlank)! {
            showError(button: saveButton, activityIndicator: myActivityIndicator, error: .fieldEmpty)
            return false
        }
        
        hideError(button: saveButton, defaultButtonText: self.defaultButtonText)
        
        return true
    }
    
    // MARK: - TextField Delegate
    
    func textFieldDidChange(_ textField: UITextField) {
        checkFields()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkFields()
    }

}
