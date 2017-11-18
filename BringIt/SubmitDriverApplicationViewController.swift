//
//  SubmitDriverApplicationViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 6/18/17.
//  Copyright © 2017 Campus Enterprises. All rights reserved.
//
import UIKit
import IQKeyboardManagerSwift
import RealmSwift
import SendGrid

class SubmitDriverApplicationViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var fullNameView: UIView!
    @IBOutlet weak var fullName: UITextField!
    
    @IBOutlet weak var emailAddressView: UIView!
    @IBOutlet weak var emailAddress: UITextField!
    
    @IBOutlet weak var phoneNumberView: UIView!
    @IBOutlet weak var phoneNumber: UITextField!
    
    @IBOutlet weak var hoursAvailableView: UIView!
    @IBOutlet weak var hoursAvailable: UITextField!
    
    @IBOutlet weak var mySegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var submitButton: UIButton!
    
    // MARK: - Passed Variables
    
    let defaultButtonText = "Submit Application"
    var returnKeyHandler: IQKeyboardReturnKeyHandler?
    
    // MARK: - Variables
    
    let defaults = UserDefaults.standard // Initialize UserDefaults
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup UI
        setupUI()
        
        // Set up targets for text fields
        fullName.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        emailAddress.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        phoneNumber.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        hoursAvailable.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        // Setup auto Next and Done buttons for keyboard
        returnKeyHandler = IQKeyboardReturnKeyHandler(controller: self)
        returnKeyHandler?.lastTextFieldReturnKeyType = UIReturnKeyType.done
    }
    
    func setupUI() {
        
        // Set title
        self.title = "Driver Application"
        
        // Setup text field and button UI
        fullNameView.layer.cornerRadius = Constants.cornerRadius
        emailAddressView.layer.cornerRadius = Constants.cornerRadius
        phoneNumberView.layer.cornerRadius = Constants.cornerRadius
        hoursAvailableView.layer.cornerRadius = Constants.cornerRadius
        submitButton.layer.cornerRadius = Constants.cornerRadius
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submitApplicationButtonTapped(_ sender: UIButton) {
        
        // Send out emails
        sendConfirmationEmail()
        sendApplicationEmail()
        
    }
    
    func sendConfirmationEmail() {
        
        var status = ""
        if mySegmentedControl.selectedSegmentIndex == 0 {
            status = "Yes"
        } else {
            status = "No"
        }
        
        // Send an advanced example
        let recipient = Address(emailAddress.text!)
        let personalizations = Personalization(
            to: [recipient],
            cc: nil,
            bcc: nil,
            subject: "Thanks for Applying to Be a Driver With GoBringIt"
        )
        let contents = Content.emailBody(
            plain: "<p>Thanks for applying to be a driver with GoBringIt! We love having hardworking members on our team and look forward to scheduling a follow-up meeting with you. You should expect that in the next couple of days--for now, sit tight and perhaps order some food :)<br><br>Here are your application details:<br><b>Full name: </b>\(fullName.text!)<br><b>Email: </b>\(emailAddress.text!)<br><b>Phone Number: </b>\(phoneNumber.text!)<br><b># of Available Hours/Week (Approx.): </b>\(hoursAvailable.text!)<br><b>Is Duke Student: </b>\(status)</p>",
            html: "<p>Thanks for applying to be a driver with GoBringIt! We love having hardworking members on our team and look forward to scheduling a follow-up meeting with you. You should expect that in the next couple of days--for now, sit tight and perhaps order some food :)<br><br>Here are your application details:<br><b>Full name: </b>\(fullName.text!)<br><b>Email: </b>\(emailAddress.text!)<br><b>Phone Number: </b>\(phoneNumber.text!)<br><b># of Available Hours/Week (Approx.): </b>\(hoursAvailable.text!)<br><b>Is Duke Student: </b>\(status)</p>"
        )
        let email = Email(
            personalizations: [personalizations],
            from: Address("info@gobring.it"),
            content: contents,
            subject: nil
        )
        do {
            try Session.shared.send(request: email) { (response) in
                print(response?.httpUrlResponse?.statusCode)
            }
        } catch {
            print(error)
            print("Email couldn't send.")
        }

    }
    
    func sendApplicationEmail() {
        
        var status = ""
        if mySegmentedControl.selectedSegmentIndex == 0 {
            status = "Yes"
        } else {
            status = "No"
        }
        
        // Send an advanced example
        let recipient = Address(Constants.contactEmail)
        let personalizations = Personalization(
            to: [recipient],
            cc: nil,
            bcc: nil,
            subject: "GoBringIt Driver Application: \(fullName.text!)"
        )
        let contents = Content.emailBody(
            plain: "<p>New driver application from \(fullName.text!)!<br><br>Details:<br><b>Full name: </b>\(fullName.text!)<br><b>Email: </b>\(emailAddress.text!)<br><b>Phone Number: </b>\(phoneNumber.text!)<br><b># of Available Hours/Week (Approx.): </b>\(hoursAvailable.text!)<br><b>Is Duke Student: </b>\(status)<br><br><b>NOTE: </b>Please alert restaurants of this application ASAP so they can schedule a follow-up meeting with the applicant. Thanks :)</p>",
            html: "<p>New driver application from \(fullName.text!)!<br><br>Details:<br><b>Full name: </b>\(fullName.text!)<br><b>Email: </b>\(emailAddress.text!)<br><b>Phone Number: </b>\(phoneNumber.text!)<br><b># of Available Hours/Week (Approx.): </b>\(hoursAvailable.text!)<br><b>Is Duke Student: </b>\(status)<br><br><b>NOTE: </b>Please alert restaurants of this application ASAP so they can schedule a follow-up meeting with the applicant. Thanks :)</p>"
        )
        let email = Email(
            personalizations: [personalizations],
            from: Address(emailAddress.text!),
            content: contents,
            subject: nil
        )
        do {
            try Session.shared.send(request: email) { (response) in
                print(response?.httpUrlResponse?.statusCode)
            }
        } catch {
            print(error)
            print("Email couldn't send.")
        }
    }
    
    
    /*
     * Check that all fields are filled and correctly formatted, else return
     */
    func checkFields() -> Bool {
        if (fullName.text?.isBlank)! {
            //            showError(button: saveButton, error: .fieldEmpty)
            //            showError(button: saveButton, error: .fieldEmpty)
            return false
        } //else if (emailAddress.text?.isBlank)! {
        //            showError(button: saveButton, error: .fieldEmpty)
        //            return false
        //        } else if !emailAddress.text?.isEmail {
        //            showError(button: saveButton, error: .invalidEmail)
        //            return false
        //        } else if (phoneNumber.text?.isBlank)! {
        //            showError(button: saveButton, error: .fieldEmpty)
        //            return false
        //        } else if !phoneNumber.text?.isPhoneNumber {
        //            showError(button: saveButton, error: .invalidPhoneNumber)
        //            return false
        //        } else if hoursAvailable.text.isEmpty {
        //            showError(button: saveButton, error: .fieldEmpty)
        //            return false
        //        }
        //
        //        hideError(button: saveButton, defaultButtonText: self.defaultButtonText)
        
        return true
    }
    
    // MARK: - TextField Delegate
    
    func textFieldDidChange(_ textField: UITextField) {
        checkFields()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkFields()
    }
    
}
