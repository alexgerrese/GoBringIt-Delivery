//
//  BringItHomeTableViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/16/16.
//  Copyright © 2016 Campus Enterprises. All rights reserved.
//

import UIKit
import BTNavigationDropdownMenu

class BringItHomeTableViewController: UITableViewController {
    
    // SAMPLE DATA - REPLACE WITH BACKEND
    let coverImages = ["sushiLove", "dunkinDonuts", "dames"]
    let restaurantNames = ["Sushi Love", "Dunkin' Donuts", "Dames"]
    let cuisineTypes = ["SUSHI", "BREAKFAST", "AMERICAN"]
    let openHours = ["5:30PM - 10:30PM", "7:00AM - 11:00AM", "10:00AM - 5:00PM"]
    let isOpen = [true, false, false]
    
    let rectShape = CAShapeLayer()
    let indicatorHeight: CGFloat = 3
    var indicatorWidth: CGFloat!
    let indicatorBottomMargin: CGFloat = 2
    let indicatorLeftMargin: CGFloat = 2
    var maxY: CGFloat!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set custom back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        // MARK: - Dropdown Menu Setup
        var menuView: BTNavigationDropdownMenu!
        let items = ["Bring It", "Maid My Day"]
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.darkTextColor()]
        
        menuView = BTNavigationDropdownMenu(navigationController: self.navigationController, title: items[0], items: items)
        menuView.cellHeight = 55
        menuView.cellSeparatorColor = UIColor.lightGrayColor()
        menuView.cellBackgroundColor = self.navigationController?.navigationBar.barTintColor
        menuView.cellSelectionColor = GREEN
        menuView.keepSelectedCellColor = true
        menuView.cellTextLabelColor = UIColor.darkTextColor()
        menuView.cellTextLabelFont = UIFont(name: "Avenir", size: 17)
        menuView.cellTextLabelAlignment = .Center // .Center // .Right // .Left
        menuView.arrowPadding = 15
        menuView.animationDuration = 0.5
        menuView.maskBackgroundColor = UIColor.blackColor()
        menuView.maskBackgroundOpacity = 0.3
        menuView.arrowImage = UIImage(named: "arrowDown")
        menuView.didSelectItemAtIndexHandler = {(indexPath: Int) -> () in
            print("Did select item at index: \(indexPath)")
        }
        
        self.navigationItem.titleView = menuView
        
        // setup tabbar indicator
        rectShape.fillColor = GREEN.CGColor
        indicatorWidth = view.bounds.maxX / 3 // count of items
        self.tabBarController!.view.layer.addSublayer(rectShape)
        self.tabBarController?.delegate = self
        
        // initial position
        maxY = view.bounds.maxY - indicatorHeight
        updateTabbarIndicatorBySelectedTabIndex(0)
    }
    
    func updateTabbarIndicatorBySelectedTabIndex(index: Int) -> Void
    {
        let updatedBounds = CGRect( x: CGFloat(index) * (indicatorWidth + indicatorLeftMargin),
                                    y: maxY,
                                    width: indicatorWidth - indicatorLeftMargin,
                                    height: indicatorHeight)
        
        print(view.bounds.maxY - indicatorHeight)
        
        let path = CGPathCreateMutable()
        CGPathAddRect(path, nil, updatedBounds)
        rectShape.path = path
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return coverImages.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("bringItHomeCell", forIndexPath: indexPath) as! BringItHomeTableViewCell

        // Set up cell properties
        cell.restaurantBannerImage.image = UIImage(named: coverImages[indexPath.row])
        cell.restaurantNameLabel.text = restaurantNames[indexPath.row]
        cell.cuisineTypeLabel.text = cuisineTypes[indexPath.row]
        cell.restaurantHoursLabel.text = openHours[indexPath.row]
        if isOpen[indexPath.row] {
            cell.openIndicator.image = UIImage(named: "oval-green")
            cell.openClosedLabel.text = "OPEN"
        } else {
            cell.openIndicator.image = UIImage(named: "oval-red")
            cell.openClosedLabel.text = "CLOSED"
        }

        return cell
    }

    
    // MARK: - Navigation
     
    @IBAction func returnHome(segue: UIStoryboardSegue) {
    }

}

extension BringItHomeTableViewController: UITabBarControllerDelegate {
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        updateTabbarIndicatorBySelectedTabIndex(tabBarController.selectedIndex)
    }
}
