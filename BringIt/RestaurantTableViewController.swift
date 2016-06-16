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
    //@IBOutlet weak var openClosedLabel: UILabel!
    @IBOutlet weak var isOpenIndicator: UIImageView!
    
    // Categories
    var restaurantName = String();
    var restaurantID = String();
    var restaurantType = String();
    var restaurantHours = String();
    var open_hours = String();
    var menuCategories = [String]()
    var menuID = [String]()
    var idList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set SAMPLE title
        self.title = restaurantName
        self.cuisineTypeLabel.text = restaurantType
        
        // Set tableView cells to custom height and automatically resize if needed
        tableView.estimatedRowHeight = 50
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        // Set custom back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
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
                                    self.open_hours = Restaurant["open_hours"] as! String
                                    
                                }
                            }
                            
                            NSOperationQueue.mainQueue().addOperationWithBlock {
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
