//
//  UpdateAccountInfoViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 6/4/17.
//  Copyright © 2017 Campus Enterprises. All rights reserved.
//

import UIKit
import RealmSwift
import IQKeyboardManagerSwift
import Moya
import Alamofire

class UpdateAccountInfoViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var fullNameView: UIView!
    @IBOutlet weak var fullName: UITextField!
    
    @IBOutlet weak var emailAddressView: UIView!
    @IBOutlet weak var emailAddress: UITextField!
    
    @IBOutlet weak var phoneNumberView: UIView!
    @IBOutlet weak var phoneNumber: UITextField!
    
    @IBOutlet weak var updateButton: UIButton!
    
    // MARK: - Variables
    
    let defaults = UserDefaults.standard // Initialize UserDefaults
    let realm = try! Realm() // Initialize Realm
    
    let defaultButtonText = "Update Account Info"
    var returnKeyHandler: IQKeyboardReturnKeyHandler?
    var user = User()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup UI
        setupUI()
        
        // Setup Realm
        setupRealm()
        
        // Fetch account info from the database
        fetchAccountInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupUI() {
        
        // Set title
        self.title = "Account Info"
        
        // Setup text field and button UI
        fullNameView.layer.cornerRadius = Constants.cornerRadius
        emailAddressView.layer.cornerRadius = Constants.cornerRadius
        phoneNumberView.layer.cornerRadius = Constants.cornerRadius
        updateButton.layer.cornerRadius = Constants.cornerRadius
        
        // Set up targets for text fields
        fullName.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        emailAddress.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        phoneNumber.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        // Set up custom back button
        setCustomBackButton()
        
        // Setup auto Next and Done buttons for keyboard
        returnKeyHandler = IQKeyboardReturnKeyHandler(controller: self)
        returnKeyHandler?.lastTextFieldReturnKeyType = UIReturnKeyType.done
    }
    
    func setupRealm() {
        
        let filteredUsers = self.realm.objects(User.self).filter("isCurrent = %@", NSNumber(booleanLiteral: true))
        user = filteredUsers.first!
    }
    
    func fetchAccountInfo() {
        
        // Setup Moya provider and send network request
        let provider = MoyaProvider<APICalls>()
        provider.request(.fetchAccountInfo(uid: user.id)) { result in
            switch result {
            case let .success(moyaResponse):
                do {
                    
                    print("Status code: \(moyaResponse.statusCode)")
                    
                    let response = try moyaResponse.mapJSON() as! [String: Any]
                    
                    print("User ID: \(self.user.id)")
                    print("Retrieved Response: \(response)")
                    
                    
                    self.fullName.text = response["name"] as? String
                    self.emailAddress.text = response["email"] as? String
                    self.phoneNumber.text = response["phone"] as? String
                    
                } catch {
                    // Miscellaneous network error
                    
                    // TO-DO: MAKE THIS A MODAL POPUP???
                    print("Network error")
                }
            case .failure(_):
                // Connection failed
                
                // TO-DO: MAKE THIS A MODAL POPUP???
                print("Connection failed. Make sure you're connected to the internet.")
            }
        }
    }
    
    func updateAccountInfo() {
        
        // Setup Moya provider and send network request
        let provider = MoyaProvider<APICalls>()
        provider.request(.updateAccountInfo(uid: user.id, fullName: fullName.text!, email: emailAddress.text!, phoneNumber: phoneNumber.text!)) { result in
            switch result {
            case let .success(moyaResponse):
                do {
                    
                    print("Status code: \(moyaResponse.statusCode)")
                    try moyaResponse.filterSuccessfulStatusCodes()
                    
                    let response = try moyaResponse.mapJSON() as! [String: Any]
                    
                    print("Retrieved Response: \(response)")
                    
                } catch {
                    // Miscellaneous network error
                    
                    // TO-DO: MAKE THIS A MODAL POPUP???
                    print("Network error")
                }
            case .failure(_):
                // Connection failed
                
                // TO-DO: MAKE THIS A MODAL POPUP???
                print("Connection failed. Make sure you're connected to the internet.")
            }
        }
        
    }

    
    @IBAction func updateButtonTapped(_ sender: UIButton) {
        if checkFields() {
            updateAccountInfo()
            if let nav = self.navigationController {
                nav.popViewController(animated: true)
            }
//            self.dismiss(animated: true, completion: nil)
            // TO-DO: Add unwind segue
        }
    }
    
    /*
     * Check that all fields are filled and correctly formatted, else return
     */
    func checkFields() -> Bool {
        if (fullName.text?.isBlank)! {
            showError(button: updateButton, error: .fieldEmpty)
            return false
        } else if (emailAddress.text?.isBlank)! {
            showError(button: updateButton, error: .fieldEmpty)
            return false
        } else if !(emailAddress.text?.isEmail)! {
            showError(button: updateButton, error: .invalidEmail)
            return false
        } else if phoneNumber.text == "" {
            showError(button: updateButton, error: .fieldEmpty)
            return false
        } else if !(phoneNumber.text?.isPhoneNumber)! {
            showError(button: updateButton, error: .invalidPhoneNumber)
            return false
        }
        
        hideError(button: updateButton, defaultButtonText: self.defaultButtonText)
        
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
