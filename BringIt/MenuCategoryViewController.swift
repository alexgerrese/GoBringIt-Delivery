//
//  MenuCategoryViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/18/17.
//  Copyright © 2017 Campus Enterprises. All rights reserved.
//

import UIKit
import RealmSwift

class MenuCategoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var viewCartButton: UIButton!
    @IBOutlet weak var cartSubtotal: UILabel!
    @IBOutlet weak var viewCartButtonView: UIView!
    @IBOutlet weak var viewCartView: UIView!
    @IBOutlet weak var viewCartViewToBottom: NSLayoutConstraint!
    
    // MARK: - Variables
    
    let defaults = UserDefaults.standard // Initialize UserDefaults
    
    var menuCategoryID = ""
    var restaurantID = ""
    var menuCategory = MenuCategory()
    var cart = Order()
    var menuItems: Results<MenuItem>!
    var selectedMenuItemID = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup Realm
        setupRealm()
        
        // Setup UI
        setupUI()
        
        // Setup tableview
        setupTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Check if there is a cart to display
        checkCart()
    }
    
    func setupUI() {
        
        setCustomBackButton()
        
        self.title = menuCategory.name
        
        viewCartButtonView.layer.cornerRadius = Constants.cornerRadius
        viewCartView.backgroundColor = UIColor.white
        self.viewCartView.layer.shadowColor = Constants.lightGray.cgColor
        self.viewCartView.layer.shadowOpacity = 0.15
        self.viewCartView.layer.shadowRadius = Constants.shadowRadius
        viewCartViewToBottom.constant = viewCartView.frame.height // start offscreen
    }
    
    func setupRealm() {
        
        let realm = try! Realm() // Initialize Realm
        
        // Get selected restaurant and menu categories
        menuCategory = realm.object(ofType: MenuCategory.self, forPrimaryKey: menuCategoryID)!
        menuItems = menuCategory.menuItems.sorted(byKeyPath: "name")
        
    }
    
    func setupTableView() {
        
        // Set tableView cells to custom height and automatically resize if needed
        self.myTableView.estimatedRowHeight = 150
        self.myTableView.rowHeight = UITableViewAutomaticDimension
        self.myTableView.setNeedsLayout()
        self.myTableView.layoutIfNeeded()
//        viewCartViewToBottom.constant = 60
    }
    
    func checkCart() {
        
        let realm = try! Realm() // Initialize Realm
        
        let predicate = NSPredicate(format: "restaurantID = %@ AND isComplete = %@", restaurantID, NSNumber(booleanLiteral: false))
        let filteredOrders = realm.objects(Order.self).filter(predicate)
        if filteredOrders.count > 0 {
            
            print("Cart exists. Showing View Cart button")
            
            cart = filteredOrders.first!
            print(cart.subtotal)
            print(cart.restaurantID)
            print(cart.menuItems)
            
            cartSubtotal.text = "$" + String(format: "%.2f", cart.subtotal)
            
            // Check if iPhone X
            if UIScreen.main.nativeBounds.height == 2436 {
                viewCartViewToBottom.constant = 0
            } else {
                viewCartViewToBottom.constant = 16
            }
        } else {
            
            print("Cart does not exist. Hide View Cart button")
            
            viewCartViewToBottom.constant = viewCartView.frame.height
        }

        UIView.animate(withDuration: 0.4, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func viewCartButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toCheckoutFromMenuCategory", sender: self)
    }

    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let realm = try! Realm() // Initialize Realm
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuItemCell", for: indexPath) as! MenuItemTableViewCell
        
        cell.name.text = menuItems[indexPath.row].name
        cell.details.text = menuItems[indexPath.row].details
        let price = menuItems[indexPath.row].price
        cell.price.text = "$" + String(format: "%.2f", price)
        cell.tag = indexPath.row
        
        let image = menuItems[indexPath.row].image
        if image != nil {
            
            print("Image is already saved at index: \(indexPath.row).")
            
            cell.menuImage.image = UIImage(data: image! as Data)
        } else {
            
            let imageURL = menuItems[indexPath.row].imageURL
            if imageURL != "" {
                
                print("Image is not yet saved. Downloading asynchronously.")
                
                DispatchQueue.global(qos: .background).async {
                    let url = URL(string: imageURL)
                    let imageData = NSData(contentsOf: url!)
                    
                    DispatchQueue.main.async {
                        // Cache image
                        let realm = try! Realm() // Initialize Realm
                        try! realm.write {
                            self.menuItems[indexPath.row].image = imageData
                        }
                        
                        // Set image to downloaded asset only if cell is still visible
                        cell.menuImage.alpha = 0
                        if imageURL == self.menuItems[indexPath.row].imageURL && imageData != nil {
                            cell.menuImage.image = UIImage(data: imageData! as Data)
                            UIView.animate(withDuration: 0.3) {
                                cell.menuImage.alpha = 1
                            }
                        }
                    }
                }
            } else {
                print("Image does not exist.")
                cell.menuImage.image = nil
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        selectedMenuItemID = menuItems[indexPath.row].id
        
        return indexPath
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
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        myTableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "toAddToCart", sender: self)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toAddToCart" {
            let nav = segue.destination as! UINavigationController
            let addToCartVC = nav.topViewController as! AddToCartVC
            addToCartVC.menuItemID = selectedMenuItemID
            addToCartVC.restaurantID = restaurantID
        } else if segue.identifier == "toCheckoutFromMenuCategory" {
            
            let nav = segue.destination as! UINavigationController
            let checkoutVC = nav.topViewController as! CheckoutVC
            checkoutVC.restaurantID = restaurantID
        }
    }

}
