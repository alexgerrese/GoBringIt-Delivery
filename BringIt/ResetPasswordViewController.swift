//
//  ResetPasswordViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 7/23/16.
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

class ResetPasswordViewController: UIViewController {
    
    //MARK: - IBOutlets
    
    // Text fields
    @IBOutlet weak var currentPasswordTextField: B68UIFloatLabelTextField!
    @IBOutlet weak var newPassword1TextField: B68UIFloatLabelTextField!
    @IBOutlet weak var newPassword2TextField: B68UIFloatLabelTextField!
    
    // Alert messages
    @IBOutlet weak var currentPasswordErrorLabel: UILabel!
    @IBOutlet weak var newPasswordErrorLabel: UILabel!
    
    // Doing this and the two lines in ViewDidLoad automatically handles all keyboard and textField problems!
    var returnKeyHandler : IQKeyboardReturnKeyHandler!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title
        self.title = "Reset Password"
        
        // Set custom back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        returnKeyHandler = IQKeyboardReturnKeyHandler(controller: self)
        returnKeyHandler.lastTextFieldReturnKeyType = UIReturnKeyType.Done
        
        // Hide error messages
        currentPasswordErrorLabel.hidden = true
        newPasswordErrorLabel.hidden = true
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    @IBAction func resetPasswordButtonPressed(sender: UIButton) {
        
        var canContinue = false
        
        
        let userID = self.defaults.objectForKey("userID") as AnyObject! as! String
        
        // 1. Pull all users
        // 2. seperate out user with the user-id, save password_salt and password_hash
        // 3. Run sha512 on entered in new password + salt
        
        var isVerified = false
        var passSalt = ""
        
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
                        let userID_DB = User["uid"] as! String
                        
                        // Verify email and hashed password
                        if (userID == userID_DB) {
                            passSalt = User["password_salt"] as! String
                            let passTotal = self.currentPasswordTextField.text! + passSalt
                            if ((passTotal.sha512()) == (User["password_hash"] as! String)) {
                                // User is verified
                                isVerified = true
                                print("THe USER is Verified")
                            }
                        }
                    }
                    
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        
                        if isVerified {
                            self.currentPasswordErrorLabel.hidden = true
                            if self.newPassword1TextField.text == self.newPassword2TextField.text {
                                self.newPasswordErrorLabel.hidden = true
                                
                                // Task 2 is used later
                                // Create JSON data and configure the request
                                let params = ["uid": userID,
                                    "password": self.newPassword1TextField.text!,
                                    "salt": passSalt,
                                    ]
                                    as Dictionary<String, String>
                                
                                print(userID)
                                print(self.currentPasswordTextField.text!)
                                print(passSalt)
                                
                                // create the request & response
                                let request2 = NSMutableURLRequest(URL: NSURL(string: "http://www.gobring.it/CHADupdatePassword.php")!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 15)
                                
                                do {
                                    let jsonData = try NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions.PrettyPrinted)
                                    request2.HTTPBody = jsonData
                                } catch let error as NSError {
                                    print(error)
                                }
                                request2.HTTPMethod = "POST"
                                request2.setValue("application/json", forHTTPHeaderField: "Content-Type")
                                
                                // send the request
                                let session2 = NSURLSession.sharedSession()
                                let task2 = session2.dataTaskWithRequest(request2) {
                                    (let data, let response, let error) in
                                    
                                    print(data)
                                    print(response)
                                }
                                
                                task2.resume()
                                
                                
                                canContinue = true
                                
                            } else {
                                
                                self.newPasswordErrorLabel.hidden = false
                            }
                        } else {
                            print ("don't send the passowrd1")
                            self.currentPasswordErrorLabel.hidden = false
                        }
                        
                        //NSOperationQueue.mainQueue().addOperationWithBlock {
                        
                        if canContinue {
                            print("CAN CONTINUEEEEE")
                            self.performSegueWithIdentifier("returnToContactInfo", sender: self)
                            
                        } else {
                            print ("don't send the passowrd2")
                        }
                    }
                    
                    
                } catch {
                    print("Error with Json: \(error)")
                }
            }
        }
        
        task.resume()
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
