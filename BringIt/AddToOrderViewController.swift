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
    //var maxCartOrderID: Int = 0
    var specialInstructions = ""
    
    // Get USER ID
    let defaults = UserDefaults.standard
    
    // Coming from checkoutVC?
    var comingFromCheckoutVC = false
    
    // Doing this and the two lines in ViewDidLoad automatically handles all keyboard and textField problems!
    var returnKeyHandler : IQKeyboardReturnKeyHandler!
    
    // CoreData
    let appDelegate =
        UIApplication.shared.delegate as! AppDelegate
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Start activity indicator
        myActivityIndicator.startAnimating()
        self.myActivityIndicator.isHidden = false
        
        // Set title
        self.title = selectedFoodName
        
        // Set custom nav bar font
        navigationController!.navigationBar.titleTextAttributes =
            ([NSFontAttributeName: TITLE_FONT,
                NSForegroundColorAttributeName: UIColor.black])
        
        // Set custom back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
        returnKeyHandler = IQKeyboardReturnKeyHandler(controller: self)
        returnKeyHandler.lastTextFieldReturnKeyType = UIReturnKeyType.done
        
        // Set tableView cells to custom height and automatically resize if needed
        myTableView.estimatedRowHeight = 50
        myTableView.rowHeight = UITableViewAutomaticDimension
        
        // Allow multiple selection in tableView
        self.myTableView.allowsMultipleSelection = true
        
        // Set stepper font
        stepper.labelFont = UIFont(name: "Avenir-Medium", size: 20)!
        stepper.buttonsFont = UIFont(name: "Avenir-Black", size: 20)!
        stepper.addTarget(self, action: #selector(AddToOrderViewController.stepperTapped(_:)), for: .valueChanged)
        
        if comingFromCheckoutVC {
            self.passedSides = self.passedItem!.sides?.allObjects as? [Side]
            stepper.value = Double((self.passedItem?.quantity)!)
            addToOrderButton.setTitle("UPDATE ORDER", for: UIControlState())
        }
        
        // Open Connection to PHP Service to menuSides
        let requestURL1: URL = URL(string: "http://www.gobringit.com/CHADmenuSides.php")!
        let urlRequest1 = URLRequest(url: requestURL1)
        let session1 = URLSession.shared
        let task1 = session1.dataTask(with: urlRequest1, completionHandler: { (data, response, error) -> Void in
            if let data = data {
                do {
                    let httpResponse = response as! HTTPURLResponse
                    let statusCode = httpResponse.statusCode
                    
                    // Check HTTP Response
                    if (statusCode == 200) {
                        
                        do{
                            // Parse JSON
                            let json = try JSONSerialization.jsonObject(with: data, options:.allowFragments)
                            
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
                            
                            OperationQueue.main.addOperation {
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
                                        if let index = self.requiredSideTitles.index(of: self.sideItems[i].sideGrouping) {
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
                                            if let index = self.requiredSideTitles.index(of: "Sides") {
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
                                
                                if let sIndex = self.sectionNames.index(of: "Sides") {
                                    self.sidesIndex = sIndex
                                }
                                if let eIndex = self.sectionNames.index(of: "Extras") {
                                    self.extrasIndex = eIndex
                                }
                                self.specialInstructionsIndex = self.sectionNames.index(of: "Special Instructions")!
                                self.priceIndex = self.sectionNames.index(of: "Price")!
                                
                                self.calculatePrice()
                                self.calculateNumOfSidesSelected()
                                self.checkRequiredSides()
                                
                                // Stop activity indicator
                                self.myActivityIndicator.stopAnimating()
                                self.myActivityIndicator.isHidden = true
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
        
        // Open Connection to PHP Service
        let requestURL: URL = URL(string: "http://www.gobringit.com/CHADmenuSidesItemLink.php")!
        let urlRequest = URLRequest(url: requestURL)
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) -> Void in
            if let data = data {
                do {
                    let httpResponse = response as! HTTPURLResponse
                    let statusCode = httpResponse.statusCode
                    
                    // Check HTTP Response
                    if (statusCode == 200) {
                        
                        do{
                            // Parse JSON
                            let json = try JSONSerialization.jsonObject(with: data, options:.allowFragments)
                            
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
                            OperationQueue.main.addOperation {
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
        }) 
        
        task.resume()
        
        // Set tableView cells to custom height and automatically resize if needed
        myTableView.estimatedRowHeight = 55
        self.myTableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addToOrderButtonPressed(_ sender: UIButton) {
        
        // Check if there is an existing active cart from this restaurant
        let fetchRequest = NSFetchRequest<Order>(entityName: "Order")
        let firstPredicate = NSPredicate(format: "isActive == %@", true as CVarArg)
        let secondPredicate = NSPredicate(format: "restaurant == %@", selectedRestaurantName)
        let predicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [firstPredicate, secondPredicate])
        fetchRequest.predicate = predicate
        
        var activeCart = [Order]()
        
        do {
            if let fetchResults = try managedContext.fetch(fetchRequest) as? [Order] {
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
                    items[i].price = selectedFoodPrice as NSNumber?
                    items[i].quantity = Int(stepper.value) as NSNumber?
                    items[i].selectedFoodSidesNum = Int(selectedFoodSidesNum) as NSNumber?
                    items[i].dbDescription = selectedFoodDescription
                    
                    // Retrieve special instructions if available
                    let indexPath = IndexPath(row: 0, section: specialInstructionsIndex)
                    let selectedCell = myTableView.cellForRow(at: indexPath) as! AddToOrderSpecialInstructionsTableViewCell!
                    if selectedCell != nil && selectedCell?.specialInstructionsText.text != nil {
                        specialInstructions = (selectedCell?.specialInstructionsText.text!)!
                    }
                    items[i].specialInstructions = specialInstructions
                    
                    // SIDES
                    
                    for i in items[i].sides?.allObjects as! [Side] {
                        i.item = nil
                    }

                    for r in requiredSides {
                        for s in r {
                            if s.selected {
                                
                                let sideEntity =  NSEntityDescription.entity(forEntityName: "Side", in:managedContext)
                                let side = NSManagedObject(entity: sideEntity!, insertInto: managedContext) as! Side
                                
                                side.name = s.sideName
                                side.id = s.sideID
                                side.price = Double(s.sidePrice) as NSNumber?
                                side.isRequired = true
                                
                                side.item = items[i]
                                sides.append(side)
                            }
                        }
                    }
                    
                    for s in extras {
                        if s.selected {
                            
                            let sideEntity =  NSEntityDescription.entity(forEntityName: "Side", in:managedContext)
                            let side = NSManagedObject(entity: sideEntity!, insertInto: managedContext) as! Side
                            
                            side.name = s.sideName
                            side.id = s.sideID
                            side.price = Double(s.sidePrice) as NSNumber?
                            side.isRequired = false
                            
                            side.item = items[i]
                            sides.append(side)
                        }
                    }
                    
                }
            }
            self.dismiss(animated: true, completion: nil)
            
        } else {
            
            // If cart is empty, then create new active cart with this restaurant
            if activeCart.isEmpty {
                
                let order = NSEntityDescription.insertNewObject(forEntityName: "Order", into: managedContext) as! Order
                
                order.isActive = true
                order.restaurant = selectedRestaurantName
                print("Selectedrestaurant name: ", selectedRestaurantName)
                
                // Make DB Call to category_items and save delivery_fee if (selectedRestaurantName == name)
                // Open Connection to PHP Service
                let requestURL: URL = URL(string: "http://www.gobringit.com/CHADrestaurantImage.php")!
                let urlRequest = URLRequest(url: requestURL)
                let session = URLSession.shared
                let task = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) -> Void in
                    if let data = data {
                        do {
                            let httpResponse = response as! HTTPURLResponse
                            let statusCode = httpResponse.statusCode
                            
                            // Check HTTP Response
                            if (statusCode == 200) {
                                
                                do{
                                    // Parse JSON
                                    let json = try JSONSerialization.jsonObject(with: data, options:.allowFragments)
                                    
                                    for Restaurant in json as! [Dictionary<String, AnyObject>] {
                                        let name = Restaurant["name"] as! String
                                        if (name == selectedRestaurantName) {
                                            let deliveryFee = Restaurant["delivery_fee"] as! String
                                            let serviceID = Restaurant["id"] as! String
                                            order.deliveryFee = Double(deliveryFee) as NSNumber?
                                            order.restaurantID = serviceID
                                            print("Order FEE: ", order.deliveryFee)
                                        }
                                        
                                    }
                                    
                                    OperationQueue.main.addOperation {
                                        activeCart.append(order)
                                        
                                        // ITEM
                                        
                                        let itemEntity =  NSEntityDescription.entity(forEntityName: "Item", in:self.managedContext)
                                        let item = NSManagedObject(entity: itemEntity!, insertInto: self.managedContext) as! Item
                                        
                                        item.name = self.selectedFoodName
                                        item.id = self.selectedFoodID
                                        item.price = self.selectedFoodPrice as NSNumber?
                                        item.quantity = Int(self.stepper.value) as NSNumber?
                                        item.selectedFoodSidesNum = Int(self.selectedFoodSidesNum) as NSNumber?
                                        item.dbDescription = self.selectedFoodDescription
                                        
                                        // Retrieve special instructions if available
                                        let indexPath = IndexPath(row: 0, section: self.specialInstructionsIndex)
                                        let selectedCell = self.myTableView.cellForRow(at: indexPath) as! AddToOrderSpecialInstructionsTableViewCell!
                                        if selectedCell != nil && selectedCell?.specialInstructionsText.text != nil {
                                            self.specialInstructions = (selectedCell?.specialInstructionsText.text!)!
                                        }
                                        item.specialInstructions = self.specialInstructions
                                        item.order = activeCart[0]
                                        
                                        // SIDES
                                        
                                        for r in self.requiredSides {
                                            for i in r {
                                                if i.selected {
                                                    
                                                    let sideEntity =  NSEntityDescription.entity(forEntityName: "Side", in:self.managedContext)
                                                    let side = NSManagedObject(entity: sideEntity!, insertInto: self.managedContext) as! Side
                                                    
                                                    side.name = i.sideName
                                                    side.id = i.sideID
                                                    side.price = Double(i.sidePrice) as NSNumber?
                                                    side.isRequired = true
                                                    
                                                    side.item = item
                                                    self.sides.append(side)
                                                }
                                            }
                                        }

                                        for i in self.extras {
                                            if i.selected {
                                                
                                                let sideEntity =  NSEntityDescription.entity(forEntityName: "Side", in:self.managedContext)
                                                let side = NSManagedObject(entity: sideEntity!, insertInto: self.managedContext) as! Side
                                                
                                                side.name = i.sideName
                                                side.id = i.sideID
                                                side.price = Double(i.sidePrice) as NSNumber?
                                                side.isRequired = false
                                                
                                                side.item = item
                                                self.sides.append(side)
                                            }
                                        }
                                        
                                        do {
                                            try self.managedContext.save()
                                            self.dismiss(animated: true, completion: nil)
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
                }) 
                
                task.resume()
            } else {
                
                // ITEM
                
                let itemEntity =  NSEntityDescription.entity(forEntityName: "Item", in:managedContext)
                let item = NSManagedObject(entity: itemEntity!, insertInto: managedContext) as! Item
                
                item.name = selectedFoodName
                item.id = selectedFoodID
                item.price = selectedFoodPrice as NSNumber?
                item.quantity = Int(stepper.value) as NSNumber?
                item.selectedFoodSidesNum = Int(selectedFoodSidesNum) as NSNumber?
                item.dbDescription = selectedFoodDescription
                
                // Retrieve special instructions if available
                let indexPath = IndexPath(row: 0, section: specialInstructionsIndex)
                let selectedCell = myTableView.cellForRow(at: indexPath) as! AddToOrderSpecialInstructionsTableViewCell!
                if selectedCell != nil && selectedCell?.specialInstructionsText.text != nil {
                    specialInstructions = (selectedCell?.specialInstructionsText.text!)!
                }
                item.specialInstructions = specialInstructions
                item.order = activeCart[0]
                
                // SIDES
                
                for r in requiredSides {
                    for i in r {
                        if i.selected {
                            
                            let sideEntity =  NSEntityDescription.entity(forEntityName: "Side", in:managedContext)
                            let side = NSManagedObject(entity: sideEntity!, insertInto: managedContext) as! Side
                            
                            side.name = i.sideName
                            side.id = i.sideID
                            side.price = Double(i.sidePrice) as NSNumber?
                            side.isRequired = true
                            
                            side.item = item
                            sides.append(side)
                        }
                    }
                }
                
                for i in extras {
                    if i.selected {
                        
                        let sideEntity =  NSEntityDescription.entity(forEntityName: "Side", in:managedContext)
                        let side = NSManagedObject(entity: sideEntity!, insertInto: managedContext) as! Side
                        
                        side.name = i.sideName
                        side.id = i.sideID
                        side.price = Double(i.sidePrice) as NSNumber?
                        side.isRequired = false
                        
                        side.item = item
                        sides.append(side)
                    }
                }
                
                // SAVE
                do {
                    try managedContext.save()
                    self.dismiss(animated: true, completion: nil)
                } catch {
                    fatalError("Failure to save context: \(error)")
                }
                
                print("SAVED")
                
            }
        }
    }
    
    @IBAction func xButtonClicked(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
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
    
    func stepperTapped(_ sender: GMStepper) {
        // Recalculate price
        calculatePrice()
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionNames.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "descriptionCell", for: indexPath) as! AddToOrderSpecialInstructionsTableViewCell
            
            if selectedFoodDescription == "" || selectedFoodDescription == "No Description" {
                cell.textLabel?.text = "No description, but we promise it's good."
            } else {
                cell.textLabel?.text = selectedFoodDescription
            }
            
            return cell
        } else if (indexPath as NSIndexPath).section == extrasIndex {
            let cell = tableView.dequeueReusableCell(withIdentifier: "addToOrderCell", for: indexPath) as! AddToOrderTableViewCell
            
            // Set cell properties
            cell.selectionStyle = .none
            cell.sideLabel.text = extras[(indexPath as NSIndexPath).row].sideName
            cell.extraCostLabel.isHidden = false
            let price = Double(extras[(indexPath as NSIndexPath).row].sidePrice)
            cell.extraCostLabel.text = String(format: "+$%.2f", price!)

            
            //Change cell's tint color
            cell.tintColor = GREEN
            
            if extras[(indexPath as NSIndexPath).row].selected {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            
            return cell
        } else if (indexPath as NSIndexPath).section == specialInstructionsIndex {
            let cell = tableView.dequeueReusableCell(withIdentifier: "specialInstructionsCell", for: indexPath) as! AddToOrderSpecialInstructionsTableViewCell
            
            // Preload if coming from checkoutVC
            if comingFromCheckoutVC {
                cell.specialInstructionsText.text = passedItem?.specialInstructions
            }
            
            return cell
        } else if (indexPath as NSIndexPath).section == priceIndex {
            let cell = tableView.dequeueReusableCell(withIdentifier: "priceCell", for: indexPath) as! AddToOrderPriceTableViewCell
            
            cell.priceLabel.text = String(format: "$%.2f", totalPrice)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "addToOrderCell", for: indexPath) as! AddToOrderTableViewCell
            
            // Set cell properties
            cell.selectionStyle = .none
            cell.sideLabel.text = requiredSides[(indexPath as NSIndexPath).section - 1][(indexPath as NSIndexPath).row].sideName
            cell.extraCostLabel.isHidden = true
            
            //Change cell's tint color
            cell.tintColor = GREEN
            
            if requiredSides[(indexPath as NSIndexPath).section - 1][(indexPath as NSIndexPath).row].selected {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        calculateNumOfSidesSelected()
        
        if (indexPath as NSIndexPath).section == extrasIndex {
            if !extras[(indexPath as NSIndexPath).row].selected {
                extras[(indexPath as NSIndexPath).row].selected = true
            } else {
                extras[(indexPath as NSIndexPath).row].selected = false
            }
        } else if (indexPath as NSIndexPath).section == priceIndex || (indexPath as NSIndexPath).section == specialInstructionsIndex || (indexPath as NSIndexPath).section == extrasIndex || (indexPath as NSIndexPath).section == 0 {
        } else {
            if !requiredSides[(indexPath as NSIndexPath).section - 1][(indexPath as NSIndexPath).row].selected {
                if requiredSides[(indexPath as NSIndexPath).section - 1][(indexPath as NSIndexPath).row].sideGrouping != "Sides" {
                    if numberOfSidesSelected[(indexPath as NSIndexPath).section - 1] < 1 {
                        requiredSides[(indexPath as NSIndexPath).section - 1][(indexPath as NSIndexPath).row].selected = true
                    }
                } else {
                    print((indexPath as NSIndexPath).section)
                    print(numberOfSidesSelected.count)
                    print((Int(selectedFoodSidesNum)! - requiredSideTitles.count + 1))
                    if numberOfSidesSelected[(indexPath as NSIndexPath).section - 1] < (Int(selectedFoodSidesNum)! - requiredSideTitles.count + 1) {
                        requiredSides[(indexPath as NSIndexPath).section - 1][(indexPath as NSIndexPath).row].selected = true
                    }
                }
            } else {
                requiredSides[(indexPath as NSIndexPath).section - 1][(indexPath as NSIndexPath).row].selected = false
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
        addToOrderButton.isEnabled = true
        
        // Enable the stepper and make it opaque
        stepper.alpha = 1
        stepper.isEnabled = true
    }
    
    func disableAddToOrder() {
        // Disable the button and make it transparent
        addToOrderButton.alpha = 0.5
        addToOrderButton.isEnabled = false
        
        // Disable the stepper and make it transparent
        stepper.alpha = 0.5
        stepper.isEnabled = false
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section != priceIndex {
            return 55
        } else {
            return CGFloat.leastNormalMagnitude
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as! HeaderTableViewCell
        
        // Set header text
        headerCell.titleLabel.text = sectionNames[section]
        
        if section == priceIndex || section == specialInstructionsIndex || section == extrasIndex || section == 0 {
            headerCell.pickXLabel.isHidden = true
        } else {
            headerCell.pickXLabel.isHidden = false
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
