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
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title
        self.title = "Thank You!"
        
        // Set nav bar preferences
        self.navigationController?.navigationBar.tintColor = UIColor.darkGray
        navigationController!.navigationBar.titleTextAttributes =
            ([NSFontAttributeName: TITLE_FONT,
                NSForegroundColorAttributeName: UIColor.black])
        
        // Set order total label
        orderTotalLabel.text = "Including delivery fee and tip, you spent \(String(format: "$%.2f", passedOrderTotal)) at \(passedRestaurantName)."
        
        updateFirstOrderStatus()

        // Do any additional setup after loading the view.
    }

    @IBAction func finishAndClosedButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        comingFromOrderPlaced = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateFirstOrderStatus() {
        let userID = defaults.object(forKey: "userID")
        let alreadyOrdered = defaults.bool(forKey: "alreadyOrdered")
        
        if !alreadyOrdered {
            // Update value to false in userDefaults
            defaults.set(true, forKey: "alreadyOrdered")
            print("This was the user's first order")
            
            // Update value on db
            // Create JSON data and configure the request
            let params = ["uid": userID as! String,
                "already_ordered": "1"]
                as Dictionary<String, String>
            
            // create the request & response
            var request = URLRequest(url: URL(string: "http://www.gobringit.com/CHADupdateFirstOrder.php")!, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 15)
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions.prettyPrinted)
                request.httpBody = jsonData
            } catch let error as NSError {
                print(error)
            }
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // send the request
            let session = URLSession.shared
            let task = session.dataTask(with: request, completionHandler: {
                (data, response, error) in
            }) 
            
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
