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
        // Added by Chad for DB purposes
        var id: String
    }
    
    // Create empty array of Restaurants to be filled in ViewDidLoad
    var restaurants: [Restaurant] = []
    
    // DB DATA
    var coverImages = [String]()
    var restaurantNames = [String]()
    var cuisineTypes = [String]()
    //TODO
    let openHours = ["5:30PM - 10:30PM", "7:00AM - 11:00AM", "10:00AM - 5:00PM", "10:00AM - 8:00PM", "2:30PM - 6:30PM", "12:30PM - 5:30PM"]
    let isOpen = [true, false, false, true, true, true]
    var idList = [String]()
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title
        self.title = "BringIt"
        
        // Set custom back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        // get list of coverImages, restaurantNames, id
        
        // Open Connection to PHP Service
        let requestURL: NSURL = NSURL(string: "http://www.gobring.it/CHADrestaurantImage.php")!
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
                            
                            for Restaurant in json as! [Dictionary<String, AnyObject>] {
                                let image = Restaurant["image"] as! String
                                self.coverImages.append(image)
                                let name = Restaurant["name"] as! String
                                self.restaurantNames.append(name)
                                let type = Restaurant["type"] as! String
                                self.cuisineTypes.append(type)
                                let idHere = Restaurant["id"] as! String
                                self.idList.append(idHere)
                            }
                            
                            NSOperationQueue.mainQueue().addOperationWithBlock {
                                for i in 0..<self.coverImages.count {
                                    self.restaurants.append(Restaurant(coverImage: self.coverImages[i], restaurantName: self.restaurantNames[i], cuisineType: self.cuisineTypes[i], openHours: self.openHours[i], isOpen: self.isOpen[i], id: self.idList[i]))
                                }
                                self.tableView.reloadData()
                            }
                        }
                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
        
        task.resume()
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
        let url = NSURL(string: "http://www.gobring.it/images/" + restaurants[indexPath.row].coverImage)
        let data = NSData(contentsOfURL: url!)
        cell.restaurantBannerImage.image = UIImage(data: data!)
        cell.restaurantNameLabel.text = restaurants[indexPath.row].restaurantName.uppercaseString
        cell.cuisineTypeLabel.text = restaurants[indexPath.row].cuisineType
        cell.restaurantHoursLabel.text = restaurants[indexPath.row].openHours
        if restaurants[indexPath.row].isOpen {
            cell.openClosedImage.image = UIImage(named: "Open")
        } else {
            cell.openClosedImage.image = UIImage(named: "Closed")
        }
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        
        let indexPath = tableView.indexPathForSelectedRow?.row
        let destination = segue.destinationViewController as? RestaurantTableViewController
        destination?.restaurantName = restaurants[indexPath!].restaurantName
        destination?.restaurantID = restaurants[indexPath!].id
        destination?.restaurantType = restaurants[indexPath!].cuisineType
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


