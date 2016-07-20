//
//  AddToOrderTableViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/25/16.
//  Copyright © 2016 Campus Enterprises. All rights reserved.
//

import UIKit
import GMStepper

class AddToOrderViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // Get USER ID
    let defaults = NSUserDefaults.standardUserDefaults()
    
    // Create struct to organize data
    struct SideItem {
        var sideName: String
        var sidePrice: String
        var sideRequired: String
        var sideID: String
        var selected: Bool
    }
    
    // Create empty array of Restaurants to be filled in ViewDidLoad
    var sideItems: [SideItem] = []
    
    // DATA
    var sideNames = [String]()
    var sidePrices = [String]()
    var sideRequireds = [String]()
    var sideIDs = [String]()
    var sideIDSelectedArray = [String]()
    
    // DATA
    var sectionNames = [String]() //["DESCRIPTION", "SIDES (PICK 2)", "EXTRAS", "SPECIAL INSTRUCTIONS"]
    var section1 = [String]()
    var section2 = [SideItem]()
    let section3 = "E.g. Easy on the mayo, add bacon"
    
    var numberOfSidesSelected = 0
    var totalPrice = 0.0
    
    // Get indexes of each section (in case some aren't added because there are no rows to show)
    var sidesIndex = -1
    var extrasIndex = -1
    var specialInstructionsIndex = -1
    var priceIndex = -1
    
    // MARK: - IBOutlets
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var stepper: GMStepper!
    @IBOutlet weak var addToOrderButton: UIButton!
    
    // Data passed from previous View Controller
    var selectedFoodName = ""
    var selectedFoodDescription = ""
    var selectedFoodPrice = ""
    var selectedFoodID = ""
    var selectedFoodSidesNum = ""
    
    // Backend Data
    var sidesIDList = [String]()
    var currentActiveCartOrderID = "NONE"
    var currentActiveCartID = "NONE"
    var maxCartOrderID: Int = 0
    var specialInstructions = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userID = self.defaults.objectForKey("userID") as AnyObject! as! String
        print(userID)
        
        // Set title
        self.title = selectedFoodName
        
        // Set custom nav bar font
        navigationController!.navigationBar.titleTextAttributes =
            ([NSFontAttributeName: TITLE_FONT,
                NSForegroundColorAttributeName: UIColor.blackColor()])
        
        // Set custom back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        // Calculate base price
        calculatePrice()
        
        // Set tableView cells to custom height and automatically resize if needed
        myTableView.estimatedRowHeight = 50
        myTableView.rowHeight = UITableViewAutomaticDimension
        
        // Allow multiple selection in tableView
        self.myTableView.allowsMultipleSelection = true
        
        // Set stepper font
        stepper.labelFont = UIFont(name: "Avenir-Medium", size: 20)!
        stepper.buttonsFont = UIFont(name: "Avenir-Black", size: 20)!
        stepper.addTarget(self, action: #selector(AddToOrderViewController.stepperTapped(_:)), forControlEvents: .ValueChanged)
        
        // Check if the required sides have been selected
        if numberOfSidesSelected == Int(selectedFoodSidesNum) {
            // Enable the button and make it opaque
            addToOrderButton.alpha = 1
            addToOrderButton.enabled = true
            
            // Enable the stepper and make it opaque
            stepper.alpha = 1
            stepper.enabled = true
        } else {
            // Disable the button and make it transparent
            addToOrderButton.alpha = 0.5
            addToOrderButton.enabled = false
            
            // Disable the stepper and make it transparent
            stepper.alpha = 0.5
            stepper.enabled = false
        }
        
        // Set tableView cells to custom height and automatically resize if needed
        myTableView.estimatedRowHeight = 55
        self.myTableView.rowHeight = UITableViewAutomaticDimension
        
        /*// Open Connection to PHP Service to carts DB to find an active cart
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
         
         let order_id = Cart["order_id"] as! String
         if (Int(order_id)! > self.maxCartOrderID) {
         print( Int(order_id)!)
         self.maxCartOrderID = Int(order_id)!
         }
         
         let user_id = Cart["user_id"] as! String
         
         if (userID == user_id) {
         let active_cart = Cart["active"] as! String
         if (active_cart == "1") {
         print(order_id)
         self.currentActiveCartOrderID = order_id
         }
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
         
         task2.resume();*/
        
        // Open Connection to PHP Service to menuSides
        let requestURL1: NSURL = NSURL(string: "http://www.gobring.it/CHADmenuSides.php")!
        let urlRequest1: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL1)
        let session1 = NSURLSession.sharedSession()
        let task1 = session1.dataTaskWithRequest(urlRequest1) { (data, response, error) -> Void in
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
                                let side_id = Restaurant["id"] as! String
                                if (self.sidesIDList.contains(side_id)) {
                                    print(Restaurant["name"] as! String)
                                    self.sideNames.append(Restaurant["name"] as! String)
                                    self.sidePrices.append(Restaurant["price"] as! String)
                                    self.sideRequireds.append(Restaurant["required"] as! String)
                                    self.sideIDs.append(side_id)
                                }
                            }
                            
                            NSOperationQueue.mainQueue().addOperationWithBlock {
                                // Loop through DB data and append Restaurant objects into restaurants array
                                for i in 0..<self.sideNames.count {
                                    self.sideItems.append(SideItem(sideName: self.sideNames[i], sidePrice: self.sidePrices[i], sideRequired: self.sideRequireds[i], sideID: self.sideIDs[i], selected: false))
                                }
                                for i in 0..<self.sideItems.count {
                                    // If required and price == 0, Section 1
                                    if (self.sideItems[i].sideRequired == "1" && self.sideItems[i].sidePrice == "0") {
                                        self.section1.append(self.sideItems[i].sideName)
                                        print("S1:" + self.sideItems[i].sideName)
                                    }
                                    // If required and price !=0, Section 2
                                    if (self.sideItems[i].sideRequired == "1" && self.sideItems[i].sidePrice != "0") {
                                        self.section2.append(SideItem(sideName: self.sideItems[i].sideName, sidePrice: self.sideItems[i].sidePrice, sideRequired: "0", sideID: self.sideIDs[i], selected: false))
                                        print("S2:" + self.sideItems[i].sideName + "S2Price:" + self.sideItems[i].sidePrice)
                                    }
                                    // If not required, Section 2
                                    if (self.sideItems[i].sideRequired == "0") {
                                        self.section2.append(SideItem(sideName: self.sideItems[i].sideName, sidePrice: self.sideItems[i].sidePrice, sideRequired: "0", sideID: self.sideIDs[i], selected: false))
                                        print("S2:" + self.sideItems[i].sideName + "S2Price:" + self.sideItems[i].sidePrice)
                                    }
                                }
                                
                                // Populate sectionNames array
                                print("Selected Food ID: " + self.selectedFoodID)
                                print("How many sides this food item can have: " + self.selectedFoodSidesNum)
                                self.sectionNames.append("Description")
                                if self.section1.count > 0 {
                                    self.sectionNames.append("Sides")
                                }
                                if self.section2.count > 0 {
                                    self.sectionNames.append("Extras")
                                }
                                self.sectionNames.append("Special Instructions")
                                self.sectionNames.append("Price")
                                
                                if let sIndex = self.sectionNames.indexOf("Sides") {
                                    self.sidesIndex = sIndex
                                }
                                if let eIndex = self.sectionNames.indexOf("Extras") {
                                    self.extrasIndex = eIndex
                                }
                                self.specialInstructionsIndex = self.sectionNames.indexOf("Special Instructions")!
                                self.priceIndex = self.sectionNames.indexOf("Price")!
                                
                                self.myTableView.reloadData()
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
        
        // Open Connection to PHP Service
        let requestURL: NSURL = NSURL(string: "http://www.gobring.it/CHADmenuSidesItemLink.php")!
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
                                var item_id: String?
                                item_id = Restaurant["item_id"] as? String
                                if (item_id == nil) {
                                } else {
                                    // loop through item_id's and make an array of corresponding sides_id's
                                    if (self.selectedFoodID == item_id) {
                                        let sides_id = Restaurant["sides_id"] as! String
                                        self.sidesIDList.append(sides_id)
                                    }
                                }
                            }
                            NSOperationQueue.mainQueue().addOperationWithBlock {
                                for i in 0..<self.sidesIDList.count {
                                    print("SidesIDs: " + self.sidesIDList[i])
                                }
                                
                                // Only create list of actual sides after the ID's have been collected
                                task1.resume()
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
        
        task.resume()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func addToOrderButtonPressed(sender: UIButton) {
        
        // loop through all carts with user_id searching for active
        let userID = self.defaults.objectForKey("userID") as AnyObject! as! String
        print(userID)
        
        // Retrieve special instructions if available
        let indexPath = NSIndexPath(forRow: 0, inSection: 3)
        let selectedCell = myTableView.cellForRowAtIndexPath(indexPath) as! AddToOrderSpecialInstructionsTableViewCell!
        if selectedCell != nil && selectedCell.specialInstructionsText.text != nil {
            specialInstructions = selectedCell.specialInstructionsText.text!
        }
        
        // Retrieve the selected sides and put them in sideIDSelectedArray
        // For required sides
        for item in sideItems {
            if item.selected {
                sideIDSelectedArray.append(item.sideID)
            }
        }
        // For optional sides
        for item in section2 {
            if item.selected {
                sideIDSelectedArray.append(item.sideID)
            }
        }
        
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
                                
                                let order_id = Cart["order_id"] as! String
                                if (Int(order_id)! > self.maxCartOrderID) {
                                    self.maxCartOrderID = Int(order_id)!
                                }
                                
                                let user_id = Cart["user_id"] as! String
                                
                                if (userID == user_id) {
                                    let active_cart = Cart["active"] as! String
                                    if (active_cart == "1") {
                                        //print(order_id)
                                        self.currentActiveCartOrderID = order_id
                                        self.currentActiveCartID = Cart["uid"] as! String
                                    }
                                }
                            }
                            
                            NSOperationQueue.mainQueue().addOperationWithBlock {
                                if (self.currentActiveCartOrderID == "NONE") {
                                    self.maxCartOrderID = self.maxCartOrderID + 10;
                                    self.currentActiveCartOrderID = String(self.maxCartOrderID);
                                } else {
                                    //print("This is the active cart order id value", self.currentActiveCartOrderID)
                                }
                                //print("This is the current max order_id", self.maxCartOrderID)
                                
                                // Send main item data to carts DB
                                
                                // Create JSON data and configure the request
                                let params = ["item_id": self.selectedFoodID,
                                    "user_id": userID,
                                    "quantity": String(Int(self.stepper.value)),
                                    "active": "1",
                                    "instructions": self.specialInstructions,
                                    "order_id": String(self.currentActiveCartOrderID),
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
                                            //print("This is the result of header", contentType)
                                            
                                            NSOperationQueue.mainQueue().addOperationWithBlock {
                                                self.currentActiveCartID = contentType
                                                
                                                // Send Side Item Data to cart_sides DB
                                                for sideID in self.sideIDSelectedArray {
                                                    //print("SideId: ", sideID)
                                                    //print("Cart's UID2: ",self.currentActiveCartID)
                                                    
                                                    // Create JSON data and configure the request
                                                    
                                                    // to get this currentActiveCartID, we need to get the Cart UID for the active cart for the specific user for the specific item_id
                                                    let params1 = ["cart_entry_uid": self.currentActiveCartID,
                                                        "side_id": sideID,
                                                        "quantity": String(self.stepper.value),
                                                        ]
                                                        as Dictionary<String, String>
                                                    
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
                                }
                                task.resume()
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
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func xButtonClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func calculatePrice() {
        totalPrice = Double(selectedFoodPrice)!
        for side in section2 {
            if side.selected {
                totalPrice += Double(side.sidePrice)!
            }
        }
        totalPrice = totalPrice * stepper.value
        
        myTableView.reloadData()
    }
    
    func stepperTapped(sender: GMStepper) {
        // Recalculate price
        calculatePrice()
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionNames.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 { // Description
            return 1
        } else if section == sidesIndex { // Sides
            return section1.count
        } else if section == extrasIndex { // Extras
            return section2.count
        } else if section == specialInstructionsIndex { // Special Instructions
            return 1
        } else { // Price
            return 1
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("descriptionCell", forIndexPath: indexPath) as! AddToOrderSpecialInstructionsTableViewCell
            
            cell.textLabel?.text = selectedFoodDescription
            
            return cell
        } else if indexPath.section == sidesIndex {
            let cell = tableView.dequeueReusableCellWithIdentifier("addToOrderCell", forIndexPath: indexPath) as! AddToOrderTableViewCell
            
            // Set cell properties
            cell.selectionStyle = .None
            cell.sideLabel.text = section1[indexPath.row]
            cell.extraCostLabel.hidden = true
            
            //Change cell's tint color
            cell.tintColor = GREEN
            
            if sideItems[indexPath.row].selected {
                cell.accessoryType = .Checkmark
            } else {
                cell.accessoryType = .None
            }
            
            return cell
        } else if indexPath.section == extrasIndex {
            let cell = tableView.dequeueReusableCellWithIdentifier("addToOrderCell", forIndexPath: indexPath) as! AddToOrderTableViewCell
            
            // Set cell properties
            cell.selectionStyle = .None
            cell.sideLabel.text = section2[indexPath.row].sideName
            cell.extraCostLabel.hidden = false
            cell.extraCostLabel.text = "+$\(section2[indexPath.row].sidePrice)"
            
            //Change cell's tint color
            cell.tintColor = GREEN
            
            if section2[indexPath.row].selected {
                cell.accessoryType = .Checkmark
            } else {
                cell.accessoryType = .None
            }
            
            return cell
        } else if indexPath.section == specialInstructionsIndex {
            let cell = tableView.dequeueReusableCellWithIdentifier("specialInstructionsCell", forIndexPath: indexPath) as! AddToOrderSpecialInstructionsTableViewCell
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("priceCell", forIndexPath: indexPath) as! AddToOrderPriceTableViewCell
            
            cell.priceLabel.text = String(format: "$%.2f", totalPrice)
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == sidesIndex {
            if !sideItems[indexPath.row].selected {
                if numberOfSidesSelected < Int(selectedFoodSidesNum) {
                    sideItems[indexPath.row].selected = true
                    numberOfSidesSelected += 1
                }
            } else {
                sideItems[indexPath.row].selected = false
                numberOfSidesSelected -= 1
            }
        } else if indexPath.section == extrasIndex {
            if !section2[indexPath.row].selected {
                section2[indexPath.row].selected = true
            } else {
                section2[indexPath.row].selected = false
            }
        }
        
        if numberOfSidesSelected == Int(selectedFoodSidesNum) {
            // Enable the button and make it opaque
            addToOrderButton.alpha = 1
            addToOrderButton.enabled = true
            
            // Enable the stepper and make it opaque
            stepper.alpha = 1
            stepper.enabled = true
        } else {
            // Disable the button and make it transparent
            addToOrderButton.alpha = 0.5
            addToOrderButton.enabled = false
            
            // Disable the stepper and make it transparent
            stepper.alpha = 0.5
            stepper.enabled = false
        }
        
        // Recalculate price
        calculatePrice()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section != priceIndex {
            return 55
        } else {
            return CGFloat.min
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerCell = tableView.dequeueReusableCellWithIdentifier("headerCell") as! HeaderTableViewCell
        
        // Set header text
        headerCell.titleLabel.text = sectionNames[section]
        
        if section != sidesIndex && section != priceIndex {
            headerCell.pickXLabel.hidden = true
        } else {
            headerCell.pickXLabel.hidden = false
            if section == sidesIndex {
                headerCell.pickXLabel.text = "(Pick " + selectedFoodSidesNum + ")"
            } /*else {
                headerCell.pickXLabel.textColor = GREEN
                headerCell.pickXLabel.text = String(format: "$%.2f", totalPrice)
            }*/
        }
        
        return headerCell
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
     if editingStyle == .Delete {
     // Delete the row from the data source
     tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
     } else if editingStyle == .Insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}