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
        orderTotalLabel.text = String(format: "$%.2f", passedOrderTotal)

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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
