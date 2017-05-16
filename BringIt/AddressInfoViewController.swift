//
//  AddressInfoViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/15/16.
//  Copyright © 2016 Campus Enterprises. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class AddressInfoViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var address1TextField: B68UIFloatLabelTextField!
    @IBOutlet weak var address2TextField: B68UIFloatLabelTextField!
    @IBOutlet weak var cityTextField: B68UIFloatLabelTextField!
    @IBOutlet weak var zipTextField: B68UIFloatLabelTextField!
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var campus: UISegmentedControl!
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title
        self.title = "Address Info"
        
        // Set custom back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
        returnKeyHandler = IQKeyboardReturnKeyHandler(controller: self)
        returnKeyHandler.lastTextFieldReturnKeyType = UIReturnKeyType.done
        
        // Hide error messages
        invalidAddressLabel.isHidden = true
        invalidCitylabel.isHidden = true
        invalidZipLabel.isHidden = true
        
        // Hide activity indicator
        myActivityIndicator.stopAnimating()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - IBActions
    @IBAction func continueButtonClicked(_ sender: UIButton) {
        // Show activity indicator
        myActivityIndicator.startAnimating()
        
        var canContinue = true
        
        if address1TextField.text!.isBlank {
            invalidAddressLabel.isHidden = false
            canContinue = false
        } else {
            invalidAddressLabel.isHidden = true
        }
        if cityTextField.text!.isBlank {
            invalidCitylabel.isHidden = false
            canContinue = false
        } else {
            invalidCitylabel.isHidden = true
        }
        if !zipTextField.text!.isZipCode {
            invalidZipLabel.isHidden = false
            canContinue = false
        } else {
            invalidZipLabel.isHidden = true
        }
        
        // Hide activity indicator
        myActivityIndicator.stopAnimating()
        
        if canContinue {
            
            // Hide error messages
            invalidAddressLabel.isHidden = true
            invalidCitylabel.isHidden = true
            invalidZipLabel.isHidden = true
            
            // Reset canContinue variable
            canContinue = true
            
            performSegue(withIdentifier: "toPaymentInfo", sender: self)
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toPaymentInfo" {
            // Send initial data to next screen
            let VC = segue.destination as! PaymentInfoViewController
            
            VC.fullName = self.fullName
            VC.email = self.email
            VC.password = self.password
            VC.phoneNumber = self.phoneNumber
            let index = campus.selectedSegmentIndex
            VC.campusLocation = campus.titleForSegment(at: index)!
            VC.address1 = address1TextField.text!
            if address2TextField.text!.isBlank {
                VC.address2 = ""
            } else {
                VC.address2 = address2TextField.text!
            }
            VC.city = cityTextField.text!
            VC.zip = zipTextField.text!
        }
    }
    

}
