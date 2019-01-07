//
//  PastOrdersViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/25/17.
//  Copyright © 2017 Campus Enterprises. All rights reserved.
//

import UIKit
import RealmSwift

class PastOrdersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - IBOutlets

    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var emptyStateView: UIView!
    @IBOutlet weak var browseRestaurantsButton: UIButton!
    
    // MARK: - Variables
    
    let defaults = UserDefaults.standard // Initialize UserDefaults
    
    var user = User()
    var orders: Results<Order>!
    
    var selectedOrderID = 0
    var selectedRestaurant = Restaurant()
    var restaurants = [Restaurant]()
    var deliveryFee = 0.00
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup UI
        setupUI()
        
        // Setup Realm
        setupRealm()
        
        // Setup tableview
        setupTableView()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupUI() {
        
        // Set title
        self.title = "Order History"
        
        // Add border to Browse Restaurants button
        browseRestaurantsButton.layer.borderColor = Constants.darkGray.cgColor
        browseRestaurantsButton.layer.borderWidth = 1.6
        browseRestaurantsButton.layer.cornerRadius = Constants.cornerRadius
        
        setCustomBackButton()

    }
    
    func setupRealm() {
        
        let realm = try! Realm() // Initialize Realm
        
        let numberOfUsers = realm.objects(User.self)
        if numberOfUsers != nil && numberOfUsers.count > 0 {
            let filteredUsers = realm.objects(User.self).filter("isCurrent = %@", NSNumber(booleanLiteral: true))
            if let user = filteredUsers.first {
                orders = user.pastOrders.sorted(byKeyPath: "orderTime", ascending: false)
                
                if orders.count > 0 {
                    emptyStateView.isHidden = true
                } else {
                    emptyStateView.isHidden = false
                }

            }
        }

    }
    
    func setupTableView() {
        
        // Set tableView cells to custom height and automatically resize if needed
        self.myTableView.estimatedRowHeight = 150
        self.myTableView.rowHeight = UITableViewAutomaticDimension
        self.myTableView.setNeedsLayout()
        self.myTableView.layoutIfNeeded()
    }
    
    @IBAction func browseRestaurantsButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 // Make dynamic to months
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let o = orders {
            if o.count > 0 {
                return orders.count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let realm = try! Realm() // Initialize Realm
        let cell = tableView.dequeueReusableCell(withIdentifier: "pastOrderCell", for: indexPath) as! PastOrderTableViewCell
        
        // Format date components of order time
        let order = orders[indexPath.row]
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        let orderTime = order.orderTime
        let month = formatter.string(from: order.orderTime! as Date).uppercased()
        formatter.dateFormat = "d"
        let day = formatter.string(from: order.orderTime! as Date)
        
        // Get restaurant name
        var restaurantName = ""
        for restaurant in restaurants {
            if restaurant.id == order.restaurantID {
                restaurantName = restaurant.name
            }
        }
//        let restaurantName = realm.object(ofType: Restaurant.self, forPrimaryKey: order.restaurantID)?.name
        
        // Get order details
        let totalPrice = order.subtotal + order.deliveryFee
        let numberOfItems = order.menuItems.count
        
        cell.month.text = month
        cell.day.text = day
        cell.restaurantName.text = restaurantName
        cell.orderDetails.text = "$\(String(format: "%.2f", totalPrice)) • \(numberOfItems) items"
        cell.dateView.layer.cornerRadius = Constants.cornerRadius
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Past Orders" //TO-DO: Change when dynamic
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
        return Constants.headerHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedOrderID = orders[indexPath.row].id
        for restaurant in restaurants {
            if restaurant.id == orders[indexPath.row].restaurantID {
                selectedRestaurant = restaurant
            }
        }
        
        myTableView.deselectRow(at: indexPath, animated: true)
        
        performSegue(withIdentifier: "toPastOrderDetail", sender: self)
        
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let pastOrderDetailVC = segue.destination as! PastOrderDetailViewController
        pastOrderDetailVC.orderID = selectedOrderID
        pastOrderDetailVC.restaurant = selectedRestaurant
        
    }

}
