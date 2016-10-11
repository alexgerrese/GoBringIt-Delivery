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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Deselect cells when view appears
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print(menuCategories.count)
        return menuCategories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCategories", for: indexPath)
        
        // Set up cell properties
        cell.textLabel?.text = menuCategories[(indexPath as NSIndexPath).row]
        
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
