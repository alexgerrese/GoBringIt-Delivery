//
//  ContactInfoViewController
//  BringIt
//
//  Created by Alexander's MacBook on 7/23/16.
//  Copyright © 2016 Campus Enterprises. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

// Later to think about: Check if anything has changed, and if not then no need to call db

class ContactInfoViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var profilePicImage: UIImageView!
    @IBOutlet weak var chooseImageButton: UIButton!
//    @IBOutlet weak var fullNameTextField: B68UIFloatLabelTextField!
//    @IBOutlet weak var emailTextField: B68UIFloatLabelTextField!
//    @IBOutlet weak var phoneNumberTextField: B68UIFloatLabelTextField!
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    
    // Error messages
    @IBOutlet weak var invalidNameLabel: UILabel!
    @IBOutlet weak var invalidEmailLabel: UILabel!
    @IBOutlet weak var invalidPhoneNumberLabel: UILabel!
    
    // Variables to choose profile pic
    var picker: UIImagePickerController? = UIImagePickerController()
    var popover: UIPopoverController? = nil
    
    // Doing this and the two lines in ViewDidLoad automatically handles all keyboard and textField problems!
    var returnKeyHandler : IQKeyboardReturnKeyHandler!
    
    let defaults = UserDefaults.standard
    var userID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title
        self.title = "Contact Info"
        
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
        invalidPhoneNumberLabel.isHidden = true
        phoneNumberTextField.delegate = self
        
        // Set userID
        if let id = self.defaults.object(forKey: "userID") {
            userID = id as! String
        }
        
        var fullname = ""
        var email = ""
        var phoneNum = ""
        
        // Start activity indicator
        myActivityIndicator.startAnimating()
        
        // Make call to accounts DB
        // Check if uid == userID
        // Pull name, email, phone
        let requestURL1: URL = URL(string: "http://www.gobringit.com/CHADservice.php")!
        let urlRequest1 = URLRequest(url: requestURL1)
        let session1 = URLSession.shared
        let task1 = session1.dataTask(with: urlRequest1, completionHandler: {
            (data, response, error) -> Void in
            
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            // Check HTTP Response
            if (statusCode == 200) {
                
                do{
                    // Parse JSON
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments)
                    
                    for User in json as! [Dictionary<String, AnyObject>] {
                        let user_id = User["uid"] as! String
                        if (user_id == self.userID) {
                            fullname = User["name"] as! String
                            email = User["email"] as! String
                            phoneNum = User["phone"] as! String
                            
                            OperationQueue.main.addOperation {
                                // I think this should reload the labels, not sure
                                self.fullNameTextField.text = fullname
                                self.emailTextField.text = email
                                self.phoneNumberTextField.text = phoneNum
                                
                                // Start activity indicator
                                self.myActivityIndicator.stopAnimating()
                            }
                        }
                    }
                } catch {
                    print("Error with Json: \(error)")
                }
            }
        }) 
        task1.resume()
        
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
        }
        
        return false
    }
    
    // MARK: - IBActions
    @IBAction func saveButtonClicked(_ sender: UIButton) {
        
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
        if !phoneNumberTextField.text!.isPhoneNumber {
            invalidPhoneNumberLabel.isHidden = false
            canContinue = false
        } else {
            invalidPhoneNumberLabel.isHidden = true
        }
        
        if canContinue {
            // Hide error messages
            self.invalidNameLabel.isHidden = true
            self.invalidEmailLabel.isHidden = true
            self.invalidPhoneNumberLabel.isHidden = true
            
            // Create JSON data and configure the request
            let params = ["uid": userID,
                          "name": self.fullNameTextField.text!,
                          "phone": self.phoneNumberTextField.text!,
                          "email": self.emailTextField.text!,
                          ]
                as Dictionary<String, String>
            
            // create the request & response
            var request2 = URLRequest(url: URL(string: "http://www.gobringit.com/CHADupdateAccount.php")!, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 15)
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions.prettyPrinted)
                request2.httpBody = jsonData
            } catch let error as NSError {
                print(error)
            }
            request2.httpMethod = "POST"
            request2.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // send the request
            let session2 = URLSession.shared
            let task2 = session2.dataTask(with: request2, completionHandler: {
                (data, response, error) in
                
                print(data)
                print(response)
                
                OperationQueue.main.addOperation {
                    // Reset canContinue variable
                    canContinue = false
                    
                    self.defaults.set(self.fullNameTextField, forKey: "userName")
                    
                    // End activity indicator animation
                    self.myActivityIndicator.stopAnimating()
                    
                    // Perform unwind segue
                    self.performSegue(withIdentifier: "returnToSettings", sender: self)
                }
            }) 
            
            task2.resume()
        
        } else {
            // End activity indicator animation
            self.myActivityIndicator.stopAnimating()
            self.myActivityIndicator.isHidden = true
        }
    }
    
    @IBAction func returnToContactInfo(_ segue: UIStoryboardSegue) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    /*override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     
     if segue.identifier == "toAddressInfo" {
     // Send initial data to next screen
     let VC = segue.destinationViewController as! AddressInfoViewController
     
     VC.fullName = fullNameTextField.text!
     VC.email = emailTextField.text!
     VC.password = passwordTextField.text!
     VC.phoneNumber = phoneNumberTextField.text!
     }
     
     }*/
    
}
