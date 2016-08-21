//
//  OrderPlacedViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 7/1/16.
//  Copyright © 2016 Campus Enterprises. All rights reserved.
//

import UIKit

class OrderPlacedViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var orderTotalLabel: UILabel!
    
    // MARK: - Variables
    var passedOrderTotal = 0.0
    var passedRestaurantName = ""
    
    // Set up userDefaults
    let defaults = NSUserDefaults.standardUserDefaults()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title
        self.title = "Thank You!"
        
        // Set nav bar preferences
        self.navigationController?.navigationBar.tintColor = UIColor.darkGrayColor()
        navigationController!.navigationBar.titleTextAttributes =
            ([NSFontAttributeName: TITLE_FONT,
                NSForegroundColorAttributeName: UIColor.blackColor()])
        
        // Set order total label
        orderTotalLabel.text = "Including delivery fee, you spent \(String(format: "$%.2f", passedOrderTotal)) at \(passedRestaurantName)."
        
        updateFirstOrderStatus()

        // Do any additional setup after loading the view.
    }

    @IBAction func finishAndClosedButtonPressed(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
        comingFromOrderPlaced = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateFirstOrderStatus() {
        let userID = defaults.objectForKey("userID")
        let alreadyOrdered = defaults.boolForKey("alreadyOrdered")
        
        if !alreadyOrdered {
            // Update value to false in userDefaults
            defaults.setBool(true, forKey: "alreadyOrdered")
            print("This was the user's first order")
            
            // Update value on db
            // Create JSON data and configure the request
            let params = ["uid": userID as! String,
                "already_ordered": "1"]
                as Dictionary<String, String>
            
            // create the request & response
            let request = NSMutableURLRequest(URL: NSURL(string: "http://www.gobring.it/CHADupdateFirstOrder.php")!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 15)
            
            do {
                let jsonData = try NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions.PrettyPrinted)
                request.HTTPBody = jsonData
            } catch let error as NSError {
                print(error)
            }
            request.HTTPMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // send the request
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request) {
                (let data, let response, let error) in
            }
            
            task.resume()
        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
