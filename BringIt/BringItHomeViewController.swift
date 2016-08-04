//
//  BringItHomeTableViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/16/16.
//  Copyright © 2016 Campus Enterprises. All rights reserved.
//

import UIKit

var selectedRestaurantName = ""

class BringItHomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - IBOutlets
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var loadingRestaurantsIcon: UIImageView!
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    
    // Variables
    let rectShape = CAShapeLayer()
    let indicatorHeight: CGFloat = 3
    var indicatorWidth: CGFloat!
    let indicatorBottomMargin: CGFloat = 2
    let indicatorLeftMargin: CGFloat = 2
    var maxY: CGFloat!
    
    // MARK: - SAMPLE DATA - CHAD REPLACE WITH BACKEND
    
    /* The best way to do this would be to grab it from the database and store it in an array of objects like below. If you use the same variable names, they should automatically work with the front end.
     NOTE: Here, the "images" are actually just image names referencing locally stored images. If we are pulling images from the DB (we'll talk about this later cuz we need new pictures), we will need to change a couple of things.
     NOTE 2: isOpen will need to be calculated on the fly, but we need to deal with the format of the open hours so our app understands what each time means, and this will take a bit of time later. */
    
    // Create struct to organize data
    struct Restaurant {
        var coverImage: NSData
        var restaurantName: String
        var cuisineType: String
        var openHours: String
        var isOpen: Bool
        var id: String
    }
    
    // Create empty array of Restaurants to be filled in ViewDidLoad
    var restaurants: [Restaurant] = []
    
    // DB DATA
    var coverImages = [String]()
    var restaurantNames = [String]()
    var cuisineTypes = [String]()
    
    //TODO: CHAD! This is still reliant on sample data. Please pull these from the database!!! Essentially do what you did in the restaurantVC but for each restaurant in the tableview!
    var openHours = [String]()
    var isOpen = [Bool]()
    var idList = [String]()
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title
        self.navigationItem.title = "Restaurants"
        
        // Set custom back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        // Set nav bar preferences
        self.navigationController?.navigationBar.tintColor = UIColor.darkGrayColor()
        navigationController!.navigationBar.titleTextAttributes =
            ([NSFontAttributeName: TITLE_FONT,
                NSForegroundColorAttributeName: UIColor.blackColor()])
        
        // Start activity indicator and show loading icon
        myActivityIndicator.startAnimating()
        self.myActivityIndicator.hidden = false
        loadingRestaurantsIcon.hidden = false
        myTableView.hidden = true
        
        // setup tabbar indicator
        rectShape.fillColor = GREEN.CGColor
        indicatorWidth = view.bounds.maxX / 3 // count of items
        self.tabBarController!.view.layer.addSublayer(rectShape)
        self.tabBarController?.delegate = self
        
        // initial position
        maxY = view.bounds.maxY - indicatorHeight
        updateTabbarIndicatorBySelectedTabIndex(0)
        
        // Get list of coverImages, restaurantNames, id
        
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
                                    
                                    // Get image data
                                    let url = NSURL(string: "http://www.gobring.it/images/" + self.coverImages[i])
                                    let data = NSData(contentsOfURL: url!)
                                    
                                    self.restaurants.append(Restaurant(coverImage: data!, restaurantName: self.restaurantNames[i], cuisineType: self.cuisineTypes[i], openHours: self.openHours[i], isOpen: self.isOpen[i], id: self.idList[i]))
                                }
                                

                                self.myTableView.reloadData()
                                
                                // Show tableview, end activity indicator and hide loading icon
                                self.myTableView.hidden = false
                                self.loadingRestaurantsIcon.hidden = true
                                self.myActivityIndicator.stopAnimating()
                                self.myActivityIndicator.hidden = true
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
        
        // Get restaurant hours
        
        // Open Connection to PHP Service
        let requestURL1: NSURL = NSURL(string: "http://www.gobring.it/CHADrestaurantHours.php")!
        let urlRequest1: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL1)
        let session1 = NSURLSession.sharedSession()
        let task1 = session1.dataTaskWithRequest(urlRequest1) { (data, response, error) -> Void in
            if let data = data {
                do {
                    let httpResponse = response as! NSHTTPURLResponse
                    let statusCode = httpResponse.statusCode
                    
                    // Check HTTP Response
                    if (statusCode == 200) {
                        
                        do{
                            // Parse JSON
                            let json = try NSJSONSerialization.JSONObjectWithData(data, options:.AllowFragments)
                            
                            var count = 0
                            self.openHours.append("")
                            self.isOpen.append(false)
                            for Restaurant in json as! [Dictionary<String, AnyObject>] {
                                

                                let restaurant_id = Restaurant["restaurant_id"] as? String

                                    let all_hours = Restaurant["open_hours"] as! String
                                    let hours_byDay = all_hours.componentsSeparatedByString(", ")
                                    
                                    let currentCalendar = NSCalendar.currentCalendar()
                                    let currentDate = NSDate()
                                    let localDate = NSDate(timeInterval: NSTimeInterval(NSTimeZone.systemTimeZone().secondsFromGMT), sinceDate: currentDate)
                                    let components = currentCalendar.components([.Year, .Month, .Day, .TimeZone, .Hour, .Minute], fromDate: localDate)
                                    print(currentDate)
                                    print(localDate)
                                    let componentTime : Float = Float(components.hour - 17) + Float(components.minute) / 60
                                    var estTime : Float
                                    if (componentTime > 4) {
                                        estTime = componentTime + 20 - 24
                                    } else {
                                        estTime = componentTime + 20
                                    }
                                    
                                    let dateFormatter = NSDateFormatter()
                                    dateFormatter.locale = NSLocale.currentLocale()
                                    dateFormatter.dateFormat = "EEEE"
                                    let convertedDate = dateFormatter.stringFromDate(localDate)
                                    
                                    var openDate : Float? = nil
                                    var closeDate : Float? = nil
                                    
                                    for i in 0..<hours_byDay.count {
                                        if (hours_byDay[i].rangeOfString(convertedDate) != nil) {
                                            self.openHours[count] = hours_byDay[i]
                                            
                                            // Extract exact hours of operation for this day
                                            var hours_pieces = hours_byDay[i].componentsSeparatedByString(" ");
                                            for j in 0..<hours_pieces.count {
                                                
                                                // Find time pieces (not the Day, not the "-", just the "time + am" or "time + pm")
                                                if ((hours_pieces[j].rangeOfString(convertedDate) == nil) && (hours_pieces[j].rangeOfString("-") == nil)) {
                                                    
                                                    let dateMaker = NSDateFormatter()
                                                    dateMaker.dateFormat = "yyyy/MM/dd HH:mm:ss"
                                                    
                                                    if (openDate == nil) {
                                                        var newTime : Float? = nil
                                                        var minuteTime : Float? = nil
                                                        if (hours_pieces[j].rangeOfString("pm") != nil) {
                                                            let time_pieces = hours_pieces[j].componentsSeparatedByString("pm");
                                                            let hour_minute = time_pieces[0].componentsSeparatedByString(":");
                                                            newTime = Float(time_pieces[0])! + 12
                                                            if (hour_minute.count > 1) {
                                                                minuteTime = Float(hour_minute[1])
                                                            }
                                                        }
                                                        if (hours_pieces[j].rangeOfString("am") != nil) {
                                                            let time_pieces = hours_pieces[j].componentsSeparatedByString("am");
                                                            let hour_minute = time_pieces[0].componentsSeparatedByString(":");
                                                            newTime = Float(time_pieces[0])!
                                                            if (hour_minute.count > 1) {
                                                                minuteTime = Float(hour_minute[1])
                                                            }
                                                        }
                                                        if (minuteTime != nil) {
                                                            let minuteDecimal : Float = Float(minuteTime!)/60.0
                                                            newTime = newTime! + minuteDecimal
                                                        }
                                                        print("The open time is: ", newTime!)
                                                        openDate = newTime!
                                                    } else if (closeDate == nil) {
                                                        var newTime : Float? = nil
                                                        var minuteTime : Float? = nil
                                                        if (hours_pieces[j].rangeOfString("pm") != nil) {
                                                            let time_pieces = hours_pieces[j].componentsSeparatedByString("pm");
                                                            let hour_minute = time_pieces[0].componentsSeparatedByString(":");
                                                            newTime = Float(hour_minute[0])! + 12
                                                            if (hour_minute.count > 1) {
                                                                minuteTime = Float(hour_minute[1])
                                                            }
                                                        }
                                                        if (hours_pieces[j].rangeOfString("am") != nil) {
                                                            let time_pieces = hours_pieces[j].componentsSeparatedByString("am");
                                                            let hour_minute = time_pieces[0].componentsSeparatedByString(":");
                                                            newTime = Float(hour_minute[0])!
                                                            if (hour_minute.count > 1) {
                                                                minuteTime = Float(hour_minute[1])
                                                            }
                                                        }
                                                        if (minuteTime != nil) {
                                                            let minuteDecimal : Float = Float(minuteTime!)/60.0
                                                            newTime = newTime! + minuteDecimal
                                                        }
                                                        print("The close time is: ", newTime!)
                                                        closeDate = newTime!
                                                    }
                                                }
                                            }
                                            
                                            // Check if localDate is between openDate and closeDate
                                            if (estTime > openDate && estTime < closeDate) {
                                                print("open")
                                                self.isOpen[count] = true;
                                            } else {
                                                print("close")
                                                self.isOpen[count] = false;
                                            }
                                        }
                                    }
                                
                                print(count)
                                print(self.openHours[count])
                                print(self.isOpen[count])
                                
                                
                                //Update count
                                count += 1
                                // Add space in arrays
                                self.isOpen.append(false)
                                self.openHours.append("")

                                }
                            NSOperationQueue.mainQueue().addOperationWithBlock {
                                
                                for i in self.openHours {
                                    print(i)
                                }
                                
                                // Only create list of actual sides after the ID's have been collected
                                task.resume()
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
        
        task1.resume()
    }
    
    override func viewWillAppear(animated: Bool) {
        updateTabbarIndicatorBySelectedTabIndex(0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateTabbarIndicatorBySelectedTabIndex(index: Int) -> Void
    {
        let updatedBounds = CGRect( x: CGFloat(index) * (indicatorWidth + indicatorLeftMargin),
                                    y: maxY,
                                    width: indicatorWidth - indicatorLeftMargin,
                                    height: indicatorHeight)
        
        print(view.bounds.maxY - indicatorHeight)
        
        let path = CGPathCreateMutable()
        CGPathAddRect(path, nil, updatedBounds)
        rectShape.path = path
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return restaurants.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("bringItHomeCell", forIndexPath: indexPath) as! BringItHomeTableViewCell

        cell.restaurantBannerImage.image = UIImage(data: restaurants[indexPath.row].coverImage)
        cell.restaurantNameLabel.text = restaurants[indexPath.row].restaurantName.uppercaseString
        cell.cuisineTypeLabel.text = restaurants[indexPath.row].cuisineType
        cell.restaurantHoursLabel.text = openHours[indexPath.row + 1]
        if restaurants[indexPath.row].isOpen {
            cell.openClosedImage.image = UIImage(named: "Open")
        } else {
            cell.openClosedImage.image = UIImage(named: "Closed")
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        selectedRestaurantName = restaurants[indexPath.row].restaurantName
        
        return indexPath
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        let indexPath = myTableView.indexPathForSelectedRow?.row
        let destination = segue.destinationViewController as? RestaurantTableViewController
        destination?.restaurantImageData = restaurants[indexPath!].coverImage;
        destination?.restaurantName = restaurants[indexPath!].restaurantName
        destination?.restaurantID = restaurants[indexPath!].id
        destination?.restaurantType = restaurants[indexPath!].cuisineType
    }
    
    /*override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "- RESTAURANTS -"
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        //header.contentView.backgroundColor = UIColor.whiteColor()
        header.textLabel!.textColor = UIColor.darkGrayColor()
        header.textLabel?.font = TV_HEADER_FONT
        header.textLabel?.textAlignment = .Center
    }*/
    
    // MARK: - Navigation
    
    @IBAction func returnHome(segue: UIStoryboardSegue) {
    }
    
}

extension BringItHomeViewController: UITabBarControllerDelegate {
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        updateTabbarIndicatorBySelectedTabIndex(tabBarController.selectedIndex)
    }
}


