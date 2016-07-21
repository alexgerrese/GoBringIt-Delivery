//
//  SettingsTableViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/24/16.
//  Copyright © 2016 Campus Enterprises. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var profilePicImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var memberSinceLabel: UILabel!
    @IBOutlet weak var myTableView: UITableView!
    
    // Tableview cells
    let infoCells = ["Contact Info", "Addresses", "Payment Methods"]
    let helpCells = ["Contact Us", "Become a BringIt Driver"]
    
    // TO-DO: CHAD! Please pull the db data and make these dynamic. See below for where to put the data!
    var cellNumbers = [Int]()
    var userName = ""
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var selectedCell = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title
        self.navigationItem.title = "Settings"
        
        // Round profile pic image
        self.profilePicImage.layer.cornerRadius = self.profilePicImage.frame.size.width / 2
        self.profilePicImage.clipsToBounds = true
        self.profilePicImage.layer.borderWidth = 2.0
        self.profilePicImage.layer.borderColor = UIColor.lightGrayColor().CGColor
        
        // Set nav bar preferences
        self.navigationController?.navigationBar.tintColor = UIColor.darkGrayColor()
        navigationController!.navigationBar.titleTextAttributes =
            ([NSFontAttributeName: TITLE_FONT,
                NSForegroundColorAttributeName: UIColor.blackColor()])
        
        // CHAD! Here is where you can load the data into the dummy variables
        cellNumbers = [0, 2, 1] // These represent the number of each that exist (0 means not applicable, then the 2 means the user has 2 addresses, and 1 means the user has one payment method on file).
        userName = "Alexander Gerrese"
        
        // Set name
        nameLabel.text = userName
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return infoCells.count
        } else {
            return helpCells.count
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("settingsCell", forIndexPath: indexPath)

        if indexPath.section == 0 {
            cell.textLabel?.text = infoCells[indexPath.row]
            if cellNumbers[indexPath.row] == 0 {
                cell.detailTextLabel?.text = ""
            } else {
                cell.detailTextLabel?.text = String(cellNumbers[indexPath.row])
            }
        } else {
            cell.textLabel?.text = helpCells[indexPath.row]
            cell.detailTextLabel?.text = ""
        }

        return cell
    }
    
    // Set up custom header
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        header.textLabel!.textColor = UIColor.darkGrayColor()
        header.textLabel?.font = TV_HEADER_FONT
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "INFO"
        } else {
            return "HELP"
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 1 || indexPath.row == 2 {
            performSegueWithIdentifier("toDeliverToPayingWithFromProfile", sender: self)
        }
    }
    
    // Find out which cell was selected and sent to prepareForSegue
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        selectedCell = indexPath.row
        
        return indexPath
    }
    
    // BUG - If you log out then back in, you will come back here, not home.
    @IBAction func logOutButtonClicked(sender: UIButton) {
        defaults.setBool(false, forKey: "loggedIn")
        defaults.setObject(nil, forKey: "userID")
        (self.tabBarController as! TabBarController).checkLoggedIn()
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toDeliverToPayingWithFromProfile" {
            let VC = segue.destinationViewController as! DeliverToPayingWithTableViewController
            if self.selectedCell == 1 {
                VC.selectedCell = "Deliver To"
            } else if self.selectedCell == 2 {
                VC.selectedCell = "Paying With"
            }
        }
    }
    

}
