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
    @IBOutlet weak var addDukeCardButton: UIButton!
    @IBOutlet weak var addCreditCardButton: UIButton!
    
    // MARK: - Variables
    
    let defaults = UserDefaults.standard // Initialize UserDefaults
    var paymentOptions = ""
    var comingFromCheckout = false
    var paymentMethods: Results<PaymentMethod>!
    var unsavedPaymentMethods: Results<PaymentMethod>!
    var selectedPaymentKey: String?
    var pin = ""
    var paymentOptionsArray: [Substring]?
    
    var order = Order()
    
    var user = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRealm()
        paymentOptionsArray = paymentOptions.split(separator: ",")
        setupUI()
        populatePaymentMethods()
        
        // Setup tableview
        setupTableView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        self.myTableView.reloadData()
        
    }
    
    func setupRealm() {
        
        let realm = try! Realm() // Initialize Realm
        
        // Check if addresses for current User already exists in Realm
        let predicate = NSPredicate(format: "isCurrent = %@", NSNumber(booleanLiteral: true))
        user = realm.objects(User.self).filter(predicate).first!
        
        paymentMethods = realm.objects(PaymentMethod.self).filter(NSPredicate(format: "userID = %@ && unsaved = false", user.id))

        try! realm.write {
            realm.delete(paymentMethods)
        }
        
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
                            let existingCards = realm.objects(PaymentMethod.self).filter(NSPredicate(format: "paymentMethodID == %d AND userID = %@", "2", self.user.id))
                            
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
                                creditCard.paymentMethodID = 2
                                creditCard.paymentValue = card["cardID"] as! String
                                creditCard.paymentString = "\(card["brand"] as! String) •••• \(card["lastFour"] as! String)"
                                creditCard.compoundKey = "\(creditCard.paymentMethodID)-\(creditCard.paymentValue)"

                                
                                print(creditCard)
                                
                                try! realm.write {
                                    realm.add(creditCard, update: .all)
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
    
    func retrieveDukeCards() {
        let realm = try! Realm() // Initialize Realm
        
        // Setup Moya provider and send network request
        let provider = MoyaProvider<CombinedAPICalls>()
        provider.request(.retrieveDukeCards(uid: user.id)) { result in
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
                            let existingCards = realm.objects(PaymentMethod.self).filter(NSPredicate(format: "paymentMethodID == %d AND userID = %@ AND unsaved = false", "2", self.user.id))
                            
                            for card in existingCards {
                                try! realm.write {
                                    realm.delete(card)
                                }
                            }
                            
                            // Add new cards
                            let dukeCards = response["cards"] as! [AnyObject]
                            print("DUKE CARDS: \(dukeCards)")
                            
                            for card in dukeCards {
                                print(card)
                                
                                let dukeCardFoodPoints = PaymentMethod()
                                dukeCardFoodPoints.userID = self.user.id
                                dukeCardFoodPoints.paymentMethodID = 0
                                dukeCardFoodPoints.paymentValue = (card["cardID"] as! String)
                                dukeCardFoodPoints.paymentString = "Duke Food Points •••• \(card["lastFour"] as! String)"
                                dukeCardFoodPoints.paymentPin = self.pin
                                dukeCardFoodPoints.compoundKey = "\(dukeCardFoodPoints.paymentMethodID)-\(dukeCardFoodPoints.paymentValue)"
                                
                                print(dukeCardFoodPoints)
                                
                                let dukeCardFlex = PaymentMethod()
                                dukeCardFlex.userID = self.user.id
                                dukeCardFlex.paymentMethodID = 5
                                dukeCardFlex.paymentValue = (card["cardID"] as! String)
                                dukeCardFlex.paymentString = "Duke Flex •••• \(card["lastFour"] as! String)"
                                dukeCardFlex.paymentPin = self.pin
                                dukeCardFlex.compoundKey = "\(dukeCardFlex.paymentMethodID)-\(dukeCardFlex.paymentValue)"

                                
                                print(dukeCardFlex)
                                
                                try! realm.write {
                                    realm.add(dukeCardFoodPoints, update: .all)
                                    realm.add(dukeCardFlex, update: .all)
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

        paymentMethods = realm.objects(PaymentMethod.self).filter(NSPredicate(format: "userID = %@", user.id))
        
        print("CURRENT PAYMENT METHODS: \(paymentMethods)")
        for paymentMethod in paymentMethods {
            if paymentMethod.userID == "" || paymentMethod.paymentValue == "" {
                try! realm.write {
                    realm.delete(paymentMethod)
                }
            }
        }
  
        print("NEW PAYMENT METHODS: \(paymentMethods)")
        if (comingFromCheckout){

            if paymentOptionsArray!.contains("credit") {
                let hasCredit = paymentMethods.filter(NSPredicate(format: "paymentMethodID == %d", 1)).count > 0
                if !hasCredit {
                    let creditCard = PaymentMethod()
                    creditCard.userID = user.id
                    creditCard.paymentMethodID = 1
                    creditCard.paymentValue = "credit"
                    creditCard.paymentString = "Credit Card (Pay at the door)"
                    creditCard.compoundKey = "\(creditCard.paymentMethodID)-\(creditCard.paymentValue)"

                    
                    try! realm.write {
                        realm.add(creditCard, update: .all)
                    }
                }
            }
            
            if paymentOptionsArray!.contains("cash") {
                let hasCash = paymentMethods.filter(NSPredicate(format: "paymentMethodID == %d", "3")).count > 0
                if !hasCash {
                    let cash = PaymentMethod()
                    cash.paymentMethodID = 3
                    cash.userID = user.id
                    cash.paymentValue = "cash"
                    cash.paymentString = "Cash"
                    cash.compoundKey = "\(cash.paymentMethodID)-\(cash.paymentValue)"
                    
                    try! realm.write {
                        realm.add(cash, update: .all)
                    }
                }
            }
        }
    }
    
    /* Do initial UI setup */
    func setupUI() {
        
        setCustomBackButton()
        
        self.title = "Payment Methods"
        
        if paymentOptionsArray!.contains("stripe-credit") || !comingFromCheckout {
            addCreditCardButton.isHidden = false
            retrieveCreditCards()
        } else {
            addCreditCardButton.isHidden = true
        }
        
        if paymentOptionsArray!.contains("duke-food-points") || !comingFromCheckout {
            addDukeCardButton.isHidden = false
            retrieveDukeCards()
        } else {
            addDukeCardButton.isHidden = true
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
        return paymentMethods.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "paymentMethodCell", for: indexPath)
  
        let paymentMethod = paymentMethods[indexPath.row]
        cell.textLabel?.text = paymentMethod.paymentString
        
        // Change checkmark color
        cell.tintColor = Constants.green
        
        if paymentMethod.compoundKey == selectedPaymentKey {
            cell.accessoryType = .checkmark
            
            let realm = try! Realm() // Initialize Realm

            try! realm.write {
                realm.add(paymentMethod, update: .all)
                order.paymentMethod = paymentMethod
            }
            
        } else {
            cell.accessoryType = .none
        }
        
        return cell
        
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if comingFromCheckout {
            return "Available Payment Methods"
        }
        return "Saved Payment Methods"
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
        if comingFromCheckout{
            if (paymentMethods[indexPath.row].paymentMethodID == 0 || paymentMethods[indexPath.row].paymentMethodID == 5){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let presentedVC = storyboard.instantiateViewController(withIdentifier: "EnterPinPopUpVC") as! EnterPinPopUpVC
            presentedVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                presentedVC.closure = { pin in return self.selectRow(pin: pin, indexPath: indexPath, tableView: tableView)}
            present(presentedVC, animated: true)
            }
            else{
                selectRow(pin: "", indexPath: indexPath, tableView: tableView)
            }
        }
    }
    
    func selectRow(pin: String, indexPath: IndexPath, tableView: UITableView){
        let realm = try! Realm() // Initialize Realm

        // food points or flex, need pin
        if (paymentMethods[indexPath.row].paymentMethodID == 0 || paymentMethods[indexPath.row].paymentMethodID == 5){
            if (pin == "") {
                tableView.deselectRow(at: indexPath, animated: true)
                return
            }
            else{
                try! realm.write {
                    paymentMethods[indexPath.row].paymentPin = pin
                }
                self.pin = pin
            }
        }

        selectedPaymentKey = paymentMethods[indexPath.row].compoundKey
        if comingFromCheckout {
            try! realm.write {
                realm.add(paymentMethods[indexPath.row], update: .all)
                order.paymentMethod = paymentMethods[indexPath.row]
            }
        }
        
        myTableView.deselectRow(at: indexPath, animated: true)
        myTableView.reloadData()
    }
    
    @IBAction func addDukeCardTapped(_ sender: Any) {
        performSegue(withIdentifier: "toAddDukeCardFromPaymentMethods", sender: self)
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAddDukeCardFromPaymentMethods" {
            let newDukeCardVC = segue.destination as! NewDukeCardVC
            newDukeCardVC.user = user
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if (paymentMethods[indexPath.row].paymentMethodID == 0 || paymentMethods[indexPath.row].paymentMethodID == 5){
                let realm = try! Realm() // Initialize Realm

                let paymentMethodsToDelete = realm.objects(PaymentMethod.self).filter(NSPredicate(format: "userID = %@ && paymentValue = %@", user.id, paymentMethods[indexPath.row].paymentValue))

                let cardId = paymentMethods[indexPath.row].paymentValue
                let unsaved = paymentMethods[indexPath.row].unsaved
                
                try! realm.write {
                    realm.delete(paymentMethodsToDelete)
                }
                
                if (unsaved == false){
                    deleteDukeCard(cardId: cardId)
                }

                tableView.reloadData()
            }
        }
    }
    
    func deleteDukeCard(cardId: String){
        // Setup Moya provider and send network request
        let provider = MoyaProvider<CombinedAPICalls>()
        provider.request(.deleteDukeCard(uid: user.id, cardId: cardId)) { result in
            switch result {
            case let .success(moyaResponse):
                do {
                    
                    print("Status code: \(moyaResponse.statusCode)")
                    try moyaResponse.filterSuccessfulStatusCodes()
                    
                    let response = try moyaResponse.mapJSON() as! [String: Any]
                    print(response)
                    
//                    if let success = response["success"] {
//
//                    }
                    
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
}
