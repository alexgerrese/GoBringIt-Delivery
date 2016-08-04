//
//  RestaurantTableViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/16/16.
//  Copyright © 2016 Campus Enterprises. All rights reserved.
//

import UIKit

class RestaurantTableViewController: UITableViewController {
    
    @IBOutlet weak var restaurantNameLabel: UILabel!
    @IBOutlet weak var restaurantBackgroundImage: UIImageView!
    @IBOutlet weak var cuisineTypeLabel: UILabel!
    @IBOutlet weak var restaurantHoursLabel: UILabel!
    @IBOutlet weak var isOpenIndicator: UIImageView!
    @IBOutlet weak var detailsView: UIView!
    
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
        
        // Set title
        self.title = restaurantName
        restaurantNameLabel.text = restaurantName.uppercaseString
        
        self.cuisineTypeLabel.text = restaurantType
        
        //let url = NSURL(string: restaurantImageURL)
        //let data = NSData(contentsOfURL: url!)
        self.restaurantBackgroundImage.image = UIImage(data: restaurantImageData)
        
        // Set tableView cells to custom height and automatically resize if needed
        tableView.estimatedRowHeight = 50
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        // Set custom back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        // Add shadow to detailsView
        detailsView.layer.shadowColor = UIColor.darkGrayColor().CGColor
        detailsView.layer.shadowOpacity = 0.5
        detailsView.layer.shadowOffset = CGSizeZero
        detailsView.layer.shadowRadius = 1.5
        
        // Open Connection to PHP Service
        let requestURL: NSURL = NSURL(string: "http://www.gobring.it/CHADmenuCategories.php")!
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
                                
                                let service_id = Restaurant["service_id"] as! String
                                
                                if (service_id == self.restaurantID) {
                                    let name = Restaurant["name"] as! String
                                    self.menuCategories.append(name)
                                    self.idList.append(service_id)
                                    let id = Restaurant["id"] as! String
                                    self.menuID.append(id)
                                }
                            }
                            
                            NSOperationQueue.mainQueue().addOperationWithBlock {
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
                            
                            for Restaurant in json as! [Dictionary<String, AnyObject>] {
                                
                                let restaurant_id = Restaurant["restaurant_id"] as? String
                                
                                if (restaurant_id == self.restaurantID) {
                                    

                                    
                                    let all_hours = Restaurant["open_hours"] as! String
                                    let hours_byDay = all_hours.componentsSeparatedByString(", ")
                                    
                                    let currentCalendar = NSCalendar.currentCalendar()
                                    let currentDate = NSDate()
                                    let localDate = NSDate(timeInterval: NSTimeInterval(NSTimeZone.systemTimeZone().secondsFromGMT), sinceDate: currentDate)
                                    let components = currentCalendar.components([.Year, .Month, .Day, .TimeZone, .Hour, .Minute], fromDate: localDate)
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
                                    //print(convertedDate)
                                    
                                    var openDate : Float? = nil
                                    var closeDate : Float? = nil
                                    
                                    for i in 0..<hours_byDay.count {
                                        if (hours_byDay[i].rangeOfString(convertedDate) != nil) {
                                            self.open_hours = hours_byDay[i]
                                            
                                            // Extract exact hours of operation for this day
                                            var hours_pieces = hours_byDay[i].componentsSeparatedByString(" ");
                                            for j in 0..<hours_pieces.count {
                                                
                                                // Find time pieces (not the Day, not the "-", just the "time + am" or "time + pm")
                                                if ((hours_pieces[j].rangeOfString(convertedDate) == nil) && (hours_pieces[j].rangeOfString("-") == nil)) {
                                                    
                                                    let dateMaker = NSDateFormatter()
                                                    dateMaker.dateFormat = "yyyy/MM/dd HH:mm:ss"
                                                    //let components = currentCalendar.components([.Year, .Month, .Day, .TimeZone], fromDate: localDate)
                                                    
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
                                                self.isOpen = true;
                                            } else {
                                                print("close")
                                                self.isOpen = false;
                                            }
                                        }
                                    }
                                }
                            }
                            
                            NSOperationQueue.mainQueue().addOperationWithBlock {
                                if (self.isOpen) {
                                    self.isOpenIndicator.image = UIImage(named: "oval-green");
                                } else {
                                    self.isOpenIndicator.image = UIImage(named: "oval-red");
                                }
                                self.restaurantHoursLabel.text = self.open_hours
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
        
        task1.resume()
        
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
        } else {
            let indexPath = tableView.indexPathForSelectedRow?.row
            let destination = segue.destinationViewController as? MenuTableViewController
            destination?.titleCell = menuCategories[indexPath!]
            destination?.titleID = menuID[indexPath!]
        }
    }
    
}