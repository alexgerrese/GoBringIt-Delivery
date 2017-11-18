//
//  CheckoutVC.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/20/17.
//  Copyright © 2017 Campus Enterprises. All rights reserved.
//

import UIKit
import RealmSwift
import Moya
import Alamofire
import AudioToolbox
import SendGrid

class CheckoutVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var checkoutButton: UIButton!
    @IBOutlet weak var cartTotal: UILabel!
    @IBOutlet weak var checkoutButtonView: UIView!
    @IBOutlet weak var checkoutView: UIView!
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    
    // Checking out view
    @IBOutlet weak var checkingOutView: UIView!
    @IBOutlet weak var checkingOutTitle: UILabel!
    @IBOutlet weak var checkingOutDetails: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var tryAgainButton: UIButton!
    
    // MARK: - Variables
    
    let defaults = UserDefaults.standard // Initialize UserDefaults
    
    var order = Order()
    var user = User()
    var selectedItem = MenuItem()
    var restaurantEmail = ""
    var restaurantPrinterEmail = ""
    let defaultButtonText = "Checkout"
    
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
        calculateTotal()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        print("In viewWillAppear")
        
        // TO-DO: Check if coming from SignInVC
        
        checkIfLoggedIn()
        
        myTableView.reloadData()
        
        checkButtonStatus()
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if checkingOutView.alpha == 1 {
            checkingOutView.removeFromSuperview()
        }
    }
    
    func setupRealm() {
        
        print("In setupRealm()")
        
        checkIfLoggedIn()
        
        let realm = try! Realm() // Initialize Realm
        
        // Query current order
        let predicate = NSPredicate(format: "restaurantID = %@ && isComplete = %@", restaurantID, NSNumber(booleanLiteral: false))
        let filteredOrders = realm.objects(Order.self).filter(predicate)
        
        order = filteredOrders.first!
        
        // Query restaurant for printer email
        let restaurants = realm.objects(Restaurant.self).filter("id = %@", restaurantID)
        restaurantEmail = restaurants.first!.email
        restaurantPrinterEmail = restaurants.first!.printerEmail
    }
    
    func checkIfLoggedIn() {
        
        let realm = try! Realm() // Initialize Realm
        
        print("Checking if logged in")
        
        if comingFromSignIn == true {
            print("Came from sign in, dismissing.")
            comingFromSignIn = false
            self.dismiss(animated: true, completion: nil)
        }
        
        // If not logged in, go to SignInVC
        let loggedIn = defaults.bool(forKey: "loggedIn")
        if !loggedIn {
            
            print("Not logged in, going to SignInVC")
            performSegue(withIdentifier: "toSignIn", sender: self)
        } else {
            
            print("Logged in, querying user")
            // Check if user already exists in Realm
            let predicate = NSPredicate(format: "isCurrent = %@", NSNumber(booleanLiteral: true))
            user = realm.objects(User.self).filter(predicate).first!
        }
    }
    
    /* Do initial UI setup */
    func setupUI() {
        
        print("Setting up UI")
        
        setCustomBackButton()
        
        self.title = "Checkout"
        checkoutButtonView.layer.cornerRadius = Constants.cornerRadius
        checkoutView.layer.shadowColor = Constants.lightGray.cgColor
        checkoutView.layer.shadowOpacity = 1
        checkoutView.layer.shadowRadius = Constants.shadowRadius
        checkoutView.layer.shadowOffset = CGSize.zero
        myActivityIndicator.isHidden = true
        
        // Setup checking out view
        checkingOutView.alpha = 0.0
        confirmButton.layer.cornerRadius = Constants.cornerRadius
        tryAgainButton.layer.cornerRadius = Constants.cornerRadius
        cancelButton.layer.cornerRadius = Constants.cornerRadius
        cancelButton.layer.borderColor = UIColor.white.cgColor
        cancelButton.layer.borderWidth = Constants.borderWidth
        tryAgainButton.alpha = 0
        
        checkButtonStatus()
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
    
    // If there are items in the cart, and the address and payment method are defined, enable button
    func checkButtonStatus() {
        
        let realm = try! Realm() // Initialize Realm
        
        // Check that there are items in the cart
        if !(order.menuItems.count > 0) {
            checkoutButton.isEnabled = false
            checkoutButtonView.backgroundColor = Constants.red
            checkoutButton.setTitle("Please add items to your cart", for: .normal)
            return
        }
        
        // Check that there is a selected address
        let filteredAddresses = realm.objects(DeliveryAddress.self).filter("userID = %@ AND isCurrent = %@", user.id, NSNumber(booleanLiteral: true))
        
        if filteredAddresses.count > 0 {
            
            checkoutButton.isEnabled = true
            checkoutButtonView.backgroundColor = Constants.green
            checkoutButton.setTitle("Checkout", for: .normal)
        } else {
            
            checkoutButton.isEnabled = false
            checkoutButtonView.backgroundColor = Constants.red
            checkoutButton.setTitle("Please select a delivery address", for: .normal)
            
            return
        }
        
        // Check that there is a payment method selected
        let filteredPaymentMethods = realm.objects(PaymentMethod.self).filter("userID = %@ AND isSelected = %@", user.id, NSNumber(booleanLiteral: true))

        if filteredPaymentMethods.count < 0 {
            
            checkoutButton.isEnabled = false
            checkoutButtonView.backgroundColor = Constants.red
            checkoutButton.setTitle("Please select a payment method", for: .normal)
        } else {
            checkoutButton.isEnabled = true
            checkoutButtonView.backgroundColor = Constants.green
            checkoutButton.setTitle("Checkout", for: .normal)
        }
        
//         Check that the restaurant is open
        let filteredRestaurant = realm.objects(Restaurant.self).filter("id = %@", restaurantID)
        if !filteredRestaurant.first!.isOpen() {
            checkoutButton.isEnabled = false
            checkoutButtonView.backgroundColor = Constants.red
            checkoutButton.setTitle("This restaurant is currently closed", for: .normal)
        } else {
            checkoutButton.isEnabled = true
            checkoutButtonView.backgroundColor = Constants.green
            checkoutButton.setTitle("Checkout", for: .normal)
        }
    }

    @IBAction func checkoutButtonTapped(_ sender: UIButton) {
        
        // Show checking out view
        UIView.animate(withDuration: 0.4, animations: {
            self.checkingOutView.alpha = 1.0
        })
        
        // Add haptic feedback
        if #available(iOS 10.0, *) {
            let notification = UINotificationFeedbackGenerator()
            notification.notificationOccurred(.warning)
        }
        
        setupConfirmView()
    }
    
    func setupConfirmView() {
        
        UIApplication.shared.keyWindow?.addSubview(checkingOutView)
        
        tryAgainButton.alpha = 0
        confirmButton.alpha = 1
        confirmButton.isEnabled = true
        checkingOutView.backgroundColor = Constants.green
        checkingOutTitle.text = "Are you sure you want to checkout?"
        checkingOutDetails.text = "You will be charged $\(String(format: "%.2f", calculateTotal())) upon delivery."
//        confirmButton.setTitle("Checkout", for: .normal)
        cancelButton.setTitle("Cancel", for: .normal)
    }
    
    func showConfirmViewError(errorTitle: String, errorMessage: String) {
        
        tryAgainButton.alpha = 1
        cancelButton.alpha = 1
        tryAgainButton.isEnabled = true
        cancelButton.isEnabled = true
        
        checkingOutView.backgroundColor = Constants.red
        checkingOutTitle.text = errorTitle
        checkingOutDetails.text = errorMessage
        myActivityIndicator.stopAnimating()
        myActivityIndicator.isHidden = true
    }
    
    @IBAction func tryAgainButtonTapped(_ sender: UIButton) {
        
        confirmOrder()
    }
    
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        
        // Show checking out view
        UIView.animate(withDuration: 0.4, animations: {
            self.checkingOutView.alpha = 0
        })
    }
    
    @IBAction func confirmButtonTapped(_ sender: UIButton) {
        confirmOrder()
    }
    
    func confirmOrder() {
        
        let realm = try! Realm() // Initialize Realm
        
        // Animate activity indicator
        myActivityIndicator.isHidden = false
        myActivityIndicator.startAnimating()
        
        // Update UI
        checkingOutView.backgroundColor = Constants.green
        checkingOutTitle.text = "Placing Order..."
        checkingOutDetails.text = ""
        confirmButton.alpha = 0
        cancelButton.alpha = 0
        confirmButton.isEnabled = false
        cancelButton.isEnabled = false
        
        // Add final Realm details
        try! realm.write {
            
            let filteredAddresses = realm.objects(DeliveryAddress.self).filter("userID = %@ AND isCurrent = %@", user.id, NSNumber(booleanLiteral: true))
            order.address = filteredAddresses.first!
            
            let filteredPaymentMethods = realm.objects(PaymentMethod.self).filter("userID = %@ AND isSelected = %@", user.id, NSNumber(booleanLiteral: true))
            
            if self.isCreditCardHours() {
                order.paymentMethod = "Credit Card"
            } else {
                order.paymentMethod = filteredPaymentMethods.first!.method
            }
            
        }
        
        var count = 0
        
        addAllToCart() {
            (result: Int) in
            
            count += 1
            
            print(count)
            if count == self.order.menuItems.count {
                self.addOrder()
            }
        }
    }

    @IBAction func XButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
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
        
        let realm = try! Realm() // Initialize Realm
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "deliveryDetailCell", for: indexPath)
            
            // Delivery To
            if indexPath.row == 0 {
                
                cell.textLabel?.text = "Deliver To"

                let filteredAddresses = realm.objects(DeliveryAddress.self).filter("userID = %@ AND isCurrent = %@", user.id, NSNumber(booleanLiteral: true))
                
                if filteredAddresses.count > 0 {
                    cell.detailTextLabel?.text = filteredAddresses.first!.streetAddress
                } else {
                    cell.detailTextLabel?.text = "Please select a delivery address"
                }
                
            } else {
                
                cell.textLabel?.text = "Paying With"
                
                let filteredPaymentMethods = realm.objects(PaymentMethod.self).filter("userID = %@ AND isSelected = %@", user.id, NSNumber(booleanLiteral: true))
                
                if filteredPaymentMethods.count > 0 {
                    
                    // Check if currently in credit card hours
                    if self.isCreditCardHours() {
                        cell.detailTextLabel?.text = "Credit Card"
                    } else {
                        cell.detailTextLabel?.text = filteredPaymentMethods.first!.method
                    }
                    
                } else {
                    cell.detailTextLabel?.text = "Please select a payment method"
                }
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
                
//                cell.textLabel?.font = Constants.mediumFont
//                cell.detailTextLabel?.font = Constants.mediumFont
                
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            
            if indexPath.row == 0 {
                
                performSegue(withIdentifier: "toAddressesFromCheckout", sender: self)
            } else if indexPath.row == 1 {
                
                performSegue(withIdentifier: "toPaymentMethodsFromCheckout", sender: self)
            }
        } else if indexPath.section == 1 {
            
            selectedItem = order.menuItems[indexPath.row]
            performSegue(withIdentifier: "toAddToCartFromCheckout", sender: self)
        }
        
        myTableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        let realm = try! Realm() // Initialize Realm
        
        if indexPath.section == 1 {
            if editingStyle == .delete {
                
                // Delete the row from the data source
                try! realm.write {
                    let item = self.order.menuItems[indexPath.row]
                    self.order.subtotal -= item.totalCost
                    realm.delete(item)
                    
                }
                
                myTableView.deleteRows(at: [indexPath], with: .automatic)
                
                // Reload tableview and adjust tableview height and recalculate costs
                myTableView.reloadData()
                updateViewConstraints()
                calculateTotal()
                
            }
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toAddToCartFromCheckout" {
            let nav = segue.destination as! UINavigationController
            let addToCartVC = nav.topViewController as! AddToCartVC
            addToCartVC.passedMenuItemID = selectedItem.id
            addToCartVC.comingFromCheckout = true
        } else if segue.identifier == "toOrderPlaced" {
            
            print("Preparing for toOrderPlaced segue")
            
            let orderPlacedVC = segue.destination as! OrderPlacedVC
            orderPlacedVC.totalSpent = calculateTotal()
            orderPlacedVC.streetAddress = (order.address?.streetAddress)!
            
            // Calculate ETA range and format to String
            let calendar = Calendar.current
            let orderTime = order.orderTime
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            formatter.dateStyle = .none
            
            // Lower ETA
            let lowerETA = orderTime?.addingTimeInterval(35.0 * 60.0)
//            let lowerHour = calendar.component(.hour, from: lowerETA! as Date)
//            let lowerMinutes = calendar.component(.minute, from: lowerETA! as Date)
            
            // Upper ETA
            let upperETA = orderTime?.addingTimeInterval(55.0 * 60.0)
//            let upperHour = calendar.component(.hour, from: upperETA! as Date)
//            let upperMinutes = calendar.component(.minute, from: upperETA! as Date)
            
//            orderPlacedVC.ETA = "\(lowerHour):\(lowerMinutes)-\(upperHour):\(upperMinutes)"
            
            orderPlacedVC.ETA = formatter.string(from: lowerETA! as Date) + "-" + formatter.string(from: upperETA as! Date)
            
            print("Finished preparing for toOrderPlaced segue")
        } else if segue.identifier == "toSignIn" {
            let nav = segue.destination as! UINavigationController
            let signInVC = nav.topViewController as! SignInVC
            signInVC.comingFromCheckout = true
        }

    }


}
