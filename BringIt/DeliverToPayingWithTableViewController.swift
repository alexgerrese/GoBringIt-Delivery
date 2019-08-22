//
//  DeliverToPayingWithTableViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 7/1/16.
//  Copyright © 2016 Campus Enterprises. All rights reserved.
//

import UIKit

//struct Address {
//    var address: String
//    var selected: Bool
//}

class DeliverToPayingWithViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var addNewButton: UIButton!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var pageTitleLabel: UILabel!
    @IBOutlet weak var myTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var descriptionLabel: UILabel!

    // Enable UserDefaults
    let defaults = UserDefaults.standard
    
    // Addresses
    var addresses = [String]()
    
    var selectedCell = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title
        self.title = "Address Info"
        
        // Set addNewText button
        if selectedCell == "Deliver To" {
            addNewButton.setTitle("+ NEW ADDRESS", for: UIControlState())
            pageTitleLabel.text = "Addresses"
            descriptionLabel.text = "Select or add an address to deliver to."
        } /*else {
            addNewButton.setTitle("+ NEW PAYMENT METHOD", forState: .Normal)
            pageTitleLabel.text = "Payment Methods"
            descriptionLabel.text = "Credit/debit card payments coming soon."
        }*/
        
        // Set custom back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
        // Set tableView cells to custom height and automatically resize if needed
        myTableView.rowHeight = 120
        //self.myTableView.rowHeight = UITableViewAutomaticDimension
        
        // Only one cell can be selected at a time
        myTableView.allowsMultipleSelection = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let addressesArray = defaults.object(forKey: "Addresses") {
            addresses = addressesArray as! [String]
        }
        
        myTableView.reloadData()
        updateViewConstraints()
    }
    
    // Resize itemsTableView
    override func updateViewConstraints() {
        super.updateViewConstraints()
        print("TABLEVIEW CONTENT SIZE HEIGHT: \(myTableView.contentSize.height)")
        print("Number of rows: \(myTableView.numberOfRows(inSection: 0))")
        print("Row height: \(self.myTableView.rowHeight)")
        myTableViewHeight.constant = myTableView.contentSize.height
    }

    @IBAction func newButtonPressed(_ sender: UIButton) {
            performSegue(withIdentifier: "toNewAddress", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return addresses.count
    }

    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "deliverToPayingWithCell", for: indexPath)

        cell.textLabel?.text = addresses[(indexPath as NSIndexPath).row]
        let selectedRow = defaults.object(forKey: "CurrentAddressIndex") as! Int
        
        //Change cell's tint color
        cell.tintColor = Constants.green
        
        if (indexPath as NSIndexPath).row == selectedRow {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        return cell
    }
    
    // MAKE SURE THIS WORKSSSSSSSS
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        defaults.set((indexPath as NSIndexPath).row, forKey: "CurrentAddressIndex")
        
        tableView.reloadData()
    }
    
    @IBAction func returnToDeliverTo(_ segue: UIStoryboardSegue) {
    }

    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: IndexPath) {
        if editingStyle == .delete {
            
            // Delete the row from the data source
            addresses.remove(at: (indexPath as NSIndexPath).row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
            
            // Update UserDefaults
            if addresses.count > 1 {
                defaults.set((indexPath as NSIndexPath).row - 1, forKey: "CurrentAddressIndex")
            } else {
                defaults.set(-1, forKey: "CurrentAddressIndex")
            }
            
            defaults.set(addresses, forKey: "Addresses")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
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
