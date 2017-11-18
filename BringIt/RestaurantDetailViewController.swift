//
//  RestaurantDetailViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/18/17.
//  Copyright © 2017 Campus Enterprises. All rights reserved.
//

import UIKit
import RealmSwift

class RestaurantDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - IBOutlets

    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var viewCartButton: UIButton!
    @IBOutlet weak var cartSubtotal: UILabel!
    @IBOutlet weak var viewCartButtonView: UIView!
    @IBOutlet weak var viewCartView: UIView!
    @IBOutlet weak var viewCartViewToBottom: NSLayoutConstraint!
    
    // MARK: - Variables
    
    let defaults = UserDefaults.standard // Initialize UserDefaults
    
    var restaurantID = ""
    var restaurant = Restaurant()
    var cart = Order()
    var menuCategories: Results<MenuCategory>!
    var selectedMenuCategoryID = ""
    var selectedMenuItemID = ""
    
    // For collection view
    var featuredDishes = List<MenuItem>()
    var storedOffsets = [Int: CGFloat]()
    var bannerIndex = 0
    var callRestaurantIndex = 1
    var featuredDishesIndex = -1
    var dishesIndex = -1

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // Setup UI
        setupUI()
        
        // Setup Realm
        setupRealm()
        
        // Check if there is a cart to display
        checkCart()
        
        // Setup tableview
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Check if there is a cart to display
        checkCart()
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupUI() {
        
        setCustomBackButton()
        
        viewCartButtonView.layer.cornerRadius = Constants.cornerRadius
        viewCartView.layer.shadowColor = Constants.lightGray.cgColor
        viewCartView.layer.shadowOpacity = 1
        viewCartView.layer.shadowRadius = Constants.shadowRadius
        viewCartView.layer.shadowOffset = CGSize.zero
        viewCartViewToBottom.constant = 60 // start offscreen
    }
    
    func setupRealm() {
        
        let realm = try! Realm() // Initialize Realm
        
        // Get selected restaurant and menu categories
        restaurant = realm.object(ofType: Restaurant.self, forPrimaryKey: restaurantID)!
        menuCategories = restaurant.menuCategories.sorted(byKeyPath: "name")
        
        for menuCategory in menuCategories {
            
            let items = menuCategory.menuItems
            let filteredItems = items.filter("isFeatured = %@", true)
            
            featuredDishes.append(contentsOf: filteredItems)
        }
        
        
        if (featuredDishes.count) > 0 {
            featuredDishesIndex = 2
            dishesIndex = 3
        } else {
            dishesIndex = 2
        }
        
        print("Number of featured dishes: \(featuredDishes.count)")
        
    }
    
    func setupTableView() {
        
        // Set tableView cells to custom height and automatically resize if needed
//        self.myTableView.estimatedRowHeight = 150
//        self.myTableView.rowHeight = UITableViewAutomaticDimension
//        self.myTableView.setNeedsLayout()
//        self.myTableView.layoutIfNeeded()
    }
    
    func checkCart() {
        
        let realm = try! Realm() // Initialize Realm
        
        let predicate = NSPredicate(format: "restaurantID = %@ AND isComplete = %@", restaurantID, NSNumber(booleanLiteral: false))
        let filteredOrders = realm.objects(Order.self).filter(predicate)
        if filteredOrders.count > 0 {
            
            print("Cart exists. Showing View Cart button")
            
            cart = filteredOrders.first!
            
            cartSubtotal.text = "$" + String(format: "%.2f", cart.subtotal)
            
            viewCartViewToBottom.constant = 0
        } else {
            
            print("Cart does not exist. Hide View Cart button")
            
            viewCartViewToBottom.constant = 60
        }
        
        UIView.animate(withDuration: 0.4, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func viewCartButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toCheckoutFromRestaurantDetail", sender: self)
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        // Rewind segue to Restaurants VC
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if featuredDishes.count > 0 {
            return 4
        }
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == dishesIndex {
            return menuCategories.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.section == featuredDishesIndex {
            guard let tableViewCell = cell as? FeaturedDishTableViewCell else { return }
            
            tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
            tableViewCell.collectionViewOffset = storedOffsets[indexPath.row] ?? 0
        }

    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.section == featuredDishesIndex {
            
            guard let tableViewCell = cell as? FeaturedDishTableViewCell else { return }
            
            storedOffsets[indexPath.row] = tableViewCell.collectionViewOffset
        }

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.section == bannerIndex {
            return 178
        } else if indexPath.section == featuredDishesIndex {
            return 155
        }
        return 45
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == bannerIndex {
            let cell = tableView.dequeueReusableCell(withIdentifier: "bannerCell", for: indexPath) as! BannerTableViewCell
            
            cell.delegate = self
            cell.restaurantName.text = restaurant.name
            cell.cuisineAndHours.text = restaurant.cuisineType + " • " + restaurant.restaurantHours.getOpenHoursString()
            cell.bannerImage.image = UIImage(data: restaurant.image! as Data)
            
            return cell

        } else if indexPath.section == callRestaurantIndex {
            let cell = tableView.dequeueReusableCell(withIdentifier: "callRestaurantCell", for: indexPath)
            
            let formattedNumber = restaurant.phoneNumber.toPhoneNumber()
            cell.detailTextLabel?.text = formattedNumber
            
            return cell
        } else if indexPath.section == dishesIndex {
           let cell = tableView.dequeueReusableCell(withIdentifier: "menuCategoryCell", for: indexPath)
        
        cell.textLabel?.text = menuCategories[indexPath.row].name
        
        return cell 
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "featuredDishTableViewCell", for: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        if indexPath.section == featuredDishesIndex {
            
            // TO-DO: Fill this out
            // selectedMenuCategoryID =
            
        } else if indexPath.section == dishesIndex {
            selectedMenuCategoryID = menuCategories[indexPath.row].id
        }
        
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == featuredDishesIndex {
            return "Most Popular Dishes"
        } else if section == dishesIndex {
            return "Menu Categories"
        }
         return ""
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
        if section == bannerIndex || section == callRestaurantIndex {
            return CGFloat.leastNormalMagnitude
        }
        return Constants.headerHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        myTableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == callRestaurantIndex {
            let url = URL(string: "telprompt://" + restaurant.phoneNumber)
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url!)
            }
        } else if indexPath.section == dishesIndex {
            
            performSegue(withIdentifier: "toMenuCategory", sender: self)
        }

    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toMenuCategory" {
            let menuCategoryVC = segue.destination as! MenuCategoryViewController
            menuCategoryVC.menuCategoryID = selectedMenuCategoryID
            menuCategoryVC.restaurantID = restaurantID
        } else if segue.identifier == "toCheckoutFromRestaurantDetail" {
            
            let nav = segue.destination as! UINavigationController
            let checkoutVC = nav.topViewController as! CheckoutVC
            checkoutVC.restaurantID = restaurantID
        } else if segue.identifier == "toAddToCartFromRestaurantDetail" {
            
            let nav = segue.destination as! UINavigationController
            let addToCartVC = nav.topViewController as! AddToCartVC
            addToCartVC.menuItemID = selectedMenuItemID
            addToCartVC.restaurantID = restaurantID

        }
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }

}

extension RestaurantDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return featuredDishes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "featuredDishCell", for: indexPath) as! FeaturedDishCollectionViewCell
        
        let featuredDish = featuredDishes[indexPath.row]
        
        cell.dishImage.image = UIImage(data: featuredDish.image! as Data)
        cell.dishName.text = featuredDish.name
//        cell.dishDescription.text = featuredDish.details
        cell.dishPrice.text = "$" + String(format: "%.2f", (featuredDish.price))

        print("returning collection view cell")
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: 147)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        selectedMenuItemID = featuredDishes[indexPath.row].id
        performSegue(withIdentifier: "toAddToCartFromRestaurantDetail", sender: self)

    }

}

extension RestaurantDetailViewController: BannerCellDelegate {
    
    func cancelButtonTapped(cell: BannerTableViewCell) {
        self.dismiss(animated: true, completion: nil)
    }
    

}

