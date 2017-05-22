//
//  NewAddressVC.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/21/17.
//  Copyright © 2017 Campus Enterprises. All rights reserved.
//

import UIKit
import RealmSwift
import IQKeyboardManagerSwift

class NewAddressVC: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var campusView: UIView!
    @IBOutlet weak var campus: UITextField!
    
    @IBOutlet weak var streetAddressView: UIView!
    @IBOutlet weak var streetAddress: UITextField!
    
    @IBOutlet weak var roomNumberView: UIView!
    @IBOutlet weak var roomNumber: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    
    // MARK: - Variables
    
    let defaultButtonText = "Save and finish"
    var returnKeyHandler: IQKeyboardReturnKeyHandler?
    
    // Passed from AddressesVC
//    var passedUserID = ""
    
    let defaults = UserDefaults.standard // Initialize UserDefaults
    let realm = try! Realm() // Initialize Realm
    var user = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRealm()
        
        // Set title
        self.title = "Add New Address"
        
        // Setup text field and button UI
        campusView.layer.cornerRadius = Constants.cornerRadius
        streetAddressView.layer.cornerRadius = Constants.cornerRadius
        roomNumberView.layer.cornerRadius = Constants.cornerRadius
        saveButton.layer.cornerRadius = Constants.cornerRadius
        
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
    
    func setupRealm() {
        
        // Get current User 
        let predicate = NSPredicate(format: "isCurrent = %@", NSNumber(booleanLiteral: true))
        user = self.realm.objects(User.self).filter(predicate).first!
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        
        // Check that all fields are filled and correctly formatted, else return
        if !checkFields() {
            return
        }
        
        createNewAddress()
        
        navigationController?.popViewController(animated: true)
    }
    
    /*
     * Create new Realm Address
     */
    func createNewAddress() {
        
        let address = DeliveryAddress()
        address.userID = user.id
        address.campus = campus.text!
        address.streetAddress = streetAddress.text!
        address.roomNumber = roomNumber.text!
        
        try! self.realm.write() {
            user.addresses.append(address)
        }
    }
    
    /*
     * Check that all fields are filled and correctly formatted, else return
     */
    func checkFields() -> Bool {
        if (campus.text?.isBlank)! {
            showError(button: saveButton, error: .fieldEmpty)
            return false
        } else if (streetAddress.text?.isBlank)! {
            showError(button: saveButton, error: .fieldEmpty)
            return false
        } else if (roomNumber.text?.isBlank)! {
            showError(button: saveButton, error: .fieldEmpty)
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
