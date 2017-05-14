//
//  SignIn-SignUpViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/14/17.
//  Copyright © 2017 Campus Enterprises. All rights reserved.
//

//THINGS TO MAKE CODE BETTER:
//    - Make a global constants page and extend it in each other page

import UIKit
import IQKeyboardManagerSwift
import Stripe
//import Alomafire
//import Moya

class SignIn_SignUpViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var emailAddressView: UIView!
    @IBOutlet weak var emailAddress: UITextField!
    
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    // MARK: - Variables
    let CORNER_RADIUS = 3 // TO-DO: Make this global

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup text field and button UI
        emailAddressView.layer.cornerRadius = CORNER_RADIUS
        passwordView.layer.cornerRadius = CORNER_RADIUS
        signInButton.layer.cornerRadius = CORNER_RADIUS
        signUpButton.layer.cornerRadius = CORNER_RADIUS

    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBarHidden = false
    }
    
    // Verify credentials and sign in
    @IBAction func signInButtonTapped(_ sender: UIButton) {
        
        // Animate activity indicator
        
        // Send network request and process response IN BACKGROUND THREAD
        
            // If ok, then do some UserDefaults setup (and Stripe stuff?) and continue
        
            // If not ok, show error message on button and try again
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
