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
import Moya

class NewAddressVC: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var campusView: UIView!
    @IBOutlet weak var campus: UITextField!
    
    @IBOutlet weak var streetAddressView: UIView!
    @IBOutlet weak var streetAddress: UITextField!
    
    @IBOutlet weak var roomNumberView: UIView!
    @IBOutlet weak var roomNumber: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    
    // MARK: - Variables
    
    let defaultButtonText = "Save and finish"
    var returnKeyHandler: IQKeyboardReturnKeyHandler?
    
    // Passed from AddressesVC
//    var passedUserID = ""
    
    let defaults = UserDefaults.standard // Initialize UserDefaults
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
    
    func setupRealm() {
        
        let realm = try! Realm() // Initialize Realm
        
        // Get current User 
        let predicate = NSPredicate(format: "isCurrent = %@", NSNumber(booleanLiteral: true))
        user = realm.objects(User.self).filter(predicate).first!
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        
        // Check that all fields are filled and correctly formatted, else return
        if !checkFields() {
            return
        }
        self.createNewAddress()
        
        
        // Verifies address with Google Maps API. If valid, it creates the address
//        verifyAddress()
    }
//
//    func verifyAddress() {
//
//        // Animate activity indicator
//        startAnimating(activityIndicator: myActivityIndicator, button: saveButton)
//
//        let addressString = "\(streetAddress.text!), \(city.text!), NC, USA"
//
//        // Setup Moya provider and send network request
//        let provider = MoyaProvider<APICalls>()
//        provider.request(.verifyAddress(addressString: addressString)) { result in
//            switch result {
//            case let .success(moyaResponse):
//                do {
//
//                    print("Status code: \(moyaResponse.statusCode)")
//                    try moyaResponse.filterSuccessfulStatusCodes()
//
//                    let response = try moyaResponse.mapJSON() as! [String: Any]
//                    print(response)
//
//                    if let success = response["success"] {
//
//                        if success as! Int == 1 {
//
//                            print("Address is verified with Google Maps.")
//
//                            self.createNewAddress()
//
//                            self.navigationController?.popViewController(animated: true)
//
//                        } else {
//
//                            self.showError(button: self.saveButton, activityIndicator: self.myActivityIndicator, error: .incorrectAddress, defaultButtonText: "Save and finish")
//                        }
//                    }
//
//            } catch {
//                    // Miscellaneous network error
//                    print("Network Error")
//                    self.showError(button: self.saveButton, activityIndicator: self.myActivityIndicator, error: .networkError, defaultButtonText: "Save and finish")
//
//                }
//            case .failure(_):
//                // Connection failed
//                print("Connection failed")
//                self.showError(button: self.saveButton, activityIndicator: self.myActivityIndicator, error: .connectionFailed, defaultButtonText: "Save and finish")
//            }
//        }
//    }
    
    /*
     * Create new Realm Address
     */
    func createNewAddress() {
        
        let realm = try! Realm() // Initialize Realm
        
        let address = DeliveryAddress()
        address.userID = user.id
        address.campus = campus.text!
        address.streetAddress = "\(streetAddress.text!)" // TODO: Change from hardcoding to taking result from GMaps call?
        address.roomNumber = roomNumber.text!
        address.isCurrent = true
        
        let provider = MoyaProvider<CombinedAPICalls>()
        provider.request(.addAddress(uid: user.id, address: address.streetAddress, apartment: address.roomNumber, campus: address.campus)) { result in
            switch result {
            case let .success(moyaResponse):
                do {

                    print("Status code: \(moyaResponse.statusCode)")
                    try moyaResponse.filterSuccessfulStatusCodes()

                    let response = try moyaResponse.mapJSON() as! [String: Any]
                    print(response)

                    if let status = response["status"] as? String {

                        if status == "success" {
                            print("Saved Address")
                            let addressId = response["address_id"] as! String
                            try! realm.write() {
                                for add in self.user.addresses {
                                    add.isCurrent = false;
                                }
                                address.id = addressId
                                self.user.addresses.append(address)
                                self.navigationController?.popViewController(animated: true)
                            }
                        } else {
                            self.showError(button: self.saveButton, activityIndicator: self.myActivityIndicator, error: .incorrectAddress, defaultButtonText: "Save and finish")
                        }
                    }

            } catch {
                    // Miscellaneous network error
                    print("Network Error")
                    self.showError(button: self.saveButton, activityIndicator: self.myActivityIndicator, error: .networkError, defaultButtonText: "Save and finish")

                }
            case .failure(_):
                // Connection failed
                print("Connection failed")
                self.showError(button: self.saveButton, activityIndicator: self.myActivityIndicator, error: .connectionFailed, defaultButtonText: "Save and finish")
            }
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
        }
        // The following has been commented out because we now support off-campus addresses and shouldn't require room/apartment numbers
//        else if (roomNumber.text?.isBlank)! {
//            showError(button: saveButton, error: .fieldEmpty)
//            return false
//        }
        
        hideError(button: saveButton, defaultButtonText: self.defaultButtonText)
        
        return true
    }
    
    // MARK: - TextField Delegate
    
    @objc func textFieldDidChange(_ textField: UITextField) {
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
