//
//  ScheduleDetailViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 7/1/16.
//  Copyright © 2016 Campus Enterprises. All rights reserved.
//

import UIKit
import CoreData

class ScheduleDetailViewController: UIViewController, UIScrollViewDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var totalCostLabel: UILabel!
    @IBOutlet weak var myTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var orderView: UIView!
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var deliveryFeeLabel: UILabel!
    @IBOutlet weak var subtotalCostLabel: UILabel!
    
    // MARK: - Variables
    var order: Order?
//    var items: [Item]?
    var date = ""
    var backgroundImageURL = ""
    
    // CoreData
//    let appDelegate =
//        UIApplication.shared.delegate as! AppDelegate
//    let managedContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Start activity indicator
        myActivityIndicator.startAnimating()
        self.myActivityIndicator.isHidden = false
        
        // Set title
        self.title = date
        
        // Set custom back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
        // Add shadow to orderView
        orderView.layer.shadowColor = UIColor.darkGray.cgColor
        orderView.layer.shadowOpacity = 0.5
        orderView.layer.shadowOffset = CGSize.zero
        orderView.layer.shadowRadius = 1
        
        // TO-DO: CHAD! Please load the background image of the restaurant that was ordered from!
//        let restaurantID = order!.restaurantID
//        var backPic: UIImage?
//        
//        // DB Call to category_items
//        // check if restaurantID == id, save image
//        let requestURL: URL = URL(string: "http://www.gobringit.com/CHADrestaurantImage.php")!
//        let urlRequest = URLRequest(url: requestURL)
//        let session = URLSession.shared
//        let task = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) -> Void in
//            if let data = data {
//                do {
//                    let httpResponse = response as! HTTPURLResponse
//                    let statusCode = httpResponse.statusCode
//                    
//                    // Check HTTP Response
//                    if (statusCode == 200) {
//                        
//                        do{
//                            // Parse JSON
//                            let json = try JSONSerialization.jsonObject(with: data, options:.allowFragments)
//                            
//                            for Restaurant in json as! [Dictionary<String, AnyObject>] {
//                                let id = Restaurant["id"] as! String
//                                if (id == restaurantID) {
//                                    let image = Restaurant["image"] as! String
//                                    let url = URL(string: "http://www.gobringit.com/images/" + image)
//                                    let data = try? Data(contentsOf: url!)
//                                    backPic = UIImage(data: data!)
//                                    
//                                    
//                                    print("ID MATCHES")
//                                }
//                            }
//                            
//                            OperationQueue.main.addOperation {
//                                self.myTableView.reloadData()
//                                // Stop activity indicator
//                                //TO-DO: Place this so it is executed after the db request is made!
//                                self.backgroundImageView.image = backPic!
//                                self.myActivityIndicator.stopAnimating()
//                                self.myActivityIndicator.isHidden = true
//                                
//                            }
//                        }
//                    }
//                } catch let error as NSError {
//                    print(error.localizedDescription)
//                }
//            } else if let error = error {
//                print(error.localizedDescription)
//            }
//        }) 
//        
//        task.resume()
//        
//        items = order!.items?.allObjects as? [Item]
//        print("HEIGHT1: \(myTableViewHeight.constant)")
//        
//        myTableView.reloadData()
//        updateViewConstraints()
//        
//        let deliveryFee = Double((order?.deliveryFee)!)
//        let subTotal = Double((order?.totalPrice)!) - Double((order?.deliveryFee)!)
//        let totalCost = Double((order?.totalPrice)!)
//        
//        self.deliveryFeeLabel.text = String(format: "$%.2f", deliveryFee )
//        self.subtotalCostLabel.text = String(format: "$%.2f", subTotal)
//        self.totalCostLabel.text = String(format: "$%.2f", totalCost)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    @IBAction func orderAgainButtonPressed(_ sender: UIButton) {
//        
        // Check if there is an existing active cart from this restaurant
