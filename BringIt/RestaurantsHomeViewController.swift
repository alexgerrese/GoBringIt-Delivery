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
    @IBOutlet weak var downloadingView: UIView!
    @IBOutlet weak var downloadingTitle: UILabel!
    @IBOutlet weak var downloadingDetails: UILabel!
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var getStartedButton: UIButton!
    @IBOutlet weak var downloadingImage: UIImageView!
    
    // MARK: - Variables
    
    let refreshControl = UIRefreshControl()
    
    var restaurants: Results<Restaurant>!
    var backendVersionNumber = -1
    var selectedRestaurantID = ""
    
    let defaults = UserDefaults.standard // Initialize UserDefaults
    let realm = try! Realm() // Initialize Realm

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        // Prepare data for TableView and CollectionView
        restaurants = self.realm.objects(Restaurant.self)
        
        
        setupTableView()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupUI() {
        
        // Set title
        self.title = "Restaurants"
        
        downloadingView.alpha = 0
        getStartedButton.layer.cornerRadius = Constants.cornerRadius
        
        // Download restaurant data if necessary
        checkForUpdates()
    }
    
    func setupTableView() {
        
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
    
    func refreshData(refreshControl: UIRefreshControl) {
        checkForUpdates()
    }
    
    func showDownloadingView() {
        
        print("Showing downloading view")
        
        self.navigationController?.isNavigationBarHidden = true
        
        myActivityIndicator.isHidden = false
        myActivityIndicator.startAnimating()
        downloadingView.alpha = 1
        downloadingImage.image = UIImage(named: "RestaurantDataImage")
        downloadingTitle.text = "Downloading restaurant data..."
        downloadingDetails.text = "It’ll only take a few seconds, and once it’s done you’ll be able to use the app even offline (except ordering of course)!"
        getStartedButton.alpha = 0
        
       
        
    }
    
    func showFinishedDownloadingView() {
        
        myActivityIndicator.stopAnimating()
        myActivityIndicator.isHidden = true
        downloadingTitle.text = "Download Complete!"
        downloadingDetails.text = "You’re all set to use the GoBringIt Delivery app 🍣🍗🍔 Online or offline, you can always view our delicious menu and prepare your order 🎉"
        getStartedButton.alpha = 1
        getStartedButton.setTitle("Get Started", for: .normal)
        getStartedButton.setTitleColor(Constants.green, for: .normal)
        
    }
    
    func showErrorView() {
        
        myActivityIndicator.stopAnimating()
        myActivityIndicator.isHidden = true
        downloadingImage.image = UIImage(named: "RestaurantDataErrorImage")
        downloadingTitle.text = "Network Error"
        downloadingDetails.text = "Something went wrong 😱 Make sure you’re connected to the internet and try again!"
        getStartedButton.setTitle("Try Again!", for: .normal)
        getStartedButton.setTitleColor(Constants.red, for: .normal)
        
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        
        if downloadingTitle.text == "Download Complete!" {
            
            // Show checking out view
            UIView.animate(withDuration: 0.4, animations: {
                
                self.navigationController?.isNavigationBarHidden = false
                self.downloadingView.alpha = 0
            })
        } else {
            
            showDownloadingView()
            self.fetchRestaurantData()
        }
    }
    
    func checkForUpdates() {
        
        // Check if restaurant data already exists in Realm
        let dataExists = self.realm.objects(Restaurant.self).count > 0
        
        if !dataExists {
            
            print("No data exists. Fetching restaurant data.")
            
            showDownloadingView()
            
            // Create models from backend data
            self.fetchRestaurantData()
            
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
                    
                    // Create models from backend data
                    self.fetchRestaurantData()
                    
                } else {
                    
                    print("Version numbers match. Loading UI.")
                    
                    self.refreshControl.endRefreshing()
                }
            }
        }
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
        cell.openHours.text = self.getOpenHoursString(data: restaurant.restaurantHours)
        cell.bannerImage.image = UIImage(data: restaurant.image! as Data)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {

        selectedRestaurantID = restaurants[indexPath.row].id
        
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Open" // TO-DO: Change later when dynamic
    }
    
    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = Constants.headerFont
        header.textLabel?.textColor = Constants.darkGray
        header.textLabel?.textAlignment = .center
        header.backgroundView?.backgroundColor = Constants.backgroungGray
        header.textLabel?.text = header.textLabel?.text?.uppercased()
        
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.headerHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        myTableView.deselectRow(at: indexPath, animated: true)
        
        performSegue(withIdentifier: "toRestaurantDetail", sender: self)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "toRestaurantDetail" {
            let nav = segue.destination as! UINavigationController
            let detailVC = nav.topViewController as! RestaurantDetailViewController
            detailVC.restaurantID = selectedRestaurantID
        }
        
    }

}
