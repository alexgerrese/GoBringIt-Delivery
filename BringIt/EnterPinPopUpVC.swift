//
//  EnterPinPopUpVC.swift
//  BringIt
//
//  Created by Young, Joshua on 7/6/19.
//  Copyright © 2019 Campus Enterprises. All rights reserved.
//

import UIKit

class EnterPinPopUpVC: UIViewController {
    
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var pinTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    var closure: ((String)->Void)!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pinTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
    }
    

    @IBAction func pinSubmitTouched(_ sender: Any) {
        // Check that all fields are filled and correctly formatted, else return
        if !checkFields() {
            return
        }
        
        if let presenter = presentingViewController as? PaymentMethodsVC {
            presenter.pin = pinTextField.text!
        }
        closure(pinTextField.text!)
        dismiss(animated: true)

    }

    func checkFields() -> Bool {
        
        // Check for empty fields
        if (pinTextField.text?.isBlank)! {
            showError(button: submitButton, error: .fieldEmpty)
            return false
        }
        
        // Check for correct input type
        if pinTextField.text?.isNumber == false {
            showError(button: submitButton, error: .nonNumerical)
            return false
        }
        
        // Check for correct input lengths
        if pinTextField.text?.count != 4 {
            showError(button: submitButton, error: .invalidInput)
            return false
        }
        
        hideError(button: submitButton, defaultButtonText: "Submit")
        
        return true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        checkFields()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkFields()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        var touch: UITouch? = touches.first
        //location is relative to the current view
        // do something with the touched point
        if touch?.view != popUpView {
            closure("")
            dismiss(animated: true)
        }
    }

}
