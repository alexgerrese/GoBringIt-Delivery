//
//  RestaurantTableViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/16/16.
//  Copyright © 2016 Campus Enterprises. All rights reserved.
//

import UIKit

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
        
        // Make nav bar transparent
        // BUG - If you keep scrolling, tab bar will stay over tableView content
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController!.navigationBar.titleTextAttributes =
            ([NSFontAttributeName: UIFont(name: "Avenir", size: 17)!,
                NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        // Round corners of openClosedLabel and add shadow
        openClosedLabel.layer.cornerRadius = 11
        openClosedLabel.clipsToBounds = true
        openClosedLabel.layer.shadowColor = UIColor.whiteColor().CGColor
        openClosedLabel.layer.shadowOpacity = 1
        openClosedLabel.layer.shadowOffset = CGSizeZero
        openClosedLabel.layer.shadowRadius = 5
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
    
    // MARK: - Navigation
    
    override func viewWillDisappear(animated: Bool){
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBarHidden = false
    }

}
