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
    
    var cameFromVC = ""
    var deliverTo = ""
    var payWith = ""
    var totalCost = 0.0
    var selectedCell = 0
    var deliveryFee = 2.5 // TO-DO: CHAD! Please pull this from the db on AddToOrder!!!
    
    var items_ordered: [String] = []
    var items_ordered_quantity: [String] = []
    var items_ordered_cartUID: [String] = []
    var cartUID_side = [String: String]()
    var items_ordered_instructions: [String] = []
    
    var service_id = ""
    
    // CoreData variables
    var activeCart = [Order]()
    var items = [Item]()
    var sides = [Side]()
    
    // TO-DO: CHAD! So I've created 3 more fields in the struct for you to put the sides, extras and special instructions in. The way you can format it is to pull all the sides and extras and special instructions associated with one item, and create a single string with all the sides/extras separated by commas. For example, "Mashed Potatoes, Fries, Mac & Cheese". I will deal with other formatting later!
    /*
     // Data structure
     struct Item {
     var uid = ""
     var name = ""
     var quantity = 0
     var price = 0.00
     var sides = ""
     var extras = ""
     var specialInstructions = ""
     }
     
     struct Side {
     var uid = ""
     // Name of Side
     var name = ""
     // Price of Side
     var price = 0.00
     // isRequired = 0 means Extra, isRequired = 1 means Side
     var isRequired = 0
     }
     */
    
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
        userID = self.defaults.objectForKey("userID") as AnyObject! as! String
        var addressString: String?
        
        /*
         // Open Connection to PHP Service
         let requestURL4: NSURL = NSURL(string: "http://www.gobring.it/CHADrestaurantImage.php")!
         let urlRequest4: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL4)
         let session4 = NSURLSession.sharedSession()
         let task4 = session4.dataTaskWithRequest(urlRequest4) { (data, response, error) -> Void in
         if let data = data {
         do {
         let httpResponse = response as! NSHTTPURLResponse
         let statusCode = httpResponse.statusCode
         
         // Check HTTP Response
         if (statusCode == 200) {
         
         do{
         // Parse JSON
         let json = try NSJSONSerialization.JSONObjectWithData(data, options:.AllowFragments)
         
         for Restaurant in json as! [Dictionary<String, AnyObject>] {
         //var account_id: String?
         let id = Restaurant["id"] as! String
         if ( id == self.service_id ) {
         let delivery_fee = Restaurant["delivery_fee"] as AnyObject! as! String
         print(delivery_fee)
         self.deliveryFee = Double(delivery_fee)!
         }
         }
         NSOperationQueue.mainQueue().addOperationWithBlock {
         
         // Connect the sides in self.sides with self.items based on uid
         for i in 0...self.items.count - 1 {
         let indiv_item = self.items[i]
         let item_uid = indiv_item.uid
         for indiv_side in self.sides {
         let side_uid = indiv_side.uid
         if (item_uid == side_uid) {
         print("This is a side", indiv_side.name)
         print("for this item", indiv_item.name)
         
         if (indiv_side.isRequired == 1) {
         let newSides = indiv_item.sides + indiv_side.name + "($" + String(indiv_side.price) + "), "
         self.items[i] = Item(uid: indiv_item.uid, name: indiv_item.name, quantity: indiv_item.quantity, price: indiv_item.price, sides: newSides, extras: indiv_item.extras, specialInstructions: indiv_item.specialInstructions)
         print("newSides : ", newSides)
         } else {
         //indiv_item.extras += indiv_side.name + ", "
         var newExtras = indiv_item.extras + indiv_side.name + "($" + String(indiv_side.price) + "), "
         self.items[i] = Item(uid: indiv_item.uid, name: indiv_item.name, quantity: indiv_item.quantity, price: indiv_item.price, sides: indiv_item.sides, extras: newExtras, specialInstructions: indiv_item.specialInstructions)
         print("newExtras : ", newExtras)
         }
         
         
         }
         }
         }
         
         
         
         
         //THIS IS WHERE WE NEED TO RELOAD EVERYTHING
         self.itemsTableView.reloadData()
         self.detailsTableView.reloadData()
         self.updateViewConstraints()
         
         // Calculate and display delivery Fee and totalCost
         self.calculateTotalCost()
         self.deliveryFeeLabel.text = String(format: "$%.2f", self.deliveryFee)
         self.subtotalCostLabel.text = String(format: "$%.2f", self.totalCost)
         self.totalCostLabel.text = String(format: "$%.2f", self.totalCost + self.deliveryFee)
         
         // Stop activity indicator
         self.myActivityIndicator.stopAnimating()
         self.myActivityIndicator.hidden = true
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
         */
        
        // Open Connection to PHP Service
        let requestURL: NSURL = NSURL(string: "http://www.gobring.it/CHADaccountAddresses.php")!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(urlRequest) { (data, response, error) -> Void in
            if let data = data {
                do {
                    let httpResponse = response as! NSHTTPURLResponse
                    let statusCode = httpResponse.statusCode
                    
                    // Check HTTP Response
                    if (statusCode == 200) {
                        
                        do{
                            // Parse JSON
                            let json = try NSJSONSerialization.JSONObjectWithData(data, options:.AllowFragments)
                            
                            for Restaurant in json as! [Dictionary<String, AnyObject>] {
                                //var account_id: String?
                                let account_id = Restaurant["account_id"] as! String
                                if ( account_id.rangeOfString(self.userID) != nil ) {
                                    print(self.userID)
                                    print(Restaurant["street"] as? String)
                                    let street = Restaurant["street"] as AnyObject! as! String //+ ", " + Restaurant["apartment"] as AnyObject! as! String
                                    let apartment = Restaurant["apartment"] as AnyObject! as! String
                                    addressString = street + ", " + apartment
                                }
                            }
                            NSOperationQueue.mainQueue().addOperationWithBlock {
                                
                                print(addressString!)
                                self.deliverTo = addressString!
                                self.detailsTableView.reloadData()
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
        
        // COMMENTED OUT TO TRY COREDATA
        
        /*
         let requestURL3: NSURL = NSURL(string: "http://www.gobring.it/CHADitems.php")!
         let urlRequest3: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL3)
         let session3 = NSURLSession.sharedSession()
         let task3 = session3.dataTaskWithRequest(urlRequest3) { (data, response, error) -> Void in
         if let data = data {
         do {
         let httpResponse = response as! NSHTTPURLResponse
         let statusCode = httpResponse.statusCode
         
         // Check HTTP Response
         if (statusCode == 200) {
         
         do{
         // Parse JSON
         let json = try NSJSONSerialization.JSONObjectWithData(data, options:.AllowFragments)
         
         for Cart in json as! [Dictionary<String, AnyObject>] {
         
         let id = Cart["id"] as! String
         
         if self.items_ordered.contains(id) {
         print("this item id exists")
         print(Cart["name"] as! String)
         print(Cart["price"] as! String)
         
         let itemIndex = Int(self.items_ordered.indexOf(id)!);
         
         //CHAD! Pull from the db and replace the dummy variables here
         self.items.append(Item(uid: self.items_ordered_cartUID[itemIndex], name: Cart["name"] as! String, quantity: Int(self.items_ordered_quantity[itemIndex])!, price: Double(Cart["price"] as! String)!, sides: "", extras: "", specialInstructions: self.items_ordered_instructions[itemIndex]))
         self.service_id = Cart["service_id"] as! String
         }
         }
         NSOperationQueue.mainQueue().addOperationWithBlock {
         task.resume()
         
         //THIS IS WHERE WE NEED TO RELOAD EVERYTHING
         self.itemsTableView.reloadData()
         self.detailsTableView.reloadData()
         self.updateViewConstraints()
         //task4.resume()
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
         
         // search all menu_sides
         // if the cartUID_side contains the value item_id
         // save the name, price, required
         let requestURL6: NSURL = NSURL(string: "http://www.gobring.it/CHADmenuSides.php")!
         let urlRequest6: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL6)
         let session6 = NSURLSession.sharedSession()
         let task6 = session6.dataTaskWithRequest(urlRequest6) { (data, response, error) -> Void in
         if let data = data {
         do {
         let httpResponse = response as! NSHTTPURLResponse
         let statusCode = httpResponse.statusCode
         
         // Check HTTP Response
         if (statusCode == 200) {
         
         do{
         // Parse JSON
         let json = try NSJSONSerialization.JSONObjectWithData(data, options:.AllowFragments)
         
         for Side1 in json as! [Dictionary<String, AnyObject>] {
         let side_id = Side1["id"] as! String
         for (key, value) in self.cartUID_side {
         if (value == side_id) {
         self.sides.append(Side(uid: key, name: Side1["name"] as! String, price: Double(Side1["price"] as! String)!, isRequired: Int(Side1["required"] as! String)!))
         }
         }
         }
         
         NSOperationQueue.mainQueue().addOperationWithBlock {
         for side in self.sides {
         print("Side:", side.uid)
         print("Side:", side.name)
         print("Side:", side.price)
         print("Side:", side.isRequired)
         }
         //task3.resume()
         task4.resume()
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
         
         
         // search all cart_sides
         // if the cart_entry_uid is contained in self.cartUID_side
         // then update the value for that uid key with the side_id
         // Open Connection to PHP Service
         let requestURL5: NSURL = NSURL(string: "https://www.gobring.it/CHADcartSides.php")!
         let urlRequest5: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL5)
         let session5 = NSURLSession.sharedSession()
         let task5 = session5.dataTaskWithRequest(urlRequest5) { (data, response, error) -> Void in
         if let data = data {
         do {
         let httpResponse = response as! NSHTTPURLResponse
         let statusCode = httpResponse.statusCode
         
         // Check HTTP Response
         if (statusCode == 200) {
         
         do{
         // Parse JSON
         let json = try NSJSONSerialization.JSONObjectWithData(data, options:.AllowFragments)
         
         for Cart in json as! [Dictionary<String, AnyObject>] {
         //var account_id: String?
         let cart_entry_uid = Cart["cart_entry_uid"] as! String
         if let val = self.cartUID_side[cart_entry_uid] {
         self.cartUID_side.updateValue(Cart["side_id"] as! String, forKey: cart_entry_uid)
         }
         }
         NSOperationQueue.mainQueue().addOperationWithBlock {
         for (key, value) in self.cartUID_side {
         //print("Dictionary key \(key) -  Dictionary value \(value)")
         }
         
         // Activate task that will get the side_item name and price from this Dictionary
         task6.resume()
         
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
         
         // go through carts DB
         // filter by user_id
         // filter by active
         // save all the item_id's in an array
         // Open Connection to PHP Service to carts DB to find an active cart
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
         // Parse JSON
         let json = try NSJSONSerialization.JSONObjectWithData(data, options:.AllowFragments)
         
         for Cart in json as! [Dictionary<String, AnyObject>] {
         
         //let order_id = Cart["order_id"] as! String
         
         let user_id = Cart["user_id"] as! String
         
         if (userID == user_id) {
         let active_cart = Cart["active"] as! String
         if (active_cart == "1") {
         //print(order_id)
         self.items_ordered.append(Cart["item_id"] as! String)
         self.items_ordered_quantity.append(Cart["quantity"] as! String)
         self.items_ordered_cartUID.append(Cart["uid"] as! String)
         self.cartUID_side[Cart["uid"] as! String] = "NONE"
         self.items_ordered_instructions.append(Cart["instructions"] as! String)
         }
         }
         }
         NSOperationQueue.mainQueue().addOperationWithBlock {
         for item in self.items_ordered {
         //print("Item here:", item)
         }
         
         for item in self.items_ordered_quantity {
         //print("Item quantity here:", item)
         }
         
         for (key, value) in self.cartUID_side {
         //print("Dictionary key \(key) -  Dictionary value \(value)")
         }
         
         
         
         // now activate the cart_side search on if items_ordered_cartUID
         task5.resume()
         task3.resume()
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
         
         task2.resume();
         
         
         // go through menu_items DB
         // for all the elements with item_id matching in the previous array, save the name, price, and 1 service_id
         // this is done in task3
         
         // go through category_items DB
         // filter by service_id from previous
         // save delivery_fee
         
         /*var addressString: String?
         
         // Open Connection to PHP Service
         let requestURL: NSURL = NSURL(string: "http://www.gobring.it/CHADaccountAddresses.php")!
         let urlRequest: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL)
         let session = NSURLSession.sharedSession()
         let task = session.dataTaskWithRequest(urlRequest) { (data, response, error) -> Void in
         if let data = data {
         do {
         let httpResponse = response as! NSHTTPURLResponse
         let statusCode = httpResponse.statusCode
         
         // Check HTTP Response
         if (statusCode == 200) {
         
         do{
         // Parse JSON
         let json = try NSJSONSerialization.JSONObjectWithData(data, options:.AllowFragments)
         
         for Restaurant in json as! [Dictionary<String, AnyObject>] {
         //var account_id: String?
         let account_id = Restaurant["account_id"] as! String
         if ( account_id.rangeOfString(userID) != nil ) {
         print(userID)
         print(Restaurant["street"] as? String)
         let street = Restaurant["street"] as AnyObject! as! String //+ ", " + Restaurant["apartment"] as AnyObject! as! String
         let apartment = Restaurant["apartment"] as AnyObject! as! String
         addressString = street + ", " + apartment
         }
         }
         NSOperationQueue.mainQueue().addOperationWithBlock {
         print(addressString!)
         self.deliverTo = addressString!
         self.detailsTableView.reloadData()
         self.itemsTableView.reloadData();
         dispatch_async(dispatch_get_main_queue(), { () -> Void in
         self.itemsTableView.reloadData()
         })
         self.itemsTableView.performSelectorOnMainThread(Selector("reloadData"), withObject: nil, waitUntilDone: true)
         }
         }
         }
         } catch let error as NSError {
         print("Error:" + error.localizedDescription)
         }
         } else if let error = error {
         print("Error:" + error.localizedDescription)
         }
         }*/
         */
        
        task.resume()
        
        // Set SAMPLE DATA
        //deliverTo = "1369 Campus Drive"
        payWith = "Food Points"
        
        /*self.itemsTableView.reloadData();
         dispatch_async(dispatch_get_main_queue(), { () -> Void in
         self.itemsTableView.reloadData()
         })
         self.itemsTableView.performSelectorOnMainThread(#selector(UITableView.reloadData), withObject: nil, waitUntilDone: true)*/
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        if comingFromOrderPlaced == true {
            comingFromOrderPlaced = false
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        // Fetch all active carts, if any exist
        
        let fetchRequest = NSFetchRequest(entityName: "Order")
        let firstPredicate = NSPredicate(format: "isActive == %@", true)
        // TO-DO: FInd a way to know which restaurant we're in then uncomment below
        let secondPredicate = NSPredicate(format: "restaurant == %@", selectedRestaurantName)
        let predicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [firstPredicate, secondPredicate])
        fetchRequest.predicate = predicate
        
        
        
        do {
            if let fetchResults = try managedContext.executeFetchRequest(fetchRequest) as? [Order] {
                activeCart = fetchResults
                print(fetchResults.count)
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        // If cart is empty, then load empty state
        if activeCart.isEmpty {
            print("CART IS EMPTY")
        }
            //If request returns a cart, then display the cart
        else {
            let order = activeCart[0] // MAYBE DON'T HARD CODE
            items = order.items?.allObjects as! [Item]
            
            for i in 0..<order.items!.count {
                print((items[i].name))
            }
            
        }
        
        self.calculateTotalCost()
        self.deliveryFeeLabel.text = String(format: "$%.2f", self.deliveryFee)
        self.subtotalCostLabel.text = String(format: "$%.2f", self.totalCost)
        self.totalCostLabel.text = String(format: "$%.2f", self.totalCost + self.deliveryFee)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func calculateTotalCost() {
        totalCost = 0.0
        for item in items {
            var costOfSides = 0.0
            for side in item.sides?.allObjects as! [Side] {
                costOfSides += Double(side.price!)
            }
            totalCost += (Double(item.price!) + costOfSides) * Double(item.quantity!)
        }
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == itemsTableView {
            return items.count
        } else {
            return 2
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == itemsTableView {
            let cell = tableView.dequeueReusableCellWithIdentifier("checkoutCell", forIndexPath: indexPath) as! CheckoutTableViewCell
            
            // Set name and quantity labels
            cell.itemNameLabel.text = items[indexPath.row].name
            cell.itemQuantityLabel.text = String(items[indexPath.row].quantity!)
            
            // Calculate total item cost
            var totalItemCost = 0.0
            var costOfSides = 0.0
            for side in items[indexPath.row].sides?.allObjects as! [Side] {
                costOfSides += Double(side.price!)
            }
            totalItemCost += (Double(items[indexPath.row].price!) + costOfSides) * Double(items[indexPath.row].quantity!)
            cell.totalCostLabel.text = String(format: "%.2f", totalItemCost)
            
            // Format all sides and extras
            var sides = "Sides: "
            var extras = "Extras: "
            let allSides = items[indexPath.row].sides?.allObjects as! [Side]
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
            if items[indexPath.row].specialInstructions != "" {
                specialInstructions += items[indexPath.row].specialInstructions!
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
            
            cell.sidesLabel.attributedText = sidesAS
            cell.extrasLabel.attributedText = extrasAS
            cell.specialInstructionsLabel.attributedText = specialInstructionsAS
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("checkoutDetailsCell", forIndexPath: indexPath)
            
            if indexPath.row == 0 {
                cell.textLabel?.text = "Deliver To"
                cell.detailTextLabel?.text = deliverTo
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
                managedContext.deleteObject(items[indexPath.row])
                appDelegate.saveContext()
                
                items.removeAtIndex(indexPath.row)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                
                // Reload tableview and adjust tableview height
                itemsTableView.reloadData()
                updateViewConstraints()
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
    
    
    @IBAction func checkoutButtonPressed(sender: UIButton) {
        
        let alertController = UIAlertController(title: "Checkout", message: "Are you sure you want to checkout?", preferredStyle: .ActionSheet)
        let checkout = UIAlertAction(title: "Yes, bring me my food!", style: .Default, handler: { (action) -> Void in
            print("Checkout Button Pressed")
            
            // Start activity indicator again
            self.myActivityIndicator.hidden = false
            self.myActivityIndicator.startAnimating()
            
            // Update and save CoreData
            self.activeCart[0].dateOrdered = NSDate()
            self.activeCart[0].isActive = false
            self.activeCart[0].totalPrice = self.totalCost + self.deliveryFee
            
            self.appDelegate.saveContext()
            
            // TO-DO: CHAD! When you get checkout working, this is where you should make the final call!
            // I've set up the loops so you can go through all the items and each of their sides. To access the attributes of the items or sides, just write item. or side. and a list of attributes should pop up. Let me know if you need to add any attributes!
            
            // 1. Get 10 + order_id (task 2)
            // 2. (task)addItem using that order_id (), save the Party response header
            // 3. addSide (side-id, cart entry-id, quantity)
            
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
                                    
                                    for item in self.items {
                                        // Loop through all items
                                        print("HERERHERHERHE")
                                        print(item.id)
                                        print(item.name)
                                        print(item.quantity)
                                        //print(item.)
                                        // Create JSON data and configure the request
                                        let params = ["item_id": item.id!,
                                            "user_id": self.userID,
                                            "quantity": String(item.quantity!),
                                            "active": "1",
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
                                        
                                        // send the request
                                        let session = NSURLSession.sharedSession()
                                        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
                                            if let httpResponse = response as? NSHTTPURLResponse {
                                                if let contentType = httpResponse.allHeaderFields["Party"] as? String {
                                                    // use contentType here
                                                    print("This is the result of header", contentType)
                                                    
                                                    //NSOperationQueue.mainQueue().addOperationWithBlock {
                                                    var currentActiveCartID = contentType
                                                    print("currentActiveCartID", currentActiveCartID)
                                                    print("elements in side array", self.sides.count)
                                                    
                                                    // This line not working!
                                                    //self.sides.append(Side(name: "test", id: "11", price: 5.00, isRequired: false, item: nil))
                                                    
                                                    // Send Side Item Data to cart_sides DB
                                                    for side in self.sides {
                                                        // Loop through the sides for each item
                                                        print("HERHERH")
                                                        print(side.id)
                                                        print(side.name)
                                                        print(side.price)
                                                        
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
                                                    //}
                                                }
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
            
            task2.resume();
            
            
            // Stop activity indicator again
            self.myActivityIndicator.hidden = true
            self.myActivityIndicator.startAnimating()
            
            self.performSegueWithIdentifier("toOrderPlaced", sender: self)
        })
        let cancel = UIAlertAction(title: "No, cancel", style: .Cancel, handler: { (action) -> Void in
            print("Cancel Button Pressed")
        })
        
        alertController.addAction(checkout)
        alertController.addAction(cancel)
        
        presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func xButtonPressed(sender: AnyObject) {
        
        self.navigationController?.popViewControllerAnimated(true);
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "prepareForUnwind" {
            let VC = segue.destinationViewController as! MenuTableViewController
            VC.backToVC = cameFromVC
        } else if segue.identifier == "toDeliverToPayingWith" {
            let VC = segue.destinationViewController as! DeliverToPayingWithTableViewController
            if self.selectedCell == 0 {
                VC.selectedCell = "Deliver To"
            } else if self.selectedCell == 1 {
                VC.selectedCell = "Paying With"
            }
        } else if segue.identifier == "toChangeOrder" {
            let nav = segue.destinationViewController as! UINavigationController
            let VC = nav.topViewController as! AddToOrderViewController
            
            VC.comingFromCheckoutVC = true
            VC.passedItem = items[selectedCell]
            VC.selectedFoodName = items[selectedCell].name!
            VC.selectedFoodDescription = items[selectedCell].dbDescription!
            VC.selectedFoodPrice = Double(items[selectedCell].price!)
            VC.selectedFoodID = items[selectedCell].id!
            VC.selectedFoodSidesNum = String(items[selectedCell].selectedFoodSidesNum!)
        } else if segue.identifier == "toOrderPlaced" {
            let nav = segue.destinationViewController as! UINavigationController
            let VC = nav.topViewController as! OrderPlacedViewController
            
            VC.passedOrderTotal = totalCost + deliveryFee
        }
    }
    
}
