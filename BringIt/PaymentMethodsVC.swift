//
//  PaymentMethodsVC.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/21/17.
//  Copyright © 2017 Campus Enterprises. All rights reserved.
//

import UIKit
import RealmSwift
import Moya

class PaymentMethodsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - IBOutlets
    
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var addCardView: UIView!
    
    // MARK: - Variables
    
    let defaults = UserDefaults.standard // Initialize UserDefaults
    var paymentOptions = ""
    var comingFromCheckout = false
    var availablePaymentOptions: Results<PaymentMethod>!
    var paymentMethods: Results<PaymentMethod>!
    var selectedPaymentMethod = ""
    var order = Order()
    
    var user = User()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup Realm
        setupRealm()
        
        // Setup available payment options
        if comingFromCheckout {
            setUpPaymentOptions()
        }
        
        // Setup UI
        setupUI()
        
        retrieveCreditCards()
        
        // Setup tableview
        setupTableView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        retrieveCreditCards()
    }
    
    func setupRealm() {
        
        let realm = try! Realm() // Initialize Realm
        
        // Check if addresses for current User already exists in Realm
        let predicate = NSPredicate(format: "isCurrent = %@", NSNumber(booleanLiteral: true))
        user = realm.objects(User.self).filter(predicate).first!
        
        paymentMethods = realm.objects(PaymentMethod.self).filter(NSPredicate(format: "userID = %@", user.id))
        
        populatePaymentMethods()
    }
    
    func retrieveCreditCards() {
        
        let realm = try! Realm() // Initialize Realm
        
        // Setup Moya provider and send network request
        let provider = MoyaProvider<APICalls>()
        provider.request(.stripeRetrieveCards(userID: user.id)) { result in
            switch result {
            case let .success(moyaResponse):
                do {
                    
                    print("Status code: \(moyaResponse.statusCode)")
                    try moyaResponse.filterSuccessfulStatusCodes()
                    
                    let response = try moyaResponse.mapJSON() as! [String: Any]
                    print(response)
                    
                    if let success = response["success"] {
                        
                        if success as! Int == 1 {
                            
                            // Delete saved cards
                            let existingCards = realm.objects(PaymentMethod.self).filter(NSPredicate(format: "methodID CONTAINS %@ AND userID = %@", "card_", self.user.id))
                            
                            for card in existingCards {
                                try! realm.write {
                                    realm.delete(card)
                                }
                            }
                            
                            // Add new cards
                            let creditCards = response["cards"] as! [AnyObject]
                            print("CREDIT CARDS: \(creditCards)")
                            
                            for card in creditCards {
                                print(card)
                                
                                let creditCard = PaymentMethod()
                                creditCard.userID = self.user.id
                                creditCard.methodID = card["cardID"] as! String
                                creditCard.method = "\(card["brand"] as! String) •••• \(card["lastFour"] as! String)"
                                
                                print(creditCard)
                                
                                try! realm.write {
                                    realm.add(creditCard, update: true)
                                }
                                
                                self.myTableView.reloadData()
                            }
                        }
                    }
                    
                } catch {
                    // Miscellaneous network error
                    print("Network Error")
                }
            case .failure(_):
                // Connection failed
                print("Connection failed")
            }
        }
        
    }
    
    func populatePaymentMethods() {
        let realm = try! Realm() // Initialize Realm
        
        print("CURRENT PAYMENT METHODS: \(paymentMethods)")
        for paymentMethod in paymentMethods {
            if paymentMethod.userID == "" || paymentMethod.methodID == "" {
                try! realm.write {
                    realm.delete(paymentMethod)
                }
            }
        }
        print("NEW PAYMENT METHODS: \(paymentMethods)")
        
        let hasFoodPoints = paymentMethods.filter(NSPredicate(format: "methodID = %@", "duke-food-points")).count > 0
        if !hasFoodPoints {
            let foodPoints = PaymentMethod()
            foodPoints.userID = user.id
            foodPoints.methodID = "duke-food-points"
            foodPoints.method = "Food Points"
            
            try! realm.write {
                realm.add(foodPoints, update: true)
            }
        }
        
        let hasCredit = paymentMethods.filter(NSPredicate(format: "methodID = %@", "credit")).count > 0
        if !hasCredit {
            let creditCard = PaymentMethod()
            creditCard.userID = user.id
            creditCard.methodID = "credit"
            creditCard.method = "Credit Card (Pay at the door)"
            
            try! realm.write {
                realm.add(creditCard, update: true)
            }
        }
        
        let hasCash = paymentMethods.filter(NSPredicate(format: "methodID = %@", "cash")).count > 0
        if !hasCash {
            let cash = PaymentMethod()
            cash.userID = user.id
            cash.methodID = "cash"
            cash.method = "Cash"
            
            try! realm.write {
                realm.add(cash, update: true)
            }
        }
    }
    
    func setUpPaymentOptions() {
        
        let realm = try! Realm() // Initialize Realm
        
        let predicate = NSPredicate(format: "isCurrent = %@", NSNumber(booleanLiteral: true))
        user = realm.objects(User.self).filter(predicate).first!
        
        let paymentOptionsArray = paymentOptions.split(separator: ",")
        print("PAYMENT OPTIONS ARRAY: \(paymentOptionsArray)")
        
        if paymentOptionsArray.contains("stripe-credit") {
            availablePaymentOptions = realm.objects(PaymentMethod.self).filter(NSPredicate(format: "methodID IN %@ OR methodID CONTAINS %@ AND userID = %@", paymentOptionsArray, "card_", user.id)).sorted(byKeyPath: "method")
        } else {
            availablePaymentOptions = realm.objects(PaymentMethod.self).filter(NSPredicate(format: "methodID IN %@ AND userID = %@", paymentOptionsArray, user.id)).sorted(byKeyPath: "method")
        }
        
        print("AVAILABLE PAYMENT OPTIONS: \(availablePaymentOptions)")
    }
    
    /* Do initial UI setup */
    func setupUI() {
        
        setCustomBackButton()
        
        self.title = "Payment Methods"
        
        let paymentOptionsArray = paymentOptions.split(separator: ",")
        
        if !paymentOptionsArray.contains("stripe-credit") {
            addCardView.isHidden = true
        } else {
            addCardView.isHidden = false
        }
    }
    
    /* Customize tableView attributes */
    func setupTableView() {
        
        // Set tableView cells to custom height and automatically resize if needed
        self.myTableView.estimatedRowHeight = 50
        self.myTableView.rowHeight = UITableView.automaticDimension
        self.myTableView.setNeedsLayout()
        self.myTableView.layoutIfNeeded()
        
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if comingFromCheckout {
            return availablePaymentOptions.count
        }
        return paymentMethods.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "paymentMethodCell", for: indexPath)
        
        if comingFromCheckout {
            let paymentMethod = availablePaymentOptions[indexPath.row]
            cell.textLabel?.text = paymentMethod.method
            
            // Change checkmark color
            cell.tintColor = Constants.green
            
            if paymentMethod.method == order.paymentMethod {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            
            return cell
            
        } else {
            let paymentMethod = paymentMethods[indexPath.row]
            cell.textLabel?.text = paymentMethod.method
            
            // Change checkmark color
            cell.tintColor = Constants.green
            
            if paymentMethod.method == order.paymentMethod {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if comingFromCheckout {
            return "Available Payment Methods"
        }
        return "Default Payment Method"
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
        
        let realm = try! Realm() // Initialize Realm
        
        if comingFromCheckout {
            try! realm.write {
                order.paymentMethod = availablePaymentOptions[indexPath.row].method
            }
        }
        
        
//        for i in 0..<availablePaymentOptions.count {
//            if i == indexPath.row {
//                try! realm.write() {
//
//                    availablePaymentOptions[i].isSelected = true
//                    print("Selected \(availablePaymentOptions[i])")
//                }
//            } else {
//                try! realm.write() {
//                    availablePaymentOptions[i].isSelected = false
//                    print("Deselected \(availablePaymentOptions[i])")
//                }
//            }
//        }
        
//        deselectAllPaymentMethods()
        
        myTableView.deselectRow(at: indexPath, animated: true)
        myTableView.reloadData()
        
    }
    
//    func deselectAllPaymentMethods() {
//
//        let realm = try! Realm() // Initialize Realm
//        
//        for paymentMethod in paymentMethods {
//            if paymentMethod.methodID != selectedPaymentMethod {
//                try! realm.write() {
//                    paymentMethod.isSelected = false
//                }
//            }
//        }
//    }


}
