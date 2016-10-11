//
//  PaymentInfoViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/15/16.
//  Copyright © 2016 Campus Enterprises. All rights reserved.
//

import UIKit
import B68UIFloatLabelTextField
import IQKeyboardManagerSwift

class PaymentInfoViewController: UIViewController {
    
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
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title
        self.title = "Payment Info"
        
        // Set custom back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
        returnKeyHandler = IQKeyboardReturnKeyHandler(controller: self)
        returnKeyHandler.lastTextFieldReturnKeyType = UIReturnKeyType.done
        
        // Hide activity indicator
        myActivityIndicator.stopAnimating()
    }
    
    // MARK: - IBActions
    
    @IBAction func saveAndFinishButtonClicked(_ sender: UIButton) {
        // Show activity indicator
        myActivityIndicator.startAnimating()
        
        // Save address to UserDefaults
        var addresses = [String]()
        
        if let addressesArray = defaults.object(forKey: "Addresses") {
            addresses = addressesArray as! [String]
        }
        
        var newAddress = ""
        if address2 == "" {
            newAddress = address1 + "\n" + city + "\n" + zip
        } else {
            newAddress = address1 + "\n" + address2 + "\n" + city + "\n" + zip
        }
        
        addresses.append(newAddress)
        defaults.set(addresses, forKey: "Addresses")
        defaults.set(addresses.count - 1, forKey: "CurrentAddressIndex")
        defaults.set(fullName, forKey: "userName")
        
        // Create JSON data and configure the request
        let params = ["name": fullName, // from SignUpVC
            "email": email, // from SignUpVC
            "phone": phoneNumber, // from SignUpVC
            "password": password, // from SignUpVC
            "address": address1, // from AddressInfoVC
            "apartment": address2, // from AddressInfoVC
            "city": city, // from AddressInfoVC
            "state": "NC", // from AddressInfoVC
            "zip": zip] // from AddressInfoVC
            as Dictionary<String, String>//"campus_loc": campusLocation] // from AddressInfoVC
        
        print(fullName)
        print(address1)
        print(city)
        print(zip)
        print(campusLocation)
        
        
        // create the request & response
        var request = URLRequest(url: URL(string: "http://www.gobringit.com/CHADaddUser.php")!, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 15)
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions.prettyPrinted)
            request.httpBody = jsonData
        } catch let error as NSError {
            print(error)
        }
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // send the request
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: {
            (data, response, error) in
        }) 
        
        task.resume()
        
        // Query accounts DB and get uid for email-phone combination
        // Open Connection to PHP Service
        let requestURL1: URL = URL(string: "http://www.gobringit.com/CHADservice.php")!
        let urlRequest1: URLRequest = URLRequest(url: requestURL1)
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
                        let emailID = User["email"] as! String
                        let phoneID = User["phone"] as! String
                        
                        // Verify email and hashed password
                        if (emailID == self.email && phoneID == self.phoneNumber) {
                            OperationQueue.main.addOperation {
                                
                                print("SUCCESSFULLY RETRIEVED NEWLY CREATED USER! WOOHOO!")
                                
                                // Update UserDefaults
                                self.defaults.set("", forKey: "stripeCustomerID")
                                self.defaults.set(true, forKey: "loggedIn")
                                self.defaults.set(User["uid"] as! String, forKey: "userID")
                                print((User["uid"] as! String, forKey: "userID"))
                                print(self.defaults.object(forKey: "stripeCustomerID"))
                                print(self.defaults.object(forKey: "loggedIn"))
                                print(self.defaults.object(forKey: "userID"))
                                
                                // Stop animating activity indicator and enter app
                                self.myActivityIndicator.stopAnimating()
                                //self.defaults.setBool(true, forKey: "loggedIn")
                                comingFromSignIn = true
                                self.dismiss(animated: true, completion: nil)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
