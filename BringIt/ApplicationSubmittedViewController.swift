//
//  ApplicationSubmittedViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 6/18/17.
//  Copyright © 2017 Campus Enterprises. All rights reserved.
//

import UIKit

class ApplicationSubmittedViewController: UIViewController {

    @IBOutlet weak var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup UI
        setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupUI() {
        doneButton.layer.cornerRadius = Constants.cornerRadius
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        
        self.navigationController?.isNavigationBarHidden = false
        
       // Pop back to settings VC
        self.navigationController?.popToRootViewController(animated: true)
    }

}
