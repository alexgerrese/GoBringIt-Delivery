//
//  CheckoutViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/26/16.
//  Copyright © 2016 Campus Enterprises. All rights reserved.
//

import UIKit
import CoreData
import GMStepper
import AFNetworking

var comingFromOrderPlaced = false
var comingFromSignIn = false

class CheckoutViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, STPPaymentContextDelegate {
    
    // MARK: - Payment IBOutlets and variables
    
    // Stripe variables
    var paymentContext = STPPaymentContext()
    var customerID = ""
    var paymentCurrency = "usd"
    var paymentMethodLabel = ""
    
    // MARK: - IBOutlets
    @IBOutlet weak var itemsTableView: UITableView!
    @IBOutlet weak var detailsTableView: UITableView!
    @IBOutlet weak var itemsTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var deliveryFeeLabel: UILabel!
    @IBOutlet weak var subtotalCostLabel: UILabel!
    @IBOutlet weak var totalCostLabel: UILabel!
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var checkoutButton: UIButton!
    @IBOutlet weak var checkoutErrorLabel: UILabel!
    // Tip View
    @IBOutlet weak var tipDriverView: UIView!
    @IBOutlet weak var tipStepper: GMStepper!
    var blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    // MARK: - Variables
    
    // Global variables
    var cameFromVC = ""
    var totalCost = 0.0
    var selectedCell = 0
    var deliveryFee = 0.0
    var isOpen = false
    var usingFoodPoints = false
    var tipAmount = 0.0
    
    // DB data
    var items_ordered: [String] = []
    var items_ordered_quantity: [String] = []
    var items_ordered_cartUID: [String] = []
    var cartUID_side = [String: String]()
    var items_ordered_instructions: [String] = []
    var service_id = ""
    
    // Chad's data
    var maxCartOrderID = 0
    var reset = false
    var userID = ""
    var currentAddress = ""
    var serviceID = ""
    
    // CoreData variables
    var activeCart: [Order]?
    var items: [Item]?
    var sides: [Side]?
    
    // Set up CoreData
    let appDelegate =
        UIApplication.shared.delegate as! AppDelegate
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    // Set up UserDefaults
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title
        self.title = "Checkout"
        
        // Set nav bar preferences
        self.navigationController?.navigationBar.tintColor = UIColor.darkGray
        navigationController!.navigationBar.titleTextAttributes =
            ([NSFontAttributeName: TITLE_FONT,
                NSForegroundColorAttributeName: UIColor.black])
        
        // Set custom back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
        // Set tableView cells to custom height and automatically resize if needed
        itemsTableView.estimatedRowHeight = 110
        itemsTableView.rowHeight = UITableViewAutomaticDimension
        
        // Hide activity indicator
        myActivityIndicator.isHidden = true
        
        // Add shadow to tipDriverView
        tipDriverView.layer.shadowColor = UIColor.darkGray.cgColor
        tipDriverView.layer.shadowOpacity = 0.5
        tipDriverView.layer.shadowOffset = CGSize.zero
        tipDriverView.layer.shadowRadius = 5
        
        // Set font of tipStepper
        tipStepper.labelFont = UIFont(name: "Avenir-Black", size: 32)!
        
        calculateTotalCost()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        print("CHECKOUT VC")
        
