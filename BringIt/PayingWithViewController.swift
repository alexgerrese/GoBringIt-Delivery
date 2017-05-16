//
//  PayingWithViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 8/22/16.
//  Copyright © 2016 Campus Enterprises. All rights reserved.
//

import UIKit

class PayingWithViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var useFoodPointsSwitch: UISwitch!
    @IBOutlet weak var currentCreditCardLabel: UILabel!
    @IBOutlet weak var paymentMethodsSegmentedControl: UISegmentedControl!
    @IBOutlet weak var errorMessage: UILabel!
    
    // Enable UserDefaults
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title
        self.title = "Payment Info"
        
        if let switchOn = defaults.object(forKey: "useFoodPoints") {
            useFoodPointsSwitch.isOn = switchOn as! Bool
        } else {
            defaults.set(true, forKey: "useFoodPoints")
        }
        
        // Set default payment method
        if let pm = defaults.object(forKey: "selectedPaymentMethod") {
            if pm as! String == "Food Points" {
                paymentMethodsSegmentedControl.selectedSegmentIndex = 0
            } else {
                paymentMethodsSegmentedControl.selectedSegmentIndex = 1
            }
        } else {
            if checkIfCanUseFoodPoints() {
                paymentMethodsSegmentedControl.selectedSegmentIndex = 0
                defaults.set("Food Points", forKey: "selectedPaymentMethod")
            } else {
                paymentMethodsSegmentedControl.selectedSegmentIndex = 1
                defaults.set("Credit Card", forKey: "selectedPaymentMethod")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Hide error message
        errorMessage.isHidden = true
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
        
        // CREDIT CARD
        if paymentMethodsSegmentedControl.selectedSegmentIndex == 1 {
            // Turn switch off if usually manually changes from food points payment method when those are available
            if checkIfCanUseFoodPoints() {
                if useFoodPointsSwitch.isOn {
                    useFoodPointsSwitch.isOn = false
                }
            }
            // Make sure a credit card exists
            if paymentMethodsSegmentedControl.titleForSegment(at: 1) == "Credit Card" {
                defaults.set("Credit Card", forKey: "selectedPaymentMethod")
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
