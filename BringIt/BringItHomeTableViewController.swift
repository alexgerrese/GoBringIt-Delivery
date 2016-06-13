//
//  BringItHomeTableViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/16/16.
//  Copyright © 2016 Campus Enterprises. All rights reserved.
//

import UIKit

class BringItHomeTableViewController: UITableViewController {
    
    // MARK: - SAMPLE DATA - CHAD REPLACE WITH BACKEND
    
    /* The best way to do this would be to grab it from the database and store it in an array of objects like below. If you use the same variable names, they should automatically work with the front end.
     NOTE: Here, the "images" are actually just image names referencing locally stored images. If we are pulling images from the DB (we'll talk about this later cuz we need new pictures), we will need to change a couple of things.
     NOTE 2: isOpen will need to be calculated on the fly, but we need to deal with the format of the open hours so our app understands what each time means, and this will take a bit of time later. */
    
    // Create struct to organize data
    struct Restaurant {
        var coverImage: String
        var restaurantName: String
        var cuisineType: String
        var openHours: String
        var isOpen: Bool
    }
    
    // Create empty array of Restaurants to be filled in ViewDidLoad
    var restaurants: [Restaurant] = []
    
    // SAMPLE DATA (pay no attention to this Chad)
    let coverImages = ["Sushi Love Background", "Dunkin Donuts Background", "Dames Background", "TGIF Background", "Hungry Leaf Background", "Mediterra Background"]
    let restaurantNames = ["Sushi Love", "Dunkin' Donuts", "Dames", "TGI Friday's", "Hungry Leaf", "Mediterra"]
    let cuisineTypes = ["Sushi", "Breakfast", "Chicken and Waffles", "American Bar and Grill", "Salad", "Greek"]
    let openHours = ["5:30PM - 10:30PM", "7:00AM - 11:00AM", "10:00AM - 5:00PM", "10:00AM - 8:00PM", "2:30PM - 6:30PM", "12:30PM - 5:30PM"]
    let isOpen = [true, false, false, true, true, true]
    
    let defaults = NSUserDefaults.standardUserDefaults()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title
        self.title = "BringIt"
        
        // Set custom back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        // CHAD: Loop through DB data and append Restaurant objects into restaurants array
        for i in 0..<coverImages.count {
            restaurants.append(Restaurant(coverImage: coverImages[i], restaurantName: restaurantNames[i], cuisineType: cuisineTypes[i], openHours: openHours[i], isOpen: isOpen[i]))
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
        return restaurants.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("bringItHomeCell", forIndexPath: indexPath) as! BringItHomeTableViewCell

        // Set up cell properties
        cell.restaurantBannerImage.image = UIImage(named: restaurants[indexPath.row].coverImage)
        cell.restaurantNameLabel.text = restaurants[indexPath.row].restaurantName
        cell.cuisineTypeLabel.text = restaurants[indexPath.row].cuisineType
        cell.restaurantHoursLabel.text = restaurants[indexPath.row].openHours
        if restaurants[indexPath.row].isOpen {
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
        //header.contentView.backgroundColor = UIColor.whiteColor()
        header.textLabel!.textColor = UIColor.darkGrayColor()
        header.textLabel?.font = TV_HEADER_FONT
        header.textLabel?.textAlignment = .Center
    }
    
    // MARK: - Navigation
    
    @IBAction func returnHome(segue: UIStoryboardSegue) {
    }

}


