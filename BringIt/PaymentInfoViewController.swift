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
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    
    // Passed data
    var fullName = ""
    var email = ""
    var password = ""
    var phoneNumber = ""
    var campusLocation = ""
    var address1 = ""
    var address2 = ""
    var city = ""
    var zip = ""
    
    // Doing this and the two lines in viewDidLoad automatically handles all keyboard and textField problems!
    var returnKeyHandler : IQKeyboardReturnKeyHandler!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title
        self.title = "Payment Info"
        
        // Set custom back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        returnKeyHandler = IQKeyboardReturnKeyHandler(controller: self)
        returnKeyHandler.lastTextFieldReturnKeyType = UIReturnKeyType.Done
        
        // Hide activity indicator
        myActivityIndicator.stopAnimating()
    }
    
    // MARK: - IBActions
    
    @IBAction func saveAndFinishButtonClicked(sender: UIButton) {
        // Show activity indicator
        myActivityIndicator.startAnimating()
        
        // Save address to UserDefaults
        var addresses = [String]()
        
        if let addressesArray = defaults.objectForKey("Addresses") {
            addresses = addressesArray as! [String]
        }
        
        var newAddress = ""
        if address2 == "" {
            newAddress = address1 + "\n" + city + "\n" + zip
        } else {
            newAddress = address1 + "\n" + address2 + "\n" + city + "\n" + zip
        }
        
        addresses.append(newAddress)
        defaults.setObject(addresses, forKey: "Addresses")
        defaults.setObject(addresses.count - 1, forKey: "CurrentAddressIndex")
        defaults.setObject(fullName, forKey: "userName")
        
        // Create JSON data and configure the request
        let params = ["name": fullName, // from SignUpVC
            "email": email, // from SignUpVC
            "phone": phoneNumber, // from SignUpVC
            "password": password, // from SignUpVC
            "address": address1, // from AddressInfoVC
            "apartment": address2, // from AddressInfoVC
            "city": city, // from AddressInfoVC
            "state": "NC", // from AddressInfoVC
            "zip": zip, // from AddressInfoVC
            "campus_loc": campusLocation] // from AddressInfoVC
            as Dictionary<String, String>
        
        // This is not being saved anywhere: PaymentInfoVC: card_type, card_number, card_zip, card_cvc, card_exp
        
        // create the request & response
        let request = NSMutableURLRequest(URL: NSURL(string: "http://www.gobring.it/CHADaddUser.php")!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 15)
        
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
        
        // Query accounts DB and get uid for email-phone combination
        // Open Connection to PHP Service
        let requestURL1: NSURL = NSURL(string: "http://www.gobring.it/CHADservice.php")!
        let urlRequest1: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL1)
        let session1 = NSURLSession.sharedSession()
        let task1 = session1.dataTaskWithRequest(urlRequest1) {
            (data, response, error) -> Void in
            
            let httpResponse = response as! NSHTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            // Check HTTP Response
            if (statusCode == 200) {
                
                do{
                    // Parse JSON
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
                    
                    for User in json as! [Dictionary<String, AnyObject>] {
                        let emailID = User["email"] as! String
                        let phoneID = User["phone"] as! String
                        
                        // Verify email and hashed password
                        if (emailID == self.email && phoneID == self.phoneNumber) {
                            NSOperationQueue.mainQueue().addOperationWithBlock {
                                // Update UserDefaults
                                self.defaults.setBool(true, forKey: "loggedIn")
                                self.defaults.setObject(User["uid"] as! String, forKey: "userID")
                                print((User["uid"] as! String, forKey: "userID"))
                            }
                        }
                    }
                } catch {
                    print("Error with Json: \(error)")
                }
            }
        }
        
        task1.resume()
        
        // Stop animating activity indicator and enter app
        myActivityIndicator.stopAnimating()
        self.defaults.setBool(true, forKey: "loggedIn")
        performSegueWithIdentifier("toHomeFromSignUp", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}