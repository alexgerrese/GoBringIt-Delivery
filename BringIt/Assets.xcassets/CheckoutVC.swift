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
    @IBOutlet weak var checkoutViewToBottom: NSLayoutConstraint!
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var deliveryOrPickup: UISegmentedControl!

    @IBOutlet weak var deliveryOrPickupToTop: NSLayoutConstraint!
    
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
    var travelTimeMessage = ""
    let dispatch_group = DispatchGroup()
    var addressId = -1
    
    // Section Indices
    var deliveryDetailsIndex = 0
    var menuItemsIndex = 1
    var totalIndex = 2
    
    // Row Indices
    var subtotalIndex = 0
    var deliveryFeeIndex = 1
    var goBringItCreditIndex = 2
    var totalCostIndex = 3
    
    // Passed from previousVC
//    var restaurantID = ""
    var restaurant = Restaurant()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup Realm
        setupRealm()
        
        // Setup UI
        setupUI()
        
        // Setup tableview
        setupTableView()
        
        // Calculate delivery fee
        calculateDeliveryFee()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        print("In viewWillAppear")
        
        // TO-DO: Check if coming from SignInVC
        checkIfLoggedIn()
        calculateDeliveryFee()
        calculateTotal()
        setupUI()
        myTableView.reloadData()
        checkButtonStatus()
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if !checkingOutView.isHidden {
            checkingOutView.removeFromSuperview()
        }
    }
    
    func setupRealm() {
        
        print("In setupRealm()")
        
        checkIfLoggedIn()
        
        let realm = try! Realm() // Initialize Realm
        
        // Query current order
        let predicate = NSPredicate(format: "restaurantID = %@ && isComplete = %@", restaurant.id, NSNumber(booleanLiteral: false))
        let filteredOrders = realm.objects(Order.self).filter(predicate)
        
        order = filteredOrders.first!
        
        // Query restaurant for printer email
//        let restaurants = realm.objects(Restaurant.self).filter("id = %@", restaurantID)
        restaurantEmail = restaurant.email
        restaurantPrinterEmail = restaurant.printerEmail
    }
    
