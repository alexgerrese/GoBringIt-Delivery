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
    var openRestaurants: [Restaurant] = []
    var closedRestaurants: [Restaurant] = []
    
    // DB DATA
    var coverImages = [String]()
    var restaurantNames = [String]()
    var cuisineTypes = [String]()
    var openHours = [String]()
    var isOpen = [Bool]()
    var idList = [String]()
    
    var showThanksMessage = false
   // var showThanksMessageIndexPath: NSindex
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(defaults.objectForKey("userID"))
        
        // Set title
        self.navigationItem.title = "BringIt"
        
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
        
        // Set tableView cells to custom height and automatically resize if needed
        //self.imageHeight.constant = UIScreen.mainScreen().bounds.height * 0.25
        self.myTableView.estimatedRowHeight = 235
        self.myTableView.rowHeight = UITableViewAutomaticDimension
        
        // initial position
        maxY = view.bounds.maxY - indicatorHeight
        updateTabbarIndicatorBySelectedTabIndex(0)
        
        // Check if should show thanksMessageLabel
        showThanksMessage = checkShowThanksMessage()
        
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
                                
                                self.reorganizeRestaurants()
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
                                

                                //let restaurant_id = Restaurant["restaurant_id"] as? String

                                    let all_hours = Restaurant["open_hours"] as! String
                                    let hours_byDay = all_hours.componentsSeparatedByString(", ")
                                    
                                    let currentCalendar = NSCalendar.currentCalendar()
                                    let currentDate = NSDate()
                                    let localDate = NSDate(timeInterval: NSTimeInterval(NSTimeZone.systemTimeZone().secondsFromGMT), sinceDate: currentDate)
                                    let components = currentCalendar.components([.Year, .Month, .Day, .TimeZone, .Hour, .Minute], fromDate: currentDate)
                                    print(currentDate)
                                    print(localDate)
                                    let componentTime : Float = Float(components.hour) + Float(components.minute) / 60
                                    var estTime : Float
                                    if (componentTime > 4) {
                                        estTime = componentTime
                                    } else {
                                        estTime = componentTime
                                    }
                                    
                                    let dateFormatter = NSDateFormatter()
                                    dateFormatter.locale = NSLocale.currentLocale()
                                    dateFormatter.dateFormat = "EEEE"
                                    let convertedDate = dateFormatter.stringFromDate(currentDate)
                                    
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
                                                            if time_pieces[0] == "12" {
                                                                newTime = Float(time_pieces[0])
                                                            } else {
                                                                newTime = Float(time_pieces[0])! + 12
                                                            }
                                                            
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
                                                            if time_pieces[0] == "12" {
                                                                newTime = Float(hour_minute[0])
                                                            } else {
                                                                newTime = Float(hour_minute[0])! + 12
                                                            }

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
                                                        //print("The close time is: ", newTime?)
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
                                
                                print(openDate)
                                print(closeDate)
                                print(estTime)
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
    
    func reorganizeRestaurants() {
        for r in restaurants {
            if r.isOpen {
                openRestaurants.append(r)
            } else {
                closedRestaurants.append(r)
            }
        }
    }
    
    func checkShowThanksMessage() -> Bool {
        if let alreadyOrdered = self.defaults.objectForKey("alreadyOrdered") {
            if (alreadyOrdered as! Bool){
                return false
            }
        }
        if let shown = self.defaults.objectForKey("thanksMessageShown") {
            if shown as! Bool {
                return false
            }
        }
        return true
    }
    
    func xButtonPressed(button: UIButton) {
        let indexPath = NSIndexPath(forItem: 0, inSection: 0)
        showThanksMessage = false
        myTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        self.defaults.setObject(true, forKey: "thanksMessageShown")
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
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if showThanksMessage {
                return 1
            }
            return 0
        } else if section == 1 {
            return openRestaurants.count
        } else {
            return closedRestaurants.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("thanksCell", forIndexPath: indexPath) as! ThanksTableViewCell
            
            cell.gotItButton.addTarget(self, action: #selector(BringItHomeViewController.xButtonPressed(_:)), forControlEvents: .TouchUpInside)
            
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("bringItHomeCell", forIndexPath: indexPath) as! BringItHomeTableViewCell
            
            cell.restaurantBannerImage.image = UIImage(data: openRestaurants[indexPath.row].coverImage)
            cell.cuisineTypeLabel.text = openRestaurants[indexPath.row].cuisineType
            cell.restaurantHoursLabel.text = openRestaurants[indexPath.row].openHours
            /*if isOpen[indexPath.row] {
                cell.openClosedImage.image = UIImage(named: "Open")
            } else {
                cell.openClosedImage.image = UIImage(named: "Closed")
            }*/
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("bringItHomeCell", forIndexPath: indexPath) as! BringItHomeTableViewCell
            
            cell.restaurantBannerImage.image = UIImage(data: closedRestaurants[indexPath.row].coverImage)
            cell.cuisineTypeLabel.text = closedRestaurants[indexPath.row].cuisineType
            cell.restaurantHoursLabel.text = closedRestaurants[indexPath.row].openHours
            /*if isOpen[indexPath.row] {
                cell.openClosedImage.image = UIImage(named: "Open")
            } else {
                cell.openClosedImage.image = UIImage(named: "Closed")
            }*/
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.section == 1 {
            selectedRestaurantName = openRestaurants[indexPath.row].restaurantName
        } else if indexPath.section == 2 {
            selectedRestaurantName = closedRestaurants[indexPath.row].restaurantName
        }
        
        return indexPath
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return ""
        } else if section == 1 {
            return "- Open Restaurants -"
        } else {
            return "- Closed Restaurants -"
        }
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "Avenir-Black", size: 15)!
        header.textLabel?.textColor = UIColor.darkGrayColor()
        header.textLabel?.textAlignment = .Center
        header.backgroundView?.backgroundColor = UIColor.groupTableViewBackgroundColor()
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return 25
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        let nav = segue.destinationViewController as! UINavigationController
        let VC = nav.topViewController as! RestaurantViewController
        
        let indexPath = myTableView.indexPathForSelectedRow
        //let destination = segue.destinationViewController as? RestaurantTableViewController
        if indexPath?.section == 1 {
            VC.restaurantImageData = openRestaurants[indexPath!.row].coverImage
            VC.restaurantName = openRestaurants[indexPath!.row].restaurantName
            VC.restaurantID = openRestaurants[indexPath!.row].id
            VC.restaurantType = openRestaurants[indexPath!.row].cuisineType
        } else if indexPath?.section == 2 {
            VC.restaurantImageData = closedRestaurants[indexPath!.row].coverImage;
            VC.restaurantName = closedRestaurants[indexPath!.row].restaurantName
            VC.restaurantID = closedRestaurants[indexPath!.row].id
            VC.restaurantType = closedRestaurants[indexPath!.row].cuisineType
        }
        
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


