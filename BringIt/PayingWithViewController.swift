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
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title
        self.title = "Payment Info"
        
        // Set up PaymentContext
        let paymentContext = STPPaymentContext(apiAdapter: MyAPIClient.sharedClient)
        let userInformation = STPUserInformation()
        paymentContext.prefilledInformation = userInformation
        paymentContext.paymentAmount = 1540 // MAKE DYNAMIC
        paymentContext.paymentCurrency = self.paymentCurrency
        self.paymentContext = paymentContext
        self.paymentContext.delegate = self
        paymentContext.hostViewController = self
        
        if let switchOn = defaults.object(forKey: "useFoodPoints") {
            useFoodPointsSwitch.isOn = switchOn as! Bool
        } else {
            defaults.set(true, forKey: "useFoodPoints")
        }
        
        // Set default payment method
        if let pm = defaults.object(forKey: "selectedPaymentMethod") {
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
                defaults.set("Food Points", forKey: "selectedPaymentMethod")
            } else {
                paymentMethodsSegmentedControl.selectedSegmentIndex = 1
                defaults.set("Cash", forKey: "selectedPaymentMethod")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Hide error message
        errorMessage.isHidden = true
        
        // Set customerID
        customerID = defaults.object(forKey: "stripeCustomerID") as! String
        MyAPIClient.sharedClient.customerID = self.customerID
    }
    
    @IBAction func paymentMethodChanged(_ sender: UISegmentedControl) {
        errorMessage.isHidden = true
        print("PAYMENT METHOD CHANGED")
        
        // FOOD POINTS
        if paymentMethodsSegmentedControl.selectedSegmentIndex == 0 {
            if checkIfCanUseFoodPoints() {
                defaults.set("Food Points", forKey: "selectedPaymentMethod")
            } else {
                // Show error message
                errorMessage.isHidden = false
                errorMessage.text = "You cannot use food points at this time. Please select another payment method."
            }
        }
        
        // CASH
        if paymentMethodsSegmentedControl.selectedSegmentIndex == 1 {
            defaults.set("Cash", forKey: "selectedPaymentMethod")
        }
        
        // CREDIT CARD
        if paymentMethodsSegmentedControl.selectedSegmentIndex == 2 {
            // Turn switch off if usually manually changes from food points payment method when those are available
            if checkIfCanUseFoodPoints() {
                if useFoodPointsSwitch.isOn {
                    useFoodPointsSwitch.isOn = false
                }
            }
            // Make sure a credit card exists
            if paymentMethodsSegmentedControl.titleForSegment(at: 2) == "Credit Card" {
                // Show error message
                errorMessage.isHidden = false
                errorMessage.text = "Please add a credit card and try again."
            } else {
                defaults.set(paymentMethodsSegmentedControl.titleForSegment(at: 2), forKey: "selectedPaymentMethod")
            }
        }
    }
    
    @IBAction func switchPressed(_ sender: UISwitch) {
        if sender.isOn {
            defaults.set(true, forKey: "useFoodPoints")
        } else {
            defaults.set(false, forKey: "useFoodPoints")
        }
    }
    
    // MARK: Payment Actions
    
    @IBAction func manageCardsButtonPreseed(_ sender: UIButton) {
        self.paymentContext.pushPaymentMethodsViewController()
    }
    
    func handleError(_ error: NSError) {
        print(error)
        UIAlertView(title: "Please Try Again",
                    message: error.localizedDescription,
                    delegate: nil,
                    cancelButtonTitle: "OK").show()
        
    }
    
    // MARK: STPPaymentContextDelegate
    
    
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPErrorBlock) {
        MyAPIClient.sharedClient.completeCharge(paymentResult, amount: self.paymentContext.paymentAmount,
                                                completion: completion)
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        let title: String
        let message: String
        switch status {
        case .error:
            title = "Error"
            message = error?.localizedDescription ?? ""
        case .success:
            title = "Success"
            message = "You bought a!"
        case .userCancellation:
            return
        }
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        if let paymentMethod = paymentContext.selectedPaymentMethod {
            paymentMethodsSegmentedControl.setTitle(paymentMethod.label, forSegmentAt: 2)
        }
        else {
            paymentMethodsSegmentedControl.setTitle("Credit Card", forSegmentAt: 2)
        }
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        let alertController = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            self.navigationController?.popViewController(animated: true)
        })
        let retry = UIAlertAction(title: "Retry", style: .default, handler: { action in
            self.paymentContext.retryLoading()
        })
        alertController.addAction(cancel)
        alertController.addAction(retry)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // Helper methods
    
    // Check if the user is currently using food points or a credit card
    func checkIfCanUseFoodPoints() -> Bool {
        
            // Check if the time is between 8pm and 10pm
            let calendar = Calendar.current
            var components = DateComponents()
            components.day = 1
            components.month = 01
            components.year = 2016
            components.hour = 19
            components.minute = 40
            let eightPM = calendar.date(from: components)
            
            components.day = 1
            components.month = 01
            components.year = 2016
            components.hour = 22
            components.minute = 00
            let tenPM = calendar.date(from: components)
            
            let betweenEightAndTen = Date.timeIsBetween(eightPM!, endDate: tenPM!)
            if betweenEightAndTen {
                print("BETWEEN 8 and 10")
                return true
            } else {
                print("NOT BETWEEN 8 and 10")
            }
        
        return false
    }

}
