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
import IDZSwiftCommonCrypto

extension String {
    func sha512() -> String {
        let data = self.data(using: String.Encoding.utf8)!
        let sha : Digest = Digest(algorithm:.sha512)
        sha.update(data: data)
        let digest = sha.final()
        //var digest = [UInt8](count:Int(CC_SHA512_DIGEST_LENGTH), repeatedValue: 0)
        //CC_SHA512(data.bytes, CC_LONG(data.length), &digest)
        return hexString(fromArray: digest)
        //let hexBytes = digest.map { String(format: "%02hhx", $0) }
        //return hexBytes.joinWithSeparator("")
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
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
        returnKeyHandler = IQKeyboardReturnKeyHandler(controller: self)
        returnKeyHandler.lastTextFieldReturnKeyType = UIReturnKeyType.done
        
        // Hide error messages
        currentPasswordErrorLabel.isHidden = true
        newPasswordErrorLabel.isHidden = true
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    let defaults = UserDefaults.standard
    
    @IBAction func resetPasswordButtonPressed(_ sender: UIButton) {
        
        var canContinue = false
        
        
        let userID = self.defaults.object(forKey: "userID") as AnyObject! as! String
        
        // 1. Pull all users
        // 2. seperate out user with the user-id, save password_salt and password_hash
        // 3. Run sha512 on entered in new password + salt
        
        var isVerified = false
        var passSalt = ""
        
        // Open Connection to PHP Service
        let requestURL: URL = URL(string: "http://www.gobringit.com/CHADservice.php")!
        let urlRequest = URLRequest(url: requestURL)
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest, completionHandler: {
            (data, response, error) -> Void in
            
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            // Check HTTP Response
            if (statusCode == 200) {
                
                do{
                    // Parse JSON
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments)
                    
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
                    
                    OperationQueue.main.addOperation {
                        
                        if isVerified {
                            self.currentPasswordErrorLabel.isHidden = true
                            if self.newPassword1TextField.text == self.newPassword2TextField.text {
                                self.newPasswordErrorLabel.isHidden = true
                                
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
                                var request2 = URLRequest(url: URL(string: "http://www.gobringit.com/CHADupdatePassword.php")!, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 15)
                                
                                do {
                                    let jsonData = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions.prettyPrinted)
                                    request2.httpBody = jsonData
                                } catch let error as NSError {
                                    print(error)
                                }
                                request2.httpMethod = "POST"
                                request2.setValue("application/json", forHTTPHeaderField: "Content-Type")
                                
                                // send the request
                                let session2 = URLSession.shared
                                let task2 = session2.dataTask(with: request2, completionHandler: {
                                    (data, response, error) in
                                    
                                    print(data)
                                    print(response)
                                }) 
                                
                                task2.resume()
                                
                                
                                canContinue = true
                                
                            } else {
                                
                                self.newPasswordErrorLabel.isHidden = false
                            }
                        } else {
                            print ("don't send the passowrd1")
                            self.currentPasswordErrorLabel.isHidden = false
                        }
                        
                        //NSOperationQueue.mainQueue().addOperationWithBlock {
                        
                        if canContinue {
                            print("CAN CONTINUEEEEE")
                            self.performSegue(withIdentifier: "returnToContactInfo", sender: self)
                            self.navigationController?.popViewController(animated: true)
                        } else {
                            print ("don't send the passowrd2")
                        }
                    }
                    
                    
                } catch {
                    print("Error with Json: \(error)")
                }
            }
        }) 
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
