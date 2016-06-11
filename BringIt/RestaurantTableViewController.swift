//
//  RestaurantTableViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/16/16.
//  Copyright © 2016 Campus Enterprises. All rights reserved.
//

import UIKit

//var cameFromRestaurant =

class RestaurantTableViewController: UITableViewController {
    
    @IBOutlet weak var cuisineTypeLabel: UILabel!
    @IBOutlet weak var restaurantHoursLabel: UILabel!
    @IBOutlet weak var openClosedLabel: UILabel!
    @IBOutlet weak var isOpenIndicator: UIImageView!
    
    // SAMPLE DATA
    let menuCategories = ["Signature Chicken and Waffles", "Weekend Brunch", "Omelets", "Burgers, Cluckers, etc.", "Weekend Brunch", "Omelets", "Burgers, Cluckers, etc."]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set SAMPLE title
        self.title = "Dames"
        
        // Set tableView cells to custom height and automatically resize if needed
        tableView.estimatedRowHeight = 50
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        // Set custom back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return menuCategories.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("menuCategories", forIndexPath: indexPath)

        // Set up cell properties
        cell.textLabel?.text = menuCategories[indexPath.row]

        return cell
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
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
        }
    }
    

}
