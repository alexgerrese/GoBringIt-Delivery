//
//  Extensions.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/16/17.
//  Copyright © 2017 Campus Enterprises. All rights reserved.
//

import Foundation

/* Extension to handle errors upon button taps.
 *
 * Use cases:
 *      - When a user tries to sign in with the wrong password
 *      - When a user taps to the next text field and the previous one is empty/incorrect
 *
 * Example usage: 
 *      - showError(button: signInButton, activityIndicator: myActivityIndicator, error: .connectionFailed)
 */
extension UIViewController {
    
    enum Error {
        case connectionFailed
        case networkError
        case invalidEmail
        case invalidPassword
        case invalidPhoneNumber
        case fieldEmpty
        case unacceptablePasswordLength
        case userAlreadyExists
    }
    
    func showError(button: UIButton, activityIndicator: UIActivityIndicatorView?, error: Error, defaultButtonText: String?) {
        
        if let a = activityIndicator {
            a.isHidden = true
        }
        button.layer.backgroundColor = Constants.red.cgColor
        button.isEnabled = false
        
        switch error {
        case .connectionFailed:
            button.setTitle("Connection failed. Please try again.", for: .normal)
            hideErrorAfterDelay(button: button, defaultButtonText: defaultButtonText!, delay: Constants.delay)
        case .networkError:
            button.setTitle("Network Error. Please try again.", for: .normal)
            hideErrorAfterDelay(button: button, defaultButtonText: defaultButtonText!, delay: Constants.delay)
        case .invalidEmail:
            button.setTitle("Please enter a valid email.", for: .normal)
            button.isEnabled = false
        case .invalidPassword:
            button.setTitle("Incorrect password. Please try again.", for: .normal)
            button.isEnabled = false
        case .invalidPhoneNumber:
            button.setTitle("Please enter a valid phone number.", for: .normal)
            button.isEnabled = false
        case .fieldEmpty:
            button.setTitle("Please fill in all fields.", for: .normal)
            button.isEnabled = false
        case .unacceptablePasswordLength:
            button.setTitle("Password must be at least 8 characters.", for: .normal)
            button.isEnabled = false
        case .userAlreadyExists:
            button.setTitle("Email already connected to an account. ", for: .normal)
            button.isEnabled = false
        }
    }
    
    func showError(button: UIButton, activityIndicator: UIActivityIndicatorView?, error: Error) {
        showError(button: button, activityIndicator: activityIndicator, error: error, defaultButtonText: nil)
    }
    
    func showError(button: UIButton, error: Error) {
        showError(button: button, activityIndicator: nil, error: error, defaultButtonText: nil)
    }
    
    func showError(button: UIButton, error: Error, defaultButtonText: String) {
        showError(button: button, activityIndicator: nil, error: error, defaultButtonText: defaultButtonText)
    }
    
    func hideErrorAfterDelay(button: UIButton, defaultButtonText: String, delay: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.hideError(button: button, defaultButtonText: defaultButtonText)
        }
    }
    
    func hideError(button: UIButton, defaultButtonText: String) {
        
        button.layer.backgroundColor = Constants.green.cgColor
        button.setTitle(defaultButtonText, for: .normal)
        button.isEnabled = true
        
    }
}

/* Extension to handle activity indicators reusably with buttons
 *
 * Use cases:
 *      - When a user presses a button and the server takes longer than 1s to respond
 *      - When you need to do more than just animate and hide
 *
 * Example usage:
 *      - 
 */
extension UIViewController {
    
    func startAnimating(activityIndicator: UIActivityIndicatorView, button: UIButton) {
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        button.setTitle("", for: .normal)
        
        // TO-DO: Have timers so it starts after 1s so it doesn't feel glitchy
    }
    
}

/* Extension to check fields for whitespace, and email and phone formatting
 *
 * Use cases:
 *      - When you want to verify that a user has inputted a valid email or phone number
 *
 * Example usage:
 *      - if emailAddress.text.isEmail() { // Do something }
 */
extension String {
    
    // Check if text field or String is blank
    var isBlank: Bool {
        get {
            let trimmed = trimmingCharacters(in: CharacterSet.whitespaces)
            return trimmed.isEmpty
        }
    }
    
    // Validate email address
    var isEmail: Bool {
        guard let dataDetector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
            return false
        }
        let range = NSMakeRange(0, NSString(string: self).length)
        let allMatches = dataDetector.matches(in: self, options: [], range: range)
        
        if allMatches.count == 1,
            allMatches.first?.url?.absoluteString.contains("mailto:") == true
        {
            return true
        }
        return false
    }
    
    // Validate phone number
    var isPhoneNumber: Bool {
        let PHONE_REGEX = "^\\(\\d{3}\\)\\s\\d{3}-\\d{4}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: self)
        return result
    }
    
    // Validate password length
    var isAcceptablePasswordLength: Bool {
        return (self.characters.count >= 8)
    }
}

/* Extension to cleanly format phone numbers as users type them in. 
 * NOTE: This must be implemented inside the textField method "shouldChangeCharactersIn range"
 *
 * Use cases:
 *      - When users type a phone number in
 *
 * Example usage:
 *      -
 *      - if textField == phoneNumber {
 *           return textField.formatPhoneNumber(textField: textField, string: string, range: range)
 *        }
 */
extension UITextField {
    
    func formatPhoneNumber(textField: UITextField, string: String, range: NSRange) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        let components = newString.components(separatedBy: CharacterSet.decimalDigits.inverted)
        
        let decimalString : String = components.joined(separator: "")
        let length = decimalString.characters.count
        let decimalStr = decimalString as NSString
        let hasLeadingOne = length > 0 && decimalStr.character(at: 0) == (1 as unichar)
        
        if length == 0 || (length > 10 && !hasLeadingOne) || length > 11
        {
            let newLength = (textField.text! as NSString).length + (string as NSString).length - range.length as Int
            
            return (newLength > 10) ? false : true
        }
        var index = 0 as Int
        let formattedString = NSMutableString()
        
        if hasLeadingOne
        {
            formattedString.append("1 ")
            index += 1
        }
        if (length - index) > 3
        {
            let areaCode = decimalStr.substring(with: NSMakeRange(index, 3))
            formattedString.appendFormat("(%@) ", areaCode)
            index += 3
        }
        if length - index > 3
        {
            let prefix = decimalStr.substring(with: NSMakeRange(index, 3))
            formattedString.appendFormat("%@-", prefix)
            index += 3
        }
        
        let remainder = decimalStr.substring(from: index)
        formattedString.append(remainder)
        textField.text = formattedString as String
        
        return false
    }
    
}

extension UIViewController {
    
    func setCustomBackButton() {
        self.navigationController?.navigationBar.backIndicatorImage = UIImage(named: "backButton")
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "backButton")
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
    }
    
}
