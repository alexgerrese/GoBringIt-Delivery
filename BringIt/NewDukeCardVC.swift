//
//  NewDukeCardVC.swift
//  BringIt
//
//  Created by Young, Joshua on 6/29/19.
//  Copyright © 2019 Campus Enterprises. All rights reserved.
//

import UIKit
import RealmSwift
import IQKeyboardManagerSwift
import Moya

class NewDukeCardVC: UIViewController, UITextFieldDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var cardNumberView: UIView!
    @IBOutlet weak var cardNumber: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!

    // MARK: - Variables
    var user = User()
    var returnKeyHandler: IQKeyboardReturnKeyHandler?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title
        self.title = "New Duke Card"
        
        // Setup text field and button UI
        cardNumberView.layer.cornerRadius = Constants.cornerRadius
        saveButton.layer.cornerRadius = Constants.cornerRadius
        myActivityIndicator.isHidden = true
        
        cardNumber.delegate = self
        
        // Set up targets for text fields
//        cardNumber.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        // Setup auto Next and Done buttons for keyboard
        returnKeyHandler = IQKeyboardReturnKeyHandler(controller: self)
        returnKeyHandler?.lastTextFieldReturnKeyType = UIReturnKeyType.done
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     * Check that all fields are filled and correctly formatted, else return
     */
    func checkFields() -> Bool {
        
        // Check for empty fields
        if (cardNumber.text?.isBlank)! {
            showError(button: saveButton, error: .fieldEmpty)
            return false
        }
        
        // Check for correct input type
        var updatedText = cardNumber.text!
        updatedText.removeAll(where: {$0 == " "})
        if updatedText.isNumber == false {
            showError(button: saveButton, error: .nonNumerical)
            return false
        }
        
        // Check for correct input lengths
        if cardNumber.text?.count != 19 {
            showError(button: saveButton, error: .invalidInput)
            return false
        }
        
        hideError(button: saveButton, defaultButtonText: "Save Duke Card")
        
        return true
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        
        // Check that all fields are filled and correctly formatted, else return
        if !checkFields() {
            return
        }
        
        let realm = try! Realm() // Initialize Realm

        let newPaymentFood = PaymentMethod()
        newPaymentFood.paymentString = "Duke Food Points •••• \(String(cardNumber.text!.suffix(4)))"
        newPaymentFood.paymentValue = cardNumber.text!
        newPaymentFood.userID = user.id
        newPaymentFood.paymentMethodID = 0
        newPaymentFood.paymentPin = ""
        newPaymentFood.unsaved = true
        newPaymentFood.compoundKey = "\(newPaymentFood.paymentMethodID)-\(newPaymentFood.paymentValue)"


        let newPaymentFlex = PaymentMethod()
        newPaymentFlex.paymentString = "Duke Flex •••• \(String(cardNumber.text!.suffix(4)))"
        newPaymentFlex.paymentValue = cardNumber.text!
        newPaymentFlex.userID = user.id
        newPaymentFlex.paymentMethodID = 5
        newPaymentFlex.paymentPin = ""
        newPaymentFlex.unsaved = true
        newPaymentFlex.compoundKey = "\(newPaymentFlex.paymentMethodID)-\(newPaymentFlex.paymentValue)"

        
        try! realm.write {
            realm.add(newPaymentFood, update: .all)
            realm.add(newPaymentFlex, update: .all)
        }
        self.navigationController?.popViewController(animated: true)
        
    }
    
    let maxNumberOfCharacters = 19
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text, let textRange = Range(range, in: text) else {
            return false
        }
        var updatedText = text.replacingCharacters(in: textRange, with: string)
        updatedText.removeAll(where: {$0 == " "})
        if (updatedText.count > 16){
            return false
        }
        textField.text = updatedText.separate(every: 4, with: " ")
        checkFields()
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkFields()
    }
    
}
