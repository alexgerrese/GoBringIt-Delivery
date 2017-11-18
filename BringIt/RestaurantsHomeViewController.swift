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
    var promotions: Results<Promotion>!
    var storedOffsets = [Int: CGFloat]()
    var alertMessage = ""
    var alertMessageIndex = -1
    var promotionsIndex = -1
    var restaurantsIndex = -1
    var alreadyDisplayedCollectionView = false
    
    var selectedPromotionID = ""
    
    let defaults = UserDefaults.standard // Initialize UserDefaults

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let realm = try! Realm() // Initialize Realm
        
        // Set base index
        restaurantsIndex = 0
        
        // Setup UI
        setupUI()
        
        // Prepare data for TableView and CollectionView
        restaurants = realm.objects(Restaurant.self)
        promotions = realm.objects(Promotion.self)
        
        // Setup TableView
        setupTableView()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupUI() {
        
        setCustomBackButton()
        
        // Set logo as title
        let logo = UIImage(named: "NavBarLogo")
        let imageView = UIImageView(image: logo)
        imageView.contentMode = .scaleAspectFit // set imageview's content mode
        self.navigationItem.titleView = imageView
        
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
    
    func updateIndices() {
        
        // TO-DO: Add third check for messages from server (put those in the getbackendnumber call
        
        if alertMessage != "" {
            if promotions.count > 0 {
                alertMessageIndex = 0
                promotionsIndex = 1
                restaurantsIndex = 2
            } else {
                alertMessageIndex = 0
                restaurantsIndex = 1
            }
        } else {
            if promotions.count > 0 {
                promotionsIndex = 0
                restaurantsIndex = 1
            } else {
                restaurantsIndex = 0
            }
        }
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
        
        let realm = try! Realm() // Initialize Realm
        
        // Check if restaurant data already exists in Realm
        let dataExists = realm.objects(Restaurant.self).count > 0
        
        if !dataExists {
            
            print("No data exists. Fetching restaurant data.")
            
            // Retrieving backend number
            getBackendVersionNumber() {
                (result: Int) in
            }
            
            // Retrieving promotions
            fetchPromotions() {
                (result: Int) in

                self.updateIndices()
                self.myTableView.reloadData()
            }
            
            // Show loading view as empty state
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
                    
                    // Delete current promotions
                    try! realm.write {
                        
                        let promotions = realm.objects(Promotion.self)
                        realm.delete(promotions)
                        print("After deleting, there are \(promotions.count) promotions")
                    }
                    
                    // Update promotions
                    self.fetchPromotions() {
                        (result: Int) in
                        
                        self.updateIndices()
                        self.myTableView.reloadData()
                    }
                    
                    // Save new version number to UserDefaults
                    self.defaults.set(self.backendVersionNumber, forKey: "currentVersion")
                    
                    // Create models from backend data
                    self.fetchRestaurantData()
                    
                } else {
                    
                    print("Version numbers match. Loading UI.")
                    
                    self.updateIndices()
                    self.myTableView.reloadData()
                    
                    self.refreshControl.endRefreshing()
                }
            }
        }
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        var count = 1
        
        if alertMessage != "" {
            count += 1
        }
        
        if promotions.count > 0 {
            count += 1
        }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == promotionsIndex || section == alertMessageIndex {
            return 1
        } else if section == restaurantsIndex {
            return restaurants.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.section == promotionsIndex {
            guard let tableViewCell = cell as? PromotionsTableViewCell else { return }
            
            tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
            if !alreadyDisplayedCollectionView && promotions.count > 2 {
                alreadyDisplayedCollectionView = true
                let i = IndexPath(item: 1, section: 0)
                tableViewCell.myCollectionView.scrollToItem(at: i, at: .centeredHorizontally, animated: true)
            } else {
                tableViewCell.collectionViewOffset = storedOffsets[indexPath.row] ?? 0
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.section == promotionsIndex {
            
            guard let tableViewCell = cell as? PromotionsTableViewCell else { return }
            
            storedOffsets[indexPath.row] = tableViewCell.collectionViewOffset
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == promotionsIndex {
            return UIScreen.main.bounds.width*0.85*0.51
        } else if indexPath.section == restaurantsIndex {
            return 230
        } else {
            return 60
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == alertMessageIndex {
            let cell = tableView.dequeueReusableCell(withIdentifier: "alertMessageCell", for: indexPath)
            
            cell.textLabel?.text = alertMessage
            
            return cell
        } else if indexPath.section == restaurantsIndex {
            let cell = tableView.dequeueReusableCell(withIdentifier: "restaurantsCell", for: indexPath) as! RestaurantTableViewCell
            
            let restaurant = restaurants[indexPath.row]
            
            cell.name.text = restaurant.name
            cell.cuisineType.text = restaurant.cuisineType
            cell.bannerImage.image = UIImage(data: restaurant.image! as Data)
            
            let todaysHours = restaurant.restaurantHours.getOpenHoursString()
            if (restaurant.isOpen()) {
                cell.openHours.text = "Open"
            } else if todaysHours == "Hours unavailable" {
                cell.openHours.text = todaysHours
            } else {
                cell.openHours.text = "Closed"
            }
            
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "promotionsCell", for: indexPath)
        
        return cell

    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        if indexPath.section == promotionsIndex {
            // TO-DO: Implement
        } else if indexPath.section == restaurantsIndex {
            selectedRestaurantID = restaurants[indexPath.row].id
        }

        return indexPath
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == restaurantsIndex {
            return "Restaurants"
        }
        return ""
        
    }
    
    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = Constants.headerFont
        header.textLabel?.textColor = Constants.darkGray
        header.textLabel?.textAlignment = .center
        header.backgroundView?.backgroundColor = UIColor.white
        header.textLabel?.text = header.textLabel?.text?.uppercased()
        
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == restaurantsIndex {
            return Constants.headerHeight
        }
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        myTableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == promotionsIndex {
            performSegue(withIdentifier: "toPromotionVC", sender: self)
        } else if indexPath.section == restaurantsIndex {
            performSegue(withIdentifier: "toRestaurantDetail", sender: self)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "toRestaurantDetail" {
            let nav = segue.destination as! UINavigationController
            let detailVC = nav.topViewController as! RestaurantDetailViewController
            detailVC.restaurantID = selectedRestaurantID
        } else if segue.identifier == "toPromotionVC" {
            let promotionVC = segue.destination as! PromotionsViewController
            promotionVC.passedPromotionID = selectedPromotionID
        }
        
    }

}

extension RestaurantsHomeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("Number of promotions: \(promotions.count)")
        return promotions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "promotionCell", for: indexPath) as! PromotionCollectionViewCell
        
        // TO-DO: UNCOMMENT FOR SHADOW
        
//        cell.promotionImage.layer.shadowOffset = CGSize(width: 0, height: 10)
//        cell.promotionImage.layer.shadowRadius = 5
//        cell.promotionImage.layer.shadowColor = UIColor.black.cgColor
//        cell.promotionImage.layer.shadowOpacity = 0.25
//        cell.promotionImage.layer.masksToBounds = false
        cell.promotionImage.image = UIImage(data: promotions[indexPath.row].image! as Data)
        
        
        return cell
    }
    
    // TO-DO: Finish implementing this feature
    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        
//        let restaurantID = promotions[indexPath.row % promotions.count].restaurantID
//        selectedPromotionID = promotions[indexPath.row].id
//        
//        if restaurantID != "0" && restaurantID != nil {
//            
//            selectedRestaurantID = promotions[indexPath.row % promotions.count].restaurantID
//            performSegue(withIdentifier: "toPromotionVC", sender: self)
////            performSegue(withIdentifier: "toRestaurantDetail", sender: self)
//        }
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width*0.85
        let height = width*0.51
        return CGSize(width: width, height: height)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if promotionsIndex != -1 {
            
            let visibleIndexPaths = myTableView.indexPathsForVisibleRows
            let promotionsIndexPath = IndexPath(row: 0, section: promotionsIndex)
            
            if (visibleIndexPaths?.contains(promotionsIndexPath))! && myTableView.cellForRow(at: promotionsIndexPath) != nil {
                
                print(promotionsIndexPath)
                
                let cell = myTableView.cellForRow(at: promotionsIndexPath) as! PromotionsTableViewCell
                
                if scrollView == cell.myCollectionView {
                    
                    // Find cell closest to the frame centre with reference from the targetContentOffset.
                    let frameCenter: CGPoint = cell.myCollectionView.center
                    var targetOffsetToCenter: CGPoint = CGPoint(x: targetContentOffset.pointee.x + frameCenter.x, y: targetContentOffset.pointee.y + frameCenter.y)
                    var indexPath: IndexPath? = cell.myCollectionView.indexPathForItem(at: targetOffsetToCenter)
                    
                    // Check for "edge case" where the target will land right between cells and then next neighbor to prevent scrolling to index {0,0}.
                    while indexPath == nil {
                        targetOffsetToCenter.x += 10
                        indexPath = cell.myCollectionView.indexPathForItem(at: targetOffsetToCenter)
                    }
                    // safe unwrap to make sure we found a valid index path
                    if let index = indexPath {
                        // Find the centre of the target cell
                        if let centerCellPoint: CGPoint = cell.myCollectionView.layoutAttributesForItem(at: index)?.center {
                            
                            // Calculate the desired scrollview offset with reference to desired target cell centre.
                            let desiredOffset: CGPoint = CGPoint(x: centerCellPoint.x - frameCenter.x, y: centerCellPoint.y - frameCenter.y)
                            targetContentOffset.pointee = desiredOffset
                        }
                    }
                }
                
            }

        }
            
            
            
    }
            

}
