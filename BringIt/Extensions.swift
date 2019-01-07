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
        case incorrectAddress
        case nonNumerical
        case invalidInput
        case incorrectCreditCard
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
        case .incorrectAddress:
            button.setTitle("Incorrect address. Please try again.", for: .normal)
            button.isEnabled = false
        case .nonNumerical:
            button.setTitle("All digits must be numerical.", for: .normal)
            button.isEnabled = false
        case .invalidInput:
            button.setTitle("Invalid input or range.", for: .normal)
            button.isEnabled = false
        case .incorrectCreditCard:
            button.setTitle("Incorrect credit card details.", for: .normal)
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
        if defaultButtonText != nil {
            button.setTitle(defaultButtonText, for: .normal)
        }
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
    
    // Check if a String is comprised of only numerical digits
    var isNumber: Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
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
    
    public func isValidCardNumber() -> Bool {
        do {
            try SwiftLuhn.performLuhnAlgorithm(with: self)
            return true
        }
        catch {
            return false
        }
    }
    
    public func cardType() -> SwiftLuhn.CardType? {
        let cardType = try? SwiftLuhn.cardType(for: self)
        return cardType
    }
    
    public func suggestedCardType() -> SwiftLuhn.CardType? {
        let cardType = try? SwiftLuhn.cardType(for: self, suggest: true)
        return cardType
    }
    
    public func formattedCardNumber() -> String {
        let numbersOnlyEquivalent = replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression, range: nil)
        return numbersOnlyEquivalent.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
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
    
    /* Returns String name of day of the week. e.g. "Monday" */
    func getDayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        print("CURRENT DAY OF THE WEEK: \(dateFormatter.string(from: self).capitalized)")
        return dateFormatter.string(from: self).capitalized
    }
    
    static var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: Date())!
    }
    
}

/* Date extension to:
 *      - Get the index of the day of the week
 *      - Get the string of the day of the week
 *      - Format openHours to a certain day of the week
 */
extension String {
    
    /* Converts timestring to 24-hour time */
    func to24HourTime() -> String? {
        print(self)
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "h:mma"
        
        if let date = dateFormatter.date(from: self) {
            dateFormatter.dateFormat = "HH:mm"
            print(date)
            print(dateFormatter.string(from: date))
            
            return dateFormatter.string(from: date)
        }
        
        print("HOURS WERE UNAVAILABLE")
        return "Hours unavailable"
    }
    
    /*
     * Parses restaurant's weekly open hours and returns one for the current day.
     * Use optional overrideIndex variable to get openHours for another day of the week.
     */
    func getOpenHoursString(overrideIndex: Int = -1) -> String {
        
        // Check for empty strings
        if self != "" {
            // Separate by ","
            var openHours = self.components(separatedBy: ",")
            
            // Trim whitespaces
            for i in 0..<openHours.count {
                openHours[i] = openHours[i].replacingOccurrences(of: " ", with: "")
            }
            
            // Get correct index
            let index = overrideIndex == -1 ? Date().getIndexOfWeek()! : overrideIndex
            if index < openHours.count {

                var todaysHours = openHours[index]
                
                // Clean out day of the week
                let dayOfTheWeek = overrideIndex == -1 ? Date().getDayOfWeek()! : Date.yesterday.getDayOfWeek()!
                todaysHours = todaysHours.replacingOccurrences(of: dayOfTheWeek, with: "")
                print("TODAY'S HOURS: \(todaysHours)")
                
                return todaysHours
            }
        }
        
        return "Hours unavailable"
    }
    
    /* Takes openHours string for a certain day and returns array with [openTime,closeTime]. Use optional isYesterday variable for previous day openHours to ensure the correct date is being compared for isRestaurantOpen() function. */
    func getOpenAndCloseTimes(isYesterday: Bool = false) -> Array<Date> {
        
        // Return false if data is not in the right format or was unavailable
        if self == "Hours unavailable" {
            return []
        }
        
        // Separate into open and close times
        var openHours = self.components(separatedBy: "-")
        
        // Convert to 24-hour time
        for i in 0..<openHours.count {
            openHours[i] = openHours[i].to24HourTime()!
            if openHours[i] == "Hours unavailable" {
                return []
            }
        }
        
        // Separate into hours and minutes
        var open = openHours[0].components(separatedBy: ":")
        var closed = openHours[1].components(separatedBy: ":")
        
        let now = isYesterday ? Date.yesterday : Date()
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "EDT")!
        
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
        
