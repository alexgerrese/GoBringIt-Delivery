//
//  MenuTableViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/16/16.
//  Copyright © 2016 Campus Enterprises. All rights reserved.
//

import UIKit
import CoreData

class MenuTableViewController: UITableViewController {
    
    @IBOutlet weak var cartButton: UIBarButtonItem!
    
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
    
    // CoreData
    let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
    let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title
        self.title = titleCell
        
        // Set custom back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        // Set tableView cells to custom height and automatically resize if needed
        tableView.estimatedRowHeight = 75
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.setNeedsLayout()
        self.tableView.layoutIfNeeded()
        
        // Create JSON data and configure the request
        let params = ["category_ID": self.titleID]
            as Dictionary<String, String>
        
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
                                self.tableView.reloadData()
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
        override func viewWillAppear(animated: Bool) {
            
            // Deselect cells when view appears
            if let indexPath = tableView.indexPathForSelectedRow {
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
            
            // Fetch all active carts, if any exist
            
            let fetchRequest = NSFetchRequest(entityName: "Order")
            let firstPredicate = NSPredicate(format: "isActive == %@", true)
            let secondPredicate = NSPredicate(format: "restaurant == %@", selectedRestaurantName)
            let predicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [firstPredicate, secondPredicate])
            fetchRequest.predicate = predicate
            
            do {
                if let fetchResults = try managedContext.executeFetchRequest(fetchRequest) as? [Order] {
                    if fetchResults.count > 0 {
                        let order = fetchResults[0]
                        if order.items?.count > 0 {
                            cartButton.tintColor = GREEN
                        } else {
                            cartButton.tintColor = UIColor.darkGrayColor()
                        }
                    }
                    print(fetchResults.count)
                }
            } catch let error as NSError {
                print("Could not fetch \(error), \(error.userInfo)")
            }
        }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("menuCell", forIndexPath: indexPath) as! MenuTableViewCell
        
        cell.menuItemLabel.text = menuItems[indexPath.row].foodName
        cell.itemDescriptionLabel.text = menuItems[indexPath.row].foodDescription
        cell.itemPriceLabel.text = menuItems[indexPath.row].foodPrice
        
        return cell
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
    
    
    // MARK: - Navigation
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
    }
    
    @IBAction func returnToMenu(segue: UIStoryboardSegue) {
    }
    
    override func canPerformUnwindSegueAction(action: Selector, fromViewController: UIViewController, withSender sender: AnyObject) -> Bool {
        if backToVC == "Menu" {
            return true
        }
        return false
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        print("PRE SEGUE WORKS")
        
        if segue.identifier == "toAddToOrder" {
            // Send selected food's data to AddToOrder screen
            let nav = segue.destinationViewController as! UINavigationController
            let VC = nav.topViewController as! AddToOrderViewController
            let indexPath = self.tableView.indexPathForSelectedRow!
            VC.selectedFoodName = foodNames[indexPath.row]
            VC.selectedFoodDescription = foodDescriptions[indexPath.row]
            VC.selectedFoodPrice = Double(foodPrices[indexPath.row])!
            VC.selectedFoodID = foodIDs[indexPath.row]
            VC.selectedFoodSidesNum = foodSideNums[indexPath.row]
            
            print("SEGUE WORKS")
        } else if segue.identifier == "toCheckoutFromMenu" {
            // Send selected food's data to AddToOrder screen
            let nav = segue.destinationViewController as! UINavigationController
            let VC = nav.topViewController as! CheckoutViewController
            VC.cameFromVC = "Menu"
        }
        
    }
    
}