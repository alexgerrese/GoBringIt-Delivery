//
//  DeliverToPayingWithTableViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 7/1/16.
//  Copyright © 2016 Campus Enterprises. All rights reserved.
//

import UIKit

struct Address {
    var address: String
    var selected: Bool
}

class DeliverToPayingWithViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var addNewButton: UIButton!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var pageTitleLabel: UILabel!
    @IBOutlet weak var myTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    // MARK: - SAMPLE DATA
    
    struct PaymentMethod {
        var method: String
        var selected: Bool
        // NOTE: Something to connect to Stripe? Don't know if we need two different structs
    }
    
    // Enable UserDefaults
    let defaults = NSUserDefaults.standardUserDefaults()
    
    // Addresses
    var addresses = [String]() //[Address(address: "1368 Campus Drive \nDurham, NC \n27708", selected: false), Address(address: "1100 Alexander Drive \nDurham, NC \n27708", selected: true)]
    // Payment Methods
    var paymentMethods = [PaymentMethod(method: "Food points", selected: true), PaymentMethod(method: "Credit Card", selected: false)]
    
    var selectedCell = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title
        self.title = selectedCell
        
        // Set addNewText button
        if selectedCell == "Deliver To" {
            addNewButton.setTitle("+ NEW ADDRESS", forState: .Normal)
            pageTitleLabel.text = "Addresses"
            descriptionLabel.text = "Select or add an address to deliver to."
        } else {
            addNewButton.setTitle("+ NEW PAYMENT METHOD", forState: .Normal)
            pageTitleLabel.text = "Payment Methods"
            descriptionLabel.text = "Pay with food points upon delivery. Credit/debit card payments coming soon."
        }
        
        // Set custom back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        // Set tableView cells to custom height and automatically resize if needed
        myTableView.estimatedRowHeight = 50
        self.myTableView.rowHeight = UITableViewAutomaticDimension
        
        // Only one cell can be selected at a time
        myTableView.allowsMultipleSelection = false
        
        if selectedCell == "Deliver To" {
            
        } else {
            
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        
        if let addressesArray = defaults.objectForKey("Addresses") {
            addresses = addressesArray as! [String]
        }
        
        myTableView.reloadData()
        updateViewConstraints()
    }
    
    // Resize itemsTableView
    override func updateViewConstraints() {
        super.updateViewConstraints()
        myTableViewHeight.constant = myTableView.contentSize.height
    }

    @IBAction func newButtonPressed(sender: UIButton) {
        if selectedCell == "Deliver To" {
            performSegueWithIdentifier("toNewAddress", sender: self)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedCell == "Deliver To" {
            return addresses.count
        } else {
            return paymentMethods.count
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("deliverToPayingWithCell", forIndexPath: indexPath)

        if selectedCell == "Deliver To" {
            cell.textLabel?.text = addresses[indexPath.row]
            let selectedRow = defaults.objectForKey("CurrentAddressIndex") as! Int
            
            if indexPath.row == selectedRow {
                cell.accessoryType = .Checkmark
            } else {
                cell.accessoryType = .None
            }
        } else {
            cell.textLabel?.text = paymentMethods[indexPath.row].method
            if paymentMethods[indexPath.row].selected {
                cell.accessoryType = .Checkmark
            } else {
                cell.accessoryType = .None
            }
        }

        return cell
    }
    
    // MAKE SURE THIS WORKSSSSSSSS
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if selectedCell == "Deliver To" {
            //deselectAll()
            defaults.setObject(indexPath.row, forKey: "CurrentAddressIndex")
        } else {
            deselectAll()
            paymentMethods[indexPath.row].selected = true
            }
        
        tableView.reloadData()
    }
    
    // Deselect all cells
    func deselectAll() {
        /*if selectedCell == "Deliver To" {
            for i in 0..<addresses.count {
                addresses[i].selected = false
            }
        }*/ if selectedCell == "Paying With"{
            for i in 0..<paymentMethods.count {
                paymentMethods[i].selected = false
            }
        }
    }
    
    @IBAction func returnToDeliverTo(segue: UIStoryboardSegue) {
    }

    // Override to support editing the table view.
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            // Delete the row from the data source
            addresses.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            tableView.reloadData()
            
            // Update UserDefaults
            if addresses.count > 1 {
                defaults.setObject(indexPath.row - 1, forKey: "CurrentAddressIndex")
            } else {
                defaults.setObject(-1, forKey: "CurrentAddressIndex")
            }
            
            defaults.setObject(addresses, forKey: "Addresses")
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
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
