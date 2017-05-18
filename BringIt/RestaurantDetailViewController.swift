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
    
    @IBOutlet weak var myScrollView: UIScrollView!
    @IBOutlet weak var restaurantName: UILabel!
    @IBOutlet weak var cuisineAndHours: UILabel!
    @IBOutlet weak var bannerImage: UIImageView!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var viewCartButton: UIButton!
    @IBOutlet weak var cartSubtotal: UILabel!
    @IBOutlet weak var viewCartButtonView: UIView!
    @IBOutlet weak var viewCartView: UIView!
    
    // MARK: - Variables
    
    let realm = try! Realm() // Initialize Realm
    
    var restaurantID = ""
    var restaurant = Restaurant()
    var menuCategories = List<MenuCategory>()
    var selectedMenuCategoryID = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get selected restaurant and menu categories
        restaurant = realm.object(ofType: Restaurant.self, forPrimaryKey: restaurantID)!
        menuCategories = restaurant.menuCategories

        // Setup UI
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
        
        restaurantName.text = restaurant.name
        cuisineAndHours.text = restaurant.cuisineType + " • " + getOpenHoursString(data: restaurant.restaurantHours)
        bannerImage.image = UIImage(data: restaurant.image! as Data)
        viewCartButtonView.layer.cornerRadius = Constants.cornerRadius
        viewCartView.layer.shadowColor = Constants.lightGray.cgColor
        viewCartView.layer.shadowOpacity = 1
        viewCartView.layer.shadowRadius = Constants.shadowRadius
        viewCartView.layer.shadowOffset = CGSize.zero

    }
    
    func setupTableView() {
        
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        // Rewind segue to Restaurants VC
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCategoryCell", for: indexPath)
        
        cell.textLabel?.text = menuCategories[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        selectedMenuCategoryID = menuCategories[indexPath.row].id
        
        return indexPath
    }
    
    //    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    //        if section == 0 {
    //            return ""
    //        } else if section == 1 {
    //            return "- Open Restaurants -"
    //        } else {
    //            return "- Closed Restaurants -"
    //        }
    //    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "Avenir-Black", size: 15)!
        header.textLabel?.textColor = UIColor.darkGray
        header.textLabel?.textAlignment = .center
        header.backgroundView?.backgroundColor = UIColor.groupTableViewBackground
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return 25
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        myTableView.deselectRow(at: indexPath, animated: true)
        
        performSegue(withIdentifier: "toRestaurantDetail", sender: self)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override var prefersStatusBarHidden : Bool {
        return true
    }

}