//        let fetchRequest = NSFetchRequest<Order>(entityName: "Order")
//        let firstPredicate = NSPredicate(format: "isActive == %@", true as CVarArg)
//        let secondPredicate = NSPredicate(format: "restaurant == %@", (order?.restaurant)!)
//        let predicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [firstPredicate, secondPredicate])
//        fetchRequest.predicate = predicate
//        
//        var activeCart = [Order]()
//        
//        do {
//            if let fetchResults = try managedContext.fetch(fetchRequest) as? [Order] {
//                activeCart = fetchResults
//                print("THERE IS AN EXISTING CART")
//            }
//        } catch let error as NSError {
//            print("Could not fetch \(error), \(error.userInfo)")
//        }
//        
//        // Delete current cart (if any exists)
//        // TO-DO: ALEX! Add a warning that current cart will be overwritten?
//        if !activeCart.isEmpty {
//            // Shouldn't be necessary, just a precaution
//            print("ACTIVE CART IS NOT EMPTY")
//            //ctiveCart[0].isActive = false
//            activeCart.removeAll()
//        }
//        
//        var reorder = NSEntityDescription.insertNewObject(forEntityName: "Order", into: managedContext) as! Order
//        reorder = order!
//        
//        // Set this cart as the active cart
//        reorder.isActive = true
//        activeCart.append(reorder)
//        
//        // Save changes
//        self.appDelegate.saveContext()
//        
//        performSegue(withIdentifier: "toCheckoutFromReorder", sender: self)
//    }
//    
//    // MARK: - Table view data source
//    
//    
//    // MARK: - Table view data source
//    
//    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
//        return 1
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return
//            items!.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "scheduleDetailCell", for: indexPath) as! ScheduleDetailTableViewCell
//        
//        // Set name and quantity labels
//        cell.itemNameLabel.text = items![(indexPath as NSIndexPath).row].name
//        cell.itemQuantityLabel.text = String(describing: items![(indexPath as NSIndexPath).row].quantity!)
//        
//        // Calculate total item cost
//        var totalItemCost = 0.0
//        var costOfSides = 0.0
//        for side in items![(indexPath as NSIndexPath).row].sides?.allObjects as! [Side] {
//            costOfSides += Double(side.price!)
//        }
//        totalItemCost += (Double(items![(indexPath as NSIndexPath).row].price!) + costOfSides) * Double(items![(indexPath as NSIndexPath).row].quantity!)
//        cell.totalCostLabel.text = String(format: "%.2f", totalItemCost)
//        
//        // Format all sides and extras
//        var sides = "Sides: "
//        var extras = "Extras: "
//        let allSides = items![(indexPath as NSIndexPath).row].sides?.allObjects as! [Side]
//        
//        for i in 0..<allSides.count {
//            if ((allSides[i].isRequired) == true) {
//                if i < allSides.count - 1 {
//                    sides += allSides[i].name! + ", "
//                } else {
//                    sides += allSides[i].name!
//                }
//            } else {
//                if i < allSides.count - 1 {
//                    extras += allSides[i].name! + ", "
//                } else {
//                    extras += allSides[i].name!
//                }
//            }
//        }
//        if sides == "Sides: " {
//            sides += "None"
//        }
//        if extras == "Extras: " {
//            extras += "None"
//        }
//        
//        // Format special instructions
//        var specialInstructions = "Special Instructions: "
//        if items![(indexPath as NSIndexPath).row].specialInstructions != "" {
//            specialInstructions += items![(indexPath as NSIndexPath).row].specialInstructions!
//        } else {
//            specialInstructions += "None"
//        }
//        
//        // Create attributed strings of the extras
//        var sidesAS = NSMutableAttributedString()
//        var extrasAS = NSMutableAttributedString()
//        var specialInstructionsAS = NSMutableAttributedString()
//        
//        sidesAS = NSMutableAttributedString(
//            string: sides,
//            attributes: [NSFontAttributeName:UIFont(
//                name: "Avenir",
//                size: 13.0)!])
//        extrasAS = NSMutableAttributedString(
//            string: extras,
//            attributes: [NSFontAttributeName:UIFont(
//                name: "Avenir",
//                size: 13.0)!])
//        specialInstructionsAS = NSMutableAttributedString(
//            string: specialInstructions,
//            attributes: [NSFontAttributeName:UIFont(
//                name: "Avenir",
//                size: 13.0)!])
//        
//        sidesAS.addAttribute(NSFontAttributeName,
//                             value: UIFont(
//                                name: "Avenir-Heavy",
//                                size: 13.0)!,
//                             range: NSRange(
//                                location: 0,
//                                length: 6))
//        extrasAS.addAttribute(NSFontAttributeName,
//                              value: UIFont(
//                                name: "Avenir-Heavy",
//                                size: 13.0)!,
//                              range: NSRange(
//                                location: 0,
//                                length: 7))
//        specialInstructionsAS.addAttribute(NSFontAttributeName,
//                                           value: UIFont(
//                                            name: "Avenir-Heavy",
//                                            size: 13.0)!,
//                                           range: NSRange(
//                                            location: 0,
//                                            length: 21))
//        
//        cell.sidesLabel.attributedText = sidesAS
//        cell.extrasLabel.attributedText = extrasAS
//        cell.specialInstructionsLabel.attributedText = specialInstructionsAS
        
//        return cell
//    }
    
    // Resize itemsTableView
    override func updateViewConstraints() {
        super.updateViewConstraints()
        myTableViewHeight.constant = myTableView.contentSize.height
    }
    
    @IBAction func returnToScheduleDetails(_ segue: UIStoryboardSegue) {
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "toCheckoutFromReorder" {
            
//            selectedRestaurantName = (order?.restaurant)!
        }
    }
    
    
}
