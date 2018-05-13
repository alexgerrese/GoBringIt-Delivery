//
//  CreateRestaurantDetailModels.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/13/18.
//  Copyright © 2018 Campus Enterprises. All rights reserved.
//

import Foundation
import Moya
import Alamofire
import RealmSwift
import SendGrid

extension RestaurantDetailViewController {

    // MARK: - Fetch Menu Categories
    
    func fetchMenuCategories() {
        
        print("fetchMenuCategories() was called")
        
        // Setup Moya provider and send network request
        let provider = MoyaProvider<APICalls>()
        provider.request(.fetchMenuCategories(restaurantID: restaurantID)) { result in
            switch result {
            case let .success(moyaResponse):
                do {
                    
                    print("Status code: \(moyaResponse.statusCode)")
                    try moyaResponse.filterSuccessfulStatusCodes()
                    
                    let retrievedMenuCategories = try moyaResponse.mapJSON() as! [AnyObject]
                    
                    print("Retrieved Menu Categories: \(retrievedMenuCategories)")
                    
                    DispatchQueue.global(qos: .background).async {
                        
                        self.createMenuCategories(retrievedMenuCategories: retrievedMenuCategories)
                    }
                } catch {
                    // Miscellaneous network error
                    
                    // TO-DO: MAKE THIS A MODAL POPUP???
                    print("Network error")
                    self.myActivityIndicator.stopAnimating()
                    self.loadingLabel.text = "Network Error. Please try again."
                    
                }
            case .failure(_):
                // Connection failed
                // TO-DO: MAKE THIS A MODAL POPUP???
                print("Connection failed. Make sure you're connected to the internet.")
                self.myActivityIndicator.stopAnimating()
                self.loadingLabel.text = "Connection failed. Make sure you're connected to the internet."
                
            }
        }
    }

    func createMenuCategories(retrievedMenuCategories: [AnyObject]) {

        let realm = try! Realm() // Initialize Realm

        print("createMenuCategories() was called.")

        try! realm.write {

                for retrievedMenuCategory in retrievedMenuCategories {

                    let menuCategory = MenuCategory()
                    menuCategory.id = retrievedMenuCategory["id"] as! String
                    menuCategory.name = retrievedMenuCategory["name"] as! String

                    print("Menu category created: \(menuCategory.name)")
                    
                    // Have to add in main thread to avoid fatal errors
                    DispatchQueue.main.async {
                        
                        let realm = try! Realm()
                        
                        try! realm.write {
                            let existingMenuCategory = realm.object(ofType: MenuCategory.self, forPrimaryKey: menuCategory.id)
                            realm.delete(existingMenuCategory!)
//                            if existingMenuCategory == nil {
                                self.restaurant.menuCategories.append(menuCategory)
                                print("ADDING MENU CATEGORY TO RESTAURANT: \(menuCategory.name)")
//                            }
                        }
                    }
                }
            }

        print("Finished creating Menu Category models.")

        DispatchQueue.main.async {
            self.menuCategories = self.restaurant.menuCategories.sorted(byKeyPath: "name")
            self.updateIndices()
            self.myActivityIndicator.stopAnimating()
            self.loadingLabel.alpha = 0
            self.myTableView.reloadData()
        }
        
    }
    
    // MARK: - Fetch Featured Dishes
    
    func fetchFeaturedDishes() {
        
        print("fetchMenuCategories() was called")
        
        // Setup Moya provider and send network request
        let provider = MoyaProvider<APICalls>()
        provider.request(.fetchFeaturedDishes(restaurantID: restaurantID)) { result in
            switch result {
            case let .success(moyaResponse):
                do {
                    
                    print("Status code: \(moyaResponse.statusCode)")
                    try moyaResponse.filterSuccessfulStatusCodes()
                    
                    let retrievedFeaturedDishes = try moyaResponse.mapJSON() as! [AnyObject]
                    
                    print("Retrieved Featured Dishes: \(retrievedFeaturedDishes)")
                    
                    DispatchQueue.global(qos: .background).async {
                        self.createFeaturedDishes(retrievedFeaturedDishes: retrievedFeaturedDishes)
                    }
                } catch {
                    // Miscellaneous network error
                    
                    // TO-DO: MAKE THIS A MODAL POPUP???
                    print("Network error")
                    self.myActivityIndicator.stopAnimating()
                    self.loadingLabel.text = "Network error. Please try again."
                    
                }
            case .failure(_):
                // Connection failed
                // TO-DO: MAKE THIS A MODAL POPUP???
                print("Connection failed. Make sure you're connected to the internet.")
                self.myActivityIndicator.stopAnimating()
                self.loadingLabel.text = "Connection failed. Make sure you're connected to the internet."
                
            }
        }
    }
    
