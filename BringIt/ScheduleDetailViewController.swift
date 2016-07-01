//
//  ScheduleDetailViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 7/1/16.
//  Copyright © 2016 Campus Enterprises. All rights reserved.
//

import UIKit

class ScheduleDetailViewController: UIViewController {

    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var totalCostLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set custom back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // TO-DO: Finish this method
    @IBAction func orderAgainButtonPressed(sender: UIButton) {
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
