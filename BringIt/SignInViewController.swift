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

extension String {
    func sha512() -> String {
        let data = self.dataUsingEncoding(NSUTF8StringEncoding)!
        var digest = [UInt8](count:Int(CC_SHA512_DIGEST_LENGTH), repeatedValue: 0)
        CC_SHA512(data.bytes, CC_LONG(data.length), &digest)
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joinWithSeparator("")
    }
}

class SignInViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var emailTextField: B68UIFloatLabelTextField!
    @IBOutlet weak var passwordTextField: B68UIFloatLabelTextField!
    @IBOutlet weak var loginErrorMessageLabel: UILabel!
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    
    var returnKeyHandler : IQKeyboardReturnKeyHandler!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Automatically handle all keyboard and textField problems!
        returnKeyHandler = IQKeyboardReturnKeyHandler(controller: self)
        returnKeyHandler.lastTextFieldReturnKeyType = UIReturnKeyType.Done
        
        // Initially hide error label
        loginErrorMessageLabel.hidden = true
        
        myActivityIndicator.stopAnimating()
    }
    
    override func viewDidAppear(animated: Bool) {
        displayWalkthroughs()
    }
    
    // Sign in if credentials match with existing backend entry
    @IBAction func signInButtonClicked(sender: UIButton) {
    
        myActivityIndicator.startAnimating()
        
        var canLogin = false
        //customActivityIndicator.startAnimation()
        
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
                                    self.loginErrorMessageLabel.hidden = true
                                    self.myActivityIndicator.stopAnimating()
                                    self.performSegueWithIdentifier("toHome", sender: self)
                                }
                                
                            }
                        }
                    }
                    
                    // User not verified
                    if (canLogin == false) {
                        NSOperationQueue.mainQueue().addOperationWithBlock {
                            self.loginErrorMessageLabel.hidden = false
                            self.myActivityIndicator.stopAnimating()
                        }
                    }
                    
                } catch {
                    print("Error with Json: \(error)")
                }
            }
        }
        
        task.resume()
    }
    
    // Check if walkthrough has been shown, then show if needed
    func displayWalkthroughs() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let displayedWalkthrough = userDefaults.boolForKey("displayedWalkthrough")
        
        if !displayedWalkthrough {
            if let pageViewController = storyboard?.instantiateViewControllerWithIdentifier("PageViewController") {
                self.presentViewController(pageViewController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func rewindFromSignUp(segue: UIStoryboardSegue) {
    }
}