        func createFeaturedDishes(retrievedFeaturedDishes: [AnyObject]) {
    
            let realm = try! Realm() // Initialize Realm
    
            print("createFeaturedDishes() was called.")
            
            var localFeaturedDishes = List<MenuItem>()
    
            try! realm.write {

                for retrievedFeaturedDish in retrievedFeaturedDishes {

                    let featuredDish = MenuItem()
                    featuredDish.id = retrievedFeaturedDish["id"] as! String
                    featuredDish.name = retrievedFeaturedDish["name"] as! String
                    featuredDish.details = retrievedFeaturedDish["description"] as! String
                    featuredDish.price = Double(retrievedFeaturedDish["price"] as! String)!
                    featuredDish.groupings = Int(retrievedFeaturedDish["groupings"] as! String)!
                    featuredDish.numRequiredSides = Int(retrievedFeaturedDish["numRequiredSides"] as! String)!
                    featuredDish.isFeatured = true

                    // Get image data
                    let imagePath = retrievedFeaturedDish["image"] as! String
                    if imagePath != "" {
                        let urlString = Constants.imagesPath + Constants.menuItemsPath + imagePath
                        let url = URL(string: urlString)
                        let imageData = NSData(contentsOf: url!)
                        featuredDish.image = imageData
                    }

                    print("Featured Dish created: \(featuredDish)")

                    let retrievedSides = retrievedFeaturedDish["sides"] as! [AnyObject]

                    for retrievedSide in retrievedSides {

                        let side = Side()
                        side.id = retrievedSide["id"] as! String
                        if let name = retrievedSide["name"] as? String {
                            side.name = name
                        } else {
                            side.name = "Error retrieving side. Please try again later."
                        }
                        if let isRequired = retrievedSide["isRequired"] as? String {
                            if Int(isRequired) == 0 { side.isRequired = false } else { side.isRequired = true }
                        } else {
                            side.isRequired = false
                        }

                        if let sideCategory = retrievedSide["sideCategory"] as? String {
                            if sideCategory == "" {
                                side.sideCategory = "Sides"
                            } else {
                                side.sideCategory = sideCategory
                            }
                        } else {
                            side.sideCategory = "Sides"
                        }

                        if let price = retrievedSide["price"] as? String {
                            side.price = Double(price)!
                        } else {
                            side.price = 9999.99
                        }

                        print("Side created - id: \(side.id), name: \(side.name)")

                        let predicate = NSPredicate(format: "id = %@ && isOfficialDescription = true", side.id)
                        if let existingSide = realm.objects(Side.self).filter(predicate).first {
                            realm.delete(existingSide)
                            realm.add(side)
                        }

                        if side.isRequired && (side.price == 0 || side.price == 0.00) {
                            featuredDish.sides.append(side)
                        } else {
                            featuredDish.extras.append(side)
                        }

                    }

                    let predicate = NSPredicate(format: "id = %@ && isOfficialDescription = true", featuredDish.id)
                    if let existingMenuItem = realm.objects(MenuItem.self).filter(predicate).first {
                        realm.delete(existingMenuItem)
                        realm.add(featuredDish)
                    }
                    
                    // Add to featuredDishes array
                    localFeaturedDishes.append(featuredDish)
                }
            }
    
            print("Finished creating Featured Dish models.")
            
            // Refresh tableview to show updated data in realtime (instead of waiting until all elements are loaded)
            DispatchQueue.main.async {
                self.featuredDishes = localFeaturedDishes
                self.updateIndices()
                self.myActivityIndicator.stopAnimating()
                self.loadingLabel.alpha = 0
                self.myTableView.reloadData()
            }
        }
    
}
