//
//  MenuTableViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/16/16.
//  Copyright © 2016 Campus Enterprises. All rights reserved.
//

import UIKit

class MenuTableViewController: UITableViewController {
    
    // MARK: - SAMPLE DATA - CHAD REPLACE WITH BACKEND

    /* The best way to do this would be to grab it from the database and store it in an array of objects like below. If you use the same variable names, they should automatically work with the front end.*/
    
    // Create struct to organize data
    struct MenuItem {
        var foodName: String
        var foodDescription: String
        var foodPrice: String
    }
    
    // Create empty array of Restaurants to be filled in ViewDidLoad
    var menuItems: [MenuItem] = []
 
    // SAMPLE DATA (Don't pay attention to this Chad)
    let foodNames = ["The Carolina Cockerel", "The Buff Brahmas", "Frizzled Fowl", "The Quilted Buttercup", "Light Brown Leghorn", "Orange Speckled Chabo", "Make Your Own Waffle", "Breakfast Buttercup", "Parfait Waffle"]
    let foodDescriptions = ["Three chicken wings, two petite waffles, shmear", "Two cutlets, sweet potato waffles, whiskey cream sauce drizzle", "A panko-fried cutlet, petite classic waffles, almonds & plum sauce", "A chicken cutlet 'sandwiched' between sweet potato waffles, shmear", "Three drumsticks, classic waffles, caramel cashew drizzle", "Three chicken wings, two petite waffles, shmear", "Choose the type of waffle you'd like (classic, sweet potato, or vegan) and your shmear of choice! ", "Two waffles 'sandwiched' w/bacon, egg, shmear", ""]
    let foodPrices = ["10.00", "13.00", "10.00", "10.00", "10.00", "10.00", "8.00", "7.00", "6.00"]
    
    // Variables
    var backToVC = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set SAMPLE title
        self.title = "Signature Chicken and Waffles"
        
        // Set custom back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        // Set tableView cells to custom height and automatically resize if needed
        tableView.estimatedRowHeight = 75
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.setNeedsLayout()
        self.tableView.layoutIfNeeded()
        
        // CHAD: Loop through DB data and append Restaurant objects into restaurants array
        for i in 0..<foodNames.count {
            menuItems.append(MenuItem(foodName: foodNames[i], foodDescription: foodDescriptions[i], foodPrice: foodPrices[i]))
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
    
    override func canPerformUnwindSegueAction(action: Selector, fromViewController: UIViewController, withSender sender: AnyObject) -> Bool {
        if backToVC == "Menu" {
            return true
        }
        return false
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "toAddToOrder" {
            // Send selected food's data to AddToOrder screen
            let nav = segue.destinationViewController as! UINavigationController
            let VC = nav.topViewController as! AddToOrderViewController
            let indexPath = self.tableView.indexPathForSelectedRow!
            VC.selectedFoodName = foodNames[indexPath.row]
            VC.selectedFoodDescription = foodDescriptions[indexPath.row]
            VC.selectedFoodPrice = foodPrices[indexPath.row]
        } else if segue.identifier == "toCheckout" {
            // Send selected food's data to AddToOrder screen
            let nav = segue.destinationViewController as! UINavigationController
            let VC = nav.topViewController as! CheckoutViewController
            VC.cameFromVC = "Menu"
        }
        
    }
    

}