        return [openTime, closeTime]
    }
    
    /* Returns boolean for whether restaurant is open. Checks against previous day's hours as well in case the restaurant is open past midnight. */
    func isRestaurantOpen() -> Bool {
        
        // If hours aren't set in the database, restaurant is automatically closed
        if self == "" || self == nil {
            return false
        }
        
        let yesterdaysIndex = Date().getIndexOfWeek()! - 1 >= 0 ? Date().getIndexOfWeek()! - 1 : 6
        print("YESTERDAY'S INDEX: \(yesterdaysIndex)")
        print("YESTERDAY'S OPEN HOURS: \(self.getOpenHoursString(overrideIndex: yesterdaysIndex))")
        let yesterdaysTimes = self.getOpenHoursString(overrideIndex: yesterdaysIndex).getOpenAndCloseTimes(isYesterday: true)
        print("YESTERDAY'S TIMES: \(yesterdaysTimes)")
        
        let todaysTimes = self.getOpenHoursString().getOpenAndCloseTimes()
        print("TODAY'S TIMES: \(todaysTimes)")
        
        let now = Date()
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "EDT")!
        
        // Set current time
        let currentComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: now)
        let currentTime = calendar.date(from: currentComponents)!
        print("CURRENT TIME: \(currentTime)")
    
        // Check if now is between start and close times
        if currentTime >= todaysTimes[0] &&
            currentTime <= todaysTimes[1] {
            print("RESTAURANT IS OPEN.")
            return true
        } else if currentTime <= yesterdaysTimes[1] {
            print("RESTAURANT IS STILL OPEN.")
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

// MARK: - Credit Card Validation

open class SwiftLuhn {
    public enum CardType: Int {
        case amex = 0
        case visa
        case mastercard
        case discover
        case dinersClub
        case jcb
        case maestro
        case rupay
        case mir
    }
    
    public enum CardError: Error {
        case unsupported
        case invalid
    }
    
    fileprivate class func regularExpression(for cardType: CardType) -> String {
        switch cardType {
        case .amex:
            return "^3[47][0-9]{5,}$"
        case .dinersClub:
            return "^3(?:0[0-5]|[68][0-9])[0-9]{4,}$"
        case .discover:
            return "^6(?:011|5[0-9]{2})[0-9]{3,}$"
        case .jcb:
            return "^(?:2131|1800|35[0-9]{3})[0-9]{3,}$"
        case .mastercard:
            return "^5[1-5][0-9]{5,}|222[1-9][0-9]{3,}|22[3-9][0-9]{4,}|2[3-6][0-9]{5,}|27[01][0-9]{4,}|2720[0-9]{3,}$"
        case .visa:
            return "^4[0-9]{6,}$"
        case .maestro:
            return "^(5018|5020|5038|6304|6759|6761|6763)[0-9]{8,15}$"
        case .rupay:
            return "^6[0-9]{15}$"
        case .mir:
            return "^220[0-9]{13}$"
        }
    }
    
    fileprivate class func suggestionRegularExpression(for cardType: CardType) -> String {
        switch cardType {
        case .amex:
            return "^3[47][0-9]+$"
        case .dinersClub:
            return "^3(?:0[0-5]|[68][0-9])[0-9]+$"
        case .discover:
            return "^6(?:011|5[0-9]{2})[0-9]+$"
        case .jcb:
            return "^(?:2131|1800|35[0-9]{3})[0-9]+$"
        case .mastercard:
            return "^5[1-5][0-9]{5,}|222[1-9][0-9]{3,}|22[3-9][0-9]{4,}|2[3-6][0-9]{5,}|27[01][0-9]{4,}|2720[0-9]{3,}$"
        case .visa:
            return "^4[0-9]+$"
        case .maestro:
            return "^(5018|5020|5038|6304|6759|6761|6763)[0-9]+$"
        case .rupay:
            return "^6[0-9]+$"
        case .mir:
            return "^220[0-9]+$"
        }
    }
    
    class func performLuhnAlgorithm(with cardNumber: String) throws {
        
        let formattedCardNumber = cardNumber.formattedCardNumber()
        
        guard formattedCardNumber.count >= 9 else {
            throw CardError.invalid
        }
        
        let originalCheckDigit = formattedCardNumber.last!
        let characters = formattedCardNumber.dropLast().reversed()
        
        var digitSum = 0
        
        for (idx, character) in characters.enumerated() {
            let value = Int(String(character)) ?? 0
            if idx % 2 == 0 {
                var product = value * 2
                
                if product > 9 {
                    product = product - 9
                }
                
                digitSum = digitSum + product
            }
            else {
                digitSum = digitSum + value
            }
        }
        
        digitSum = digitSum * 9
        
        let computedCheckDigit = digitSum % 10
        
        let originalCheckDigitInt = Int(String(originalCheckDigit))
        let valid = originalCheckDigitInt == computedCheckDigit
        
        if valid == false {
            throw CardError.invalid
        }
    }
    
    class func cardType(for cardNumber: String, suggest: Bool = false) throws -> CardType {
        var foundCardType: CardType?
        
        for i in CardType.amex.rawValue...CardType.jcb.rawValue {
            let cardType = CardType(rawValue: i)!
            let regex = suggest ? suggestionRegularExpression(for: cardType) : regularExpression(for: cardType)
            
            let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
            
            if predicate.evaluate(with: cardNumber) == true {
                foundCardType = cardType
                break
            }
        }
        
        if foundCardType == nil {
            throw CardError.invalid
        }
        
        return foundCardType!
    }
}

public extension SwiftLuhn.CardType {
    func stringValue() -> String {
        switch self {
        case .amex:
            return "American Express"
        case .visa:
            return "Visa"
        case .mastercard:
            return "Mastercard"
        case .discover:
            return "Discover"
        case .dinersClub:
            return "Diner's Club"
        case .jcb:
            return "JCB"
        case .maestro:
            return "Maestro"
        case .rupay:
            return "Rupay"
        case .mir:
            return "Mir"
        }
    }
    
    init?(string: String) {
        switch string.lowercased() {
        case "american express":
            self.init(rawValue: 0)
        case "visa":
            self.init(rawValue: 1)
        case "mastercard":
            self.init(rawValue: 2)
        case "discover":
            self.init(rawValue: 3)
        case "diner's club":
            self.init(rawValue: 4)
        case "jcb":
            self.init(rawValue: 5)
        case "maestro":
            self.init(rawValue: 6)
        case "rupay":
            self.init(rawValue: 7)
        case "mir":
            self.init(rawValue: 8)
        default:
            return nil
        }
    }
}
