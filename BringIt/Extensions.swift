//
//  Extensions.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/16/17.
//  Copyright © 2017 Campus Enterprises. All rights reserved.
//

import Foundation
import UIKit

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
    
    public func toPhoneNumber() -> String {
        return self.replacingOccurrences(of: "(\\d{3})(\\d{3})(\\d+)", with: "($1) $2-$3", options: .regularExpression, range: nil)
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

/* Extension to set custom backbutton */
extension UIViewController {
    
    func setCustomBackButton() {
        self.navigationController?.navigationBar.backIndicatorImage = UIImage(named: "backButton")
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "backButton")
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
    }
    
}

/* Date extension to:
 *      - Get the index of the day of the week
 *      - Get the string of the day of the week
 *      - Format openHours to a certain day of the week
 */
extension Date {
    
    /* Returns an integer from 0-6, with 0 being Monday and 6 being Sunday. */
    func getIndexOfWeek() -> Int? {
        // returns an integer from 1 - 7, with 1 being Sunday and 7 being Saturday
        let rawIndex = Calendar.current.dateComponents([.weekday], from: self).weekday!
        var updatedIndex = -1
        
        if rawIndex > 1 {
            updatedIndex = rawIndex - 2
        } else {
            updatedIndex = 6
        }
        
        print("CURRENT INDEX OF THE WEEK: \(updatedIndex)")
        return updatedIndex

    }
    
    func getDayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        print("CURRENT DAY OF THE WEEK: \(dateFormatter.string(from: self).capitalized)")
        return dateFormatter.string(from: self).capitalized
    }
    
}

/* Date extension to:
 *      - Get the index of the day of the week
 *      - Get the string of the day of the week
 *      - Format openHours to a certain day of the week
 */
extension String {
    
    func to24HourTime() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "h:mma"
        
        let date = dateFormatter.date(from: self)
        dateFormatter.dateFormat = "HH:mm"

        return dateFormatter.string(from: date!)
    }
    
    func getOpenHoursString() -> String {
        
        // Check for empty strings
        if self != "" {
            // Separate by ","
            var openHours = self.components(separatedBy: ",")
            
            // Trim whitespaces
            for i in 0..<openHours.count {
                openHours[i] = openHours[i].replacingOccurrences(of: " ", with: "")
            }
            
            // Get correct index
            let index = Date().getIndexOfWeek()!
            if index < openHours.count {
                
                var todaysHours = openHours[index]
                
                // Clean out day of the week
                todaysHours = todaysHours.replacingOccurrences(of: Date().getDayOfWeek()!, with: "")
                print("TODAY'S HOURS: \(todaysHours)")
                
                return todaysHours
            }
        }
        
        return "Hours unavailable"
    }
    
    func isRestaurantOpen() -> Bool {
        
        // Return false if data is not in the right format or was unavailable
        if self == "Hours unavailable" {
            return false
        }
        
        // Separate into open and close times
        var openHours = self.components(separatedBy: "-")
        
        // Convert to 24-hour time
        for i in 0..<openHours.count {
            openHours[i] = openHours[i].to24HourTime()!
        }
        
        // Separate into hours and minutes
        var open = openHours[0].components(separatedBy: ":")
        var closed = openHours[1].components(separatedBy: ":")
        
        let now = Date()
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "EDT")!
        
        // Set current time
        let currentComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: now)
        let currentTime = calendar.date(from: currentComponents)!
        print("CURRENT TIME: \(currentTime)")
        
        // Set start time
        var openComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: now)
        openComponents.hour = Int(open[0])
        openComponents.minute = Int(open[1])
        let openTime = calendar.date(from: openComponents)!
        print("OPEN TIME: \(openTime)")
        
        // Set close time
        var closeComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: now)
        closeComponents.day = Int(open[0])! > Int(closed[0])! ? closeComponents.day! + 1 : closeComponents.day // If close hour is smaller, it must be the next morning
        closeComponents.hour = Int(closed[0])
        closeComponents.minute = Int(closed[1])
        let closeTime = calendar.date(from: closeComponents)!
        print("CLOSE TIME: \(closeTime)")
    
        // Check if now is between start and close times
        if currentTime >= openTime &&
            currentTime <= closeTime {
            print("RESTAURANT IS OPEN.")
            return true
        }
        
        print("RESTAURANT IS CLOSED.")
        return false
    }
}

/* Extension to check if the current time is in the West Union "no MOP" time */
extension UIViewController {
    
    func isCreditCardHours() -> Bool {
        
        let calendar = Calendar.current
        let now = Date()
        let openTime = calendar.date(
            bySettingHour: 6,
            minute: 0,
            second: 0,
            of: now)!
        
        let closeTime = calendar.date(
            bySettingHour: 19,
            minute: 30,
            second: 0,
            of: now)!
        
        if now >= openTime &&
            now <= closeTime {
            return true
        }
        
        return false
    }
}