        // Check if coming from OrderPlacedVC
        if comingFromOrderPlaced == true {
            comingFromOrderPlaced = false
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        // Check if coming from SignInVC
        if comingFromSignIn {
            print("COMING FROM SIGN IN")
            let loggedIn = defaults.bool(forKey: "loggedIn")
            if !loggedIn {
                self.dismiss(animated: true, completion: nil)
                return
            }
        }
        
        // Check if user is already logged in
        checkLoggedIn()
        
        print("BEFORE STRIPE SETUP")
        
        // Stripe Setup
        if let customerID = self.defaults.object(forKey: "stripeCustomerID") {
            print("1")
            MyAPIClient.sharedClient.customerID = self.customerID as String
            print("2")
            
            // Set up PaymentContext
            let paymentContext = STPPaymentContext(apiAdapter: MyAPIClient.sharedClient)
            print("3")
            let userInformation = STPUserInformation()
            print("4")
            paymentContext.prefilledInformation = userInformation
            print("5")
            paymentContext.paymentCurrency = self.paymentCurrency
            print("6")
            self.paymentContext = paymentContext
            self.paymentContext.delegate = self
            paymentContext.hostViewController = self
        }
        
        
        print("AFTER STRIPE SETUP")
        
        // Get userID
        if let id = self.defaults.object(forKey: "userID") {
            userID = id as! String
        }
        
        // Check if usingFoodPoints
        usingFoodPoints = checkIfUsingFoodPoints()
        
        if let paymentMethod = defaults.object(forKey: "selectedPaymentMethod") {
            paymentMethodLabel = paymentMethod as! String
            print(paymentMethodLabel)
        } else {
            if checkIfUsingFoodPoints() {
                paymentMethodLabel = "Food Points"
            } else {
                //paymentMethodLabel = "Cash"
                paymentMethodLabel = "Credit Card"
            }
        }
        detailsTableView.reloadData()
        
        // Deselect cells when view appears
        if let indexPath = itemsTableView.indexPathForSelectedRow {
            itemsTableView.deselectRow(at: indexPath, animated: true)
        }
        if let indexPath = detailsTableView.indexPathForSelectedRow {
            detailsTableView.deselectRow(at: indexPath, animated: true)
        }
        
        // Hide error message
        checkoutErrorLabel.isHidden = true
        
        // DETAIL TABLEVIEW
        
        var addresses = [String]()
        if let addressesArray = defaults.object(forKey: "Addresses") {
            addresses = addressesArray as! [String]
        }
        if let index = defaults.object(forKey: "CurrentAddressIndex") {
            if index as! Int != -1 {
                currentAddress = addresses[index as! Int]
            }
        }
        detailsTableView.reloadData()
        
        // ITEMS TABLEVIEW
        
        // Fetch all active carts, if any exist
        
        let fetchRequest = NSFetchRequest<Order>(entityName: "Order")
        let firstPredicate = NSPredicate(format: "isActive == %@", true as CVarArg)
        let secondPredicate = NSPredicate(format: "restaurant == %@", selectedRestaurantName)
        let predicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [firstPredicate, secondPredicate])
        fetchRequest.predicate = predicate
        
