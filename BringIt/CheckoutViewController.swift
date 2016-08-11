//
//  CheckoutViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/26/16.
//  Copyright © 2016 Campus Enterprises. All rights reserved.
//

import UIKit
import CoreData

var comingFromOrderPlaced = false

class CheckoutViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var itemsTableView: UITableView!
    @IBOutlet weak var detailsTableView: UITableView!
    @IBOutlet weak var itemsTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var deliveryFeeLabel: UILabel!
    @IBOutlet weak var subtotalCostLabel: UILabel!
    @IBOutlet weak var totalCostLabel: UILabel!
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var checkoutButton: UIButton!
    
    var cameFromVC = ""
    var payWith = ""
    var totalCost = 0.0
    var selectedCell = 0
    var deliveryFee = 0.0
    
    var items_ordered: [String] = []
    var items_ordered_quantity: [String] = []
    var items_ordered_cartUID: [String] = []
    var cartUID_side = [String: String]()
    var items_ordered_instructions: [String] = []
    
    var service_id = ""
    
    // CoreData variables
    var activeCart: [Order]?
    var items: [Item]?
    var sides: [Side]?
    
    // CoreData
    let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
    let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    // Get USER ID
    let defaults = NSUserDefaults.standardUserDefaults()
    
    // Chad's data
    var maxCartOrderID = 0
    var reset = false
    var userID = ""
    var currentAddress = ""
    var serviceID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title
        self.title = "Checkout"
        
        // Set nav bar preferences
        self.navigationController?.navigationBar.tintColor = UIColor.darkGrayColor()
        navigationController!.navigationBar.titleTextAttributes =
            ([NSFontAttributeName: TITLE_FONT,
                NSForegroundColorAttributeName: UIColor.blackColor()])
        
        // Set custom back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        // Hide activity indicator
        myActivityIndicator.hidden = true
        
        // Get Address of User
        // var userID: String?
        if let id = self.defaults.objectForKey("userID") {
            userID = id as! String
            print("USER ID: \(userID)")
        }
        
        // Set SAMPLE DATA
        //deliverTo = "1369 Campus Drive"
        payWith = "Food Points"
        
        calculateTotalCost()
    }
    
    override func viewWillAppear(animated: Bool) {
        print("HELLO1")
        if comingFromOrderPlaced == true {
            comingFromOrderPlaced = false
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        // Deselect cells when view appears
        if let indexPath = itemsTableView.indexPathForSelectedRow {
            itemsTableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        if let indexPath = detailsTableView.indexPathForSelectedRow {
            detailsTableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
        // DETAIL TABLEVIEW
        
        var addresses = [String]()
        if let addressesArray = defaults.objectForKey("Addresses") {
            addresses = addressesArray as! [String]
        }
        if let index = defaults.objectForKey("CurrentAddressIndex") {
            if index as! Int != -1 {
                currentAddress = addresses[index as! Int]
                checkoutButton.alpha = 1
                checkoutButton.enabled = true
            } else {
                checkoutButton.alpha = 0.5
                checkoutButton.enabled = false
            }
        } else {
            checkoutButton.alpha = 0.5
            checkoutButton.enabled = false
        }
        detailsTableView.reloadData()
        
        // ITEMS TABLEVIEW
        
        // Fetch all active carts, if any exist
        
        let fetchRequest = NSFetchRequest(entityName: "Order")
        let firstPredicate = NSPredicate(format: "isActive == %@", true)
        let secondPredicate = NSPredicate(format: "restaurant == %@", selectedRestaurantName)
        let predicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [firstPredicate, secondPredicate])
        fetchRequest.predicate = predicate
        
        print("HELLO2")
        
        do {
            if let fetchResults = try managedContext.executeFetchRequest(fetchRequest) as? [Order] {
                activeCart = fetchResults
                print(fetchResults.count)
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        print("HELLO3")
        
        // If cart is empty, then load empty state
        if activeCart!.isEmpty {
            print("CART IS EMPTY")
            
            // Set values to nil
            items = nil
            sides = nil
        }
            //If request returns a cart, then display the cart
        else {
            
            print("HELLO4")
            let order = activeCart![0] // MAYBE DON'T HARD CODE
            
            print("HELLO5")
            
            // Set delivery fee
            deliveryFee = Double(order.deliveryFee!)
            print("HELLO6")
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
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == itemsTableView {
            canCheckout()
            if let numItems = items?.count {
                return numItems
            }
            return 0
        } else {
            return 2
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == itemsTableView {
            let cell = tableView.dequeueReusableCellWithIdentifier("checkoutCell", forIndexPath: indexPath) as! CheckoutTableViewCell
            
            // Set name and quantity labels
            cell.itemNameLabel.text = items![indexPath.row].name
            cell.itemQuantityLabel.text = String(items![indexPath.row].quantity!)
            
            // Calculate total item cost
            var totalItemCost = 0.0
            var costOfSides = 0.0
            for side in items![indexPath.row].sides?.allObjects as! [Side] {
                costOfSides += Double(side.price!)
            }
            totalItemCost += (Double(items![indexPath.row].price!) + costOfSides) * Double(items![indexPath.row].quantity!)
            cell.totalCostLabel.text = String(format: "%.2f", totalItemCost)
            
            // Format all sides and extras
            var sides = "Sides: "
            var extras = "Extras: "
            let allSides = items![indexPath.row].sides?.allObjects as! [Side]
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
            if items![indexPath.row].specialInstructions != "" {
                specialInstructions += items![indexPath.row].specialInstructions!
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
            let cell = tableView.dequeueReusableCellWithIdentifier("checkoutDetailsCell", forIndexPath: indexPath)
            
            if indexPath.row == 0 {
                cell.textLabel?.text = "Deliver To"
                if currentAddress != "" {
                    cell.detailTextLabel?.text = currentAddress
                } else {
                    cell.detailTextLabel?.text = "Add New Address"
                }
                
            } else {
                cell.textLabel?.text = "Pay With"
                cell.detailTextLabel?.text = payWith
            }
            
            return cell
        }
    }
    
    // Resize itemsTableView
    override func updateViewConstraints() {
        super.updateViewConstraints()
        itemsTableViewHeight.constant = itemsTableView.contentSize.height
    }
    
    // Override to support editing the table view.
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == itemsTableView {
            if editingStyle == .Delete {
                
                // Delete the row from the data source
                managedContext.deleteObject(items![indexPath.row])
                appDelegate.saveContext()
                items!.removeAtIndex(indexPath.row)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                
                // Reload tableview and adjust tableview height and recalculate costs
                itemsTableView.reloadData()
                updateViewConstraints()
                calculateTotalCost()
            }
        }
    }
    
    // Find out which cell was selected and sent to prepareForSegue
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        selectedCell = indexPath.row
        
        return indexPath
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == itemsTableView {
            performSegueWithIdentifier("toChangeOrder", sender: self)
        }
    }
    
    // Check if checkout is possible. If not, disable checkout button and make it more transparent.
    func canCheckout() {
        if items != nil {
            if !(items?.isEmpty)! && currentAddress != "" {
                checkoutButton.alpha = 1.0
                checkoutButton.enabled = true
            }
        } else {
            checkoutButton.alpha = 0.5
            checkoutButton.enabled = false
        }
    }
    
    // Checkout process
    @IBAction func checkoutButtonPressed(sender: UIButton) {
        
        let alertController = UIAlertController(title: "Checkout", message: "Are you sure you want to checkout?", preferredStyle: .ActionSheet)
        let checkout = UIAlertAction(title: "Yes, bring me my food!", style: .Default, handler: { (action) -> Void in
            print("Checkout Button Pressed")
            
            // Start activity indicator again
            self.myActivityIndicator.hidden = false
            self.myActivityIndicator.startAnimating()
            
            // Update and save CoreData
            self.activeCart![0].dateOrdered = NSDate()
            self.activeCart![0].isActive = false
            self.activeCart![0].totalPrice = self.totalCost + self.deliveryFee
            
            self.appDelegate.saveContext()
            
            let addresses = self.defaults.objectForKey("Addresses") as! [String]
            let addressIndex = self.defaults.objectForKey("CurrentAddressIndex") as! Int
            
            // TO-DO: CHAD! When you get checkout working, this is where you should make the final call!
            // I've set up the loops so you can go through all the items and each of their sides. To access the attributes of the items or sides, just write item. or side. and a list of attributes should pop up. Let me know if you need to add any attributes!
            
            // 1. Get 10 + order_id (task 2)
            // 2. (task)addItem using that order_id (), save the Party response header
            // 3. addSide (side-id, cart entry-id, quantity)
            
            print("HELLO1")
            
            let requestURL2: NSURL = NSURL(string: "http://www.gobring.it/CHADcarts.php")!
            let urlRequest2: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL2)
            let session2 = NSURLSession.sharedSession()
            let task2 = session2.dataTaskWithRequest(urlRequest2) { (data, response, error) -> Void in
                if let data = data {
                    do {
                        let httpResponse = response as! NSHTTPURLResponse
                        let statusCode = httpResponse.statusCode
                        
                        // Check HTTP Response
                        if (statusCode == 200) {
                            
                            do{
                                
                                if (self.maxCartOrderID == 0) {
                                    self.reset = true
                                }
                                // Parse JSON
                                let json = try NSJSONSerialization.JSONObjectWithData(data, options:.AllowFragments)
                                
                                for Cart in json as! [Dictionary<String, AnyObject>] {
                                    
                                    let order_id = Cart["order_id"] as! String
                                    if (Int(order_id)! > self.maxCartOrderID) {
                                        self.maxCartOrderID = Int(order_id)!
                                    }
                                    
                                    /*let user_id = Cart["user_id"] as! String
                                     
                                     if (userID == user_id) {
                                     let active_cart = Cart["active"] as! String
                                     if (active_cart == "1") {
                                     print(order_id)
                                     self.currentActiveCartOrderID = order_id
                                     }
                                     }*/
                                }
                                
                                NSOperationQueue.mainQueue().addOperationWithBlock {
                                    if (self.reset == true) {
                                        self.maxCartOrderID = self.maxCartOrderID + 10;
                                    }
                                    
                                    print("This is the current max order_id", self.maxCartOrderID)
                                    
                                    // STEP 2: loop through all items and add them to cart
                                    
                                    for item in self.items! {
                                        // Loop through all items
                                        print(item.id)
                                        print(item.name)
                                        print(item.quantity)
                                        
                                        // Create JSON data and configure the request
                                        let params = ["item_id": item.id!,
                                            "user_id": self.userID,
                                            "quantity": String(item.quantity!),
                                            "active": "0",
                                            "instructions": item.specialInstructions!,
                                            "order_id": String(self.maxCartOrderID),
                                            ]
                                            as Dictionary<String, String>
                                        
                                        // create the request & response
                                        let request = NSMutableURLRequest(URL: NSURL(string: "http://www.gobring.it/CHADaddItemToCart.php")!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 15)
                                        
                                        do {
                                            let jsonData = try NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions.PrettyPrinted)
                                            request.HTTPBody = jsonData
                                            
                                        } catch let error as NSError {
                                            print(error)
                                        }
                                        request.HTTPMethod = "POST"
                                        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                                        
                                        print("HELLO3")
                                        
                                        // send the request
                                        let session = NSURLSession.sharedSession()
                                        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
                                            if let httpResponse = response as? NSHTTPURLResponse {
                                                if let contentType = httpResponse.allHeaderFields["Party"] as? String {
                                                    // use contentType here
                                                    print("This is the result of header", contentType)
                                                    
                                                    //NSOperationQueue.mainQueue().addOperationWithBlock {
                                                    let currentActiveCartID = contentType
                                                    print("currentActiveCartID", currentActiveCartID)
                                                    
                                                    // Send Side Item Data to cart_sides DB
                                                    
                                                    // Loop through the sides for each item
                                                    
                                                    for i in self.items! {
                                                        self.sides = i.self.sides!.allObjects as? [Side]
                                                        print("elements in side array", self.sides!.count)
                                                        for side in self.sides! {
                                                            
                                                            // Create JSON data and configure the request
                                                            
                                                            // to get this currentActiveCartID, we need to get the Cart UID for the active cart for the specific user for the specific item_id
                                                            let params1 = ["cart_entry_uid": currentActiveCartID,
                                                                "side_id": side.id!,
                                                                "quantity": String(item.quantity),
                                                                ]
                                                                as Dictionary<String, String>
                                                            
                                                            print("currentActiveCartID ", currentActiveCartID)
                                                            
                                                            // create the request & response
                                                            let request1 = NSMutableURLRequest(URL: NSURL(string: "http://www.gobring.it/CHADaddSideToCart.php")!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 15)
                                                            
                                                            do {
                                                                let jsonData1 = try NSJSONSerialization.dataWithJSONObject(params1, options: NSJSONWritingOptions.PrettyPrinted)
                                                                request1.HTTPBody = jsonData1
                                                            } catch let error1 as NSError {
                                                                print(error1)
                                                            }
                                                            request1.HTTPMethod = "POST"
                                                            request1.setValue("application/json", forHTTPHeaderField: "Content-Type")
                                                            
                                                            // send the request
                                                            let session1 = NSURLSession.sharedSession()
                                                            let task1 = session1.dataTaskWithRequest(request1) {
                                                                (let data1, let response1, let error1) in
                                                            }
                                                            task1.resume()
                                                        }
                                                    }
                                                }
                                                
                                            }
                                            
                                            // Stop activity indicator again
                                            self.myActivityIndicator.hidden = true
                                            self.myActivityIndicator.stopAnimating()
                                            
                                            print("SEGUE TIMEEEEEEE")
                                            self.performSegueWithIdentifier("toOrderPlaced", sender: self)
                                            
                                            NSOperationQueue.mainQueue().addOperationWithBlock {
                                                // Send String(self.maxCartOrderID) as id,self.userID as user_id, restaurant id as service_id
                                                // Create JSON data and configure the request
                                                
                                                let params3 = ["id": String(self.maxCartOrderID),
                                                    "user_id": self.userID,
                                                    "service_id": self.activeCart![0].restaurantID!,
                                                    ]
                                                    as Dictionary<String, String>
                                                
                                                // create the request & response
                                                let request3 = NSMutableURLRequest(URL: NSURL(string: "http://www.gobring.it/CHADaddOrder.php")!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 15)
                                                
                                                do {
                                                    let jsonData3 = try NSJSONSerialization.dataWithJSONObject(params3, options: NSJSONWritingOptions.PrettyPrinted)
                                                    request3.HTTPBody = jsonData3
                                                } catch let error1 as NSError {
                                                    print(error1)
                                                }
                                                request3.HTTPMethod = "POST"
                                                request3.setValue("application/json", forHTTPHeaderField: "Content-Type")
                                                
                                                // send the request
                                                let session3 = NSURLSession.sharedSession()
                                                let task3 = session3.dataTaskWithRequest(request3) {
                                                    (let data3, let response3, let error3) in
                                                    print("data3", data3)
                                                    print("response3", response3)
                                                    
                                                    // Update Customer Address
                                                    NSOperationQueue.mainQueue().addOperationWithBlock {
                                                        
                                                        
                                                        let addressToSend = addresses[addressIndex]
                                                        var addressInParts = [String]()
                                                        
                                                        var address1 = ""
                                                        var address2 = ""
                                                        var city = ""
                                                        var zip = ""
                                                        
                                                        addressToSend.enumerateLines { addressInParts.append($0.line) }
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
                                                        
                                                        // TODO Alex, can you put in the portions of the address here?
                                                        let params4 = ["account_id": self.userID,
                                                            "street": address1,
                                                            "apartment": address2,
                                                            "city": city,
                                                            "state": "NC",
                                                            "zip": zip,
                                                            ]
                                                            as Dictionary<String, String>
                                                        
                                                        // create the request & response
                                                        let request4 = NSMutableURLRequest(URL: NSURL(string: "http://www.gobring.it/CHADupdateAddress.php")!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 15)
                                                        
                                                        do {
                                                            let jsonData4 = try NSJSONSerialization.dataWithJSONObject(params4, options: NSJSONWritingOptions.PrettyPrinted)
                                                            request4.HTTPBody = jsonData4
                                                        } catch let error1 as NSError {
                                                            print(error1)
                                                        }
                                                        request4.HTTPMethod = "POST"
                                                        request4.setValue("application/json", forHTTPHeaderField: "Content-Type")
                                                        
                                                        // send the request
                                                        let session4 = NSURLSession.sharedSession()
                                                        let task4 = session4.dataTaskWithRequest(request4) {
                                                            (let data4, let response4, let error4) in
                                                            
                                                        }
                                                        
                                                        task4.resume()
                                                       
                                                    }
                                                    
                                                }
                                                // TODO: UNCOMMENT THIS LINE FOR ORDERING TO WORK
                                                task3.resume()

                                            }
                                        }
                                        task.resume()
                                    }
                                }
                            }
                        }
                    } catch let error as NSError {
                        print("Error:" + error.localizedDescription)
                    }
                } else if let error = error {
                    print("Error:" + error.localizedDescription)
                }
            }
            
            print("HELLO4")
            
            task2.resume();
            
            print("HELLO5")
            
        })
        let cancel = UIAlertAction(title: "No, cancel", style: .Cancel, handler: { (action) -> Void in
            print("Cancel Button Pressed")
        })
        
        alertController.addAction(checkout)
        alertController.addAction(cancel)
        
        presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func xButtonPressed(sender: UIBarButtonItem) {
        
        print("X button was pressed!")
        print(cameFromVC)
        
        if cameFromVC == "" {
            performSegueWithIdentifier("returnToScheduleDetails", sender: self)
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        /*if segue.identifier == "prepareForUnwind" {
            let VC = segue.destinationViewController as! MenuTableViewController
            VC.backToVC = cameFromVC
        } else*/ if segue.identifier == "toDeliverToPayingWith" {
            let VC = segue.destinationViewController as! DeliverToPayingWithViewController
            if self.selectedCell == 0 {
                VC.selectedCell = "Deliver To"
            } else if self.selectedCell == 1 {
                VC.selectedCell = "Paying With"
            }
        } else if segue.identifier == "toChangeOrder" {
            let nav = segue.destinationViewController as! UINavigationController
            let VC = nav.topViewController as! AddToOrderViewController
            
            VC.comingFromCheckoutVC = true
            VC.passedItem = items![selectedCell]
            VC.selectedFoodName = items![selectedCell].name!
            VC.selectedFoodDescription = items![selectedCell].dbDescription!
            VC.selectedFoodPrice = Double(items![selectedCell].price!)
            VC.selectedFoodID = items![selectedCell].id!
            VC.selectedFoodSidesNum = String(items![selectedCell].selectedFoodSidesNum!)
        } else if segue.identifier == "toOrderPlaced" {
            let nav = segue.destinationViewController as! UINavigationController
            let VC = nav.topViewController as! OrderPlacedViewController
            
            VC.passedOrderTotal = totalCost + deliveryFee
            VC.passedRestaurantName = activeCart![0].restaurant!
        }
    }
    
}
