//
//  RestaurantViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 8/9/16.
//  Copyright © 2016 Campus Enterprises. All rights reserved.
//

import UIKit
import CoreData
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


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
    var restaurantImageData = Data()
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
//    let appDelegate =
//        UIApplication.shared.delegate as! AppDelegate
//    let managedContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    
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
        categoriesTableViewWidth.constant = view.frame.width - 20
        menuItemsTableViewWidth.constant = view.frame.width - 20
        
        //let url = NSURL(string: restaurantImageURL)
        //let data = NSData(contentsOfURL: url!)
        self.restaurantBackgroundImage.image = UIImage(data: restaurantImageData)
        
        // Set custom back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
        // Add shadow to detailsView
        detailsView.layer.shadowColor = UIColor.darkGray.cgColor
        detailsView.layer.shadowOpacity = 0.5
        detailsView.layer.shadowOffset = CGSize.zero
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
        self.myCategoriesActivityIndicator.isHidden = false
        
        // Open Connection to PHP Service
        let requestURL: URL = URL(string: "http://www.gobringit.com/CHADmenuCategories.php")!
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
                                
                                let service_id = Restaurant["service_id"] as! String
                                
                                if (service_id == self.restaurantID) {
                                    let name = Restaurant["name"] as! String
                                    self.menuCategories.append(name)
                                    self.idList.append(service_id)
                                    let id = Restaurant["id"] as! String
                                    self.menuID.append(id)
                                }
                            }
                            
                            OperationQueue.main.addOperation {
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
        }) 
        
        task.resume()

        // Open Connection to PHP Service
        let requestURL1: URL = URL(string: "http://www.gobringit.com/CHADrestaurantHours.php")!
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
                                
                                let restaurant_id = Restaurant["restaurant_id"] as? String
                                
                                if (restaurant_id == self.restaurantID) {

                                    let all_hours = Restaurant["open_hours"] as! String
                                    let hours_byDay = all_hours.components(separatedBy: ", ")
                                    
                                    let currentCalendar = Calendar.current
                                    let currentDate = Date()
                                    let localDate = Date(timeInterval: TimeInterval(NSTimeZone.system.secondsFromGMT()), since: currentDate)
                                    let components = (currentCalendar as NSCalendar).components([.year, .month, .day, .timeZone, .hour, .minute], from: currentDate)
                                    print(currentDate)
                                    print(localDate)
                                    let componentTime : Float = Float(components.hour!) + Float(components.minute!) / 60
                                    var estTime : Float
                                    if (componentTime > 4) {
                                        estTime = componentTime
                                    } else {
                                        estTime = componentTime
                                    }
                                    
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.locale = Locale.current
                                    dateFormatter.dateFormat = "EEEE"
                                    let convertedDate = dateFormatter.string(from: currentDate)
                                    
                                    var openDate : Float? = nil
                                    var closeDate : Float? = nil
                                    
                                    for i in 0..<hours_byDay.count {
                                        if (hours_byDay[i].range(of: convertedDate) != nil) {
                                            self.open_hours = hours_byDay[i]
                                            
                                            // Extract exact hours of operation for this day
                                            var hours_pieces = hours_byDay[i].components(separatedBy: " ");
                                            for j in 0..<hours_pieces.count {
                                                
                                                // Find time pieces (not the Day, not the "-", just the "time + am" or "time + pm")
                                                if ((hours_pieces[j].range(of: convertedDate) == nil) && (hours_pieces[j].range(of: "-") == nil)) {
                                                    
                                                    let dateMaker = DateFormatter()
                                                    dateMaker.dateFormat = "yyyy/MM/dd HH:mm:ss"
                                                    
                                                    if (openDate == nil) {
                                                        var newTime : Float? = nil
                                                        var minuteTime : Float? = nil
                                                        if (hours_pieces[j].range(of: "pm") != nil) {
                                                            let time_pieces = hours_pieces[j].components(separatedBy: "pm");
                                                            let hour_minute = time_pieces[0].components(separatedBy: ":");
                                                            if time_pieces[0] == "12" {
                                                                newTime = Float(time_pieces[0])
                                                            } else {
                                                                newTime = Float(time_pieces[0])! + 12
                                                            }
                                                            
                                                            if (hour_minute.count > 1) {
                                                                minuteTime = Float(hour_minute[1])
                                                            }
                                                        }
                                                        if (hours_pieces[j].range(of: "am") != nil) {
                                                            let time_pieces = hours_pieces[j].components(separatedBy: "am");
                                                            let hour_minute = time_pieces[0].components(separatedBy: ":");
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
                                                        if (hours_pieces[j].range(of: "pm") != nil) {
                                                            let time_pieces = hours_pieces[j].components(separatedBy: "pm");
                                                            let hour_minute = time_pieces[0].components(separatedBy: ":");
                                                            if time_pieces[0] == "12" {
                                                                newTime = Float(hour_minute[0])
                                                            } else {
                                                                newTime = Float(hour_minute[0])! + 12
                                                            }
                                                            
                                                            if (hour_minute.count > 1) {
                                                                minuteTime = Float(hour_minute[1])
                                                            }
                                                        }
                                                        if (hours_pieces[j].range(of: "am") != nil) {
                                                            let time_pieces = hours_pieces[j].components(separatedBy: "am");
                                                            let hour_minute = time_pieces[0].components(separatedBy: ":");
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
                            
                            OperationQueue.main.addOperation {
                                if (self.isOpen) {
                                    self.isOpenIndicator.image = UIImage(named: "oval-green");
                                } else {
                                    self.isOpenIndicator.image = UIImage(named: "oval-red");
                                }
                                self.restaurantHoursLabel.text = self.open_hours
                                
                                self.categoriesTableView.reloadData()
                                
                                // Stop activity indicator
                                self.myCategoriesActivityIndicator.stopAnimating()
                                self.myCategoriesActivityIndicator.isHidden = true
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
        
        task1.resume()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Hide nav bar
//        self.navigationController?.isNavigationBarHidden = true
//        
//        // Deselect cells when view appears
//        if let indexPath = menuItemsTableView.indexPathForSelectedRow {
//            menuItemsTableView.deselectRow(at: indexPath, animated: true)
//        }
//        
//        // Fetch all active carts, if any exist
//        let fetchRequest = NSFetchRequest<Order>(entityName: "Order")
//        let firstPredicate = NSPredicate(format: "isActive == %@", true as CVarArg)
//        let secondPredicate = NSPredicate(format: "restaurant == %@", restaurantName)
//        let predicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [firstPredicate, secondPredicate])
//        fetchRequest.predicate = predicate
//        
//        do {
//            if let fetchResults = try managedContext.fetch(fetchRequest) as? [Order] {
//                if fetchResults.count > 0 {
//                    let order = fetchResults[0]
//                    if order.items?.count > 0 {
//                        
//                        // Calculate current total cost
//                        var totalCost = 0.0
//                        if !(order.items?.allObjects.isEmpty)! {
//                            for item in (order.items?.allObjects)! as! [Item] {
//                                var costOfSides = 0.0
//                                for side in item.sides?.allObjects as! [Side] {
//                                    costOfSides += Double(side.price!)
//                                }
//                                totalCost += (Double(item.price!) + costOfSides) * Double(item.quantity!)
//                            }
//                        }
//                        totalPriceLabel.text = String(format: "$%.2f", totalCost)
//                        
//                        hasActiveCart = true
//                    } else {
//                        hasActiveCart = false
//                    }
//                } else {
//                    hasActiveCart = false
//                }
//            }
//        } catch let error as NSError {
//            print("Could not fetch \(error), \(error.userInfo)")
//        }
        
        // Update view constraints
        updateViewConstraints()
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        menuItemsViewHeight.constant = UIScreen.main.bounds.height - 10
        categoriesViewHeight.constant = UIScreen.main.bounds.height - 237
        
        if hasActiveCart {
            cartViewToBottom.constant = 0
            categoriesTableViewToBottom.constant = 50
            menuItemsTableViewToBottom.constant = 50
            UIView.animate(withDuration: 0.4, animations: {
                self.view.layoutIfNeeded()
            }) 
        } else {
            cartViewToBottom.constant = -50
            categoriesTableViewToBottom.constant = 0
            menuItemsTableViewToBottom.constant = 0
            UIView.animate(withDuration: 0.4, animations: {
                self.view.layoutIfNeeded()
            }) 
        }
    }
    
    func getMenuItems() {
        
        // Start activity indicator
        self.myMenuItemsActivityIndicator.startAnimating()
        self.myMenuItemsActivityIndicator.isHidden = false
        
        self.foodNames.removeAll()
        self.foodDescriptions.removeAll()
        self.foodPrices.removeAll()
        self.foodIDs.removeAll()
        self.foodSideNums.removeAll()
        self.menuItems.removeAll()
        
        self.selectedCategoryNameLabel.text = self.titleCell

        // Open Connection to PHP Service
        let requestURL: URL = URL(string: "http://www.gobringit.com/CHADmenuItems.php")!
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
                            
                            OperationQueue.main.addOperation {
                                // Loop through DB data and append Restaurant objects into restaurants array
                                for i in 0..<self.foodNames.count {
                                    self.menuItems.append(MenuItem(foodName: self.foodNames[i], foodDescription: self.foodDescriptions[i], foodPrice: self.foodPrices[i], foodID: self.foodIDs[i], foodSideNum: self.foodSideNums[i]))
                                }
                                self.menuItemsTableView.reloadData()
                                
                                // Stop activity indicator
                                self.myMenuItemsActivityIndicator.stopAnimating()
                                self.myMenuItemsActivityIndicator.isHidden = true
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Show nav bar
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }

    @IBAction func xButtonPressed(_ sender: UIButton) {
        print("X BUTTON PRESSED")
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func prepareForUnwind(_ segue: UIStoryboardSegue) {
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == categoriesTableView {
            return menuCategories.count
        } else {
            return menuItems.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == categoriesTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "menuCategories", for: indexPath)
            
            // Set up cell properties
            cell.textLabel?.text = menuCategories[(indexPath as NSIndexPath).row]
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath) as! MenuTableViewCell
            
            cell.menuItemLabel.text = menuItems[(indexPath as NSIndexPath).row].foodName
            if menuItems[(indexPath as NSIndexPath).row].foodDescription != "No Description" {
                cell.itemDescriptionLabel.text = menuItems[(indexPath as NSIndexPath).row].foodDescription
            } else {
                cell.itemDescriptionLabel.text = ""
            }
        
            let price = Double(menuItems[(indexPath as NSIndexPath).row].foodPrice)
            cell.itemPriceLabel.text = String(format: "$%.2f", price!)
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == categoriesTableView {
            titleCell = ""
            titleID = ""
            
            myScrollView.setContentOffset(CGPoint(x: myScrollView.contentOffset.x + myScrollView.frame.width, y: -myScrollView.contentInset.top), animated: true)
            titleCell = menuCategories[(indexPath as NSIndexPath).row]
            titleID = menuID[(indexPath as NSIndexPath).row]
            getMenuItems()
            menuItemsTableView.reloadData()
        }
    }
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        UIScreen.main.bounds.width
        myScrollView.setContentOffset(CGPoint(x: myScrollView.contentOffset.x - myScrollView.frame.width, y: myScrollView.contentOffset.y), animated: true)
        myScrollView.scrollToTop()
        
        // Deselect cells when view appears
        if let indexPath = categoriesTableView.indexPathForSelectedRow {
            categoriesTableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "toCheckout" {
            // Send selected food's data to AddToOrder screen
            let nav = segue.destination as! UINavigationController
            let VC = nav.topViewController as! OldCheckoutViewController
            VC.cameFromVC = "Restaurant"
            VC.isOpen = self.isOpen
        } else if segue.identifier == "toTable" {
            let VC = segue.destination as! RestaurantTableViewController
            VC.restaurantImageData = self.restaurantImageData
            VC.restaurantName = self.restaurantName
            VC.restaurantID = self.restaurantID
            VC.restaurantType = self.restaurantType
        } else if segue.identifier == "toAddToOrder" {
            // Send selected food's data to AddToOrder screen
            let nav = segue.destination as! UINavigationController
            let VC = nav.topViewController as! AddToOrderViewController
            let indexPath = self.menuItemsTableView.indexPathForSelectedRow!
            VC.selectedFoodName = foodNames[(indexPath as NSIndexPath).row]
            VC.selectedFoodDescription = foodDescriptions[(indexPath as NSIndexPath).row]
            VC.selectedFoodPrice = Double(foodPrices[(indexPath as NSIndexPath).row])!
            VC.selectedFoodID = foodIDs[(indexPath as NSIndexPath).row]
            VC.selectedFoodSidesNum = foodSideNums[(indexPath as NSIndexPath).row]
            
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
