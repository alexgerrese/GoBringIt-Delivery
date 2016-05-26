//
//  AddToOrderTableViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/25/16.
//  Copyright © 2016 Campus Enterprises. All rights reserved.
//

import UIKit
import GMStepper

class AddToOrderTableViewController: UITableViewController {
    
    // SAMPLE DATA
    let sectionNames = ["SIDES (PICK 2)", "EXTRAS", "SPECIAL INSTRUCTIONS"]
    let section1 = ["Fries", "The Buff Brahmas", "Salad"]
    let section2 = ["Chili cheese fries", "Extra hot sauce", "Cool stuff"]
    let section2Prices = ["+1.75", "+1.00", "+3.99"]
    let section3 = "E.g. Easy on the mayo, add bacon"
    
    // MARK: - IBOutlets
    @IBOutlet weak var foodDescriptionLabel: UILabel!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var stepper: GMStepper!
    @IBOutlet weak var totalPriceLabel: UILabel!
    
    // SAMPLE Data passed from previous View Controller
    var selectedFoodName = ""
    var selectedFoodDescription = ""
    var selectedFoodPrice = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set SAMPLE title
        self.title = selectedFoodName
        
        // Set food description label
        foodDescriptionLabel.text = selectedFoodDescription
        
        // Set custom nav bar font
        navigationController!.navigationBar.titleTextAttributes =
            ([NSFontAttributeName: UIFont(name: "Avenir", size: 17)!,
                NSForegroundColorAttributeName: UIColor.blackColor()])
        
        // Set tableView cells to custom height and automatically resize if needed
        tableView.estimatedRowHeight = 50
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        // Set stepper font
        stepper.labelFont = UIFont(name: "Avenir-Medium", size: 18)!
        stepper.buttonsFont = UIFont(name: "Avenir-Black", size: 18)!
    }
    
    override func viewWillAppear(animated: Bool) {
        // BUGGY - Add bottomView to bottom of screen
        /*self.tableView.tableFooterView = nil
        self.bottomView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.tableView.frame.size.height - self.tableView.contentSize.height - self.bottomView.frame.size.height)
        self.tableView.tableFooterView = self.bottomView*/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // TO-DO: FINISH THIS METHOD
    @IBAction func addToOrderButtonPressed(sender: UIButton) {
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sectionNames.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return section1.count
        } else if section == 1 {
            return section2.count
        } else {
            return 1
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("addToOrderCell", forIndexPath: indexPath) as! AddToOrderTableViewCell
            
            // ISSUE: If it says pick X, you can still pick as many or as few as you want
            cell.radioButton.multipleSelectionEnabled = true
            cell.radioButton.setTitle(section1[indexPath.row], forState: .Normal)
            cell.extraCostLabel.hidden = true
            
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("addToOrderCell", forIndexPath: indexPath) as! AddToOrderTableViewCell
            
            cell.radioButton.multipleSelectionEnabled = true
            cell.radioButton.setTitle(section2[indexPath.row], forState: .Normal)
            cell.extraCostLabel.hidden = false
            cell.extraCostLabel.text = section2Prices[indexPath.row]
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("specialInstructionsCell", forIndexPath: indexPath) as! AddToOrderSpecialInstructionsTableViewCell
            
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionNames[section]
    }
    
    // Set up custom header
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor.whiteColor()
        header.textLabel!.textColor = GREEN
        header.textLabel?.font = UIFont(name: "Avenir", size: 12)
        //header.alpha = 0.5 //make the header transparent
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
