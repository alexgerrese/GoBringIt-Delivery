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

class SignInViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var emailTextField: B68UIFloatLabelTextField!
    @IBOutlet weak var passwordTextField: B68UIFloatLabelTextField!
    @IBOutlet weak var loginErrorMessageLabel: UILabel!
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var returnKeyHandler : IQKeyboardReturnKeyHandler!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set light status bar
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        // Automatically handle all keyboard and textField problems!
        returnKeyHandler = IQKeyboardReturnKeyHandler(controller: self)
        returnKeyHandler.lastTextFieldReturnKeyType = UIReturnKeyType.Done
        
        // Initially hide error label and activity indicator
        loginErrorMessageLabel.hidden = true
        myActivityIndicator.stopAnimating()
    }
    
    override func viewWillAppear(animated: Bool) {
        let defaults = NSUserDefaults.standardUserDefaults()
        let loggedIn = defaults.boolForKey("loggedIn")
        if loggedIn {
            checkIfFirstOrder()
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    // Sign in if credentials match with existing backend entry
    @IBAction func signInButtonClicked(sender: UIButton) {
    
        myActivityIndicator.startAnimating()
        
        var canLogin = false
        
        // Open Connection to PHP Service
        let requestURL: NSURL = NSURL(string: "http://www.gobring.it/CHADservice.php")!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(urlRequest) {
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
                        
                        // Verify email and hashed password
                        if (emailID == self.emailTextField.text) {
                            let passSalt = User["password_salt"] as! String
                            let passTotal = self.passwordTextField.text! + passSalt
                            if ((passTotal.sha512()) == (User["password_hash"] as! String)) {
                                // User is verified
                                canLogin = true
                                NSOperationQueue.mainQueue().addOperationWithBlock {
                                    // Reset views
                                    self.loginErrorMessageLabel.hidden = true
                                    self.myActivityIndicator.stopAnimating()
                                    self.myActivityIndicator.hidden = true
                                    
                                    // Update UserDefaults 
                                    self.defaults.setBool(true, forKey: "loggedIn")
                                    self.defaults.setObject(User["name"] as! String, forKey: "userName")
                                    self.defaults.setObject(User["uid"] as! String, forKey: "userID")
                                    self.checkIfFirstOrder()
                                    
                                    self.dismissViewControllerAnimated(true, completion: nil)
                                }
                            }
                        }
                    }
                    
                    // User not verified
                    if (!canLogin) {
                        NSOperationQueue.mainQueue().addOperationWithBlock {
                            self.loginErrorMessageLabel.hidden = false
                            self.myActivityIndicator.stopAnimating()
                            self.myActivityIndicator.hidden = true
                        }
                    }
                    
                } catch {
                    print("Error with Json: \(error)")
                }
            }
        }
        
        task.resume()
    }
    
    @IBAction func xButtonPressed(sender: UIButton) {
        comingFromSignIn = true
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func checkIfFirstOrder() {
        var alreadyO = true
        if let aO = defaults.objectForKey("alreadyOrdered") {
            alreadyO = aO as! Bool
        } else {
            alreadyO = false
        }
        if alreadyO {
            print("First order has already been saved to userDefaults.")
        } else {
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
                            let userID = User["uid"] as! String
                            
                            // Verify email and hashed password
                            if (self.defaults.objectForKey("userID") as! String == userID) {
                                NSOperationQueue.mainQueue().addOperationWithBlock {
                                    let alreadyOrdered = User["already_ordered"] as! String
                                    if alreadyOrdered == "0" {
                                        // Update UserDefaults
                                        self.defaults.setBool(false, forKey: "alreadyOrdered")
                                        print("First order has now been saved to userDefaults")
                                    }
                                }
                            }
                        }
                    } catch {
                        print("Error with Json: \(error)")
                    }
                }
            }
            
            task1.resume()
        }
    }
    
    @IBAction func rewindFromSignUp(segue: UIStoryboardSegue) {
    }
}
