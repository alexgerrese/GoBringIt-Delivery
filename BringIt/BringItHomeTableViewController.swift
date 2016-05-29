//
//  BringItHomeTableViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/16/16.
//  Copyright © 2016 Campus Enterprises. All rights reserved.
//

import UIKit
//import BTNavigationDropdownMenu

class BringItHomeTableViewController: UITableViewController {
    
    // SAMPLE DATA - REPLACE WITH BACKEND
    let coverImages = ["Sushi Love Background", "Dunkin Donuts Background", "Dames Background", "TGIF Background", "Hungry Leaf Background", "Mediterra Background"]
    let restaurantNames = ["Sushi Love", "Dunkin' Donuts", "Dames", "TGI Friday's", "Hungry Leaf", "Mediterra"]
    let cuisineTypes = ["Sushi", "Breakfast", "Chicken and Waffles", "American Bar and Grill", "Salad", "Greek"]
    let openHours = ["5:30PM - 10:30PM", "7:00AM - 11:00AM", "10:00AM - 5:00PM", "10:00AM - 8:00PM", "2:30PM - 6:30PM", "12:30PM - 5:30PM"]
    let isOpen = [true, false, false, true, true, true]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title
        self.title = "BringIt"
        
        // Set custom back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        /* MARK: - Dropdown Menu Setup
        var menuView: BTNavigationDropdownMenu!
        let items = ["Bring It", "Maid My Day"]
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.darkTextColor()]
        
        menuView = BTNavigationDropdownMenu(navigationController: self.navigationController, title: items[0], items: items)
        menuView.cellHeight = 55
        menuView.cellSeparatorColor = UIColor.lightGrayColor()
        menuView.cellBackgroundColor = self.navigationController?.navigationBar.barTintColor
        menuView.cellSelectionColor = GREEN
        menuView.keepSelectedCellColor = true
        menuView.cellTextLabelColor = UIColor.darkTextColor()
        menuView.cellTextLabelFont = TITLE_FONT
        menuView.cellTextLabelAlignment = .Center // .Center // .Right // .Left
        menuView.arrowPadding = 15
        menuView.animationDuration = 0.5
        menuView.maskBackgroundColor = UIColor.blackColor()
        menuView.maskBackgroundOpacity = 0.3
        menuView.arrowImage = UIImage(named: "arrowDown")
        menuView.didSelectItemAtIndexHandler = {(indexPath: Int) -> () in
            print("Did select item at index: \(indexPath)")
        }
        
        self.navigationItem.titleView = menuView*/
        
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
        return coverImages.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("bringItHomeCell", forIndexPath: indexPath) as! BringItHomeTableViewCell

        // Set up cell properties
        cell.restaurantBannerImage.image = UIImage(named: coverImages[indexPath.row])
        cell.restaurantNameLabel.text = restaurantNames[indexPath.row]
        cell.cuisineTypeLabel.text = cuisineTypes[indexPath.row]
        cell.restaurantHoursLabel.text = openHours[indexPath.row]
        if isOpen[indexPath.row] {
            cell.openClosedImage.image = UIImage(named: "Open")
        } else {
            cell.openClosedImage.image = UIImage(named: "Closed")
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "- RESTAURANTS -"
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor.whiteColor()
        header.textLabel!.textColor = UIColor.darkGrayColor()
        header.textLabel?.font = TV_HEADER_FONT
        header.textLabel?.textAlignment = .Center
    }
    
    // MARK: - Navigation
     
    @IBAction func returnHome(segue: UIStoryboardSegue) {
    }

}


