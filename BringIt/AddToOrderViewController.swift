//
//  AddToOrderTableViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/25/16.
//  Copyright © 2016 Campus Enterprises. All rights reserved.
//

import UIKit
import GMStepper

class AddToOrderViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Get USER ID
    let defaults = NSUserDefaults.standardUserDefaults()
    
    // Create struct to organize data
    struct SideItem {
        var sideName: String
        var sidePrice: String
        var sideRequired: String
    }
    
    // Create empty array of Restaurants to be filled in ViewDidLoad
    var sideItems: [SideItem] = []
    
    // DATA
    var sideNames = [String]()
    var sidePrices = [String]()
    var sideRequireds = [String]()
    
    // DATA
    var sectionNames = [String]() //["DESCRIPTION", "SIDES (PICK 2)", "EXTRAS", "SPECIAL INSTRUCTIONS"]
    var section1 = [String]()
    var section2 = [String]()
    var section2Prices = [String]()
    let section3 = "E.g. Easy on the mayo, add bacon"
    
    // MARK: - IBOutlets
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var stepper: GMStepper!
    
    // Data passed from previous View Controller
    var selectedFoodName = ""
    var selectedFoodDescription = ""
    var selectedFoodPrice = ""
    var selectedFoodID = ""
    var selectedFoodSidesNum = ""
    
    // Backend Data
    var sidesIDList = [String]()
    var currentActiveCartOrderID = "NONE"
    var maxCartOrderID: Int = 0
    
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
        
        // Display price in nav bar
        self.navigationItem.rightBarButtonItem?.title = selectedFoodPrice
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: TITLE_FONT,
            NSForegroundColorAttributeName: GREEN], forState: .Normal)
        
        // Set tableView cells to custom height and automatically resize if needed
        myTableView.estimatedRowHeight = 50
        myTableView.rowHeight = UITableViewAutomaticDimension
        
        // Set stepper font
        stepper.labelFont = UIFont(name: "Avenir-Medium", size: 20)!
        stepper.buttonsFont = UIFont(name: "Avenir-Black", size: 20)!
        
        // Set tableView cells to custom height and automatically resize if needed
        myTableView.estimatedRowHeight = 55
        self.myTableView.rowHeight = UITableViewAutomaticDimension
        
        print("Selected Food ID: " + selectedFoodID)
        print("How many sides this food item can have: " + selectedFoodSidesNum)
        sectionNames.append("DESCRIPTION")
        sectionNames.append("SIDES (PICK " + selectedFoodSidesNum + ")")
        sectionNames.append("EXTRAS")
        sectionNames.append("SPECIAL INSTRUCTIONS")
        
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
                                }
                            }
                            
                            NSOperationQueue.mainQueue().addOperationWithBlock {
                                // Loop through DB data and append Restaurant objects into restaurants array
                                for i in 0..<self.sideNames.count {
                                    self.sideItems.append(SideItem(sideName: self.sideNames[i], sidePrice: self.sidePrices[i], sideRequired: self.sideRequireds[i]))
                                }
                                for i in 0..<self.sideItems.count {
                                    // If required and price == 0, Section 1
                                    if (self.sideItems[i].sideRequired == "1" && self.sideItems[i].sidePrice == "0") {
                                        self.section1.append(self.sideItems[i].sideName)
                                        print("S1:" + self.sideItems[i].sideName)
                                    }
                                    // If required and price !=0, Section 2
                                    if (self.sideItems[i].sideRequired == "1" && self.sideItems[i].sidePrice != "0") {
                                        self.section2.append(self.sideItems[i].sideName)
                                        print("S2:" + self.sideItems[i].sideName)
                                        self.section2Prices.append(self.sideItems[i].sidePrice)
                                        print("S2Price:" + self.sideItems[i].sidePrice)
                                    }
                                    // If not required, Section 2
                                    if (self.sideItems[i].sideRequired == "0") {
                                        self.section2.append(self.sideItems[i].sideName)
                                        print("S2:" + self.sideItems[i].sideName)
                                        self.section2Prices.append(self.sideItems[i].sidePrice)
                                        print("S2Price:" + self.sideItems[i].sidePrice)
                                    }
                                }
                                
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
    
    // TO-DO: FINISH THIS METHOD
    @IBAction func addToOrderButtonPressed(sender: UIButton) {
        // FOR CHAD - Write code to save item to database cart
        // loop through all carts with user_id searching for active
        let userID = self.defaults.objectForKey("userID") as AnyObject! as! String
        print(userID)
        
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
                                        print(order_id)
                                        self.currentActiveCartOrderID = order_id
                                    }
                                }
                            }
                            
                            NSOperationQueue.mainQueue().addOperationWithBlock {
                                if (self.currentActiveCartOrderID == "NONE") {
                                    print("This is the old max order_id", self.maxCartOrderID)
                                    self.maxCartOrderID = self.maxCartOrderID + 10;
                                } else {
                                    print("This is the active cart id value", self.currentActiveCartOrderID)
                                }
                                print("This is the current max order_id", self.maxCartOrderID)
                                
                                // Create JSON data and configure the request
                                let params = ["item_id": self.selectedFoodID,
                                    "user_id": userID,
                                    "quantity": "?",
                                    "active": "1",
                                    "instructions": "?",
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
                                let task = session.dataTaskWithRequest(request) {
                                    (let data, let response, let error) in
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

        // 2. if none are active, get the max order_id, then add 10, and save it as the new currentActiveCartOrderID
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func xButtonClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sectionNames.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return section1.count
        } else if section == 2 {
            return section2.count
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("descriptionCell", forIndexPath: indexPath) as! AddToOrderSpecialInstructionsTableViewCell
            
            cell.textLabel?.text = selectedFoodDescription
            
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("addToOrderCell", forIndexPath: indexPath) as! AddToOrderTableViewCell
            
            // ISSUE: If it says pick X, you can still pick as many or as few as you want
            cell.radioButton.multipleSelectionEnabled = true
            cell.radioButton.setTitle(section1[indexPath.row], forState: .Normal)
            cell.extraCostLabel.hidden = true
            
            return cell
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCellWithIdentifier("addToOrderCell", forIndexPath: indexPath) as! AddToOrderTableViewCell
            
            cell.radioButton.multipleSelectionEnabled = true
            cell.radioButton.setTitle(section2[indexPath.row], forState: .Normal)
            cell.extraCostLabel.hidden = false
            cell.extraCostLabel.text = "+\(section2Prices[indexPath.row])"
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("specialInstructionsCell", forIndexPath: indexPath) as! AddToOrderSpecialInstructionsTableViewCell
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionNames[section]
    }
    
    // Set up custom header
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.textLabel!.textColor = UIColor.darkGrayColor()
        header.textLabel?.font = TV_HEADER_FONT
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