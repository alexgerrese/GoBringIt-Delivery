//
//  AddToOrderTableViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/25/16.
//  Copyright © 2016 Campus Enterprises. All rights reserved.
//

import UIKit
import GMStepper
import IQKeyboardManagerSwift
import CoreData

class AddToOrderViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // Passed data
    var passedItem: Item?
    var passedSides: [Side]?
    var sides = [NSManagedObject]()
    var sideNames = [String]()
    var sidePrices = [String]()
    var sideRequireds = [String]()
    var sideGroupings = [String]()
    var sideIDs = [String]()
    var sideIDSelectedArray = [String]()

    // Specific sideItem structure
    struct SideItem {
        var sideName: String
        var sidePrice: String
        var sideRequired: String
        var sideGrouping: String
        var sideID: String
        var selected: Bool
    }
    
    // Create empty array of Restaurants to be filled in ViewDidLoad
    var sectionNames = [String]()
    var sideItems: [SideItem] = []
    var requiredSideTitles = [String]()
    var requiredSides = [[SideItem]]()
    var extras = [SideItem]()
    let section3 = "E.g. Easy on the mayo, add bacon"

    var numberOfSidesRequired = [Int]()
    var numberOfSidesSelected = [Int]()
    var totalPrice = 0.0
    
    // To double check database correctness
    var anySidesRequired = false
    
    // Get indexes of each section (in case some aren't added because there are no rows to show)
    var sidesIndex = -1
    var extrasIndex = -1
    var specialInstructionsIndex = -1
    var priceIndex = -1
    
    // MARK: - IBOutlets
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var stepper: GMStepper!
    @IBOutlet weak var addToOrderButton: UIButton!
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    
    // Data passed from previous View Controller
    var selectedFoodName = ""
    var selectedFoodDescription = ""
    var selectedFoodPrice = 0.0
    var selectedFoodID = ""
    var selectedFoodSidesNum = ""
    
    // Backend Data
    var sidesIDList = [String]()
    var currentActiveCartOrderID = "NONE"
    var currentActiveCartID = "NONE"
    var maxCartOrderID: Int = 0
    var specialInstructions = ""
    
    // Get USER ID
    let defaults = NSUserDefaults.standardUserDefaults()
    
    // Coming from checkoutVC?
    var comingFromCheckoutVC = false
    
    // Doing this and the two lines in ViewDidLoad automatically handles all keyboard and textField problems!
    var returnKeyHandler : IQKeyboardReturnKeyHandler!
    
    // CoreData
    let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
    let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Start activity indicator
        myActivityIndicator.startAnimating()
        self.myActivityIndicator.hidden = false
        
        // Set title
        self.title = selectedFoodName
        
        // Set custom nav bar font
        navigationController!.navigationBar.titleTextAttributes =
            ([NSFontAttributeName: TITLE_FONT,
                NSForegroundColorAttributeName: UIColor.blackColor()])
        
        // Set custom back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        returnKeyHandler = IQKeyboardReturnKeyHandler(controller: self)
        returnKeyHandler.lastTextFieldReturnKeyType = UIReturnKeyType.Done
        
        // Set tableView cells to custom height and automatically resize if needed
        myTableView.estimatedRowHeight = 50
        myTableView.rowHeight = UITableViewAutomaticDimension
        
        // Allow multiple selection in tableView
        self.myTableView.allowsMultipleSelection = true
        
        // Set stepper font
        stepper.labelFont = UIFont(name: "Avenir-Medium", size: 20)!
        stepper.buttonsFont = UIFont(name: "Avenir-Black", size: 20)!
        stepper.addTarget(self, action: #selector(AddToOrderViewController.stepperTapped(_:)), forControlEvents: .ValueChanged)
        
        if comingFromCheckoutVC {
            self.passedSides = self.passedItem!.sides?.allObjects as? [Side]
            stepper.value = Double((self.passedItem?.quantity)!)
            addToOrderButton.setTitle("UPDATE ORDER", forState: .Normal)
        }
        
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
                                    if let grouping = Restaurant["grouping"] {
                                        self.sideGroupings.append(grouping as! String)
                                    } else {
                                        self.sideGroupings.append("")
                                    }
                                }
                            }
                            
                            NSOperationQueue.mainQueue().addOperationWithBlock {
                                // Loop through DB data and append Restaurant objects into restaurants array
                                for i in 0..<self.sideNames.count {
                                    var isSelected = false
                                    if self.passedSides != nil {
                                        for j in 0..<self.passedSides!.count {
                                            if self.sideNames[i] == self.passedSides![j].name {
                                                isSelected = true
                                            }
                                        }
                                    }
                                    // If anything is required, set this to true
                                    if self.sideRequireds[i] == "1"
                                    {
                                        self.anySidesRequired = true
                                    }
                                    
                                    // Append the item
                                    self.sideItems.append(SideItem(sideName: self.sideNames[i], sidePrice: self.sidePrices[i], sideRequired: self.sideRequireds[i], sideGrouping: self.sideGroupings[i], sideID: self.sideIDs[i], selected: isSelected))
                                }
                                
                                
                                // Sort sides and extras into their respective sections
                                for i in 0..<self.sideItems.count {
                                    // If a side grouping exists
                                    if self.sideItems[i].sideGrouping != "" {
                                        // If a side grouping section is already present, add SideItem to that section
                                        if let index = self.requiredSideTitles.indexOf(self.sideItems[i].sideGrouping) {
                                            self.requiredSides[index].append(SideItem(sideName: self.sideItems[i].sideName, sidePrice: self.sideItems[i].sidePrice, sideRequired: "0", sideGrouping: self.sideItems[i].sideGrouping, sideID: self.sideIDs[i], selected: self.sideItems[i].selected))
                                        } else {
                                            // Create section
                                            self.requiredSideTitles.append(self.sideItems[i].sideGrouping)
                                            self.numberOfSidesRequired.append(1)
                                            self.requiredSides.append([SideItem(sideName: self.sideItems[i].sideName, sidePrice: self.sideItems[i].sidePrice, sideRequired: "0", sideGrouping: self.sideItems[i].sideGrouping, sideID: self.sideIDs[i], selected: self.sideItems[i].selected)])
                                        }
                                    } else {
                                        // If required, add to general sides
                                        if (self.sideItems[i].sideRequired == "1" && (self.sideItems[i].sidePrice == "0" || self.sideItems[i].sidePrice == "0.00")) {
                                            if let index = self.requiredSideTitles.indexOf("Sides") {
                                                self.requiredSides[index].append(SideItem(sideName: self.sideItems[i].sideName, sidePrice: self.sideItems[i].sidePrice, sideRequired: "0", sideGrouping: "Sides", sideID: self.sideIDs[i], selected: self.sideItems[i].selected))
                                            } else {
                                                self.requiredSideTitles.append("Sides")
                                                self.numberOfSidesRequired.append(-1) // I put a negative so I can quickly find this index and recalculate the correct amount (general required sides - # of groupings)
                                                self.requiredSides.append([SideItem(sideName: self.sideItems[i].sideName, sidePrice: self.sideItems[i].sidePrice, sideRequired: "0", sideGrouping: "Sides", sideID: self.sideIDs[i], selected: self.sideItems[i].selected)])
                                            }
                                            
                                            print("S1:" + self.sideItems[i].sideName + self.sideItems[i].sideGrouping)
                                        }
                                        // If not required, add to extras
                                        if (self.sideItems[i].sideRequired == "0" || (self.sideItems[i].sidePrice != "0" && self.sideItems[i].sidePrice != "0.00")) {
                                            self.extras.append(SideItem(sideName: self.sideItems[i].sideName, sidePrice: self.sideItems[i].sidePrice, sideRequired: "0", sideGrouping: "Extras", sideID: self.sideIDs[i], selected: self.sideItems[i].selected))
                                            print("S2:" + self.sideItems[i].sideName + self.sideItems[i].sideGrouping)
                                        }
                                    }
                                }
                                
                                // Populate sectionNames array
                                print("Selected Food ID: " + self.selectedFoodID)
                                print("How many sides this food item can have: " + self.selectedFoodSidesNum)
                                
                                // Populate sectionNames array
                                self.sectionNames.append("Description")
                                for i in self.requiredSideTitles {
                                    self.sectionNames.append(i)
                                }
                                if self.extras.count > 0 {
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
                                
                                self.calculatePrice()
                                self.calculateNumOfSidesSelected()
                                self.checkRequiredSides()
                                
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
        
        // Set tableView cells to custom height and automatically resize if needed
        myTableView.estimatedRowHeight = 55
        self.myTableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addToOrderButtonPressed(sender: UIButton) {
        
        // Check if there is an existing active cart from this restaurant
        let fetchRequest = NSFetchRequest(entityName: "Order")
        let firstPredicate = NSPredicate(format: "isActive == %@", true)
        let secondPredicate = NSPredicate(format: "restaurant == %@", selectedRestaurantName)
        let predicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [firstPredicate, secondPredicate])
        fetchRequest.predicate = predicate
        
        var activeCart = [Order]()
        
        do {
            if let fetchResults = try managedContext.executeFetchRequest(fetchRequest) as? [Order] {
                activeCart = fetchResults
                print("THERE IS AN EXISTING CART")
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        if comingFromCheckoutVC {
            let items = activeCart[0].items?.allObjects as! [Item]
            
            for i in 0..<items.count {
                if items[i].id == passedItem?.id {
                    
                    // UPDATE ITEM
                    items[i].price = selectedFoodPrice
                    items[i].quantity = Int(stepper.value)
                    items[i].selectedFoodSidesNum = Int(selectedFoodSidesNum)
                    items[i].dbDescription = selectedFoodDescription
                    
                    // Retrieve special instructions if available
                    let indexPath = NSIndexPath(forRow: 0, inSection: specialInstructionsIndex)
                    let selectedCell = myTableView.cellForRowAtIndexPath(indexPath) as! AddToOrderSpecialInstructionsTableViewCell!
                    if selectedCell != nil && selectedCell.specialInstructionsText.text != nil {
                        specialInstructions = selectedCell.specialInstructionsText.text!
                    }
                    items[i].specialInstructions = specialInstructions
                    
                    // SIDES
                    
                    for i in items[i].sides?.allObjects as! [Side] {
                        i.item = nil
                    }

                    for r in requiredSides {
                        for s in r {
                            if s.selected {
                                
                                let sideEntity =  NSEntityDescription.entityForName("Side", inManagedObjectContext:managedContext)
                                let side = NSManagedObject(entity: sideEntity!, insertIntoManagedObjectContext: managedContext) as! Side
                                
                                side.name = s.sideName
                                side.id = s.sideID
                                side.price = Double(s.sidePrice)
                                side.isRequired = true
                                
                                side.item = items[i]
                                sides.append(side)
                            }
                        }
                    }
                    
                    for s in extras {
                        if s.selected {
                            
                            let sideEntity =  NSEntityDescription.entityForName("Side", inManagedObjectContext:managedContext)
                            let side = NSManagedObject(entity: sideEntity!, insertIntoManagedObjectContext: managedContext) as! Side
                            
                            side.name = s.sideName
                            side.id = s.sideID
                            side.price = Double(s.sidePrice)
                            side.isRequired = false
                            
                            side.item = items[i]
                            sides.append(side)
                        }
                    }
                    
                }
            }
            self.dismissViewControllerAnimated(true, completion: nil)
            
        } else {
            
            // If cart is empty, then create new active cart with this restaurant
            if activeCart.isEmpty {
                
                let order = NSEntityDescription.insertNewObjectForEntityForName("Order", inManagedObjectContext: managedContext) as! Order
                
                order.isActive = true
                order.restaurant = selectedRestaurantName
                print("Selectedrestaurant name: ", selectedRestaurantName)
                
                // Make DB Call to category_items and save delivery_fee if (selectedRestaurantName == name)
                // Open Connection to PHP Service
                let requestURL: NSURL = NSURL(string: "http://www.gobring.it/CHADrestaurantImage.php")!
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
                                        let name = Restaurant["name"] as! String
                                        if (name == selectedRestaurantName) {
                                            let deliveryFee = Restaurant["delivery_fee"] as! String
                                            let serviceID = Restaurant["id"] as! String
                                            order.deliveryFee = Double(deliveryFee)
                                            order.restaurantID = serviceID
                                            print("Order FEE: ", order.deliveryFee)
                                        }
                                        
                                    }
                                    
                                    NSOperationQueue.mainQueue().addOperationWithBlock {
                                        activeCart.append(order)
                                        
                                        // ITEM
                                        
                                        let itemEntity =  NSEntityDescription.entityForName("Item", inManagedObjectContext:self.managedContext)
                                        let item = NSManagedObject(entity: itemEntity!, insertIntoManagedObjectContext: self.managedContext) as! Item
                                        
                                        item.name = self.selectedFoodName
                                        item.id = self.selectedFoodID
                                        item.price = self.selectedFoodPrice
                                        item.quantity = Int(self.stepper.value)
                                        item.selectedFoodSidesNum = Int(self.selectedFoodSidesNum)
                                        item.dbDescription = self.selectedFoodDescription
                                        
                                        // Retrieve special instructions if available
                                        let indexPath = NSIndexPath(forRow: 0, inSection: self.specialInstructionsIndex)
                                        let selectedCell = self.myTableView.cellForRowAtIndexPath(indexPath) as! AddToOrderSpecialInstructionsTableViewCell!
                                        if selectedCell != nil && selectedCell.specialInstructionsText.text != nil {
                                            self.specialInstructions = selectedCell.specialInstructionsText.text!
                                        }
                                        item.specialInstructions = self.specialInstructions
                                        item.order = activeCart[0]
                                        
                                        // SIDES
                                        
                                        for r in self.requiredSides {
                                            for i in r {
                                                if i.selected {
                                                    
                                                    let sideEntity =  NSEntityDescription.entityForName("Side", inManagedObjectContext:self.managedContext)
                                                    let side = NSManagedObject(entity: sideEntity!, insertIntoManagedObjectContext: self.managedContext) as! Side
                                                    
                                                    side.name = i.sideName
                                                    side.id = i.sideID
                                                    side.price = Double(i.sidePrice)
                                                    side.isRequired = true
                                                    
                                                    side.item = item
                                                    self.sides.append(side)
                                                }
                                            }
                                        }

                                        for i in self.extras {
                                            if i.selected {
                                                
                                                let sideEntity =  NSEntityDescription.entityForName("Side", inManagedObjectContext:self.managedContext)
                                                let side = NSManagedObject(entity: sideEntity!, insertIntoManagedObjectContext: self.managedContext) as! Side
                                                
                                                side.name = i.sideName
                                                side.id = i.sideID
                                                side.price = Double(i.sidePrice)
                                                side.isRequired = false
                                                
                                                side.item = item
                                                self.sides.append(side)
                                            }
                                        }
                                        
                                        do {
                                            try self.managedContext.save()
                                            self.dismissViewControllerAnimated(true, completion: nil)
                                        } catch {
                                            fatalError("Failure to save context: \(error)")
                                        }
                                        
                                    }
                                }
                            }
                        } catch let error as NSError {
                            print(error.localizedDescription)
                        }
                    } else if let error = error {
                        print(error.localizedDescription)
                    }
                }
                
                task.resume()
            } else {
                
                // ITEM
                
                let itemEntity =  NSEntityDescription.entityForName("Item", inManagedObjectContext:managedContext)
                let item = NSManagedObject(entity: itemEntity!, insertIntoManagedObjectContext: managedContext) as! Item
                
                item.name = selectedFoodName
                item.id = selectedFoodID
                item.price = selectedFoodPrice
                item.quantity = Int(stepper.value)
                item.selectedFoodSidesNum = Int(selectedFoodSidesNum)
                item.dbDescription = selectedFoodDescription
                
                // Retrieve special instructions if available
                let indexPath = NSIndexPath(forRow: 0, inSection: specialInstructionsIndex)
                let selectedCell = myTableView.cellForRowAtIndexPath(indexPath) as! AddToOrderSpecialInstructionsTableViewCell!
                if selectedCell != nil && selectedCell.specialInstructionsText.text != nil {
                    specialInstructions = selectedCell.specialInstructionsText.text!
                }
                item.specialInstructions = specialInstructions
                item.order = activeCart[0]
                
                // SIDES
                
                for r in requiredSides {
                    for i in r {
                        if i.selected {
                            
                            let sideEntity =  NSEntityDescription.entityForName("Side", inManagedObjectContext:managedContext)
                            let side = NSManagedObject(entity: sideEntity!, insertIntoManagedObjectContext: managedContext) as! Side
                            
                            side.name = i.sideName
                            side.id = i.sideID
                            side.price = Double(i.sidePrice)
                            side.isRequired = true
                            
                            side.item = item
                            sides.append(side)
                        }
                    }
                }
                
                for i in extras {
                    if i.selected {
                        
                        let sideEntity =  NSEntityDescription.entityForName("Side", inManagedObjectContext:managedContext)
                        let side = NSManagedObject(entity: sideEntity!, insertIntoManagedObjectContext: managedContext) as! Side
                        
                        side.name = i.sideName
                        side.id = i.sideID
                        side.price = Double(i.sidePrice)
                        side.isRequired = false
                        
                        side.item = item
                        sides.append(side)
                    }
                }
                
                // SAVE
                do {
                    try managedContext.save()
                    self.dismissViewControllerAnimated(true, completion: nil)
                } catch {
                    fatalError("Failure to save context: \(error)")
                }
                
                print("SAVED")
                
            }
        }
    }
    
    @IBAction func xButtonClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func calculatePrice() {
        print(selectedFoodPrice)
        totalPrice = selectedFoodPrice
        for side in extras {
            if side.selected {
                totalPrice += Double(side.sidePrice)!
            }
        }
        totalPrice = totalPrice * stepper.value
        
        myTableView.reloadData()
    }
    
    func calculateNumOfSidesSelected() {
        
        if numberOfSidesSelected.count == 0 {
            // Initialize all values to 0
            for _ in requiredSides {
                numberOfSidesSelected.append(0)
            }
        } else {
            // Reset value
            for i in 0..<requiredSides.count {
                numberOfSidesSelected[i] = 0
            }
        }
        
        // Recalculate values
        for section in 0..<requiredSides.count {
            for index in 0..<requiredSides[section].count {
                if requiredSides[section][index].selected {
                    numberOfSidesSelected[section] += 1
                }
            }
        }
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
        } else if section == extrasIndex { // Extras
            return extras.count
        } else if section == specialInstructionsIndex { // Special Instructions
            return 1
        } else if section == priceIndex { // Price
            return 1
        } else {
            print(section)
            return requiredSides[section - 1].count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("descriptionCell", forIndexPath: indexPath) as! AddToOrderSpecialInstructionsTableViewCell
            
            if selectedFoodDescription == "" || selectedFoodDescription == "No Description" {
                cell.textLabel?.text = "No description, but we promise it's good."
            } else {
                cell.textLabel?.text = selectedFoodDescription
            }
            
            return cell
        } else if indexPath.section == extrasIndex {
            let cell = tableView.dequeueReusableCellWithIdentifier("addToOrderCell", forIndexPath: indexPath) as! AddToOrderTableViewCell
            
            // Set cell properties
            cell.selectionStyle = .None
            cell.sideLabel.text = extras[indexPath.row].sideName
            cell.extraCostLabel.hidden = false
            let price = Double(extras[indexPath.row].sidePrice)
            cell.extraCostLabel.text = String(format: "+$%.2f", price!)

            
            //Change cell's tint color
            cell.tintColor = GREEN
            
            if extras[indexPath.row].selected {
                cell.accessoryType = .Checkmark
            } else {
                cell.accessoryType = .None
            }
            
            return cell
        } else if indexPath.section == specialInstructionsIndex {
            let cell = tableView.dequeueReusableCellWithIdentifier("specialInstructionsCell", forIndexPath: indexPath) as! AddToOrderSpecialInstructionsTableViewCell
            
            // Preload if coming from checkoutVC
            if comingFromCheckoutVC {
                cell.specialInstructionsText.text = passedItem?.specialInstructions
            }
            
            return cell
        } else if indexPath.section == priceIndex {
            let cell = tableView.dequeueReusableCellWithIdentifier("priceCell", forIndexPath: indexPath) as! AddToOrderPriceTableViewCell
            
            cell.priceLabel.text = String(format: "$%.2f", totalPrice)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("addToOrderCell", forIndexPath: indexPath) as! AddToOrderTableViewCell
            
            // Set cell properties
            cell.selectionStyle = .None
            cell.sideLabel.text = requiredSides[indexPath.section - 1][indexPath.row].sideName
            cell.extraCostLabel.hidden = true
            
            //Change cell's tint color
            cell.tintColor = GREEN
            
            if requiredSides[indexPath.section - 1][indexPath.row].selected {
                cell.accessoryType = .Checkmark
            } else {
                cell.accessoryType = .None
            }
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        calculateNumOfSidesSelected()
        
        if indexPath.section == extrasIndex {
            if !extras[indexPath.row].selected {
                extras[indexPath.row].selected = true
            } else {
                extras[indexPath.row].selected = false
            }
        } else if indexPath.section == priceIndex || indexPath.section == specialInstructionsIndex || indexPath.section == extrasIndex || indexPath.section == 0 {
        } else {
            if !requiredSides[indexPath.section - 1][indexPath.row].selected {
                if requiredSides[indexPath.section - 1][indexPath.row].sideGrouping != "Sides" {
                    if numberOfSidesSelected[indexPath.section - 1] < 1 {
                        requiredSides[indexPath.section - 1][indexPath.row].selected = true
                    }
                } else {
                    print(indexPath.section)
                    print(numberOfSidesSelected.count)
                    print((Int(selectedFoodSidesNum)! - requiredSideTitles.count + 1))
                    if numberOfSidesSelected[indexPath.section - 1] < (Int(selectedFoodSidesNum)! - requiredSideTitles.count + 1) {
                        requiredSides[indexPath.section - 1][indexPath.row].selected = true
                    }
                }
            } else {
                requiredSides[indexPath.section - 1][indexPath.row].selected = false
            }
        }
        
        // Recalculate price and numOfSidesSelected
        calculatePrice()
        calculateNumOfSidesSelected()
        checkRequiredSides()
    }
    
    func checkRequiredSides() {
        if anySidesRequired {
            
            // Calculate number of sides selected
            var totalSidesSelected = 0
            for i in numberOfSidesSelected {
                totalSidesSelected += i
            }
            
            // Check if all required sides have been selected
            if totalSidesSelected == Int(selectedFoodSidesNum) {
                enableAddToOrder()
            } else {
                disableAddToOrder()
            }
        } else {
            enableAddToOrder()
        }
    }
    
    func enableAddToOrder() {
        // Enable the button and make it opaque
        addToOrderButton.alpha = 1
        addToOrderButton.enabled = true
        
        // Enable the stepper and make it opaque
        stepper.alpha = 1
        stepper.enabled = true
    }
    
    func disableAddToOrder() {
        // Disable the button and make it transparent
        addToOrderButton.alpha = 0.5
        addToOrderButton.enabled = false
        
        // Disable the stepper and make it transparent
        stepper.alpha = 0.5
        stepper.enabled = false
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
        
        if section == priceIndex || section == specialInstructionsIndex || section == extrasIndex || section == 0 {
            headerCell.pickXLabel.hidden = true
        } else {
            headerCell.pickXLabel.hidden = false
            if sectionNames[section] != "Sides" {
                headerCell.pickXLabel.text = "(Pick 1)"
            } else {
                headerCell.pickXLabel.text = "(Pick \(Int(selectedFoodSidesNum)! - requiredSideTitles.count + 1))"
            }
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