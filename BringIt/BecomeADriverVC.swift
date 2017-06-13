//
//  BecomeADriverVC.swift
//  BringIt
//
//  Created by Alexander's MacBook on 6/4/17.
//  Copyright © 2017 Campus Enterprises. All rights reserved.
//

import UIKit
import MessageUI

class BecomeADriverVC: UIViewController, MFMailComposeViewControllerDelegate {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var applyNowButton: UIButton!
    

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
        
        self.title = "Become a Driver"
        
        applyNowButton.layer.cornerRadius = Constants.cornerRadius
    }
    
    // MARK: - Compose Email Methods
    
    @IBAction func applyNowButtonPressed(_ sender: UIButton) {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["info@campusenterprises.org"])
        mailComposerVC.setSubject("BringIt Driver Application")
        mailComposerVC.setMessageBody("[Please write your full name, age, whether you are a Duke Student (and what year if you are), the approximate number of hours you think you would be able to drive per week, and your phone number. We will contact you within 48 hours for a follow-up interview and notify you of your eligibility status within 7 days.]", isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send the e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
