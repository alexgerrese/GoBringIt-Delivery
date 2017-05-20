//
//  CheckoutVC.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/20/17.
//  Copyright © 2017 Campus Enterprises. All rights reserved.
//

import UIKit
import RealmSwift

class CheckoutVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var viewCartButton: UIButton!
    @IBOutlet weak var cartTotal: UILabel!
    @IBOutlet weak var viewCartButtonView: UIView!
    @IBOutlet weak var viewCartView: UIView!
    @IBOutlet weak var viewCartViewToBottom: NSLayoutConstraint!
    
    // MARK: - Variables
    
    let defaults = UserDefaults.standard // Initialize UserDefaults
    let realm = try! Realm() // Initialize Realm
    
    var order = Order()
    
    // Passed from previousVC
    var restaurantID = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup Realm
        setupRealm()
        
        // Setup UI
        setupUI()
        
        // Setup tableview
        setupTableView()
        
        // Calculate initial item price
        calculateSubtotal()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // TO-DO: Check if coming from SignInVC
        
        checkIfLoggedIn()
    }
    
    func setupRealm() {
        
        checkIfLoggedIn()
        
        // Query current order
        let predicate = NSPredicate(format: "restaurantID = %@ && isComplete = %@", restaurantID, NSNumber(booleanLiteral: false))
        let filteredOrders = realm.objects(Order.self).filter(predicate)
        
        order = filteredOrders.first!
        
        print(order.menuItems.count)
        
    }
    
    func checkIfLoggedIn() {
        
        // If not logged in, go to SignInVC
        let loggedIn = defaults.bool(forKey: "loggedIn")
        if !loggedIn {
            performSegue(withIdentifier: "toSignIn", sender: self)
        }
    }
    
    /* Do initial UI setup */
    func setupUI() {
        
        self.title = "Checkout"
        viewCartButtonView.layer.cornerRadius = Constants.cornerRadius
        viewCartView.layer.shadowColor = Constants.lightGray.cgColor
        viewCartView.layer.shadowOpacity = 1
        viewCartView.layer.shadowRadius = Constants.shadowRadius
        viewCartView.layer.shadowOffset = CGSize.zero
        
        checkButtonStatus()
    }
    
    /* Customize tableView attributes */
    func setupTableView() {
        
        // Set tableView cells to custom height and automatically resize if needed
        self.myTableView.estimatedRowHeight = 150
        self.myTableView.rowHeight = UITableViewAutomaticDimension
        self.myTableView.setNeedsLayout()
        self.myTableView.layoutIfNeeded()
        
    }
    
    /* Iterate over menu items in cart and add their total costs to the subtotal */
    func calculateSubtotal() -> Double {
        
        // Base cost is subtotal
        var total = order.subtotal
        
        // Add delivery fee
        total += order.deliveryFee
        
        // Display total price
        cartTotal.text = "$" + String(format: "%.2f", total)
        
        return total
    }
    
    func checkButtonStatus() {
        
        // If address and payment method are defined, enable button
        
        // Else disable
    }

    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
   
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return order.menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderCell", for: indexPath) as! OrderTableViewCell
        
        let menuItem = order.menuItems[indexPath.row]
        
        cell.quantity.text = String(menuItem.quantity)
        cell.menuItemName.text = menuItem.name
        cell.price.text = String(format: "%.2f", menuItem.totalCost)
        
        var otherDetails = "w/ "
        for side in menuItem.sides {
            otherDetails = otherDetails + side.name + ", "
        }
        for extra in menuItem.extras {
            otherDetails = otherDetails + extra.name + ", "
        }
        otherDetails = otherDetails + "\n" + menuItem.specialInstructions
        
        cell.otherDetails.text = otherDetails
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Order Summary"
    }
    
    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = Constants.headerFont
        header.textLabel?.textColor = Constants.darkGray
        header.textLabel?.textAlignment = .left
        header.textLabel?.text = header.textLabel?.text?.uppercased()
        
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.headerHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        myTableView.deselectRow(at: indexPath, animated: true)
        
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
