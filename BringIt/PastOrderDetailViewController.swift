//
//  PastOrderDetailViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 6/2/17.
//  Copyright © 2017 Campus Enterprises. All rights reserved.
//

import UIKit
import RealmSwift

class PastOrderDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var reorderButton: UIButton!
    @IBOutlet weak var cartTotal: UILabel!
    @IBOutlet weak var reorderButtonView: UIView!
    @IBOutlet weak var reorderView: UIView!
    
    // MARK: - Variables
    
    let defaults = UserDefaults.standard // Initialize UserDefaults
    
    var order = Order()
    var user = User()
    var selectedItem = MenuItem()
    let defaultButtonText = "Checkout"
    
    // Passed from PastOrderVC
    var orderID = 0


    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup Realm
        setupRealm()
        
        // Setup UI
        setupUI()
        
        // Setup tableview
        setupTableView()
        
        // Calculate initial item price
        calculateTotal()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupRealm() {
        
        print("In setupRealm()")
        
        let realm = try! Realm() // Initialize Realm
        
        // Query current order
//        let predicate = NSPredicate(format: )
        let filteredOrders = realm.objects(Order.self).filter("id = %@", orderID)
        
        order = filteredOrders.first!
        
    }
    
    /* Do initial UI setup */
    func setupUI() {
        
        print("Setting up UI")
        
        setCustomBackButton()
        
        // Format order date and set as title
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let orderDate = dateFormatter.string(from: order.orderTime! as Date)
        self.title = orderDate
        
        reorderButtonView.layer.cornerRadius = Constants.cornerRadius
//        reorderView.layer.shadowColor = Constants.lightGray.cgColor
//        reorderView.layer.shadowOpacity = 1
//        reorderView.layer.shadowRadius = Constants.shadowRadius
//        reorderView.layer.shadowOffset = CGSize.zero
        
    }
    
    /* Customize tableView attributes */
    func setupTableView() {
        
        print("Setting up tableview")
        
        // Set tableView cells to custom height and automatically resize if needed
        self.myTableView.estimatedRowHeight = 150
        self.myTableView.rowHeight = UITableViewAutomaticDimension
        self.myTableView.setNeedsLayout()
        self.myTableView.layoutIfNeeded()
        
    }
    
    /* Iterate over menu items in cart and add their total costs to the subtotal */
    func calculateTotal() -> Double {
        
        // Base cost is subtotal
        var total = order.subtotal
        
        // Add delivery fee
        total += order.deliveryFee
        
        // Display total price
        cartTotal.text = "$" + String(format: "%.2f", total)
        
        return total
    }
    
    /* Iterate over selected extras and add to item price, then calculate subtotal by multiplying by quantity */
    func calculateSubtotal(menuItem: MenuItem) -> Double {
        
        // Calculate total price of menu item and selected sides
        var totalForSingleItem = menuItem.price
        for extra in menuItem.extras {
            if extra.isSelected {
                totalForSingleItem += extra.price
            }
        }
        
        // Multiply by quantity
        let subtotal = totalForSingleItem * Double(menuItem.quantity)
        
        return subtotal
    }
    
    /* Create shallow Realm copies to differentiate between the normal menu item and the item in the cart (necessary for future Realm queries), then add those copies to the order (if one exists, else create new order as well) */
    func addToCart(menuItem: MenuItem) {
        
        let realm = try! Realm() // Initialize Realm
        
        // STEP 1: Create Realm copies for the cart
        
        let newMenuItem = MenuItem()
        newMenuItem.id = menuItem.id
        newMenuItem.name = menuItem.name
        newMenuItem.details = menuItem.details
        newMenuItem.price = menuItem.price
        newMenuItem.groupings = menuItem.groupings
        newMenuItem.numRequiredSides = menuItem.numRequiredSides
        newMenuItem.quantity = menuItem.quantity
        newMenuItem.totalCost = calculateSubtotal(menuItem: menuItem)
        newMenuItem.isInCart = true
        newMenuItem.specialInstructions = menuItem.specialInstructions
        
        for side in menuItem.sides {
            
            let newSide = Side()
            newSide.id = side.id
            newSide.name = side.name
            newSide.isRequired = side.isRequired
            newSide.sideCategory = side.sideCategory
            newSide.price = side.price
            newSide.isSelected = side.isSelected
            newSide.isInCart = true
            
            newMenuItem.sides.append(newSide)
            
        }
        
        for extra in menuItem.extras {
            
            let newExtra = Side()
            newExtra.id = extra.id
            newExtra.name = extra.name
            newExtra.isRequired = extra.isRequired
            newExtra.sideCategory = extra.sideCategory
            newExtra.price = extra.price
            newExtra.isSelected = extra.isSelected
            newExtra.isInCart = true
            
            newMenuItem.sides.append(newExtra)
            
        }
        
        // Save new menu item as new object in Realm
        try! realm.write {
            realm.add(newMenuItem)
        }
        
        // STEP 2: Add copies to order
        
        // Check if an order already exists
        let predicate = NSPredicate(format: "restaurantID = %@ && isComplete = %@", order.restaurantID, NSNumber(booleanLiteral: false))
        let filteredOrders = realm.objects(Order.self).filter(predicate)
        
        try! realm.write {
            if filteredOrders.count > 0 {
                
                // Cart already exists
                print("Cart already exists. Adding new menu item.")
                
                let order = filteredOrders.first!
                order.menuItems.append(newMenuItem)
                order.subtotal += newMenuItem.totalCost
                
            } else {
                
                // Cart doesn't exist yet
                print("Cart does not exist. Creating new one.")
                
                let deliveryFee = realm.object(ofType: Restaurant.self, forPrimaryKey: order.restaurantID)?.deliveryFee
                
                let newOrder = Order()
                newOrder.restaurantID = order.restaurantID
                newOrder.menuItems.append(newMenuItem)
                newOrder.subtotal += newMenuItem.totalCost
                newOrder.deliveryFee = deliveryFee!
                newOrder.isComplete = false
                newOrder.address = order.address
                newOrder.paymentMethod = order.paymentMethod
                
                realm.add(newOrder)
            }
        }
    }
    
    @IBAction func reorderButtonTapped(_ sender: UIButton) {
        
        for menuItem in order.menuItems {
            addToCart(menuItem: menuItem)
        }
        
        performSegue(withIdentifier: "toCheckoutFromReorder", sender: self)
        
    }
    
    
    
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else if section == 1 {
            return order.menuItems.count
        } else {
            return 3 // The 3 extra are Subtotal + Delivery Fee + Total
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "deliveryDetailCell", for: indexPath)
            
            // Delivery To
            if indexPath.row == 0 {
                
                cell.textLabel?.text = "Delivered To"
                cell.detailTextLabel?.text = order.address?.streetAddress
                
            } else {
                
                cell.textLabel?.text = "Paid With"
                cell.detailTextLabel?.text = order.paymentMethod
            }
            
            return cell
        } else if indexPath.section == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "orderCell", for: indexPath) as! OrderTableViewCell
            
            let menuItem = order.menuItems[indexPath.row]
            
            cell.quantity.text = String(menuItem.quantity)
            cell.menuItemName.text = menuItem.name
            cell.price.text = "$" + String(format: "%.2f", menuItem.totalCost)
            
            var otherDetails = "w/ "
            for side in menuItem.sides {
                if side.isSelected {
                    otherDetails = otherDetails + side.name + ", "
                }
            }
            for extra in menuItem.extras {
                if extra.isSelected {
                    otherDetails = otherDetails + extra.name + ", "
                }
            }
            
            if otherDetails == "w/ " {
                otherDetails = menuItem.specialInstructions
            } else {
                let index = otherDetails.index(otherDetails.startIndex, offsetBy: otherDetails.characters.count - 2)
                otherDetails = otherDetails.substring(to: index)
                otherDetails = otherDetails + "\n" + menuItem.specialInstructions
            }
            
            cell.otherDetails.text = otherDetails
            
            return cell
        } else {
            
            // Subtotal
            if indexPath.row == 0 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "costCell", for: indexPath)
                
                cell.textLabel?.text = "Subtotal"
                cell.detailTextLabel?.text = "$" + String(format: "%.2f", order.subtotal)
                
                return cell
            }
                // Delivery Fee
            else if indexPath.row == 1 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "costCell", for: indexPath)
                
                cell.textLabel?.text = "Delivery Fee"
                cell.detailTextLabel?.text = "$" + String(format: "%.2f", order.deliveryFee)
                
                return cell
            }
                // Total
            else if indexPath.row == 2 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "costCell", for: indexPath)
                
                cell.textLabel?.text = "Total"
                cell.detailTextLabel?.text = "$" + String(format: "%.2f", calculateTotal())
                
                return cell
            }
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "costCell", for: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Delivery Details"
        } else if section == 1 {
            return "Order Summary"
        } else {
            return ""
        }
    }
    
    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = Constants.headerFont
        header.textLabel?.textColor = UIColor.black
        header.textLabel?.textAlignment = .left
        header.backgroundView?.backgroundColor = UIColor.white
        header.textLabel?.text = header.textLabel?.text?.uppercased()
        
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 {
            return CGFloat.leastNormalMagnitude
        }
        return Constants.headerHeight
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let nav = segue.destination as! UINavigationController
        let checkoutVC = nav.topViewController as! CheckoutVC
        checkoutVC.restaurantID = order.restaurantID

    }
 

}
