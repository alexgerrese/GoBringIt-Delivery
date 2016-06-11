//
//  PaymentInfoViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/15/16.
//  Copyright © 2016 Campus Enterprises. All rights reserved.
//

import UIKit
import DLRadioButton
import B68UIFloatLabelTextField
import IQKeyboardManagerSwift
import Stripe

class PaymentInfoViewController: UIViewController, STPPaymentCardTextFieldDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var creditRadioButton: DLRadioButton!
    @IBOutlet weak var debitRadioButton: DLRadioButton!
    @IBOutlet weak var cardNumberTextField: B68UIFloatLabelTextField!
    @IBOutlet weak var zipTextField: B68UIFloatLabelTextField!
    @IBOutlet weak var CVCTextField: B68UIFloatLabelTextField!
    @IBOutlet weak var expirationDateTextField: B68UIFloatLabelTextField!

    
    // Doing this and the two lines in viewDidLoad automaticaly handles all keyboard and textField problems!
    var returnKeyHandler : IQKeyboardReturnKeyHandler!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set title
        self.title = "Payment Info"
        
        // Set custom back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        returnKeyHandler = IQKeyboardReturnKeyHandler(controller: self)
        returnKeyHandler.lastTextFieldReturnKeyType = UIReturnKeyType.Done
    }
    
    // MARK: - IBActions
    
    @IBAction func saveAndFinishButtonClicked(sender: UIButton) {
        // Alex - fill in the "put_x_here" with the respective values from SignUpVC and AddressInfoVC
        // create JSON data and configure the request
        let params = ["name":"put_name_here", // from SignUpVC
                      "email":"put_email_here", // from SignUpVC
                      "phone": "put_phone_here", // from SignUpVC
                      "password": "put_password_here", // from SignUpVC
                      "address": "put_address1_here", // from AddressInfoVC
                      "apartment": "put_address2_here", // from AddressInfoVC
                      "city": "put_city_here", // from AddressInfoVC
                      "state": "put_state_here", // from AddressInfoVC
                      "zip": "put_zip_here", // from AddressInfoVC
                      "campus_loc": "put_campuslocation_here"] // from AddressInfoVC
            as Dictionary<String, String>
        
        // From SignUpVC: Full name, Email, Password, Phone #
        // From AddressInfoVC: Campus location, Address 1 (street address), Address 2 (apartment), City, Zip, Campus_loc
        // This is not being saved anywhere: PaymentInfoVC: card_type, card_number, card_zip, card_cvc, card_exp
        
        // create the request & response
        let request = NSMutableURLRequest(URL: NSURL(string: "http://www.gobring.it/CHADaddUser.php")!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 5)

        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions.PrettyPrinted)
            request.HTTPBody = jsonData
        } catch let error as NSError {
            print(error)
        }
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // send the request
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) {
            (let data, let response, let error) in
        }
        
        task.resume()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}