        do {
            if let fetchResults = try managedContext.fetch(fetchRequest) as? [Order] {
                activeCart = fetchResults
                print(fetchResults.count)
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        // If cart is empty, then load empty state
        if activeCart!.isEmpty {
            print("CART IS EMPTY")
            
            // Set values to nil
            items = nil
            sides = nil
        }
            //If request returns a cart, then display the cart
        else {
            let order = activeCart![0]
            
            // Set delivery fee
            // Check if alreadyOrdered, and update deliveryFee if not
            if let alreadyOrdered = self.defaults.object(forKey: "alreadyOrdered") {
                if !(alreadyOrdered as! Bool){
                    self.activeCart![0].deliveryFee = 0.00
                }
            }
            deliveryFee = Double(order.deliveryFee!)

            // Fill items array
            items = order.items?.allObjects as? [Item]
            
            for i in 0..<order.items!.count {
                sides = items![i].sides?.allObjects as? [Side]
                
                print((items![i].name))
            }
        }

        calculateTotalCost()
        itemsTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Update Subviews
    
    // Resize itemsTableView
    override func updateViewConstraints() {
        super.updateViewConstraints()
        itemsTableViewHeight.constant = itemsTableView.contentSize.height
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == itemsTableView {
            if let numItems = items?.count {
                return numItems
            }
            return 0
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == itemsTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "checkoutCell", for: indexPath) as! CheckoutTableViewCell
            
            // Set name and quantity labels
            cell.itemNameLabel.text = items![(indexPath as NSIndexPath).row].name
            cell.itemQuantityLabel.text = String(describing: items![(indexPath as NSIndexPath).row].quantity!)
            
            // Calculate total item cost
            var totalItemCost = 0.0
            var costOfSides = 0.0
            for side in items![(indexPath as NSIndexPath).row].sides?.allObjects as! [Side] {
                costOfSides += Double(side.price!)
            }
            totalItemCost += (Double(items![(indexPath as NSIndexPath).row].price!) + costOfSides) * Double(items![(indexPath as NSIndexPath).row].quantity!)
            cell.totalCostLabel.text = String(format: "%.2f", totalItemCost)
            
            // Format all sides and extras
            var sides = "Sides: "
            var extras = "Extras: "
            let allSides = items![(indexPath as NSIndexPath).row].sides?.allObjects as! [Side]
            for i in 0..<allSides.count {
                if ((allSides[i].isRequired) == true) {
                    if i < allSides.count - 1 {
                        sides += allSides[i].name! + ", "
                    } else {
                        sides += allSides[i].name!
                    }
                } else {
                    if i < allSides.count - 1 {
                        extras += allSides[i].name! + ", "
                    } else {
                        extras += allSides[i].name!
                    }
                }
            }
            if sides == "Sides: " {
                sides += "None"
            }
            if extras == "Extras: " {
                extras += "None"
            }
            
            // Format special instructions
            var specialInstructions = "Special Instructions: "
            if items![(indexPath as NSIndexPath).row].specialInstructions != "" {
                specialInstructions += items![(indexPath as NSIndexPath).row].specialInstructions!
            } else {
                specialInstructions += "None"
            }
            
            // Create attributed strings of the extras
            var sidesAS = NSMutableAttributedString()
            var extrasAS = NSMutableAttributedString()
            var specialInstructionsAS = NSMutableAttributedString()
            
            sidesAS = NSMutableAttributedString(
                string: sides,
                attributes: [NSFontAttributeName:UIFont(
                    name: "Avenir",
                    size: 13.0)!])
            extrasAS = NSMutableAttributedString(
                string: extras,
                attributes: [NSFontAttributeName:UIFont(
                    name: "Avenir",
                    size: 13.0)!])
            specialInstructionsAS = NSMutableAttributedString(
                string: specialInstructions,
                attributes: [NSFontAttributeName:UIFont(
                    name: "Avenir",
                    size: 13.0)!])
            
            sidesAS.addAttribute(NSFontAttributeName,
                                 value: UIFont(
                                    name: "Avenir-Heavy",
                                    size: 13.0)!,
                                 range: NSRange(
                                    location: 0,
                                    length: 6))
            extrasAS.addAttribute(NSFontAttributeName,
                                  value: UIFont(
                                    name: "Avenir-Heavy",
                                    size: 13.0)!,
                                  range: NSRange(
                                    location: 0,
                                    length: 7))
            specialInstructionsAS.addAttribute(NSFontAttributeName,
                                               value: UIFont(
                                                name: "Avenir-Heavy",
                                                size: 13.0)!,
                                               range: NSRange(
                                                location: 0,
                                                length: 21))
            
            print(sidesAS.mutableString)
            
            cell.sidesLabel.attributedText = sidesAS
            cell.extrasLabel.attributedText = extrasAS
            cell.specialInstructionsLabel.attributedText = specialInstructionsAS
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "checkoutDetailsCell", for: indexPath)
            
            if (indexPath as NSIndexPath).row == 0 {
                cell.textLabel?.text = "Deliver To"
                if currentAddress != "" {
                    cell.detailTextLabel?.text = currentAddress
                } else {
                    cell.detailTextLabel?.text = "Add New Address"
                }
                
            } else {
                cell.textLabel?.text = "Pay With"
                cell.detailTextLabel?.text = paymentMethodLabel
                print("PAYMENT METHOD: \(paymentMethodLabel)")
            }
            
            return cell
        }
    }
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if tableView == itemsTableView {
            if editingStyle == .delete {
                
                // Delete the row from the data source
                managedContext.delete(items![(indexPath as NSIndexPath).row])
                appDelegate.saveContext()
                items!.remove(at: (indexPath as NSIndexPath).row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                
                // Reload tableview and adjust tableview height and recalculate costs
                itemsTableView.reloadData()
                updateViewConstraints()
                calculateTotalCost()
            }
        }
    }
    
