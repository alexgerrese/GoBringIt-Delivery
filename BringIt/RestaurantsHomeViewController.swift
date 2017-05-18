//
//  RestaurantsHomeViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/17/17.
//  Copyright © 2017 Campus Enterprises. All rights reserved.
//

// Show activityIndicator

// download the new always-refreshed data

// check if Realm already has all other Restaurant data

    // if yes, check if there are updates to the data

    // if no, download the data and set all Realm attributes

// Stop activityIndicator



import UIKit
import Alamofire
import Moya
import RealmSwift

class RestaurantsHomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var myTableView: UITableView!
    
    // MARK: - Variables
    
    private let refreshControl = UIRefreshControl()
    
    var restaurants: Results<Restaurant>!
    var backendVersionNumber = -1
    
    let defaults = UserDefaults.standard // Initialize UserDefaults
    let realm = try! Realm() // Initialize Realm

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title
        self.title = "Restaurants"
        
        // Set tableView cells to custom height and automatically resize if needed
        self.myTableView.estimatedRowHeight = 230
        self.myTableView.rowHeight = UITableViewAutomaticDimension
        
        // Add refresh control capability
        if #available(iOS 10.0, *) {
            myTableView.refreshControl = refreshControl
        } else {
            myTableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(RestaurantsHomeViewController.refreshData(refreshControl:)), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Download restaurant data if necessary
        checkForUpdates()
        
        // Prepare data for TableView and CollectionView
        restaurants = self.realm.objects(Restaurant.self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshData(refreshControl: UIRefreshControl) {
        checkForUpdates()
        refreshControl.endRefreshing()
    }
    
    func checkForUpdates() {
        
        // Check if restaurant data already exists in Realm
        let dataExists = self.realm.objects(Restaurant.self).count > 0
        
        if !dataExists {
            
            print("No data exists. Fetching restaurant data.")
            
            // Create models from backend data
            fetchRestaurantData()
            
        } else {
            
            print("Data exists. Checking version numbers.")
            
            let currentVersionNumber = self.defaults.integer(forKey: "currentVersion")
            getBackendVersionNumber() {
                (result: Int) in
                
                print("Received backend version number via closure")
                self.backendVersionNumber = result
                
                print("Local version number: \(currentVersionNumber), Backend version number: \(self.backendVersionNumber)")
                
                if currentVersionNumber != self.backendVersionNumber {
                    
                    print("Version numbers do not match. Fetching updated restaurant data.")
                    
                    // Save new version number to UserDefaults
                    self.defaults.set(self.backendVersionNumber, forKey: "currentVersion")
                    
                    // Update models from backend data
                    self.fetchRestaurantData()
                } else {
                    
                    print("Version numbers match. Loading UI.")
                }

            }
        }
        
        self.refreshControl.endRefreshing()
        
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "restaurantsCell", for: indexPath) as! RestaurantTableViewCell
        
        let restaurant = restaurants[indexPath.row]
        
        cell.name.text = restaurant.name
        cell.cuisineType.text = restaurant.cuisineType
        cell.openHours.text = "SAMPLE TIME" // TO-DO: FINISH TIME STUFF
        cell.bannerImage.image = UIImage(data: restaurant.image! as Data)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
//        if (indexPath as NSIndexPath).section == 1 {
//            selectedRestaurantName = openRestaurants[(indexPath as NSIndexPath).row].restaurantName
//        } else if (indexPath as NSIndexPath).section == 2 {
//            selectedRestaurantName = closedRestaurants[(indexPath as NSIndexPath).row].restaurantName
//        }
        
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
