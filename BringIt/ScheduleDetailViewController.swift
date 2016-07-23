//
//  ScheduleDetailViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 7/1/16.
//  Copyright © 2016 Campus Enterprises. All rights reserved.
//

import UIKit

class ScheduleDetailViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var totalCostLabel: UILabel!
    @IBOutlet weak var myTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var orderView: UIView!
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    
    // Data structure
    struct Item {
        var name = ""
        var quantity = 0
        var price = 0.00
    }
    
    // FOR CHAD - Uncomment this when you finish the data loading
    // var items = [Item]()
    // FOR CHAD - Delete this when you finish the data loading
    let items = [Item(name: "The Carolina Cockerel", quantity: 2, price: 10.00), Item(name: "Chocolate Milkshake", quantity: 1, price: 4.99), Item(name: "Large Fries", quantity: 2, price: 3.00)]
    
    // MARK: - Variables
    var orderID = "" // Passed from previous view controller
    var date = "" // Passed from previous view controller
    var totalCost = 0.0
    var backgroundImageURL = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Start activity indicator
        myActivityIndicator.startAnimating()
        self.myActivityIndicator.hidden = false
        
        // Set title
        self.title = date
        
        // Set custom back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        // Calculate and display totalCost
        calculateTotalCost()
        totalCostLabel.text = String(format: "$%.2f", totalCost)
        
        // Add shadow to orderView
        orderView.layer.shadowColor = UIColor.darkGrayColor().CGColor
        orderView.layer.shadowOpacity = 0.5
        orderView.layer.shadowOffset = CGSizeZero
        orderView.layer.shadowRadius = 1
        
        
        // TO-DO: CHAD! Please load the background image of the restaurant that was ordered from!
        // backgroundImageView.image = // Insert image URL here

        // TO-DO: CHAD! Please load past order items into the tableview. This should be the exact same code as in checkoutViewController so copy and pasting should work!
        
        // Stop activity indicator
        //TO-DO: Place this so it is executed after the db request is made!
        self.myActivityIndicator.stopAnimating()
        self.myActivityIndicator.hidden = true
    }
    
    func calculateTotalCost() {
        for item in items {
            totalCost += Double(item.price) * Double(item.quantity)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func orderAgainButtonPressed(sender: UIButton) {
        // TO-DO: Chad! When this button is pressed, create a new cart with all the previously ordered items in it. We will load this cart in the next viewcontroller which will be the CheckoutViewController. From there, the user can make changes if needed and then use that viewcontroller as usual.
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCellWithIdentifier("checkoutCell", forIndexPath: indexPath) as! CheckoutTableViewCell
            
            cell.itemNameLabel.text = items[indexPath.row].name
            cell.itemQuantityLabel.text = String(items[indexPath.row].quantity)
            let totalItemCost = Double(items[indexPath.row].quantity) * items[indexPath.row].price
            cell.totalCostLabel.text = String(format: "%.2f", totalItemCost)
            
            return cell
    }
    
    // Resize itemsTableView
    override func updateViewConstraints() {
        super.updateViewConstraints()
        myTableViewHeight.constant = myTableView.contentSize.height
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
