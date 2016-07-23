//
//  ContactInfoViewController
//  BringIt
//
//  Created by Alexander's MacBook on 7/23/16.
//  Copyright © 2016 Campus Enterprises. All rights reserved.
//

import UIKit
import B68UIFloatLabelTextField
import IQKeyboardManagerSwift

// Later to think about: Check if anything has changed, and if not then no need to call db

class ContactInfoViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var profilePicImage: UIImageView!
    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var fullNameTextField: B68UIFloatLabelTextField!
    @IBOutlet weak var emailTextField: B68UIFloatLabelTextField!
    @IBOutlet weak var phoneNumberTextField: B68UIFloatLabelTextField!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title
        self.title = "Contact Info"
        
        // Set custom back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        // Round profile pic image
        self.profilePicImage.layer.cornerRadius = self.profilePicImage.frame.size.width / 2
        self.profilePicImage.clipsToBounds = true
        self.profilePicImage.layer.borderWidth = 2.0
        self.profilePicImage.layer.borderColor = GREEN.CGColor
        
        returnKeyHandler = IQKeyboardReturnKeyHandler(controller: self)
        returnKeyHandler.lastTextFieldReturnKeyType = UIReturnKeyType.Done
        
        // Hide error messages
        invalidNameLabel.hidden = true
        invalidEmailLabel.hidden = true
        invalidPhoneNumberLabel.hidden = true
        phoneNumberTextField.delegate = self
        
        // TO-DO: CHAD! Please preload the user's db data so we can populate the fields!
        let fullname = ""
        let email = ""
        let phoneNum = ""
        
        //WRITE YOUR CODE HEREEEE

    }

    // MARK: - Image Picker Methods
    
    @IBAction func chooseImageClicked(sender: AnyObject) {
        let alert:UIAlertController=UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default)
        {
            UIAlertAction in
            self.openCamera()
        }
        let galleryAction = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.Default)
        {
            UIAlertAction in
            self.openGallery()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel)
        {
            UIAlertAction in
        }
        
        // Add the actions
        picker?.delegate = self
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
        
        // Present the controller
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone
        {
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else
        {
            popover = UIPopoverController(contentViewController: alert)
            popover!.presentPopoverFromRect(chooseImageButton.frame, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
        }
    }
    
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera))
        {
            picker?.sourceType = UIImagePickerControllerSourceType.Camera
            picker?.allowsEditing = true
            self .presentViewController(picker!, animated: true, completion: nil)
        }
        else
        {
            openGallery()
        }
    }
    
    func openGallery()
    {
        picker?.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        picker?.allowsEditing = true
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone
        {
            self.presentViewController(picker!, animated: true, completion: nil)
        }
        else
        {
            popover = UIPopoverController(contentViewController: picker!)
            popover!.presentPopoverFromRect(chooseImageButton.frame, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        picker.dismissViewControllerAnimated(true, completion: nil)
        profilePicImage.image = info[UIImagePickerControllerEditedImage] as? UIImage
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController)
    {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if textField == phoneNumberTextField {
            let newString = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
            let components = newString.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
            
            let decimalString : String = components.joinWithSeparator("")
            let length = decimalString.characters.count
            let decimalStr = decimalString as NSString
            let hasLeadingOne = length > 0 && decimalStr.characterAtIndex(0) == (1 as unichar)
            
            if length == 0 || (length > 10 && !hasLeadingOne) || length > 11
            {
                let newLength = (textField.text! as NSString).length + (string as NSString).length - range.length as Int
                
                return (newLength > 10) ? false : true
            }
            var index = 0 as Int
            let formattedString = NSMutableString()
            
            if hasLeadingOne
            {
                formattedString.appendString("1 ")
                index += 1
            }
            if (length - index) > 3
            {
                let areaCode = decimalStr.substringWithRange(NSMakeRange(index, 3))
                formattedString.appendFormat("(%@) ", areaCode)
                index += 3
            }
            if length - index > 3
            {
                let prefix = decimalStr.substringWithRange(NSMakeRange(index, 3))
                formattedString.appendFormat("%@-", prefix)
                index += 3
            }
            
            let remainder = decimalStr.substringFromIndex(index)
            formattedString.appendString(remainder)
            textField.text = formattedString as String
            print("HELLO")
        }
        
        return false
    }
    
    // MARK: - IBActions
    @IBAction func saveButtonClicked(sender: UIButton) {
        
        // Show activity indicator
        myActivityIndicator.startAnimating()
        
        var canContinue = true
        
        // Check validity of each text field
        if fullNameTextField.text!.isBlank {
            invalidNameLabel.hidden = false
            canContinue = false
        } else {
            invalidNameLabel.hidden = true
        }
        if !emailTextField.text!.isEmail {
            invalidEmailLabel.hidden = false
            canContinue = false
        } else {
            invalidEmailLabel.hidden = true
        }
        if !phoneNumberTextField.text!.isPhoneNumber {
            invalidPhoneNumberLabel.hidden = false
            canContinue = false
        } else {
            invalidPhoneNumberLabel.hidden = true
        }
        
        if canContinue {
        // Hide error messages
        self.invalidNameLabel.hidden = true
        self.invalidEmailLabel.hidden = true
        self.invalidPhoneNumberLabel.hidden = true
            
        // TO-DO: CHAD! Please save the new user data to the db here!!!
        //WRITE CODE HEREEEEE
            
        // Reset canContinue variable
        canContinue = false
            
        // End activity indicator animation
        self.myActivityIndicator.stopAnimating()
            
        // Perform unwind segue
        self.performSegueWithIdentifier("returnToSettings", sender: self)

        } else {
            // End activity indicator animation
            self.myActivityIndicator.stopAnimating()
            self.myActivityIndicator.hidden = true
        }
    }
    
    @IBAction func returnToContactInfo(segue: UIStoryboardSegue) {
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