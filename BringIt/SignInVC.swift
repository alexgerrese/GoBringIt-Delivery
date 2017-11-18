//
//  SignIn-SignUpViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/14/17.
//  Copyright © 2017 Campus Enterprises. All rights reserved.
//

//THINGS TO MAKE CODE BETTER:
//    - Make a global constants page and extend it in each other page

import UIKit
import IQKeyboardManagerSwift
import Alamofire
import Moya
import RealmSwift

var comingFromSignIn = false

class SignInVC: UIViewController, UITextFieldDelegate {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var emailAddressView: UIView!
    @IBOutlet weak var emailAddress: UITextField!
    
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    
    // MARK: Variables
    
    let defaults = UserDefaults.standard // Initialize UserDefaults
    
    let defaultButtonText = "Sign in"
    var returnKeyHandler: IQKeyboardReturnKeyHandler?
    
    var comingFromCheckout = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("In SignInVC viewDidLoad")

        // Setup text field and button UI
        emailAddressView.layer.cornerRadius = Constants.cornerRadius
        passwordView.layer.cornerRadius = Constants.cornerRadius
        signInButton.layer.cornerRadius = Constants.cornerRadius
        signUpButton.layer.cornerRadius = Constants.cornerRadius
        signUpButton.layer.borderColor = Constants.green.cgColor
        signUpButton.layer.borderWidth = Constants.borderWidth
        
        // Set up targets for text fields
        emailAddress.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        password.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        // Set up custom back button
        setCustomBackButton()
        
