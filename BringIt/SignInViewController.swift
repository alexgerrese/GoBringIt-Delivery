//
//  SignInViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/15/16.
//  Copyright © 2016 Campus Enterprises. All rights reserved.
//

import UIKit
import B68UIFloatLabelTextField
import IQKeyboardManagerSwift
//import AFNetworking
import Stripe

class SignInViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var emailTextField: B68UIFloatLabelTextField!
    @IBOutlet weak var passwordTextField: B68UIFloatLabelTextField!
    @IBOutlet weak var loginErrorMessageLabel: UILabel!
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    
    let defaults = UserDefaults.standard
    
    var returnKeyHandler : IQKeyboardReturnKeyHandler!
    var name = ""
    var email = ""
    var uid = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set light status bar
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        
        // Automatically handle all keyboard and textField problems!
        returnKeyHandler = IQKeyboardReturnKeyHandler(controller: self)
        returnKeyHandler.lastTextFieldReturnKeyType = UIReturnKeyType.done
        
        // Initially hide error label and activity indicator
        loginErrorMessageLabel.isHidden = true
        myActivityIndicator.stopAnimating()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let defaults = UserDefaults.standard
        let loggedIn = defaults.bool(forKey: "loggedIn")
        if loggedIn {
            checkIfFirstOrder()
            dismiss(animated: true, completion: nil)
        }
    }
    
    // Sign in if credentials match with existing backend entry
    @IBAction func signInButtonClicked(_ sender: UIButton) {
        
        print("SIGN IN BUTTON CLICKED")
    
        myActivityIndicator.startAnimating()
        
        var canLogin = false
        
        // Open Connection to PHP Service
        let requestURL: URL = URL(string: "http://www.gobringit.com/CHADservice.php")!
        let urlRequest = URLRequest(url: requestURL)
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest, completionHandler: {
            (data, response, error) -> Void in
            
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            print("AFTER RECEIVING HTTP RESPONSE")
            
            // Check HTTP Response
            if (statusCode == 200) {
                
                do{
                    // Parse JSON
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments)
                    
                    for User in json as! [Dictionary<String, AnyObject>] {
                        let emailID = User["email"] as! String
                        
                        print("BEFORE VERIFYING EMAIL AND PASSWORD")
                        
                        // Verify email and hashed password
                        if (emailID == self.emailTextField.text) {
                            let passSalt = User["password_salt"] as! String
                            let passTotal = self.passwordTextField.text! + passSalt
                            if ((passTotal.sha512()) == (User["password_hash"] as! String)) {
                                // User is verified
                                canLogin = true
                                OperationQueue.main.addOperation {
                                    // Reset views
                                    self.loginErrorMessageLabel.isHidden = true
                                    self.myActivityIndicator.stopAnimating()
                                    self.myActivityIndicator.isHidden = true
                                    
                                    print("BEFORE SAVING TO USERDEFAULTS")
                                    // Update UserDefaults 
                                    self.defaults.set(true, forKey: "loggedIn")
                                    self.defaults.set(User["name"] as! String, forKey: "userName")
                                    self.defaults.set(User["uid"] as! String, forKey: "userID")
                                    self.checkIfFirstOrder()
                                    
                                    self.dismiss(animated: true, completion: nil)
                                }
                            }
                        }
                    }
                    
                    // User not verified
                    if (!canLogin) {
                        OperationQueue.main.addOperation {
                            self.loginErrorMessageLabel.isHidden = false
                            self.myActivityIndicator.stopAnimating()
                            self.myActivityIndicator.isHidden = true
                        }
                    }
                    
                } catch {
                    print("Error with Json: \(error)")
                }
            }
        }) 
        
        task.resume()
    }
    
    @IBAction func xButtonPressed(_ sender: UIButton) {
        comingFromSignIn = true
        self.dismiss(animated: true, completion: nil)
    }
    
    func checkIfFirstOrder() {        
        var alreadyO = true
        if let aO = defaults.object(forKey: "alreadyOrdered") {
            alreadyO = aO as! Bool
        } else {
            alreadyO = false
        }
        if alreadyO {
            print("First order has already been saved to userDefaults.")
        } else {
            // Query accounts DB and get uid for email-phone combination
            // Open Connection to PHP Service
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
                            let userID = User["uid"] as! String
                            
                            // Verify email and hashed password
                            if (self.defaults.object(forKey: "userID") as! String == userID) {
                                OperationQueue.main.addOperation {
                                    self.name = User["name"] as! String
                                    
                                    // Create Stripe customer if doesn't already exist
                                    if let stripeID = User["stripe_cust_id"] as? String {
                                        print("Is Stripe Customer with id: \(stripeID)")
                                        self.defaults.set(stripeID, forKey: "stripeCustomerID")
                                    } else {
                                        print("IS not a Stripe Customer")
                                        self.defaults.set("", forKey: "stripeCustomerID")
                                    }
                                    
                                    print(self.defaults.object(forKey: "stripeCustomerID")) 
                                    
                                    // Set alreadyOrdered
                                    let alreadyOrdered = User["already_ordered"] as! String
                                    if alreadyOrdered == "0" {
                                        // Update UserDefaults
                                        self.defaults.set(false, forKey: "alreadyOrdered")
                                        print("First order has now been saved to userDefaults")
                                    }
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
    }
    
    @IBAction func rewindFromSignUp(_ segue: UIStoryboardSegue) {
    }
}
