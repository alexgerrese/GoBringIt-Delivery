//
//  CreateRestaurantModels.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/18/17.
//  Copyright © 2017 Campus Enterprises. All rights reserved.
//

import Foundation
import Moya
import Alamofire
import RealmSwift
import SendGrid

extension RestaurantsHomeViewController {
    
    func getBackendVersionNumber(completion: @escaping (_ result: Int) -> Void) {
        
        print("getBackendVersionNumber() was called.")
        
        var versionNumber = -1
        
        // Setup Moya provider and send network request
        let provider = MoyaProvider<APICalls>()
        provider.request(.fetchVersionNumber) { result in
            switch result {
            case let .success(moyaResponse):
                do {
                    
                    print("Status code: \(moyaResponse.statusCode)")
                    try moyaResponse.filterSuccessfulStatusCodes()
                    
                    let response = try moyaResponse.mapJSON() as! [String: Any]
                    
                    print("Retrieved Response: \(response)")
                    
                    versionNumber = Int(response["version_number"] as! String)!
                    
                    // Set SendGrid API Key
                    let key = response["SendGridAPIKey"] as! String
                    self.defaults.set(key, forKey: "SendGridAPIKey")
                    Session.shared.authentication = Authentication.apiKey(key)
                    
                    // Set alert message
                    if response["alertMessage"] as! String != "" {
                        self.alertMessage = response["alertMessage"] as! String
                    }
                    
                    print("Retrieved Version Number: \(versionNumber)")
                    completion(versionNumber)
                    
                } catch {
                    // Miscellaneous network error
                    
                    // TO-DO: MAKE THIS A MODAL POPUP???
                    print("Network error")
                    
                    self.refreshControl.endRefreshing()
                }
            case .failure(_):
                // Connection failed
                
                // TO-DO: MAKE THIS A MODAL POPUP???
                print("Connection failed. Make sure you're connected to the internet.")
                
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    func fetchPromotions(completion: @escaping (_ result: Int) -> Void) {
        
        let realm = try! Realm() // Initialize Realm
        
        print("fetchPromotions() was called.")
        
        // Setup Moya provider and send network request
        let provider = MoyaProvider<APICalls>()
        provider.request(.fetchPromotions) { result in
            switch result {
            case let .success(moyaResponse):
                do {
                    
                    print("Status code: \(moyaResponse.statusCode)")
                    try moyaResponse.filterSuccessfulStatusCodes()
                    
                    let retrievedPromotions = try moyaResponse.mapJSON() as! [AnyObject]
                    
                    print("Retrieved Promotions: \(retrievedPromotions)")
                    
                    for retrievedPromotion in retrievedPromotions {
                        
                        let promotion = Promotion()
                        promotion.id = retrievedPromotion["id"] as! String
                        promotion.restaurantID = retrievedPromotion["restaurantID"] as! String
                        
                        // Get image data
                        let imagePath = retrievedPromotion["image"] as! String
                        let urlString = Constants.imagesPath + imagePath
                        let url = URL(string: urlString)
                        let imageData = NSData(contentsOf: url!)
                        promotion.image = imageData
                        
                        try! realm.write {
                            realm.create(Promotion.self, value: promotion, update: true)
//                            self.realm.add(promotion)
                        }
                    }
                    
                    completion(1)
                    
                } catch {
                    // Miscellaneous network error
                    
                    // TO-DO: MAKE THIS A MODAL POPUP???
                    print("Network error")
                    
                    self.refreshControl.endRefreshing()
                }
            case .failure(_):
                // Connection failed
                
                // TO-DO: MAKE THIS A MODAL POPUP???
                print("Connection failed. Make sure you're connected to the internet.")
                
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    func fetchRestaurantData() {
        
        print("fetchRestaurantData() was called")
        
        // Setup Moya provider and send network request
        let provider = MoyaProvider<APICalls>()
        provider.request(.fetchRestaurantData) { result in
            switch result {
            case let .success(moyaResponse):
                do {
                    
                    print("Status code: \(moyaResponse.statusCode)")
                    try moyaResponse.filterSuccessfulStatusCodes()
                    
                    let retrievedRestaurants = try moyaResponse.mapJSON() as! [AnyObject]
                    
                    DispatchQueue.global(qos: .background).async {
                        
                         self.createRealmModels(retrievedRestaurants: retrievedRestaurants)
                    }
                } catch {
                    // Miscellaneous network error
                    
                    // TO-DO: MAKE THIS A MODAL POPUP???
                    print("Network error")
                    self.refreshControl.endRefreshing()
                    self.showErrorView()
                    
                }
            case .failure(_):
                // Connection failed
                // TO-DO: MAKE THIS A MODAL POPUP???
                print("Connection failed. Make sure you're connected to the internet.")
                self.refreshControl.endRefreshing()
                self.showErrorView()
                
            }
        }
    }

    func createRealmModels(retrievedRestaurants: [AnyObject]) {
        
        let realm = try! Realm() // Initialize Realm
        
        print("createRealmModels was called.")
        
        var restaurantIDs = [String]() // For cleanup
        var menuCategoryIDs = [String]() // For cleanup
        var menuItemIDs = [String]() // For cleanup
        var sideIDs = [String]() // For cleanup
    
        print("Retrieved Restaurants: \(retrievedRestaurants)")
        
        try! realm.write {
        
            for retrievedRestaurant in retrievedRestaurants {
                
                let restaurant = Restaurant()
                restaurant.id = retrievedRestaurant["id"] as! String
                restaurant.email = retrievedRestaurant["email"] as! String
                restaurant.name = retrievedRestaurant["name"] as! String
                restaurant.cuisineType = retrievedRestaurant["cuisineType"] as! String
                restaurant.deliveryFee = Double(retrievedRestaurant["deliveryFee"] as! String)!
                restaurant.restaurantHours = retrievedRestaurant["restaurantHours"] as! String             
                restaurant.phoneNumber = (retrievedRestaurant["phoneNumber"] as! String)
                
                // Check if printer email exists
                let printerEmail = retrievedRestaurant["printerEmail"]
                restaurant.printerEmail = printerEmail as? String ?? ""
                
                // Get image data
                let imagePath = retrievedRestaurant["image"] as! String
                let urlString = Constants.imagesPath + imagePath
                let url = URL(string: urlString)
                let imageData = NSData(contentsOf: url!)
                restaurant.image = imageData
                
                print("Restaurant created")
                
                restaurantIDs.append(restaurant.id) // For cleanup
                
                let retrievedMenuCategories = retrievedRestaurant["menuCategories"] as! [AnyObject]
            
            
                for retrievedMenuCategory in retrievedMenuCategories {
                    
                    let menuCategory = MenuCategory()
                    menuCategory.id = retrievedMenuCategory["id"] as! String
                    menuCategory.name = retrievedMenuCategory["name"] as! String
                    
                    menuCategoryIDs.append(menuCategory.id) // For cleanup
                    
                    print("Menu category created")
                    
                    let retrievedMenuItems = retrievedMenuCategory["menuItems"] as! [AnyObject]
                    
                    for retrievedMenuItem in retrievedMenuItems {
                        
                        let menuItem = MenuItem()
                        menuItem.id = retrievedMenuItem["id"] as! String
                        menuItem.name = retrievedMenuItem["name"] as! String
                        menuItem.details = retrievedMenuItem["description"] as! String
                        menuItem.price = Double(retrievedMenuItem["price"] as! String)!
                        menuItem.groupings = Int(retrievedMenuItem["groupings"] as! String)!
                        menuItem.numRequiredSides = Int(retrievedMenuItem["numRequiredSides"] as! String)!
                        
                        if retrievedMenuItem["isFeatured"] as! String == "1" {
                            menuItem.isFeatured = true
                        } else {
                            menuItem.isFeatured = false
                        }
                        
                        // Get image data
                        let imagePath = retrievedMenuItem["image"] as! String
                        if imagePath != "" {
                            let urlString = Constants.imagesPath + imagePath
                            let url = URL(string: urlString)
                            let imageData = NSData(contentsOf: url!)
                            menuItem.image = imageData
                        }
                        
                        menuItemIDs.append(menuItem.id) // For cleanup
                        
                        print("Menu Item created")
                        
                        let retrievedSides = retrievedMenuItem["sides"] as! [AnyObject]
                        
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
                            
                            sideIDs.append(side.id) // For cleanup
                            
                            print("Side created - id: \(side.id), name: \(side.name)")
                            
                            let predicate = NSPredicate(format: "id = %@ && isOfficialDescription = true", side.id)
                            if let existingSide = realm.objects(Side.self).filter(predicate).first {
                                realm.delete(existingSide)
                                realm.add(side)
                            }
                            
                            if side.isRequired && (side.price == 0 || side.price == 0.00) {
                                menuItem.sides.append(side)
                            } else {
                                menuItem.extras.append(side)
                            }
                            
                        }
                        
                        let predicate = NSPredicate(format: "id = %@ && isOfficialDescription = true", menuItem.id)
                        if let existingMenuItem = realm.objects(MenuItem.self).filter(predicate).first {
                            realm.delete(existingMenuItem)
                            realm.add(menuItem)
                        }
                        
                        menuCategory.menuItems.append(menuItem)
                        
                    }
                    
                        realm.add(menuCategory, update: true)
                        if let existingMenuCategory = realm.object(ofType: MenuCategory.self, forPrimaryKey: menuCategory.id) {
                            restaurant.menuCategories.append(existingMenuCategory)
                        }
                    
                        let savedRestaurant = realm.objects(Restaurant.self).filter("id =  %@", restaurant.id)
                    print("Saved Restaurant hours: \(savedRestaurant.first?.restaurantHours ?? "Cant find hours")")
                        
                        realm.add(restaurant, update: true)
                        print("Restaurant hours \(restaurant.restaurantHours)")
                }
                
            }
        }
        
        print("Finished creating Restaurant models. Cleaning up now.")
        
        DispatchQueue.main.async {
            
            self.refreshControl.endRefreshing()
            
            if self.downloadingView.alpha == 1 {
                print("Showing finished downloading view")
                self.showFinishedDownloadingView()
            }
        }
        
        cleanUpRealmRestaurantModels(restaurantIDs: restaurantIDs, menuCategoryIDs: menuCategoryIDs, menuItemIDs: menuItemIDs, sideIDs: sideIDs)
    }

    // Delete Realm objects for things which have been removed from the database
    func cleanUpRealmRestaurantModels(restaurantIDs: [String], menuCategoryIDs: [String], menuItemIDs: [String], sideIDs: [String]) {
        
        let realm = try! Realm() // Initialize Realm
        
        print("Cleaning up restaurants")
        
        let restaurants = realm.objects(Restaurant.self)
        
        for restaurant in restaurants {
            if !restaurantIDs.contains(restaurant.id) {
                try! realm.write {
                    realm.delete(restaurant)
                    print("Deleted a restaurant")
                }
            }
        }
        
        print("Cleaning up menuCategories")
        
        let menuCategories = realm.objects(MenuCategory.self)
        
        for menuCategory in menuCategories {
            if !menuCategoryIDs.contains(menuCategory.id) {
                try! realm.write {
                    realm.delete(menuCategory)
                    print("Deleted a menu category")
                }
            }
        }
        
        print("Cleaning up menu items")
        
        let menuItems = realm.objects(MenuItem.self)
        
        for menuItem in menuItems {
            if !menuItemIDs.contains(menuItem.id) {
                try! realm.write {
                    realm.delete(menuItem)
                    print("Deleted a menu item")
                }
            }
        }
        
        print("Cleaning up sides")
        
        let sides = realm.objects(Side.self)
        
        for side in sides {
            if !sideIDs.contains(side.id) {
                try! realm.write {
                    realm.delete(side)
                    print("Deleted a side")
                }
            }
        }
        
        DispatchQueue.main.async {
            self.myTableView.reloadData()
        }
    }
    
}
