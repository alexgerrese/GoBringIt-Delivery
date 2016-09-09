//
//  PayingWithViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 8/22/16.
//  Copyright © 2016 Campus Enterprises. All rights reserved.
//

import UIKit
import Stripe
import AFNetworking

class PayingWithViewController: UIViewController, STPPaymentContextDelegate {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var useFoodPointsSwitch: UISwitch!
    @IBOutlet weak var currentCreditCardLabel: UILabel!
    @IBOutlet weak var paymentMethodsSegmentedControl: UISegmentedControl!
    @IBOutlet weak var errorMessage: UILabel!
    
    // Stripe variables
    var paymentContext = STPPaymentContext()
    var customerID = ""
    var paymentCurrency = "usd"
    
    // Enable UserDefaults
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title
        self.title = "Payment Info"
        
        // Set up PaymentContext
        let paymentContext = STPPaymentContext(APIAdapter: MyAPIClient.sharedClient)
        let userInformation = STPUserInformation()
        paymentContext.prefilledInformation = userInformation
        paymentContext.paymentAmount = 1540 // MAKE DYNAMIC
        paymentContext.paymentCurrency = self.paymentCurrency
        self.paymentContext = paymentContext
        self.paymentContext.delegate = self
        paymentContext.hostViewController = self
        
        if let switchOn = defaults.objectForKey("useFoodPoints") {
            useFoodPointsSwitch.on = switchOn as! Bool
        } else {
            defaults.setBool(true, forKey: "useFoodPoints")
        }
        
        // Set default payment method
        if let pm = defaults.objectForKey("selectedPaymentMethod") {
            if pm as! String == "Food Points" {
                paymentMethodsSegmentedControl.selectedSegmentIndex = 0
            } else if pm as! String == "Cash" {
                paymentMethodsSegmentedControl.selectedSegmentIndex = 1
            } else {
                paymentMethodsSegmentedControl.selectedSegmentIndex = 2
            }
        } else {
            if checkIfCanUseFoodPoints() {
                paymentMethodsSegmentedControl.selectedSegmentIndex = 0
                defaults.setObject("Food Points", forKey: "selectedPaymentMethod")
            } else {
                paymentMethodsSegmentedControl.selectedSegmentIndex = 1
                defaults.setObject("Cash", forKey: "selectedPaymentMethod")
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        // Hide error message
        errorMessage.hidden = true
        
        // Set customerID
        customerID = defaults.objectForKey("stripeCustomerID") as! String
        MyAPIClient.sharedClient.customerID = self.customerID
    }
    
    @IBAction func paymentMethodChanged(sender: UISegmentedControl) {
        errorMessage.hidden = true
        print("PAYMENT METHOD CHANGED")
        
        // FOOD POINTS
        if paymentMethodsSegmentedControl.selectedSegmentIndex == 0 {
            if checkIfCanUseFoodPoints() {
                defaults.setObject("Food Points", forKey: "selectedPaymentMethod")
            } else {
                // Show error message
                errorMessage.hidden = false
                errorMessage.text = "You cannot use food points at this time. Please select another payment method."
            }
        }
        
        // CASH
        if paymentMethodsSegmentedControl.selectedSegmentIndex == 1 {
            defaults.setObject("Cash", forKey: "selectedPaymentMethod")
        }
        
        // CREDIT CARD
        if paymentMethodsSegmentedControl.selectedSegmentIndex == 2 {
            // Turn switch off if usually manually changes from food points payment method when those are available
            if checkIfCanUseFoodPoints() {
                if useFoodPointsSwitch.on {
                    useFoodPointsSwitch.on = false
                }
            }
            // Make sure a credit card exists
            if paymentMethodsSegmentedControl.titleForSegmentAtIndex(2) == "Credit Card" {
                // Show error message
                errorMessage.hidden = false
                errorMessage.text = "Please add a credit card and try again."
            } else {
                defaults.setObject(paymentMethodsSegmentedControl.titleForSegmentAtIndex(2), forKey: "selectedPaymentMethod")
            }
        }
    }
    
    @IBAction func switchPressed(sender: UISwitch) {
        if sender.on {
            defaults.setBool(true, forKey: "useFoodPoints")
        } else {
            defaults.setBool(false, forKey: "useFoodPoints")
        }
    }
    
    // MARK: Payment Actions
    
    @IBAction func manageCardsButtonPreseed(sender: UIButton) {
        self.paymentContext.pushPaymentMethodsViewController()
    }
    
    func handleError(error: NSError) {
        print(error)
        UIAlertView(title: "Please Try Again",
                    message: error.localizedDescription,
                    delegate: nil,
                    cancelButtonTitle: "OK").show()
        
    }
    
    // MARK: STPPaymentContextDelegate
    
    func paymentContext(paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: STPErrorBlock) {
        MyAPIClient.sharedClient.completeCharge(paymentResult, amount: self.paymentContext.paymentAmount,
                                                completion: completion)
    }
    
    func paymentContext(paymentContext: STPPaymentContext, didFinishWithStatus status: STPPaymentStatus, error: NSError?) {
        let title: String
        let message: String
        switch status {
        case .Error:
            title = "Error"
            message = error?.localizedDescription ?? ""
        case .Success:
            title = "Success"
            message = "You bought a!"
        case .UserCancellation:
            return
        }
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(action)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func paymentContextDidChange(paymentContext: STPPaymentContext) {
        if let paymentMethod = paymentContext.selectedPaymentMethod {
            paymentMethodsSegmentedControl.setTitle(paymentMethod.label, forSegmentAtIndex: 2)
        }
        else {
            paymentMethodsSegmentedControl.setTitle("Credit Card", forSegmentAtIndex: 2)
        }
    }
    
    func paymentContext(paymentContext: STPPaymentContext, didFailToLoadWithError error: NSError) {
        let alertController = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .Alert
        )
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: { action in
            self.navigationController?.popViewControllerAnimated(true)
        })
        let retry = UIAlertAction(title: "Retry", style: .Default, handler: { action in
            self.paymentContext.retryLoading()
        })
        alertController.addAction(cancel)
        alertController.addAction(retry)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // Helper methods
    
    // Check if the user is currently using food points or a credit card
    func checkIfCanUseFoodPoints() -> Bool {
        
            // Check if the time is between 8pm and 10pm
            let calendar = NSCalendar.currentCalendar()
            let components = NSDateComponents()
            components.day = 1
            components.month = 01
            components.year = 2016
            components.hour = 16
            components.minute = 50
            let eightPM = calendar.dateFromComponents(components)
            
            components.day = 1
            components.month = 01
            components.year = 2016
            components.hour = 22
            components.minute = 00
            let tenPM = calendar.dateFromComponents(components)
            
            let betweenEightAndTen = NSDate.timeIsBetween(eightPM!, endDate: tenPM!)
            if betweenEightAndTen {
                print("BETWEEN 8 and 10")
                return true
            } else {
                print("NOT BETWEEN 8 and 10")
            }
        
        return false
    }

}
