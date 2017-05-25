//
//  PaymentMethodsVC.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/21/17.
//  Copyright © 2017 Campus Enterprises. All rights reserved.
//

import UIKit
import RealmSwift

class PaymentMethodsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - IBOutlets
    
    @IBOutlet weak var myTableView: UITableView!
    
    // MARK: - Variables
    
    let defaults = UserDefaults.standard // Initialize UserDefaults
    let realm = try! Realm() // Initialize Realm
    
    var user = User()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup Realm
        setupRealm()
        
        // Setup UI
        setupUI()
        
        // Setup tableview
        setupTableView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupRealm() {
        
        // Check if addresses for current User already exists in Realm
        let predicate = NSPredicate(format: "isCurrent = %@", NSNumber(booleanLiteral: true))
        user = self.realm.objects(User.self).filter(predicate).first!
        
        if !(user.paymentMethods.count > 0) {
            
            let foodPoints = PaymentMethod()
            foodPoints.userID = user.id
            foodPoints.method = "Food Points"
            
            let creditCard = PaymentMethod()
            creditCard.userID = user.id
            creditCard.method = "Credit Card"
            
            try! realm.write {
                user.paymentMethods.append(foodPoints)
                user.paymentMethods.append(creditCard)
            }

            
        }
    }
    
    /* Do initial UI setup */
    func setupUI() {
        
        setCustomBackButton()
        
        self.title = "Payment Methods"
    }
    
    /* Customize tableView attributes */
    func setupTableView() {
        
        // Set tableView cells to custom height and automatically resize if needed
        self.myTableView.estimatedRowHeight = 50
        self.myTableView.rowHeight = UITableViewAutomaticDimension
        self.myTableView.setNeedsLayout()
        self.myTableView.layoutIfNeeded()
        
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user.paymentMethods.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "paymentMethodCell", for: indexPath)
        
        let paymentMethod = user.paymentMethods[indexPath.row]
        cell.textLabel?.text = paymentMethod.method
        
        // Change checkmark color
        cell.tintColor = Constants.green
        
        if paymentMethod.isSelected {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Default Payment Method (After 8PM)"
    }
    
    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = Constants.headerFont
        header.textLabel?.textColor = UIColor.black
        header.textLabel?.textAlignment = .left
        header.backgroundView?.backgroundColor = UIColor.white
        header.textLabel?.text = header.textLabel?.text?.uppercased()
        
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.headerHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        for i in 0..<user.paymentMethods.count {
            if i == indexPath.row {
                try! self.realm.write() {
                    
                    user.paymentMethods[i].isSelected = true
                    print("Selected \(user.paymentMethods[i])")
                }
            } else {
                try! self.realm.write() {
                    user.paymentMethods[i].isSelected = false
                    print("Deselected \(user.paymentMethods[i])")
                }
            }
        }
        
        myTableView.deselectRow(at: indexPath, animated: true)
        myTableView.reloadData()
        
    }


}