    // Find out which cell was selected and sent to prepareForSegue
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        selectedCell = (indexPath as NSIndexPath).row
        
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == itemsTableView {
            performSegue(withIdentifier: "toChangeOrder", sender: self)
        } else {
            if (indexPath as NSIndexPath).row == 0 {
                performSegue(withIdentifier: "toDeliverToPayingWith", sender: self)
            } else {
                performSegue(withIdentifier: "toPayingWith", sender: self)
            }
        }
    }
    
    // MARK: - Actions
    
    // IBActions
    
    // Checkout process
    @IBAction func checkoutButtonPressed(_ sender: UIButton) {
        if canCheckout() {
            let alertController = UIAlertController(title: "Checkout", message: "Are you sure you want to checkout?", preferredStyle: .actionSheet)
            let checkout = UIAlertAction(title: "Yes, bring me my food!", style: .default, handler: { (action) -> Void in
                print("Checkout Button Pressed")
                
                // Present tip view
                self.presentTipView()
                
            })
            let cancel = UIAlertAction(title: "No, cancel", style: .cancel, handler: { (action) -> Void in
                print("Cancel Button Pressed")
            })
            
            alertController.addAction(checkout)
            alertController.addAction(cancel)
            
            present(alertController, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func xButtonPressed(_ sender: UIBarButtonItem) {
        
        print("X button was pressed!")
        print(cameFromVC)
        
        if cameFromVC == "" {
            performSegue(withIdentifier: "returnToScheduleDetails", sender: self)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func noThanksPressed(_ sender: UIButton) {
        // Update total price
        totalCost += self.deliveryFee
        
        finishOrder()
    }
    
    @IBAction func addTipPressed(_ sender: UIButton) {
        // Update total price with tip value
        tipAmount = totalCost * (tipStepper.value / 100)
        totalCost += tipAmount + self.deliveryFee
        
        finishOrder()
    }
    
    func finishOrder() {
        // Submit order to db and charge customer
        self.submitOrder()
        if paymentMethodLabel != "Food Points" {
            // Update total price for Stripe payment
            self.paymentContext.paymentAmount = Int(totalCost*100)
            print(self.paymentContext.paymentAmount)
            buyButtonTapped()
        }
        
        // Animate tip view off screen before performing segue
        hideTipView()
        self.performSegue(withIdentifier: "toOrderPlaced", sender: self)
    }
    
    // Functions
    
    func calculateTotalCost() {
        
        // Calculate costs
        totalCost = 0.0
        if items != nil {
            for item in items! {
                var costOfSides = 0.0
                for side in item.sides?.allObjects as! [Side] {
                    costOfSides += Double(side.price!)
                }
                totalCost += (Double(item.price!) + costOfSides) * Double(item.quantity!)
            }
        }
        
        // Display costs
        self.deliveryFeeLabel.text = String(format: "$%.2f", self.deliveryFee)
        self.subtotalCostLabel.text = String(format: "$%.2f", self.totalCost)
        self.totalCostLabel.text = String(format: "$%.2f", self.totalCost + self.deliveryFee)
    }
    
    // Determine if checkout is possible, and display appropriate error messages if not
    func canCheckout() -> Bool {
        if items != nil {
            if (items?.isEmpty)! {
                checkoutErrorLabel.isHidden = false
                checkoutErrorLabel.text = "Please add some food and try again."
                return false
            } else if currentAddress == "" {
                checkoutErrorLabel.isHidden = false
                checkoutErrorLabel.text = "Please add an address and try again."
                return false
            } else if !isOpen {
                checkoutErrorLabel.isHidden = false
                checkoutErrorLabel.text = "Please wait until the restaurant is open and try again."
                return false
            } else {
                if totalCost + deliveryFee < 10 {
                    checkoutErrorLabel.isHidden = false
                    checkoutErrorLabel.text = "Please make sure your total is over $10 and try again."
                    return false
                }
                checkoutErrorLabel.isHidden = true
                return true
            }
        } else {
            checkoutErrorLabel.isHidden = false
            checkoutErrorLabel.text = "Please add some food and try again."
            return false
        }
    }
    
    func submitOrder() {
        // Start activity indicator again
        self.myActivityIndicator.isHidden = false
        self.myActivityIndicator.startAnimating()
        
        // Update and save CoreData
        self.activeCart![0].dateOrdered = Date()
        self.activeCart![0].isActive = false
        self.activeCart![0].totalPrice = self.totalCost as NSNumber?
        
        self.appDelegate.saveContext()
        
        let addresses = self.defaults.object(forKey: "Addresses") as! [String]
        let addressIndex = self.defaults.object(forKey: "CurrentAddressIndex") as! Int
        
        // 1. Get 10 + order_id (task 2)
        // 2. (task)addItem using that order_id (), save the Party response header
        // 3. addSide (side-id, cart entry-id, quantity)
        
        let requestURL2: URL = URL(string: "http://www.gobringit.com/CHADcarts.php")!
        let urlRequest2 = URLRequest(url: requestURL2)
        let session2 = URLSession.shared
        let task2 = session2.dataTask(with: urlRequest2, completionHandler: { (data, response, error) -> Void in
            if let data = data {
                do {
                    let httpResponse = response as! HTTPURLResponse
                    let statusCode = httpResponse.statusCode
                    
                    // Check HTTP Response
                    if (statusCode == 200) {
                        
                        do{
                            
                            if (self.maxCartOrderID == 0) {
                                self.reset = true
                            }
                            // Parse JSON
                            let json = try JSONSerialization.jsonObject(with: data, options:.allowFragments)
                            
                            for Cart in json as! [Dictionary<String, AnyObject>] {
                                
                                let order_id = Cart["order_id"] as! String
                                if (Int(order_id)! > self.maxCartOrderID) {
                                    self.maxCartOrderID = Int(order_id)!
                                }
                            }
                            
                            OperationQueue.main.addOperation {
                                if (self.reset == true) {
                                    self.maxCartOrderID = self.maxCartOrderID + 10;
                                }
                                
                                print("This is the current max order_id", self.maxCartOrderID)
                                
                                // STEP 2: loop through all items and add them to cart
                                
                                // Stupid restructuring needed because the web dev guys suck :P Little pissed off humor
                                var restructuredItems = [Item]()
                                for item in self.items! {
                                    for _ in 0..<Int(item.quantity!) {
                                        restructuredItems.append(item)
                                    }
                                }
                                
                                for item in restructuredItems {
                                    // Loop through all items
                                    print(item.id)
                                    print(item.name)
                                    print(item.quantity)
                                    
                                    // Create JSON data and configure the request
                                    let params = ["item_id": item.id!,
                                        "user_id": self.userID,
                                        "quantity": String(describing: item.quantity!),
                                        "active": "0",
                                        "instructions": item.specialInstructions!,
                                        "order_id": String(self.maxCartOrderID),
                                        ]
                                        as Dictionary<String, String>
                                    
                                    // create the request & response
                                    var request = URLRequest(url: Foundation.URL(string: "http://www.gobringit.com/CHADaddItemToCart.php")!, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 15)
                                    
                                    do {
                                        let jsonData = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions.prettyPrinted)
                                        request.httpBody = jsonData
                                        
                                    } catch let error as NSError {
                                        print(error)
                                    }
                                    request.httpMethod = "POST"
                                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                                    
                                    // send the request
                                    let session = URLSession.shared
                                    let task = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
                                        if let httpResponse = response as? HTTPURLResponse {
                                            if let contentType = httpResponse.allHeaderFields["Party"] as? String {
                                                // use contentType here
                                                print("This is the result of header", contentType)
                                                
                                                //NSOperationQueue.mainQueue().addOperationWithBlock {
                                                let currentActiveCartID = contentType
                                                print("currentActiveCartID", currentActiveCartID)
                                                
                                                // Send Side Item Data to cart_sides DB
                                                
                                                // Loop through the sides for each item
                                                
                                                //for i in restructuredItems {
                                                    self.sides?.removeAll()
                                                    self.sides = item.sides!.allObjects as? [Side]
                                                    print("elements in side array", self.sides!.count)
                                                    for side in self.sides! {
                                                        
                                                        // Create JSON data and configure the request
                                                        
                                                        // to get this currentActiveCartID, we need to get the Cart UID for the active cart for the specific user for the specific item_id
                                                        let params1 = ["cart_entry_uid": currentActiveCartID,
                                                            "side_id": side.id!,
                                                            "quantity": String(describing: item.quantity),
                                                            ]
                                                            as Dictionary<String, String>
                                                        
                                                        print("quantity: \(item.quantity)")
                                                        print("currentActiveCartID ", currentActiveCartID)
                                                        
                                                        // create the request & response
                                                        var request1 = URLRequest(url: Foundation.URL(string: "http://www.gobringit.com/CHADaddSideToCart.php")!, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 15)
                                                        
                                                        do {
                                                            let jsonData1 = try JSONSerialization.data(withJSONObject: params1, options: JSONSerialization.WritingOptions.prettyPrinted)
                                                            request1.httpBody = jsonData1
                                                        } catch let error1 as NSError {
                                                            print(error1)
                                                        }
                                                        request1.httpMethod = "POST"
                                                        request1.setValue("application/json", forHTTPHeaderField: "Content-Type")
                                                        
                                                        // send the request
                                                        let session1 = URLSession.shared
                                                        let task1 = session1.dataTask(with: request1, completionHandler: {
                                                            (data1, response1, error1) in
                                                        }) 
                                                        task1.resume()
                                                    }
                                                //}
                                            }
                                        }
                                        
                                        // Stop activity indicator again
                                        self.myActivityIndicator.isHidden = true
                                        self.myActivityIndicator.stopAnimating()
                                        
                                        OperationQueue.main.addOperation {
                                            // Send String(self.maxCartOrderID) as id,self.userID as user_id, restaurant id as service_id
                                            // Create JSON data and configure the request
                                            var payment_cc = ""
                                            if self.usingFoodPoints {
                                                print("USING FOOD POINTS")
                                                payment_cc = "0"
                                            } /*else if self.paymentMethodLabel == "Cash" {
                                                print("USING CASH")
                                                payment_cc = "2"
                                            }*/ else {
                                                print("USING CREDIT CARD")
                                                payment_cc = "1"
                                            }
                                            
                                            let params3 = ["id": String(self.maxCartOrderID),
                                                "user_id": self.userID,
                                                "service_id": self.activeCart![0].restaurantID!,
                                                "payment_cc": payment_cc
                                                ]
                                                as Dictionary<String, String>
                                            
                                            // create the request & response
                                            var request3 = URLRequest(url: Foundation.URL(string: "http://www.gobringit.com/CHADaddOrder.php")!, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 15)
                                            
                                            do {
                                                let jsonData3 = try JSONSerialization.data(withJSONObject: params3, options: JSONSerialization.WritingOptions.prettyPrinted)
                                                request3.httpBody = jsonData3
                                            } catch let error1 as NSError {
                                                print(error1)
                                            }
                                            request3.httpMethod = "POST"
                                            request3.setValue("application/json", forHTTPHeaderField: "Content-Type")
                                            
                                            // send the request
                                            let session3 = URLSession.shared
                                            let task3 = session3.dataTask(with: request3, completionHandler: {
                                                (data3, response3, error3) in
                                                print("data3", data3)
                                                print("response3", response3)
                                                print("error3", error3)
                                                
                                                // Update Customer Address
                                                OperationQueue.main.addOperation {
                                                    
                                                    // ADDRESS WAS HERE
                                                    
                                                }
                                                
                                            }) 
                                            // TODO: UNCOMMENT THIS LINE FOR ORDERING TO WORK
                                            task3.resume()
                                            
                                        }
                                    }) 
                                    task.resume()
                                }
                                
                                let addressToSend = addresses[addressIndex]
                                var addressInParts = [String]()
                                
                                var address1 = ""
                                var address2 = ""
                                var city = ""
                                var zip = ""
                                
                                addressToSend.enumerateLines {
                                    line, stop in
                                    addressInParts.append(line)
                                }
                                if addressInParts.count == 3 {
                                    address1 = addressInParts[0]
                                    city = addressInParts[1]
                                    zip = addressInParts[2]
                                } else {
                                    address1 = addressInParts[0]
                                    address2 = addressInParts[1]
                                    city = addressInParts[2]
                                    zip = addressInParts[3]
                                }
                                
                                let params4 = ["account_id": self.userID,
                                    "street": address1,
                                    "apartment": address2,
                                    "city": city,
                                    "state": "NC",
                                    "zip": zip,
                                    ]
                                    as Dictionary<String, String>
                                
                                // create the request & response
                                var request4 = URLRequest(url: Foundation.URL(string: "http://www.gobringit.com/CHADupdateAddress.php")!, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 15)
                                
                                do {
                                    let jsonData4 = try JSONSerialization.data(withJSONObject: params4, options: JSONSerialization.WritingOptions.prettyPrinted)
                                    request4.httpBody = jsonData4
                                } catch let error1 as NSError {
                                    print(error1)
                                }
                                request4.httpMethod = "POST"
                                request4.setValue("application/json", forHTTPHeaderField: "Content-Type")
                                
                                // send the request
                                let session4 = URLSession.shared
                                let task4 = session4.dataTask(with: request4, completionHandler: {
                                    (data4, response4, error4) in
                                    
                                }) 
                                
                                task4.resume()
                                
                                // Send to CHADplaceOrder
                                let params: [String: String] = [
                                    "user_id": self.userID,
                                    "service_id": self.activeCart![0].restaurantID!,
                                    "order_id": String(self.maxCartOrderID),
                                    "tip": String(format: "%.2f", self.tipAmount),
                                    "delivery_fee": String(format: "%.2f", self.deliveryFee),
                                    "payment_type": self.paymentMethodLabel
                                ]
                                let URL = "http://www.gobringit.com/includes/accounts/CHADplaceOrder.php"
                                let manager = AFHTTPSessionManager()
                                manager.responseSerializer = AFHTTPResponseSerializer()
                                manager.post(URL, parameters: params, success: { (operation, responseObject) -> Void in
                                    
                                    
                                }) 
                            }
                        }
                    }
                } catch let error as NSError {
                    print("Error:" + error.localizedDescription)
                }
            } else if let error = error {
                print("Error:" + error.localizedDescription)
            }
        }) 
        
        task2.resume();
    }
    
    // Check if user is already logged in. If not, present SignInViewController.
    func checkLoggedIn() {
        let loggedIn = defaults.bool(forKey: "loggedIn")
        if !loggedIn {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "signIn") as! SignInViewController
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    // Show tipDriverView
    func presentTipView() {
        // Add blur overlay
        blurEffectView.isHidden = false
        blurEffectView.frame = self.view.bounds
        self.view.addSubview(blurEffectView)
        self.view.addSubview(tipDriverView)
        
        // Animate view - Slide up
        let top = CGAffineTransform(translationX: 0, y: -550)
        UIView.animate(withDuration: 0.45, animations: {
            self.tipDriverView.transform = top
            //self.tipDriverView.center = CGPointMake(self.view.bounds.size.width  / 2,
                //self.view.bounds.size.height / 2);
        })

    }
    
    // Hide tipDriverView
    func hideTipView() {
        // Animate view - Slide down
        let bottom = CGAffineTransform(translationX: 0, y: 550)
        UIView.animate(withDuration: 0.35, animations: {
            self.tipDriverView.transform = bottom
        })
        
        //Remove blur overlay
        blurEffectView.isHidden = true
    }
    
    // Check if the user is currently using food points or a credit card
    func checkIfUsingFoodPoints() -> Bool {
        
        var switchOn = false
        if let on = defaults.object(forKey: "useFoodPoints") {
            switchOn = on as! Bool
        } else {
            defaults.set(true, forKey: "useFoodPoints")
            switchOn = true
        }
        
        // Make sure that "Use food points when possible" is switched on
        if switchOn {
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
        }
        return false
    }
    
    // MARK: - Payment methods
    
    func handleError(_ error: NSError) {
        print(error)
        UIAlertView(title: "Please Try Again",
                    message: error.localizedDescription,
                    delegate: nil,
                    cancelButtonTitle: "OK").show()
        
    }
    
    func buyButtonTapped() {
        self.paymentContext.requestPayment()
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
        if let paymentMethod = defaults.object(forKey: "selectedPaymentMethod") {
            paymentMethodLabel = paymentMethod as! String
            print(paymentMethodLabel)
        } else {
            if checkIfUsingFoodPoints() {
                paymentMethodLabel = "Food Points"
            } /*else {
                paymentMethodLabel = "Cash"
            }*/
        }
        
        detailsTableView.reloadData()
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
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toChangeOrder" {
            let nav = segue.destination as! UINavigationController
            let VC = nav.topViewController as! AddToOrderViewController
            
            VC.comingFromCheckoutVC = true
            VC.passedItem = items![selectedCell]
            VC.selectedFoodName = items![selectedCell].name!
            VC.selectedFoodDescription = items![selectedCell].dbDescription!
            VC.selectedFoodPrice = Double(items![selectedCell].price!)
            VC.selectedFoodID = items![selectedCell].id!
            VC.selectedFoodSidesNum = String(describing: items![selectedCell].selectedFoodSidesNum!)
        } else if segue.identifier == "toOrderPlaced" {
            let nav = segue.destination as! UINavigationController
            let VC = nav.topViewController as! OrderPlacedViewController
            
            VC.passedOrderTotal = totalCost
            print("TOTAL: \(totalCost)")
            VC.passedRestaurantName = activeCart![0].restaurant!
        }
    }
    
}

extension Date {
    static func timeAsIntegerFromDate(_ date: Date) -> Int {
        var currentCal = Calendar.current
        currentCal.timeZone = TimeZone.autoupdatingCurrent
        let comps: DateComponents = (currentCal as NSCalendar).components([NSCalendar.Unit.hour, NSCalendar.Unit.minute], from: date)
        return comps.hour! * 100 + comps.minute!
    }
    
    static func timeIsBetween(_ startDate: Date, endDate: Date) -> Bool {
        let startTime = Date.timeAsIntegerFromDate(startDate)
        let endTime = Date.timeAsIntegerFromDate(endDate)
        let nowTime = Date.timeAsIntegerFromDate(Date())
        
        if startTime == endTime { return false }
        
        if startTime < endTime {
            if nowTime >= startTime {
                if nowTime < endTime { return true }
            }
            return false
        } else {
            if nowTime >= startTime || nowTime < endTime {
                return true
            }
            return false
        }
    }
}