        // Setup auto Next and Done buttons for keyboard
        returnKeyHandler = IQKeyboardReturnKeyHandler(controller: self)
        returnKeyHandler?.lastTextFieldReturnKeyType = UIReturnKeyType.done
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        myActivityIndicator.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        if comingFromCheckout {
            comingFromSignIn = true
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    /* 
     * Verify credentials and sign in. Returns if failure.
     */
    @IBAction func signInButtonTapped(_ sender: UIButton) {
        
        let realm = try! Realm() // Initialize Realm
        
        // Check that all fields are filled and correctly formatted, else return
        if !checkFields() {
            return
        }
        
        // Animate activity indicator
        startAnimating(activityIndicator: myActivityIndicator, button: signInButton)
        
        // Setup Moya provider and send network request
        let provider = MoyaProvider<APICalls>()
        provider.request(.signInUser(email: emailAddress.text!, password: password.text!)) { result in
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
                        // Successfully logged in
                        
                        print("Successfully logged in")
                        
                        // Set up UserDefaults
                        self.defaults.set(true, forKey: "loggedIn")
                        
                        // Check if user already exists in Realm
                        let predicate = NSPredicate(format: "id = %@", (retrievedUser["id"] as? String)!)
                        let userExists = realm.objects(User.self).filter(predicate).count > 0
                        
                        if userExists {
                            
                            print("User exists")
                            
                            // User exists, retrieve from Realm and set to current user
                            let user = realm.objects(User.self).filter(predicate).first!
                            try! realm.write {
                                user.isCurrent = true
                            }
                            
                            // Check if user has address on file
                            self.fetchExistingAddress(user: user)
                            
                        } else {
                            
                            print("User doesn't exist")
                            
                            // User doesn't exist, create new user
                            self.createNewUser(retrievedUser: retrievedUser)
                        }
                        
                        print("About to dismiss.")
                        
                        // Rewind segue to Restaurants VC
                        self.dismiss(animated: true, completion: nil)

                    } else if successResponse == -1 {
                        // Email wasn't found
                        self.showError(button: self.signInButton, activityIndicator: self.myActivityIndicator, error: .invalidEmail)
                    } else {
                        // Password was incorrect
                        self.showError(button: self.signInButton, activityIndicator: self.myActivityIndicator, error: .invalidPassword)
                    }
                } catch {
                    // Miscellaneous network error
                    self.showError(button: self.signInButton, activityIndicator: self.myActivityIndicator, error: .networkError, defaultButtonText: self.defaultButtonText)
                }
            case .failure(_):
                // Connection failed
                self.showError(button: self.signInButton, activityIndicator: self.myActivityIndicator, error: .connectionFailed, defaultButtonText: self.defaultButtonText)
            }
        }
    }
    
    /*
     * Create new Realm User from network JSON data
     */
    func createNewUser(retrievedUser: [String: Any]) {
        
        let realm = try! Realm() // Initialize Realm
        
        let newUser = User()
        newUser.isCurrent = true
        newUser.id = (retrievedUser["id"] as? String)!
        newUser.fullName = (retrievedUser["name"] as? String)!
        newUser.email = self.emailAddress.text!
        newUser.phoneNumber = (retrievedUser["phone"] as? String)!
        if (retrievedUser["already_ordered"] as? Int == 1) {
            newUser.isFirstOrder = false
        } else {
            newUser.isFirstOrder = true
        }
        
        try! realm.write() {
            realm.add(newUser)
        }
        
        // Check if user has address on file
        fetchExistingAddress(user: newUser)
    }
    
    /*
     * Checks database for an existing address and imports it if Realm doesn't already know it
     */
    func fetchExistingAddress(user: User) {
        
        let realm = try! Realm() // Initialize Realm
        
        print("Fetching existing address")
        
        // Setup Moya provider and send network request
        let provider = MoyaProvider<APICalls>()
        provider.request(.fetchAccountAddress(uid: user.id)) { result in
            switch result {
            case let .success(moyaResponse):
                do {
                    
                    print("Status code: \(moyaResponse.statusCode)")
                    try moyaResponse.filterSuccessfulStatusCodes()
                    
                    let retrievedAddress = try moyaResponse.mapJSON() as! [String: Any]
                    
                    print("Retrieved Address: \(retrievedAddress)")
                    
                    if retrievedAddress["street"] != nil && retrievedAddress["apartment"] != nil {
                        
                        // Check if address already exists in Realm
                        if realm.objects(DeliveryAddress.self).filter("userID = %@ && streetAddress = %@", user.id, retrievedAddress["streetAddress"] as! String).count == 0 {
                            
                            print("Address doesn't already exist")
                            
                            let newAddress = DeliveryAddress()
                            newAddress.userID = user.id
                            newAddress.streetAddress = retrievedAddress["streetAddress"] as! String
                            newAddress.roomNumber = retrievedAddress["roomNumber"] as! String
                            newAddress.campus = retrievedAddress["campus"] != nil ? retrievedAddress["campus"] as! String : ""
                            
                            try! realm.write() {
                                user.addresses.append(newAddress)
                            }

                        }
                        
                    }
                    
                } catch {
                    // Miscellaneous network error
                    print("Miscellaneous network error")
                }
            case .failure(_):
                // Connection failed
                print("Connection failed")
            }
        }
        
    }
    
    /* 
     * Check that all fields are filled and correctly formatted, else return 
     */
    func checkFields() -> Bool {
        if (emailAddress.text?.isBlank)! {
            showError(button: signInButton, activityIndicator: myActivityIndicator, error: .fieldEmpty)
            return false
        } else if !(emailAddress.text?.isEmail)! {
            showError(button: signInButton, activityIndicator: myActivityIndicator, error: .invalidEmail)
            return false
        } else if (password.text?.isBlank)! {
            showError(button: signInButton, activityIndicator: myActivityIndicator, error: .fieldEmpty)
            return false
        } else if !(password.text?.isAcceptablePasswordLength)! {
            showError(button: signInButton, activityIndicator: myActivityIndicator, error: .unacceptablePasswordLength)
            print(password.text!.isAcceptablePasswordLength)
            return false
        }
        
        hideError(button: signInButton, defaultButtonText: self.defaultButtonText)
        
        return true
    }
    
    // MARK: - TextField Delegate
    
    func textFieldDidChange(_ textField: UITextField) {
        checkFields()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkFields()
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
