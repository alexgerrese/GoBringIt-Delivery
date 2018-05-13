//
//  MenuTableViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/16/16.
//  Copyright © 2016 Campus Enterprises. All rights reserved.
//

/*import UIKit
import CoreData

class MenuTableViewController: UITableViewController {
    
    @IBOutlet weak var cartButton: UIBarButtonItem!
    
    
    
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
        //let params = ["category_ID": self.titleID]
            //as Dictionary<String, String>
        
        
        
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
                        print(order.items?.count)
                        if order.items?.count > 0 {
                            cartButton.tintColor = GREEN
                        } else {
                            cartButton.tintColor = UIColor.darkGrayColor()
                        }
                    } else {
                        cartButton.tintColor = UIColor.darkGrayColor()
                    }
                    print(fetchResults.count)
                } else {
                    cartButton.tintColor = UIColor.darkGrayColor()
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
    
}*/
