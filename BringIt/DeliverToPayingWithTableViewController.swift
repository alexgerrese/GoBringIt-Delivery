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

    // Enable UserDefaults
    let defaults = NSUserDefaults.standardUserDefaults()
    
    // Addresses
    var addresses = [String]()
    
    var selectedCell = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title
        self.title = "Address Info"
        
        // Set addNewText button
        if selectedCell == "Deliver To" {
            addNewButton.setTitle("+ NEW ADDRESS", forState: .Normal)
            pageTitleLabel.text = "Addresses"
            descriptionLabel.text = "Select or add an address to deliver to."
        } /*else {
            addNewButton.setTitle("+ NEW PAYMENT METHOD", forState: .Normal)
            pageTitleLabel.text = "Payment Methods"
            descriptionLabel.text = "Credit/debit card payments coming soon."
        }*/
        
        // Set custom back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        // Set tableView cells to custom height and automatically resize if needed
        myTableView.estimatedRowHeight = 50
        self.myTableView.rowHeight = UITableViewAutomaticDimension
        
        // Only one cell can be selected at a time
        myTableView.allowsMultipleSelection = false
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
            performSegueWithIdentifier("toNewAddress", sender: self)
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
            return addresses.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("deliverToPayingWithCell", forIndexPath: indexPath)

        cell.textLabel?.text = addresses[indexPath.row]
        let selectedRow = defaults.objectForKey("CurrentAddressIndex") as! Int
        
        //Change cell's tint color
        cell.tintColor = GREEN
        
        if indexPath.row == selectedRow {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }

        return cell
    }
    
    // MAKE SURE THIS WORKSSSSSSSS
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        defaults.setObject(indexPath.row, forKey: "CurrentAddressIndex")
        
        tableView.reloadData()
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
