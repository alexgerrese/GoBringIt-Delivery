//
//  SignUpViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/15/16.
//  Copyright © 2016 Campus Enterprises. All rights reserved.
//

import UIKit
import B68UIFloatLabelTextField
import IQKeyboardManagerSwift
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


// To think about later: What to do with the profile pic

class SignUpViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var profilePicImage: UIImageView!
    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var fullNameTextField: B68UIFloatLabelTextField!
    @IBOutlet weak var emailTextField: B68UIFloatLabelTextField!
    @IBOutlet weak var passwordTextField: B68UIFloatLabelTextField!
    @IBOutlet weak var phoneNumberTextField: B68UIFloatLabelTextField!
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    
    // Error messages
    @IBOutlet weak var invalidNameLabel: UILabel!
    @IBOutlet weak var invalidEmailLabel: UILabel!
    @IBOutlet weak var invalidPasswordLabel: UILabel!
    @IBOutlet weak var invalidPhoneNumberLabel: UILabel!
    
    // Variables to choose profile pic
    var picker: UIImagePickerController? = UIImagePickerController()
    var popover: UIPopoverController? = nil
    
    // Doing this and the two lines in ViewDidLoad automatically handles all keyboard and textField problems!
    var returnKeyHandler : IQKeyboardReturnKeyHandler!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title
        self.title = "Sign Up"
        
        // Set custom back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
        // Round profile pic image
        self.profilePicImage.layer.cornerRadius = self.profilePicImage.frame.size.width / 2
        self.profilePicImage.clipsToBounds = true
        self.profilePicImage.layer.borderWidth = 2.0
        self.profilePicImage.layer.borderColor = GREEN.cgColor
        
        returnKeyHandler = IQKeyboardReturnKeyHandler(controller: self)
        returnKeyHandler.lastTextFieldReturnKeyType = UIReturnKeyType.done
        
        // Hide error messages
        invalidNameLabel.isHidden = true
        invalidEmailLabel.isHidden = true
        invalidPasswordLabel.isHidden = true
        invalidPhoneNumberLabel.isHidden = true
        phoneNumberTextField.delegate = self
        
        // Hide activity indicator
        myActivityIndicator.stopAnimating()
    }
    
    @IBAction func lol(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    // MARK: - Image Picker Methods
    
    @IBAction func chooseImageClicked(_ sender: AnyObject) {
        let alert:UIAlertController=UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.default)
        {
            UIAlertAction in
            self.openCamera()
        }
        let galleryAction = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.default)
        {
            UIAlertAction in
            self.openGallery()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel)
        {
            UIAlertAction in
        }
        
        // Add the actions
        picker?.delegate = self
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
        
        // Present the controller
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            popover = UIPopoverController(contentViewController: alert)
            popover!.present(from: chooseImageButton.frame, in: self.view, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
        }
    }
    
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera))
        {
            picker?.sourceType = UIImagePickerControllerSourceType.camera
            picker?.allowsEditing = true
            self .present(picker!, animated: true, completion: nil)
        }
        else
        {
            openGallery()
        }
    }
    
    func openGallery()
    {
        picker?.sourceType = UIImagePickerControllerSourceType.photoLibrary
        picker?.allowsEditing = true
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            self.present(picker!, animated: true, completion: nil)
        }
        else
        {
            popover = UIPopoverController(contentViewController: picker!)
            popover!.present(from: chooseImageButton.frame, in: self.view, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        picker.dismiss(animated: true, completion: nil)
        profilePicImage.image = info[UIImagePickerControllerEditedImage] as? UIImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == phoneNumberTextField {
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
            print("HELLO")
        }
        
        return false
    }
    
    // MARK: - IBActions
    @IBAction func createButtonClicked(_ sender: UIButton) {
        
        // Show activity indicator
        myActivityIndicator.startAnimating()
        var canContinue = true
        
        // Check validity of each text field
        if fullNameTextField.text!.isBlank {
            invalidNameLabel.isHidden = false
            canContinue = false
        } else {
            invalidNameLabel.isHidden = true
        }
        if !emailTextField.text!.isEmail {
            invalidEmailLabel.isHidden = false
            canContinue = false
        } else {
            invalidEmailLabel.isHidden = true
        }
        if passwordTextField.text?.characters.count < 8 {
            invalidPasswordLabel.isHidden = false
            canContinue = false
        } else {
            invalidPasswordLabel.isHidden = true
        }
        if !phoneNumberTextField.text!.isPhoneNumber {
            invalidPhoneNumberLabel.isHidden = false
            canContinue = false
        } else {
            invalidPhoneNumberLabel.isHidden = true
        }
        
        // Check for existing email here
        if (canContinue) {
            // Open Connection to PHP Service
            let requestURL: URL = URL(string: "http://www.gobringit.com/CHADservice.php")!
            let urlRequest = URLRequest(url: requestURL)
            let session = URLSession.shared
            let task = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) -> Void in
                print("Task completed")
                if let data = data {
                    do {
                        let httpResponse = response as! HTTPURLResponse
                        let statusCode = httpResponse.statusCode
                        
                        // Check HTTP Response
                        if (statusCode == 200) {
                            
                            do{
                                // Parse JSON
                                let json = try JSONSerialization.jsonObject(with: data, options:.allowFragments)
                                
                                for User in json as! [Dictionary<String, AnyObject>] {
                                    let emailID = User["email"] as! String
                                    print(emailID)
                                    
                                    // Verify email
                                    if (emailID == self.emailTextField.text) {
                                        OperationQueue.main.addOperation {
                                            self.invalidEmailLabel.isHidden = false
                                            self.invalidEmailLabel.text = "This email is already associated with an account."
                                            canContinue = false
                                        }
                                    }
                                }
                                
                                OperationQueue.main.addOperation {
                                    // End activity indicator animation
                                    self.myActivityIndicator.stopAnimating()
                                    
                                    if canContinue {
                                        // Hide error messages
                                        self.invalidNameLabel.isHidden = true
                                        self.invalidEmailLabel.isHidden = true
                                        self.invalidPasswordLabel.isHidden = true
                                        self.invalidPhoneNumberLabel.isHidden = true
                                        
                                        // Reset canContinue variable
                                        canContinue = false
                                        
                                        self.performSegue(withIdentifier: "toAddressInfo", sender: self)
                                    }
                                }
                            }
                            
                        }
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                } else if let error = error {
                    print(error.localizedDescription)
                }
            }) 
            task.resume()
        }
    }
    
    @IBAction func xButtonClicked(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        
        // End activity indicator animation
        myActivityIndicator.stopAnimating()
        
        // Hide error messages
        invalidNameLabel.isHidden = true
        invalidEmailLabel.isHidden = true
        invalidPasswordLabel.isHidden = true
        invalidPhoneNumberLabel.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toAddressInfo" {
            // Send initial data to next screen
            let VC = segue.destination as! AddressInfoViewController
            
            VC.fullName = fullNameTextField.text!
            VC.email = emailTextField.text!
            VC.password = passwordTextField.text!
            VC.phoneNumber = phoneNumberTextField.text!
        }
        
    }
    
}

extension String {
    
    //To check text field or String is blank or not
    var isBlank: Bool {
        get {
            let trimmed = trimmingCharacters(in: CharacterSet.whitespaces)
            return trimmed.isEmpty
        }
    }
    
    //Validate Email
    var isEmail: Bool {
        do {
            let regex = try NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
            return regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.characters.count)) != nil
        } catch {
            return false
        }
    }
    
    //validate PhoneNumber
    var isPhoneNumber: Bool {
        let PHONE_REGEX = "^\\(\\d{3}\\)\\s\\d{3}-\\d{4}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: self)
        return result
    }
    
    //validate Zip Code
    var isZipCode: Bool {
        let ZIP_REGEX = "^\\d{5}$"
        let zipTest = NSPredicate(format: "SELF MATCHES %@", ZIP_REGEX)
        let result =  zipTest.evaluate(with: self)
        return result
    }
}
