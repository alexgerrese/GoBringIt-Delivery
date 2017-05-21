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
    
    // MARK: - Variables
    
    let defaults = UserDefaults.standard // Initialize UserDefaults
    let realm = try! Realm() // Initialize Realm
    
    var order = Order()
    var user = User()
    var selectedItem = MenuItem()
    let defaultButtonText = "Checkout"
    
    // Passed from previousVC
    var restaurantID = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("In viewDidLoad")
        
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
    
    func setupRealm() {
        
        print("In setupRealm()")
        
        checkIfLoggedIn()
        
        // Query current order
        let predicate = NSPredicate(format: "restaurantID = %@ && isComplete = %@", restaurantID, NSNumber(booleanLiteral: false))
        let filteredOrders = realm.objects(Order.self).filter(predicate)
        
        order = filteredOrders.first!
        
    }
    
    func checkIfLoggedIn() {
        
        print("Checking if logged in")
        
        // If not logged in, go to SignInVC
        let loggedIn = defaults.bool(forKey: "loggedIn")
        if !loggedIn {
            
            print("Not logged in, going to SignInVC")
            performSegue(withIdentifier: "toSignIn", sender: self)
        } else {
            
            print("Logged in, querying user")
            // Check if user already exists in Realm
            let predicate = NSPredicate(format: "isCurrent = %@", NSNumber(booleanLiteral: true))
            user = self.realm.objects(User.self).filter(predicate).first!
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
        
        // Hide checking out view
        checkingOutView.isHidden = true
        
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
    
    func checkButtonStatus() {
        
        // If address and payment method are defined, enable button
        
        let filteredAddresses = self.realm.objects(Address.self).filter("userID = %@ AND isCurrent = %@", user.id, NSNumber(booleanLiteral: true))
        
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
    }

    @IBAction func checkoutButtonTapped(_ sender: UIButton) {
        
        // Show checking out view
        UIView.animate(withDuration: 0.4, animations: {
            self.checkingOutView.isHidden = false
        })
        
        setupConfirmView()
    }
    
    func setupConfirmView() {
        
        checkingOutView.backgroundColor = Constants.green
        checkingOutTitle.text = "Are you sure you want to checkout?"
        checkingOutDetails.text = "You will be charged \(String(format: "%.2f", calculateTotal())) upon delivery."
        confirmButton.setTitle("Yes, Checkout!", for: .normal)
        cancelButton.setTitle("Cancel", for: .normal)
    }
    
    func showConfirmViewError(errorTitle: String, errorMessage: String) {
        
        checkingOutView.backgroundColor = Constants.red
        checkingOutTitle.text = errorTitle
        checkingOutDetails.text = errorMessage
        confirmButton.setTitle("Try again!", for: .normal)
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        
        // Show checking out view
        UIView.animate(withDuration: 0.4, animations: {
            self.checkingOutView.isHidden = true
        })
    }
    
    @IBAction func confirmButtonTapped(_ sender: UIButton) {
        
        // Animate activity indicator
        myActivityIndicator.startAnimating()
        
        // Update UI
        checkingOutTitle.text = "Placing Order..."
        checkingOutDetails.text = ""
        confirmButton.isHidden = true
        cancelButton.isHidden = true
        
        var count = 0
        
        addAllToCart() {
            (result: Int) in
            
            count += 1
            
            print(count)
            if count == self.order.menuItems.count - 1 {
                self.addOrder()
            }
        }
    }
    
    func addAllToCart(completion: @escaping (_ result: Int) -> Void) {
        
        for item in order.menuItems {
            
            print("Adding to cart")
            
            var sideIDs = [String]()
            for side in item.sides {
                sideIDs.append(side.id)
            }
            for extra in item.extras {
                sideIDs.append(extra.id)
            }
            
            // Setup Moya provider and send network request
            let provider = MoyaProvider<APICalls>()
            provider.request(.addItemToCart(uid: user.id, quantity: item.quantity, itemID: item.id, sideIDs: sideIDs, specialInstructions: item.specialInstructions)) { result in
                switch result {
                case let .success(moyaResponse):
                    do {
                        
                        print("Status code: \(moyaResponse.statusCode)")
                        try moyaResponse.filterSuccessfulStatusCodes()
                        
                        let response = try moyaResponse.mapJSON() as! [String: Any]
                        
                        if response["success"] as! Int == 1 {
                            
                            print("Success adding item with id: \(item.id)!")
                        }
                        
                        completion(1)
                        
                    } catch {
                        // Miscellaneous network error
                        self.showConfirmViewError(errorTitle: "Network Error", errorMessage: "Something went wrong 😱 Make sure you're connected to the internet and please try again.")
                    }
                case .failure(_):
                    // Connection failed
                    self.showConfirmViewError(errorTitle: "Network Error", errorMessage: "Something went wrong 😱 Make sure you're connected to the internet and please try again.")
                }
            }
        }
    }
    
    func addOrder() {
        
        print("Adding to order")
        
        let filteredPaymentMethods = realm.objects(PaymentMethod.self).filter("userID = %@ AND isSelected = %@", user.id, NSNumber(booleanLiteral: true))
        
        // Setup Moya provider and send network request
        let provider = MoyaProvider<APICalls>()
        provider.request(.addOrder(uid: user.id, restaurantID: order.restaurantID, payingWithCC: filteredPaymentMethods.first!.method)) { result in
            switch result {
            case let .success(moyaResponse):
                do {
                    
                    print("Status code: \(moyaResponse.statusCode)")
                    try moyaResponse.filterSuccessfulStatusCodes()
                    
                    let response = try moyaResponse.mapJSON() as! [String: Any]
                    
                    if response["success"] as! Int == 1 {
                        
                        print("Success adding order to database)!")
                        
                        try! self.realm.write {
                            self.order.id = response["orderID"] as! Int
                            self.order.isComplete = true
                            
                            self.user.pastOrders.append(self.order)
                        }
                        
                        self.myActivityIndicator.stopAnimating()
                        
                        print(self.order.id)
                        
                        self.performSegue(withIdentifier: "toOrderPlaced", sender: self)
                    }
                    
                } catch {
                    // Miscellaneous network error
                    self.showConfirmViewError(errorTitle: "Network Error", errorMessage: "Something went wrong 😱 Make sure you're connected to the internet and please try again.")
                }
            case .failure(_):
                // Connection failed
                self.showConfirmViewError(errorTitle: "Network Error", errorMessage: "Something went wrong 😱 Make sure you're connected to the internet and please try again.")
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
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "deliveryDetailCell", for: indexPath)
            
            // Delivery To
            if indexPath.row == 0 {
                
                cell.textLabel?.text = "Deliver To"

                let filteredAddresses = self.realm.objects(Address.self).filter("userID = %@ AND isCurrent = %@", user.id, NSNumber(booleanLiteral: true))
                
                if filteredAddresses.count > 0 {
                    cell.detailTextLabel?.text = filteredAddresses.first!.streetAddress
                } else {
                    cell.detailTextLabel?.text = "Please select a delivery address"
                }
                
            } else {
                
                cell.textLabel?.text = "Paying With"
                
                let filteredPaymentMethods = realm.objects(PaymentMethod.self).filter("userID = %@ AND isSelected = %@", user.id, NSNumber(booleanLiteral: true))
                
                if filteredPaymentMethods.count > 0 {
                    cell.detailTextLabel?.text = filteredPaymentMethods.first!.method
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
            cell.price.text = String(format: "%.2f", menuItem.totalCost)
            
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
                cell.detailTextLabel?.text = String(format: "%.2f", order.deliveryFee)
                
                return cell
            }
            // Total
            else if indexPath.row == 2 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "costCell", for: indexPath)
                
                cell.textLabel?.text = "Total"
                cell.detailTextLabel?.text = String(format: "%.2f", calculateTotal())
                
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
        header.textLabel?.textColor = Constants.darkGray
        header.textLabel?.textAlignment = .left
        header.backgroundView?.backgroundColor = Constants.backgroungGray
        header.textLabel?.text = header.textLabel?.text?.uppercased()
        
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 {
            return 0
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
        if editingStyle == .delete {
            
            // Delete the row from the data source
            try! realm.write {
                let item = order.menuItems[indexPath.row]
                order.subtotal -= item.totalCost
                realm.delete(item)
                
            }
            
            myTableView.deleteRows(at: [indexPath], with: .automatic)
            
            // Reload tableview and adjust tableview height and recalculate costs
            myTableView.reloadData()
            updateViewConstraints()
            calculateTotal()
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
        }

    }


}
