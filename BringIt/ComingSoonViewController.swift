//
//  ComingSoonViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 8/3/16.
//  Copyright © 2016 Campus Enterprises. All rights reserved.
//

import UIKit

class ComingSoonViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title
        self.title = "Coming Soon"

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func orderFoodButtonPressed(_ sender: AnyObject) {
        tabBarController?.selectedIndex = 0
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
