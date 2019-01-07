//
//  NewCreditCardVC.swift
//  BringIt
//
//  Created by Alexander's MacBook on 1/6/19.
//  Copyright © 2019 Campus Enterprises. All rights reserved.
//

import UIKit
import RealmSwift
import IQKeyboardManagerSwift
import Moya

class NewCreditCardVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var cardNumberView: UIView!
    @IBOutlet weak var cardNumber: UITextField!
    
    @IBOutlet weak var expMonthView: UIView!
    @IBOutlet weak var expMonth: UITextField!
    
    @IBOutlet weak var expYearView: UIView!
    @IBOutlet weak var expYear: UITextField!
    
    @IBOutlet weak var CVCView: UIView!
    @IBOutlet weak var CVC: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    
    // MARK: - Variables
    var user = User()
    var returnKeyHandler: IQKeyboardReturnKeyHandler?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRealm()
        
        // Set title
        self.title = "New Credit Card"
        
        // Setup text field and button UI
        cardNumberView.layer.cornerRadius = Constants.cornerRadius
        expMonthView.layer.cornerRadius = Constants.cornerRadius
        expYearView.layer.cornerRadius = Constants.cornerRadius
        CVCView.layer.cornerRadius = Constants.cornerRadius
        saveButton.layer.cornerRadius = Constants.cornerRadius
        
        // Set up targets for text fields
        cardNumber.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        expMonth.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        expYear.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        CVC.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
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
    
    /*
     * Check that all fields are filled and correctly formatted, else return
     */
    func checkFields() -> Bool {
        
        // Check for empty fields
        if (cardNumber.text?.isBlank)! || (expMonth.text?.isBlank)! || (expYear.text?.isBlank)! || (CVC.text?.isBlank)! {
            showError(button: saveButton, error: .fieldEmpty)
            return false
        }

        // Check for correct input type
        if cardNumber.text?.isNumber == false || expMonth.text?.isNumber == false || expYear.text?.isNumber == false || CVC.text?.isNumber == false {
            showError(button: saveButton, error: .nonNumerical)
            return false
        }
        
        // Check for correct input lengths
        if cardNumber.text?.isValidCardNumber() == false {
            showError(button: saveButton, error: .invalidInput)
            return false
        }
        let expMonthInteger = Int(expMonth.text ?? "-1")
        if expMonthInteger ?? -1 < 0 || expMonthInteger ?? -1 > 12 {
            showError(button: saveButton, error: .invalidInput)
            return false
        }
        let expYearInteger = Int(expYear.text ?? "-1")
        if expYearInteger ?? -1 <= 2018 || expYearInteger ?? -1 > 2050 {
            showError(button: saveButton, error: .invalidInput)
            return false
        }
        let CVCInteger = Int(CVC.text ?? "-1")
        if CVCInteger ?? -1 < 0 || CVCInteger ?? -1 > 9999 {
            showError(button: saveButton, error: .invalidInput)
            return false
        }
        
        hideError(button: saveButton, defaultButtonText: "Save Credit Card")
        
        return true
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        
        // Check that all fields are filled and correctly formatted, else return
        if !checkFields() {
            return
        }
        
        verifyCreditCard()
    }
    
    func verifyCreditCard() {
        
        // Setup Moya provider and send network request
        let provider = MoyaProvider<APICalls>()
        provider.request(.stripeAddCard(userID: user.id, cardNumber: cardNumber.text!, expMonth: expMonth.text!, expYear: expYear.text!, CVC: CVC.text!)) { result in
            switch result {
            case let .success(moyaResponse):
                do {
                    
                    print("Status code: \(moyaResponse.statusCode)")
                    try moyaResponse.filterSuccessfulStatusCodes()
                    
                    let response = try moyaResponse.mapJSON() as! [String: Any]
                    print(response)
                    
                    if let success = response["success"] {
                        
                        if success as! Int == 1 {
                            
                            print("Credit card is verified with Stripe")
                            self.navigationController?.popViewController(animated: true)
                            
                        } else {
                            
                            self.showError(button: self.saveButton, error: .incorrectCreditCard)
                        }
                    }
                    
                } catch {
                    // Miscellaneous network error
                    print("Network Error")
                    self.showError(button: self.saveButton, error: .networkError, defaultButtonText: "Save Credit Card")
                }
            case .failure(_):
                // Connection failed
                print("Connection failed")
                self.showError(button: self.saveButton, error: .connectionFailed, defaultButtonText: "Save Credit Card")
            }
        }
    }
    
    // MARK: - TextField Delegate
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        checkFields()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkFields()
    }
    
}
