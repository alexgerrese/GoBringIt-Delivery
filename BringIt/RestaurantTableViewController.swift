//
//  RestaurantTableViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 8/10/16.
//  Copyright © 2016 Campus Enterprises. All rights reserved.
//

import UIKit

class RestaurantTableViewController: UITableViewController {
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        // Deselect cells when view appears
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
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
        print(menuCategories.count)
        return menuCategories.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("menuCategories", forIndexPath: indexPath)
        
        // Set up cell properties
        cell.textLabel?.text = menuCategories[indexPath.row]
        
        return cell
    }
    

    
    /* MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
            let indexPath = tableView.indexPathForSelectedRow?.row
            let destination = segue.destinationViewController as? MenuTableViewController
            destination?.titleCell = menuCategories[indexPath!]
            destination?.titleID = menuID[indexPath!]
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }*/
    

}
