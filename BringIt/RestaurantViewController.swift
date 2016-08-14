//
//  RestaurantViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 8/9/16.
//  Copyright © 2016 Campus Enterprises. All rights reserved.
//

import UIKit
import CoreData

class RestaurantViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - IBOutlets
    
    // Regular Outlets
    @IBOutlet weak var restaurantBackgroundImage: UIImageView!
    @IBOutlet weak var cuisineTypeLabel: UILabel!
    @IBOutlet weak var restaurantHoursLabel: UILabel!
    @IBOutlet weak var isOpenIndicator: UIImageView!
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var cartButton: UIButton!
    @IBOutlet weak var myScrollView: UIScrollView!
    @IBOutlet weak var selectedCategoryNameLabel: UILabel!
    @IBOutlet weak var cartView: UIView!
    @IBOutlet weak var myCategoriesActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var myMenuItemsActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var totalPriceLabel: UILabel!
    
    // TableView Outlets
    @IBOutlet weak var categoriesTableView: UITableView!
    @IBOutlet weak var menuItemsTableView: UITableView!
    
    // Layout Constraint Outlets
    // Height
    @IBOutlet weak var menuItemsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var categoriesViewHeight: NSLayoutConstraint!
    // Width
    @IBOutlet weak var categoriesTableViewWidth: NSLayoutConstraint!
    @IBOutlet weak var menuItemsTableViewWidth: NSLayoutConstraint!
    //To Bottom
    @IBOutlet weak var categoriesTableViewToBottom: NSLayoutConstraint!
    @IBOutlet weak var menuItemsTableViewToBottom: NSLayoutConstraint!
    @IBOutlet weak var cartViewToBottom: NSLayoutConstraint!
    

    // MARK: - Variables
    
    // Categories
    var restaurantImageData = NSData()
    var restaurantName = String()
    var restaurantID = String()
    var restaurantType = String()
    var restaurantHours = String()
    var open_hours = String()
    var menuCategories = [String]()
    var menuID = [String]()
    var idList = [String]()
    var isOpen = Bool()
    
    // CoreData
    let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
    let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    
    // FOR MENU ITEMS
    
    // Create struct to organize data
    struct MenuItem {
        var foodName: String
        var foodDescription: String
        var foodPrice: String
        var foodID: String
        var foodSideNum: String
    }
    
    // Create empty array of Restaurants to be filled in ViewDidLoad
    var menuItems: [MenuItem] = []
    
    // DATA
    var foodNames = [String]()
    var foodDescriptions = [String]()
    var foodPrices = [String]()
    var foodIDs = [String]()
    var foodSideNums = [String]()
    
    // Variables
    var backToVC = ""
    var titleCell = String()
    var titleID = String()
    var hasActiveCart = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.cuisineTypeLabel.text = restaurantType
        
        // Set tableView widths
        categoriesTableViewWidth.constant = view.frame.width * 0.95
        menuItemsTableViewWidth.constant = view.frame.width * 0.95
        
        //let url = NSURL(string: restaurantImageURL)
        //let data = NSData(contentsOfURL: url!)
        self.restaurantBackgroundImage.image = UIImage(data: restaurantImageData)
        
        // Set custom back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        // Add shadow to detailsView
        detailsView.layer.shadowColor = UIColor.darkGrayColor().CGColor
        detailsView.layer.shadowOpacity = 0.5
        detailsView.layer.shadowOffset = CGSizeZero
        detailsView.layer.shadowRadius = 1.5
        
        // Set tableView cells to custom height and automatically resize if needed
        categoriesTableView.estimatedRowHeight = 50
        self.categoriesTableView.rowHeight = UITableViewAutomaticDimension
        
        // Set tableView cells to custom height and automatically resize if needed
        menuItemsTableView.estimatedRowHeight = 75
        menuItemsTableView.rowHeight = UITableViewAutomaticDimension
        menuItemsTableView.setNeedsLayout()
        menuItemsTableView.layoutIfNeeded()
        
        // Start activity indicator
        myCategoriesActivityIndicator.startAnimating()
        self.myCategoriesActivityIndicator.hidden = false
        
        // Open Connection to PHP Service
        let requestURL: NSURL = NSURL(string: "http://www.gobring.it/CHADmenuCategories.php")!
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
                                
                                let service_id = Restaurant["service_id"] as! String
                                
                                if (service_id == self.restaurantID) {
                                    let name = Restaurant["name"] as! String
                                    self.menuCategories.append(name)
                                    self.idList.append(service_id)
                                    let id = Restaurant["id"] as! String
                                    self.menuID.append(id)
                                }
                            }
                            
                            NSOperationQueue.mainQueue().addOperationWithBlock {
                                self.categoriesTableView.reloadData()
                                self.updateViewConstraints()
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

        // Open Connection to PHP Service
        let requestURL1: NSURL = NSURL(string: "http://www.gobring.it/CHADrestaurantHours.php")!
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
                                
                                let restaurant_id = Restaurant["restaurant_id"] as? String
                                
                                if (restaurant_id == self.restaurantID) {

                                    let all_hours = Restaurant["open_hours"] as! String
                                    let hours_byDay = all_hours.componentsSeparatedByString(", ")
                                    
                                    let currentCalendar = NSCalendar.currentCalendar()
                                    let currentDate = NSDate()
                                    let localDate = NSDate(timeInterval: NSTimeInterval(NSTimeZone.systemTimeZone().secondsFromGMT), sinceDate: currentDate)
                                    let components = currentCalendar.components([.Year, .Month, .Day, .TimeZone, .Hour, .Minute], fromDate: currentDate)
                                    print(currentDate)
                                    print(localDate)
                                    let componentTime : Float = Float(components.hour) + Float(components.minute) / 60
                                    var estTime : Float
                                    if (componentTime > 4) {
                                        estTime = componentTime
                                    } else {
                                        estTime = componentTime
                                    }
                                    
                                    let dateFormatter = NSDateFormatter()
                                    dateFormatter.locale = NSLocale.currentLocale()
                                    dateFormatter.dateFormat = "EEEE"
                                    let convertedDate = dateFormatter.stringFromDate(currentDate)
                                    
                                    var openDate : Float? = nil
                                    var closeDate : Float? = nil
                                    
                                    for i in 0..<hours_byDay.count {
                                        if (hours_byDay[i].rangeOfString(convertedDate) != nil) {
                                            self.open_hours = hours_byDay[i]
                                            
                                            // Extract exact hours of operation for this day
                                            var hours_pieces = hours_byDay[i].componentsSeparatedByString(" ");
                                            for j in 0..<hours_pieces.count {
                                                
                                                // Find time pieces (not the Day, not the "-", just the "time + am" or "time + pm")
                                                if ((hours_pieces[j].rangeOfString(convertedDate) == nil) && (hours_pieces[j].rangeOfString("-") == nil)) {
                                                    
                                                    let dateMaker = NSDateFormatter()
                                                    dateMaker.dateFormat = "yyyy/MM/dd HH:mm:ss"
                                                    
                                                    if (openDate == nil) {
                                                        var newTime : Float? = nil
                                                        var minuteTime : Float? = nil
                                                        if (hours_pieces[j].rangeOfString("pm") != nil) {
                                                            let time_pieces = hours_pieces[j].componentsSeparatedByString("pm");
                                                            let hour_minute = time_pieces[0].componentsSeparatedByString(":");
                                                            if time_pieces[0] == "12" {
                                                                newTime = Float(time_pieces[0])
                                                            } else {
                                                                newTime = Float(time_pieces[0])! + 12
                                                            }
                                                            
                                                            if (hour_minute.count > 1) {
                                                                minuteTime = Float(hour_minute[1])
                                                            }
                                                        }
                                                        if (hours_pieces[j].rangeOfString("am") != nil) {
                                                            let time_pieces = hours_pieces[j].componentsSeparatedByString("am");
                                                            let hour_minute = time_pieces[0].componentsSeparatedByString(":");
                                                            newTime = Float(time_pieces[0])!
                                                            if (hour_minute.count > 1) {
                                                                minuteTime = Float(hour_minute[1])
                                                            }
                                                        }
                                                        if (minuteTime != nil) {
                                                            let minuteDecimal : Float = Float(minuteTime!)/60.0
                                                            newTime = newTime! + minuteDecimal
                                                        }
                                                        print("The open time is: ", newTime!)
                                                        openDate = newTime!
                                                    } else if (closeDate == nil) {
                                                        var newTime : Float? = nil
                                                        var minuteTime : Float? = nil
                                                        if (hours_pieces[j].rangeOfString("pm") != nil) {
                                                            let time_pieces = hours_pieces[j].componentsSeparatedByString("pm");
                                                            let hour_minute = time_pieces[0].componentsSeparatedByString(":");
                                                            if time_pieces[0] == "12" {
                                                                newTime = Float(hour_minute[0])
                                                            } else {
                                                                newTime = Float(hour_minute[0])! + 12
                                                            }
                                                            
                                                            if (hour_minute.count > 1) {
                                                                minuteTime = Float(hour_minute[1])
                                                            }
                                                        }
                                                        if (hours_pieces[j].rangeOfString("am") != nil) {
                                                            let time_pieces = hours_pieces[j].componentsSeparatedByString("am");
                                                            let hour_minute = time_pieces[0].componentsSeparatedByString(":");
                                                            newTime = Float(hour_minute[0])!
                                                            if (hour_minute.count > 1) {
                                                                minuteTime = Float(hour_minute[1])
                                                            }
                                                        }
                                                        if (minuteTime != nil) {
                                                            let minuteDecimal : Float = Float(minuteTime!)/60.0
                                                            newTime = newTime! + minuteDecimal
                                                        }
                                                        //print("The close time is: ", newTime?)
                                                        closeDate = newTime!
                                                    }
                                                }
                                            }
                                            
                                            // Check if localDate is between openDate and closeDate
                                            if (estTime > openDate && estTime < closeDate) {
                                                print("open")
                                                self.isOpen = true;
                                            } else {
                                                print("close")
                                                self.isOpen = false;
                                            }
                                        }
                                    }
                                }
                            }
                            
                            NSOperationQueue.mainQueue().addOperationWithBlock {
                                if (self.isOpen) {
                                    self.isOpenIndicator.image = UIImage(named: "oval-green");
                                } else {
                                    self.isOpenIndicator.image = UIImage(named: "oval-red");
                                }
                                self.restaurantHoursLabel.text = self.open_hours
                                
                                self.categoriesTableView.reloadData()
                                
                                // Stop activity indicator
                                self.myCategoriesActivityIndicator.stopAnimating()
                                self.myCategoriesActivityIndicator.hidden = true
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
        
        task1.resume()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        // Hide nav bar
        self.navigationController?.navigationBarHidden = true
        
        // Deselect cells when view appears
        if let indexPath = menuItemsTableView.indexPathForSelectedRow {
            menuItemsTableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
        // Fetch all active carts, if any exist
        let fetchRequest = NSFetchRequest(entityName: "Order")
        let firstPredicate = NSPredicate(format: "isActive == %@", true)
        let secondPredicate = NSPredicate(format: "restaurant == %@", restaurantName)
        let predicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [firstPredicate, secondPredicate])
        fetchRequest.predicate = predicate
        
        do {
            if let fetchResults = try managedContext.executeFetchRequest(fetchRequest) as? [Order] {
                if fetchResults.count > 0 {
                    let order = fetchResults[0]
                    if order.items?.count > 0 {
                        
                        // Calculate current total cost
                        var totalCost = 0.0
                        if !(order.items?.allObjects.isEmpty)! {
                            for item in (order.items?.allObjects)! as! [Item] {
                                var costOfSides = 0.0
                                for side in item.sides?.allObjects as! [Side] {
                                    costOfSides += Double(side.price!)
                                }
                                totalCost += (Double(item.price!) + costOfSides) * Double(item.quantity!)
                            }
                        }
                        totalPriceLabel.text = String(format: "$%.2f", totalCost)
                        
                        hasActiveCart = true
                    } else {
                        hasActiveCart = false
                    }
                } else {
                    hasActiveCart = false
                }
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        // Update view constraints
        updateViewConstraints()
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        menuItemsViewHeight.constant = UIScreen.mainScreen().bounds.height - 10
        categoriesViewHeight.constant = UIScreen.mainScreen().bounds.height - 237
        
        if hasActiveCart {
            cartViewToBottom.constant = 0
            categoriesTableViewToBottom.constant = 50
            menuItemsTableViewToBottom.constant = 50
            UIView.animateWithDuration(0.4) {
                self.view.layoutIfNeeded()
            }
        } else {
            cartViewToBottom.constant = -50
            categoriesTableViewToBottom.constant = 0
            menuItemsTableViewToBottom.constant = 0
            UIView.animateWithDuration(0.4) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func getMenuItems() {
        
        // Start activity indicator
        self.myMenuItemsActivityIndicator.startAnimating()
        self.myMenuItemsActivityIndicator.hidden = false
        
        self.foodNames.removeAll()
        self.foodDescriptions.removeAll()
        self.foodPrices.removeAll()
        self.foodIDs.removeAll()
        self.foodSideNums.removeAll()
        self.menuItems.removeAll()
        
        self.selectedCategoryNameLabel.text = self.titleCell

        // Open Connection to PHP Service
        let requestURL: NSURL = NSURL(string: "http://www.gobring.it/CHADmenuItems.php")!
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
                            // print(json)
                            for Restaurant in json as! [Dictionary<String, AnyObject>] {
                                let category_id = Restaurant["category_id"] as! String
                                
                                if (self.titleID == category_id) {
                                    let name = Restaurant["name"] as! String
                                    self.foodNames.append(name)
                                    var desc: String?
                                    desc = Restaurant["desc"] as? String
                                    if (desc == nil) {
                                        self.foodDescriptions.append("No Description")
                                    } else {
                                        self.foodDescriptions.append(desc!)
                                    }
                                    
                                    let price = Restaurant["price"] as! String
                                    self.foodPrices.append(price)
                                    self.foodIDs.append(Restaurant["id"] as! String)
                                    self.foodSideNums.append(Restaurant["num_sides"] as! String)
                                }
                            }
                            
                            NSOperationQueue.mainQueue().addOperationWithBlock {
                                // Loop through DB data and append Restaurant objects into restaurants array
                                for i in 0..<self.foodNames.count {
                                    self.menuItems.append(MenuItem(foodName: self.foodNames[i], foodDescription: self.foodDescriptions[i], foodPrice: self.foodPrices[i], foodID: self.foodIDs[i], foodSideNum: self.foodSideNums[i]))
                                }
                                self.menuItemsTableView.reloadData()
                                
                                // Stop activity indicator
                                self.myMenuItemsActivityIndicator.stopAnimating()
                                self.myMenuItemsActivityIndicator.hidden = true
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
    
    override func viewWillDisappear(animated: Bool) {
        // Show nav bar
        self.navigationController?.navigationBarHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    @IBAction func xButtonPressed(sender: UIButton) {
        print("X BUTTON PRESSED")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == categoriesTableView {
            return menuCategories.count
        } else {
            return menuItems.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == categoriesTableView {
            let cell = tableView.dequeueReusableCellWithIdentifier("menuCategories", forIndexPath: indexPath)
            
            // Set up cell properties
            cell.textLabel?.text = menuCategories[indexPath.row]
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("menuCell", forIndexPath: indexPath) as! MenuTableViewCell
            
            cell.menuItemLabel.text = menuItems[indexPath.row].foodName
            cell.itemDescriptionLabel.text = menuItems[indexPath.row].foodDescription
            let price = Double(menuItems[indexPath.row].foodPrice)
            cell.itemPriceLabel.text = String(format: "$%.2f", price!)
            
            return cell
        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == categoriesTableView {
            titleCell = ""
            titleID = ""
            
            myScrollView.setContentOffset(CGPoint(x: myScrollView.contentOffset.x + myScrollView.frame.width, y: -myScrollView.contentInset.top), animated: true)
            titleCell = menuCategories[indexPath.row]
            titleID = menuID[indexPath.row]
            getMenuItems()
            menuItemsTableView.reloadData()
        }
    }
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        UIScreen.mainScreen().bounds.width
        myScrollView.setContentOffset(CGPoint(x: myScrollView.contentOffset.x - myScrollView.frame.width, y: myScrollView.contentOffset.y), animated: true)
        myScrollView.scrollToTop()
        
        // Deselect cells when view appears
        if let indexPath = categoriesTableView.indexPathForSelectedRow {
            categoriesTableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "toCheckout" {
            // Send selected food's data to AddToOrder screen
            let nav = segue.destinationViewController as! UINavigationController
            let VC = nav.topViewController as! CheckoutViewController
            VC.cameFromVC = "Restaurant"
            VC.isOpen = self.isOpen
        } else if segue.identifier == "toTable" {
            let VC = segue.destinationViewController as! RestaurantTableViewController
            VC.restaurantImageData = self.restaurantImageData
            VC.restaurantName = self.restaurantName
            VC.restaurantID = self.restaurantID
            VC.restaurantType = self.restaurantType
        } else if segue.identifier == "toAddToOrder" {
            // Send selected food's data to AddToOrder screen
            let nav = segue.destinationViewController as! UINavigationController
            let VC = nav.topViewController as! AddToOrderViewController
            let indexPath = self.menuItemsTableView.indexPathForSelectedRow!
            VC.selectedFoodName = foodNames[indexPath.row]
            VC.selectedFoodDescription = foodDescriptions[indexPath.row]
            VC.selectedFoodPrice = Double(foodPrices[indexPath.row])!
            VC.selectedFoodID = foodIDs[indexPath.row]
            VC.selectedFoodSidesNum = foodSideNums[indexPath.row]
            
            print("SEGUE WORKS")
        }
    }
    
}

extension UIScrollView {
    func scrollToTop() {
        let desiredOffset = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(desiredOffset, animated: true)
    }
}