//    func setupStripe() {
//        self.paymentContext = STPPaymentContext(customerContext: customerContext)
//        //        self.paymentContext.delegate = self // TODO: Uncomment
//        self.paymentContext.hostViewController = self
//        self.paymentContext.paymentAmount = Int(calculateTotal()*100.0)
//    }
    
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
            let users = realm.objects(User.self).filter(predicate)
            if users.count > 0 {
                user = users.first!
                Helper.app.updateUser(user: user)
            } else {
                print("Couldn't retrieve user, going to SignInVC")
                
                // Set up UserDefaults
                self.defaults.set(false, forKey: "loggedIn")
                
                performSegue(withIdentifier: "toSignIn", sender: self)
            }
            
        }
    }
    
    /* Do initial UI setup */
    func setupUI() {
        
        print("Setting up UI")
        
        setCustomBackButton()
        
        // Check if pickup option is available
        if restaurant.deliveryOnly {
            deliveryOrPickupToTop.constant = -44
        } else {
            deliveryOrPickupToTop.constant = 0
            myTableView.reloadData()
            
            // Check if correct segmented control index is selected
            if order.isDelivery {
                deliverySelected()
            } else {
                pickupSelected()
            }
        }
        
        self.title = "Checkout"
        checkoutButtonView.layer.cornerRadius = Constants.cornerRadius
        checkoutView.layer.shadowColor = Constants.lightGray.cgColor
        checkoutView.layer.shadowOpacity = 0.15
        checkoutView.layer.shadowRadius = Constants.shadowRadius
        checkoutView.layer.shadowOffset = CGSize.zero
        myActivityIndicator.isHidden = true
        
//        // Check if iPhone X or iPhone Xs Max
//        if UIScreen.main.nativeBounds.height == 2688 || UIScreen.main.nativeBounds.height == 2436 {
//            checkoutViewToBottom.constant = 0
//        } else {
//            checkoutViewToBottom.constant = 16
//        }
        
        // Setup checking out view
        checkingOutView.isHidden = true
        confirmButton.layer.cornerRadius = Constants.cornerRadius
        tryAgainButton.layer.cornerRadius = Constants.cornerRadius
        cancelButton.layer.cornerRadius = Constants.cornerRadius
        cancelButton.layer.borderColor = UIColor.white.cgColor
        cancelButton.layer.borderWidth = Constants.borderWidth
        tryAgainButton.isHidden = true
        
        checkButtonStatus()
    }
    
    /* Customize tableView attributes */
    func setupTableView() {
        
        print("Setting up tableview")
        
        // Set tableView cells to custom height and automatically resize if needed
        self.myTableView.estimatedRowHeight = 150
        self.myTableView.rowHeight = UITableView.automaticDimension
        self.myTableView.setNeedsLayout()
        self.myTableView.layoutIfNeeded()
        
    }
    
    /* Calculate delivery fee based on database. Some will be constant, some will depend on distance. */
    func calculateDeliveryFee(){
        
        print("Calculating delivery fee")
        
        let realm = try! Realm() // Initialize Realm
        
        if !order.isDelivery {
            print("Pickup order. No delivery fee necessary.")
            return
        }
        
//        if order.deliveryFee != -1.00 {
//            print("Delivery fee is constant: \(order.deliveryFee)")
//            return
//        }
        
        // If no address is selected, show temporary TBD label
        let filteredAddresses = realm.objects(DeliveryAddress.self).filter("userID = %@ AND isCurrent = %@", user.id, NSNumber(booleanLiteral: true))
        
        if filteredAddresses.count == 0 {
            print("Delivery fee is dynamic but can't be calculated becaues no delivery address has been selected.")
            return
        }
        
        // Setup Moya provider and send network request
        let provider = MoyaProvider<APICalls>()
        provider.request(.getDeliveryFee(addressString: (filteredAddresses.first?.streetAddress)!, restaurantID: restaurant.id)) { result in
            switch result {
            case let .success(moyaResponse):
                do {
                    
                    print("Status code for calculateDeliveryFee(): \(moyaResponse.statusCode)")
                    try moyaResponse.filterSuccessfulStatusCodes()
                    
                    let response = try moyaResponse.mapJSON() as! [String: Any]
                    print(response)
                    
                    if let success = response["success"] {
                        if (success as! Int) == 0 {
                            self.travelTimeMessage = response["travel_time_message"] as! String
                            print("TRAVEL TIME MESSAGE: \(self.travelTimeMessage)")
                            self.myTableView.reloadData()
                            
                            return
                        }
                    }
                    
                    if let deliveryFee = response["delivery_fee"] {
                        try! realm.write {
                            self.order.deliveryFee = deliveryFee as! Double
                        }
                        print("Successfully calculated dynamic delivery fee: \(self.order.deliveryFee)")
                        self.travelTimeMessage = response["travel_time_message"] as! String
                        print("TRAVEL TIME MESSAGE: \(self.travelTimeMessage)")
                        self.myTableView.reloadData()
                    }
                    
                } catch {
                    // Miscellaneous network error
                    print("Network Error")
                }
            case .failure(_):
                // Connection failed
                print("Connection failed.")
            }
        }
    }
    
    /* Iterate over menu items in cart and add their total costs to the subtotal */
    func calculateTotal() -> Double {
        
        let realm = try! Realm() // Initialize Realm
        
        // Base cost is 0.0
        var total = 0.0
        
        // Add all menu item subtotals
        for menuItem in order.menuItems {
            total += menuItem.totalCost
        }
        
        var subtotal = total
        
        var gbiCreditUsed = 0.0;
        
        // Add delivery fee
        if deliveryOrPickup.selectedSegmentIndex == 0 {
            total += order.deliveryFee >= 0.00 ? order.deliveryFee : 0.00
        }
        
        if (user.gbiCredit != 0){
            if (total >= user.gbiCredit){
                total -= user.gbiCredit
                gbiCreditUsed = user.gbiCredit
            }
            else{
                gbiCreditUsed = total
                total = 0
            }
        }
        else{
            goBringItCreditIndex = -1
            totalCostIndex -= 1
        }
        
        // Update order subtotal
        try! realm.write {
            order.subtotal = subtotal
            order.gbiCreditUsed = gbiCreditUsed
        }
        
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
        if order.isDelivery {
            let filteredAddresses = realm.objects(DeliveryAddress.self).filter("userID = %@ AND isCurrent = %@", user.id, NSNumber(booleanLiteral: true))
            
            
            if filteredAddresses.count == 0 {
                
                checkoutButton.isEnabled = false
                checkoutButtonView.backgroundColor = Constants.red
                checkoutButton.setTitle("Please select a delivery address", for: .normal)
                
                return
            }
        }
        
        // Check that there is a payment method selected
        if (order.paymentMethod == nil) && order.isDelivery {
            
            checkoutButton.isEnabled = false
            checkoutButtonView.backgroundColor = Constants.red
            checkoutButton.setTitle("Please select a payment method", for: .normal)
            
            return
        }
        
        // Check that the restaurant is open
        if !restaurant.isOpen() {
            checkoutButton.isEnabled = false
            checkoutButtonView.backgroundColor = Constants.red
            checkoutButton.setTitle("This restaurant is currently closed", for: .normal)

            return
        }
        
        // Check that the total exceeds the minimum order price
        let minimumPrice = restaurant.minimumPrice
        if order.subtotal < minimumPrice {
            checkoutButton.isEnabled = false
            checkoutButtonView.backgroundColor = Constants.red
            cartTotal.isHidden = true
            checkoutButton.setTitle("Order subtotal must be above $\(String(format: "%.2f", minimumPrice))", for: .normal)
            
            return
        }
        
        // Check that a valid delivery fee has been calculated
        if order.isDelivery && order.deliveryFee == -1.00 {
            checkoutButton.isEnabled = false
            checkoutButtonView.backgroundColor = Constants.red
            cartTotal.isHidden = true
            checkoutButton.setTitle("Failed to calculate delivery fee.", for: .normal)
            calculateDeliveryFee()
            
            return
        }
        
        // Enable button if all above tests pass
        checkoutButton.isEnabled = true
        checkoutButtonView.backgroundColor = Constants.green
        checkoutButton.setTitle("Checkout", for: .normal)
        cartTotal.isHidden = false
    }

    @IBAction func deliveryOrPickupTapped(_ sender: Any) {
        
        // Delivery is selected
        if deliveryOrPickup.selectedSegmentIndex == 0 {
            deliverySelected()
        }
        // Pickup is selected
        else {
            pickupSelected()
        }
        
        calculateTotal()
        
        UIView.transition(with: myTableView,
                          duration: 0.1,
                          options: .transitionCrossDissolve,
                          animations: { self.myTableView.reloadData() })
        
        checkButtonStatus()
        
    }
    
    func deliverySelected() {
        
        let realm = try! Realm() // Initialize Realm
        
        try! realm.write {
            order.isDelivery = true
        }
        
        deliveryOrPickup.selectedSegmentIndex = 0
        
        deliveryDetailsIndex = 0
        menuItemsIndex = 1
        totalIndex = 2
        subtotalIndex = 0
        deliveryFeeIndex = 1
        goBringItCreditIndex = 2
        totalCostIndex = 3
    }
    
    func pickupSelected() {
        
        let realm = try! Realm() // Initialize Realm
        
        try! realm.write {
            order.isDelivery = false
        }
        
        deliveryOrPickup.selectedSegmentIndex = 1
        
        deliveryDetailsIndex = -1
        menuItemsIndex = 0
        totalIndex = 1
        subtotalIndex = 0
        deliveryFeeIndex = -1
        goBringItCreditIndex = 1
        totalCostIndex = 2
    }
    
    @IBAction func checkoutButtonTapped(_ sender: UIButton) {
        
        // Show checking out view
        UIView.animate(withDuration: 0.4, animations: {
            self.checkingOutView.isHidden = false
        })
        
        // Add haptic feedback
        if #available(iOS 10.0, *) {
            let notification = UINotificationFeedbackGenerator()
            notification.notificationOccurred(.warning)
        }
        
        setupConfirmView()
    }
    
    func setupConfirmView() {
        
        //UIApplication.shared.keyWindow?.addSubview(checkingOutView) //TO-DO: CHANGE THIS TO REMOVE NAVBAR FROM CHECKOUTVIEW
        self.view.layoutIfNeeded()
        
        tryAgainButton.isHidden = true
        confirmButton.isHidden = false
        confirmButton.isEnabled = true
        checkingOutView.backgroundColor = Constants.green
        checkingOutTitle.text = "Are you sure you want to checkout?"
        checkingOutDetails.text = "Your order total is $\(String(format: "%.2f", calculateTotal()))."
        cancelButton.setTitle("Cancel", for: .normal)
    }
    
    func showConfirmViewError(errorTitle: String, errorMessage: String) {
        
        tryAgainButton.isHidden = false
        cancelButton.isHidden = false
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
            self.checkingOutView.isHidden = true
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
        confirmButton.isHidden = true
        cancelButton.isHidden = true
        confirmButton.isEnabled = false
        cancelButton.isEnabled = false
        
        // Add final Realm details
        try! realm.write {
            
            let filteredAddresses = realm.objects(DeliveryAddress.self).filter("userID = %@ AND isCurrent = %@", user.id, NSNumber(booleanLiteral: true))
            order.address = filteredAddresses.first!
            order.paidWithString = order.paymentMethod?.paymentString ?? ""
        }
        
        // If paying via credit card, charge card first before placing order
        if order.paymentMethod?.paymentMethodID == 2 {
            print("PAYING WITH STRIPE CREDIT CARD")
            chargeCard()
        } else {
            print("NOT PAYING WITH STRIPE CREDIT CARD")
            placeOrder()
        }
    }
    
    /* Places actual order once all preliminary checks and confirmations have been successfully completed. */
    func placeOrder() {
        
        var count = 0
        clearCart() {
            (result: Int) in
                if (result == 1){
                    self.addAllToCart() {
                        (result: Int) in
                        
                        count += 1
                        
                        print(count)
                        if count == self.order.menuItems.count {
                            self.addOrder()
                        }
                    }
                }
        }
    }

    @IBAction func XButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
   
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // Pickup is selected
        if deliveryOrPickup.selectedSegmentIndex == 1 {
            return 2
        }
        
        // Default: Delivery is selected
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == deliveryDetailsIndex {
            return 2
        } else if section == menuItemsIndex {
            return order.menuItems.count
        } else {
            var segments = 2 // Subtotal + Total
            if deliveryOrPickup.selectedSegmentIndex == 0 {
                segments+=1 // Delivery Fee
            }
            if order.gbiCreditUsed > 0 {
                segments+=1 //GBI Credit
            }
            return segments
        }

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let realm = try! Realm() // Initialize Realm
        
        if indexPath.section == deliveryDetailsIndex {
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
                
                if order.paymentMethod != nil {
                
                    cell.detailTextLabel?.text = order.paymentMethod?.paymentString
                    print(order.paymentMethod?.paymentPin ?? "couldn't print pin")
                    
                } else {
                    cell.detailTextLabel?.text = "Please select a payment method"
                }
                
            }
            
            return cell
        } else if indexPath.section == menuItemsIndex {
            
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
                let index = otherDetails.index(otherDetails.startIndex, offsetBy: otherDetails.count - 2)
                otherDetails = otherDetails.substring(to: index)
                otherDetails = otherDetails + "\n" + menuItem.specialInstructions
            }
            
            cell.otherDetails.text = otherDetails
            
            return cell
        } else {
            
            // Subtotal
            if indexPath.row == subtotalIndex {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "costCell", for: indexPath)
                
                cell.textLabel?.text = "Subtotal"
                cell.detailTextLabel?.text = "$" + String(format: "%.2f", order.subtotal)
                
                return cell
            }
            // Delivery Fee
            else if indexPath.row == deliveryFeeIndex {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "costCell", for: indexPath)
                
                cell.textLabel?.text = "Delivery Fee"
                if order.deliveryFee != -1.00 {
                    cell.detailTextLabel?.text = "$" + String(format: "%.2f", order.deliveryFee)
                } else {
                    cell.detailTextLabel?.text = "TBD"
                }
                
                return cell
            }
            // GoBringIt Credit
            else if indexPath.row == goBringItCreditIndex {
                
                if order.gbiCreditUsed > 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "costCell", for: indexPath)
                    
                    cell.textLabel?.text = "GoBringIt Credit"
                   
                    cell.detailTextLabel?.text = "$" + String(format: "%.2f", order.gbiCreditUsed)
                    return cell
                }
            }
            // Total
            else if indexPath.row == totalCostIndex {
                
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
        if section == deliveryDetailsIndex {
            return "Delivery Details"
        } else if section == menuItemsIndex {
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
        if section == totalIndex {
            return CGFloat.leastNormalMagnitude
        }
        return Constants.headerHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == deliveryDetailsIndex {
            
            if indexPath.row == 0 {
                
                performSegue(withIdentifier: "toAddressesFromCheckout", sender: self)
            } else if indexPath.row == 1 {
                
                performSegue(withIdentifier: "toPaymentMethodsFromCheckout", sender: self)
            }
        } else if indexPath.section == menuItemsIndex {
            
            selectedItem = order.menuItems[indexPath.row]
            performSegue(withIdentifier: "toAddToCartFromCheckout", sender: self)
        }
        
        myTableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == menuItemsIndex {
            return true
        }
        
        return false
    }
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let realm = try! Realm() // Initialize Realm
        
        if indexPath.section == menuItemsIndex {
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
                checkButtonStatus()
            }
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toAddToCartFromCheckout" {
            let nav = segue.destination as! UINavigationController
            let addToCartVC = nav.topViewController as! AddToCartVC
            addToCartVC.menuItem = selectedItem
            addToCartVC.comingFromCheckout = true
        } else if segue.identifier == "toOrderPlaced" {
            
            print("Preparing for toOrderPlaced segue")
            
            let orderPlacedVC = segue.destination as! OrderPlacedVC
            orderPlacedVC.totalSpent = calculateTotal()
            orderPlacedVC.streetAddress = (order.address?.streetAddress)!
            
            // Calculate ETA range and format to String
//            let calendar = Calendar.current
//            let orderTime = order.orderTime
//            let formatter = DateFormatter()
//            formatter.timeStyle = .short
//            formatter.dateStyle = .none
//
//            // Lower ETA
//            let lowerETA = orderTime?.addingTimeInterval(35.0 * 60.0)
////            let lowerHour = calendar.component(.hour, from: lowerETA! as Date)
////            let lowerMinutes = calendar.component(.minute, from: lowerETA! as Date)
//
//            // Upper ETA
//            let upperETA = orderTime?.addingTimeInterval(55.0 * 60.0)
////            let upperHour = calendar.component(.hour, from: upperETA! as Date)
////            let upperMinutes = calendar.component(.minute, from: upperETA! as Date)
//
////            orderPlacedVC.ETA = "\(lowerHour):\(lowerMinutes)-\(upperHour):\(upperMinutes)"
//
//            orderPlacedVC.ETA = formatter.string(from: lowerETA! as Date) + "-" + formatter.string(from: upperETA as! Date)
            
            orderPlacedVC.ETA = travelTimeMessage
            
            print("Finished preparing for toOrderPlaced segue")
        } else if segue.identifier == "toSignIn" {
            let nav = segue.destination as! UINavigationController
            let signInVC = nav.topViewController as! SignInVC
            signInVC.comingFromCheckout = true
        }
        else if segue.identifier == "toPaymentMethodsFromCheckout" {
            let paymentMethodsVC = segue.destination as! PaymentMethodsVC
            paymentMethodsVC.paymentOptions = restaurant.paymentOptions
            paymentMethodsVC.comingFromCheckout = true
            paymentMethodsVC.order = order
            paymentMethodsVC.selectedPaymentKey = order.paymentMethod?.compoundKey
        }
        else if segue.identifier == "toAddressesFromCheckout" {
            let addressesVC = segue.destination as! AddressesViewController
            let realm = try! Realm() // Initialize Realm
            let filteredAddresses = realm.objects(DeliveryAddress.self).filter("userID = %@ AND isCurrent = %@", user.id, NSNumber(booleanLiteral: true))
            addressesVC.order = order
            if filteredAddresses.count > 0 {
                addressesVC.selectedAddressId = filteredAddresses.first!.id
            }
        }

    }


}
