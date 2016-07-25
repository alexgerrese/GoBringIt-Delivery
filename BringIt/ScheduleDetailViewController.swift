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
    @IBOutlet weak var deliveryFeeLabel: UILabel!
    @IBOutlet weak var subtotalCostLabel: UILabel!
    
    // FOR CHAD - Uncomment this when you finish the data loading
    // var items = [Item]()
    // FOR CHAD - Delete this when you finish the data loading
    //let items = [Item(name: "The Carolina Cockerel", quantity: 2, price: 10.00), Item(name: "Chocolate Milkshake", quantity: 1, price: 4.99), Item(name: "Large Fries", quantity: 2, price: 3.00)]
    
    // MARK: - Variables
    var order = Order()
    var items = [Item]()
    var date = ""
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
        
        // Add shadow to orderView
        orderView.layer.shadowColor = UIColor.darkGrayColor().CGColor
        orderView.layer.shadowOpacity = 0.5
        orderView.layer.shadowOffset = CGSizeZero
        orderView.layer.shadowRadius = 1
        
        
        // TO-DO: CHAD! Please load the background image of the restaurant that was ordered from!
        // backgroundImageView.image = // Insert image URL here

        items = order.items?.allObjects as! [Item]
        
        self.deliveryFeeLabel.text = String(format: "$%.2f", order.deliveryFee!)
        self.subtotalCostLabel.text = String(format: "$%.2f", Double(order.totalPrice!) - Double(order.deliveryFee!))
        self.totalCostLabel.text = String(format: "$%.2f", order.totalPrice!)
        
        // Stop activity indicator
        //TO-DO: Place this so it is executed after the db request is made!
        self.myActivityIndicator.stopAnimating()
        self.myActivityIndicator.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func orderAgainButtonPressed(sender: UIButton) {
        // TO-DO: Chad! When this button is pressed, create a new cart with all the previously ordered items in it. We will load this cart in the next viewcontroller which will be the CheckoutViewController. From there, the user can make changes if needed and then use that viewcontroller as usual.
    }
    
    // MARK: - Table view data source
    
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCellWithIdentifier("checkoutCell", forIndexPath: indexPath) as! CheckoutTableViewCell
            
            // Set name and quantity labels
            cell.itemNameLabel.text = items[indexPath.row].name
            cell.itemQuantityLabel.text = String(items[indexPath.row].quantity!)
            
            // Calculate total item cost
            var totalItemCost = 0.0
            var costOfSides = 0.0
            for side in items[indexPath.row].sides?.allObjects as! [Side] {
                costOfSides += Double(side.price!)
            }
            totalItemCost += (Double(items[indexPath.row].price!) + costOfSides) * Double(items[indexPath.row].quantity!)
            cell.totalCostLabel.text = String(format: "%.2f", totalItemCost)
            
            // Format all sides and extras
            var sides = "Sides: "
            var extras = "Extras: "
            let allSides = items[indexPath.row].sides?.allObjects as! [Side]
            for i in 0..<allSides.count {
                if ((allSides[i].isRequired) == true) {
                    if i < allSides.count - 1 {
                        sides += allSides[i].name! + ", "
                    } else {
                        sides += allSides[i].name!
                    }
                } else {
                    if i < allSides.count - 1 {
                        extras += allSides[i].name! + ", "
                    } else {
                        extras += allSides[i].name!
                    }
                }
            }
            if sides == "Sides: " {
                sides += "None"
            }
            if extras == "Extras: " {
                extras += "None"
            }
            
            // Format special instructions
            var specialInstructions = "Special Instructions: "
            if items[indexPath.row].specialInstructions != "" {
                specialInstructions += items[indexPath.row].specialInstructions!
            } else {
                specialInstructions += "None"
            }
            
            // Create attributed strings of the extras
            var sidesAS = NSMutableAttributedString()
            var extrasAS = NSMutableAttributedString()
            var specialInstructionsAS = NSMutableAttributedString()
            
            sidesAS = NSMutableAttributedString(
                string: sides,
                attributes: [NSFontAttributeName:UIFont(
                    name: "Avenir",
                    size: 13.0)!])
            extrasAS = NSMutableAttributedString(
                string: extras,
                attributes: [NSFontAttributeName:UIFont(
                    name: "Avenir",
                    size: 13.0)!])
            specialInstructionsAS = NSMutableAttributedString(
                string: specialInstructions,
                attributes: [NSFontAttributeName:UIFont(
                    name: "Avenir",
                    size: 13.0)!])
            
            sidesAS.addAttribute(NSFontAttributeName,
                                 value: UIFont(
                                    name: "Avenir-Heavy",
                                    size: 13.0)!,
                                 range: NSRange(
                                    location: 0,
                                    length: 6))
            extrasAS.addAttribute(NSFontAttributeName,
                                  value: UIFont(
                                    name: "Avenir-Heavy",
                                    size: 13.0)!,
                                  range: NSRange(
                                    location: 0,
                                    length: 7))
            specialInstructionsAS.addAttribute(NSFontAttributeName,
                                               value: UIFont(
                                                name: "Avenir-Heavy",
                                                size: 13.0)!,
                                               range: NSRange(
                                                location: 0,
                                                length: 21))
            
            cell.sidesLabel.attributedText = sidesAS
            cell.extrasLabel.attributedText = extrasAS
            cell.specialInstructionsLabel.attributedText = specialInstructionsAS
            
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
