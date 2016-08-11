//
//  NewAddressViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 8/1/16.
//  Copyright © 2016 Campus Enterprises. All rights reserved.
//

import UIKit
import DLRadioButton
import B68UIFloatLabelTextField
import IQKeyboardManagerSwift

class NewAddressViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var campusSegmentedControl: UISegmentedControl!
    @IBOutlet weak var address1TextField: B68UIFloatLabelTextField!
    @IBOutlet weak var address2TextField: B68UIFloatLabelTextField!
    @IBOutlet weak var cityTextField: B68UIFloatLabelTextField!
    @IBOutlet weak var zipTextField: B68UIFloatLabelTextField!
    
    // Error messages
    @IBOutlet weak var invalidAddressLabel: UILabel!
    @IBOutlet weak var invalidCitylabel: UILabel!
    @IBOutlet weak var invalidZipLabel: UILabel!
    
    // Passed data
    var fullName = ""
    var email = ""
    var password = ""
    var phoneNumber = ""
    
    // Doing this and the two lines in viewDidLoad automatically handles all keyboard and textField problems!
    var returnKeyHandler : IQKeyboardReturnKeyHandler!
    
    // Enable UserDefaults
    let defaults = NSUserDefaults.standardUserDefaults()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title
        self.title = "New Address"
        
        // Set custom back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        returnKeyHandler = IQKeyboardReturnKeyHandler(controller: self)
        returnKeyHandler.lastTextFieldReturnKeyType = UIReturnKeyType.Done
        
        // Hide error messages
        invalidAddressLabel.hidden = true
        invalidCitylabel.hidden = true
        invalidZipLabel.hidden = true

        // Do any additional setup after loading the view.
    }
    
    // MARK: - IBActions
    @IBAction func continueButtonClicked(sender: UIButton) {
        
        var canContinue = true
        
        if address1TextField.text!.isBlank {
            invalidAddressLabel.hidden = false
            canContinue = false
        } else {
            invalidAddressLabel.hidden = true
        }
        if cityTextField.text!.isBlank {
            invalidCitylabel.hidden = false
            canContinue = false
        } else {
            invalidCitylabel.hidden = true
        }
        if !zipTextField.text!.isZipCode {
            invalidZipLabel.hidden = false
            canContinue = false
        } else {
            invalidZipLabel.hidden = true
        }
        
        if canContinue {
            
            // Save address to UserDefaults
            var addresses = [String]()
            
            if let addressesArray = defaults.objectForKey("Addresses") {
                addresses = addressesArray as! [String]
            }
            
            var newAddress = ""
            if address2TextField.text == "" {
                newAddress = address1TextField.text! + "\n" + cityTextField.text! + "\n" + zipTextField.text!
            } else {
                newAddress = address1TextField.text! + "\n" + address2TextField.text! + "\n" + cityTextField.text! + "\n" + zipTextField.text!
            }
            
            addresses.append(newAddress)
            defaults.setObject(addresses, forKey: "Addresses")
            defaults.setObject(addresses.count - 1, forKey: "CurrentAddressIndex")
            
            // Hide error messages
            invalidAddressLabel.hidden = true
            invalidCitylabel.hidden = true
            invalidZipLabel.hidden = true
            
            performSegueWithIdentifier("returnToDeliverTo", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
