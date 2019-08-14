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
                    
                    print("Status code for getBackendVersionNumber(): \(moyaResponse.statusCode)")
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
                    
                        if response["alertMessageColor"] as! String != "" {
                            self.alertMessageColor = UIColor(hexString: (response["alertMessageColor"] as! String))
                        }
                        
                        if response["alertMessageLink"] as! String != "" {
                            self.alertMessageLink = response["alertMessageLink"] as! String
                        }
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
                    
                    print("Status code for fetchPromotions(): \(moyaResponse.statusCode)")
                    try moyaResponse.filterSuccessfulStatusCodes()
                    
                    let retrievedPromotions = try moyaResponse.mapJSON() as! [AnyObject]
                    
                    print("Retrieved Promotions: \(retrievedPromotions)")
                    
                    self.promotions.removeAll()
                    
                    for retrievedPromotion in retrievedPromotions {
                        
                        let promotion = Promotion()
                        promotion.id = retrievedPromotion["id"] as! String
                        promotion.restaurantID = retrievedPromotion["restaurantID"] as! String
                        
                        // Get image data
                        let imagePath = retrievedPromotion["image"] as! String
                        if imagePath != "" {
                            let urlString = Constants.imagesPath + imagePath
                            promotion.imageURL = urlString
                        }
                        
                        self.promotions.append(promotion)
                        
//                        // Get image data
//                        let imagePath = retrievedPromotion["image"] as! String
//                        let urlString = Constants.imagesPath + imagePath
//                        let url = URL(string: urlString)
//                        let imageData = NSData(contentsOf: url!)
//                        promotion.image = imageData
                        
//                        try! realm.write {
//                            realm.create(Promotion.self, value: promotion, update: true)
////                            self.realm.add(promotion)
//                        }
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
    
    func fetchRestaurantsInfo() {
        
        let realm = try! Realm() // Initialize Realm
        
        print("fetchRestaurantsInfo() was called.")
        
        // Setup Moya provider and send network request
        let provider = MoyaProvider<APICalls>()
        provider.request(.fetchRestaurantsInfo) { result in
            switch result {
            case let .success(moyaResponse):
                do {
                    
                    print("Status code for fetchRestaurantsInfo(): \(moyaResponse.statusCode)")
                    try moyaResponse.filterSuccessfulStatusCodes()
                    
                    let retrievedRestaurantsInfo = try moyaResponse.mapJSON() as! [AnyObject]
                    
                    print("Retrieved Restaurants Info: \(retrievedRestaurantsInfo)")
                    
                    try! realm.write {
                        
                        self.restaurants.removeAll()
                    
                        for retrievedRestaurantInfo in retrievedRestaurantsInfo {
                            
                            print("Creating restaurant: \(retrievedRestaurantInfo["name"] as! String)")
                            
                            let restaurant = Restaurant()
                            restaurant.id = retrievedRestaurantInfo["id"] as! String
                            restaurant.email = retrievedRestaurantInfo["email"] as! String
                            restaurant.name = retrievedRestaurantInfo["name"] as! String
                            restaurant.cuisineType = retrievedRestaurantInfo["cuisineType"] as! String
                            restaurant.restaurantHours = retrievedRestaurantInfo["restaurantHours"] as? String ?? ""
                            restaurant.phoneNumber = (retrievedRestaurantInfo["phoneNumber"] as! String)
                            restaurant.minimumPrice = Double(retrievedRestaurantInfo["minimumPrice"] as! String)!
                            restaurant.paymentOptions = retrievedRestaurantInfo["paymentOptions"] as! String
                            
                            // Check if restaurant has a saved address
                            if let address = retrievedRestaurantInfo["restaurantAddress"] as? String {
                                restaurant.address = address
                            } else {
                                restaurant.address = ""
                            }
                            
                            // Check if restaurant accepts pickup as well
                            if let deliveryOnly = retrievedRestaurantInfo["deliveryOnly"] as? String {
                                print("\(restaurant.name) value for deliveryOnly is: \(deliveryOnly)")
                                restaurant.deliveryOnly = deliveryOnly == "0" ? false : true
                            }
                            
                            // Check if there's a hardcoded delivery fee
                            if let deliveryFee = retrievedRestaurantInfo["deliveryFee"] as? String {
                                restaurant.deliveryFee = Double(deliveryFee) ?? -1.00
                            } else {
                                restaurant.deliveryFee = -1.00
                            }
                            
                            // Check if there's a restaurant announcement
                            let restaurantAnnouncement = retrievedRestaurantInfo["announcement"]
                            restaurant.announcement = restaurantAnnouncement as? String ?? ""
                            
                            print("ANNOUNCEMENT: \(restaurant.announcement)")
                            
                            // Check if printer email exists
                            let printerEmail = retrievedRestaurantInfo["printerEmail"]
                            restaurant.printerEmail = printerEmail as? String ?? ""
                            
                            // Get image data
                            let imagePath = retrievedRestaurantInfo["image"] as! String
                            if imagePath != "" {
                                let urlString = Constants.imagesPath + imagePath
                                restaurant.imageURL = urlString
                            }
                            
                            // Get image data
//                            let imagePath = retrievedRestaurantInfo["image"] as! String
                            let urlString = Constants.imagesPath + imagePath
                            let url = URL(string: urlString)
                            let imageData = NSData(contentsOf: url!)
                            restaurant.image = imageData
                            
                            self.restaurants.append(restaurant)
                            
//                            realm.add(restaurant, update: true)
                            
                            print("Restaurant \(restaurant.name) created")
                        }
                        
                    }
                    
                    DispatchQueue.main.async {
                        
                        self.myTableView.hideSkeleton()
                        self.refreshControl.endRefreshing()
                        self.updateIndices()
                        self.myTableView.reloadData()
            
                        
//
//                        if self.downloadingView.alpha == 1 {
//                            print("Showing finished downloading view")
//                            self.showFinishedDownloadingView()
//                        }
                    }
                    
                } catch {
                    // Miscellaneous network error
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
    
//    func fetchMenuCategories(restaurantID: String) {
//
//        let realm = try! Realm() // Initialize Realm
//
//        print("fetchMenuCategories() was called.")
//
//        // Setup Moya provider and send network request
//        let provider = MoyaProvider<APICalls>()
//        provider.request(.fetchMenuCategories(restaurantID: restaurantID)) { result in
//            switch result {
//            case let .success(moyaResponse):
//                do {
//
//                    print("Status code: \(moyaResponse.statusCode)")
//                    try moyaResponse.filterSuccessfulStatusCodes()
//
//                    let retrievedMenuCategories = try moyaResponse.mapJSON() as! [AnyObject]
//
//                    print("Retrieved Menu Categories: \(retrievedMenuCategories)")
//
//                    try! realm.write {
//
//                        for retrievedMenuCategory in retrievedMenuCategories {
//
//                            let menuCategory = MenuCategory()
//                            menuCategory.id = retrievedMenuCategory["id"] as! String
//                            menuCategory.name = retrievedMenuCategory["name"] as! String
//
//                            realm.add(menuCategory, update: true)
//    //                        if let existingMenuCategory = realm.object(ofType: MenuCategory.self, forPrimaryKey: menuCategory.id) {
//    //                            restaurant.menuCategories.append(existingMenuCategory)
//    //                        }
//
//                            print("Retrived menu category: \(menuCategory.name)")
//
//                        }
//                    }
//
//                } catch {
//                    // Miscellaneous network error
//                    print("Network error")
//
//                    self.refreshControl.endRefreshing()
//                }
//            case .failure(_):
//                // Connection failed
//
//                // TO-DO: MAKE THIS A MODAL POPUP???
//                print("Connection failed. Make sure you're connected to the internet.")
//
//                self.refreshControl.endRefreshing()
//            }
//        }
//    }
//
//    func fetchMenuItems() {
//
//        let realm = try! Realm() // Initialize Realm
//
//        print("fetchMenuItems() was called.")
//
//        // Setup Moya provider and send network request
//        let provider = MoyaProvider<APICalls>()
//        provider.request(.fetchMenuItems(categoryID: "1")) { result in
//            switch result {
//            case let .success(moyaResponse):
//                do {
//
//                    print("Status code: \(moyaResponse.statusCode)")
//                    try moyaResponse.filterSuccessfulStatusCodes()
//
//                    let retrievedMenuItems = try moyaResponse.mapJSON() as! [AnyObject]
//
//                    print("Retrieved Menu Items: \(retrievedMenuItems)")
//
//                    try! realm.write {
//
//                        for retrievedMenuItem in retrievedMenuItems {
//
//                            let menuItem = MenuItem()
//                            menuItem.id = retrievedMenuItem["id"] as! String
//                            menuItem.name = retrievedMenuItem["name"] as! String
//                            menuItem.details = retrievedMenuItem["description"] as! String
//                            menuItem.price = Double(retrievedMenuItem["price"] as! String)!
//                            menuItem.groupings = Int(retrievedMenuItem["groupings"] as! String)!
//                            menuItem.numRequiredSides = Int(retrievedMenuItem["numRequiredSides"] as! String)!
//                            menuItem.isOfficialDescription = true
//
//                            if retrievedMenuItem["isFeatured"] as! String == "1" {
//                                menuItem.isFeatured = true
//                            } else {
//                                menuItem.isFeatured = false
//                            }
//
//                            // Get image data
//                            let imagePath = retrievedMenuItem["image"] as! String
//                            if imagePath != "" {
//                                let urlString = Constants.imagesPath + Constants.menuItemsPath + imagePath
//                                menuItem.imageURL = urlString
//                            }
//
//                            print("Menu Item created")
//
//                            let retrievedSides = retrievedMenuItem["sides"] as! [AnyObject]
//
//                            for retrievedSide in retrievedSides {
//
//                                let side = Side()
//                                side.id = retrievedSide["id"] as! String
//                                if let name = retrievedSide["name"] as? String {
//                                    side.name = name
//                                } else {
//                                    side.name = "Error retrieving side. Please try again later."
//                                }
//                                if let isRequired = retrievedSide["isRequired"] as? String {
//                                    if Int(isRequired) == 0 { side.isRequired = false } else { side.isRequired = true }
//                                } else {
//                                    side.isRequired = false
//                                }
//
//                                if let sideCategory = retrievedSide["sideCategory"] as? String {
//                                    if sideCategory == "" {
//                                        side.sideCategory = "Sides"
//                                    } else {
//                                        side.sideCategory = sideCategory
//                                    }
//                                } else {
//                                    side.sideCategory = "Sides"
//                                }
//
//                                if let price = retrievedSide["price"] as? String {
//                                    side.price = Double(price)!
//                                } else {
//                                    side.price = 9999.99
//                                }
//
//                                print("Side created - id: \(side.id), name: \(side.name)")
//
//                                let predicate = NSPredicate(format: "id = %@ && isOfficialDescription = true", side.id)
//                                if let existingSide = realm.objects(Side.self).filter(predicate).first {
//                                    realm.delete(existingSide)
//                                    realm.add(side)
//                                }
//
//                                if side.isRequired && (side.price == 0 || side.price == 0.00) {
//                                    menuItem.sides.append(side)
//                                } else {
//                                    menuItem.extras.append(side)
//                                }
//
//                            }
//
//                            let predicate = NSPredicate(format: "id = %@ && isOfficialDescription = true", menuItem.id)
//                            let existingMenuItems = realm.objects(MenuItem.self).filter(predicate)
//                            if existingMenuItems.count > 0 {
//                                realm.delete(existingMenuItems)
//                            }
//
//                        }
//                    }
//
//
//
//                } catch {
//                    // Miscellaneous network error
//                    print("Network error")
//
//                    self.refreshControl.endRefreshing()
//                }
//            case .failure(_):
//                // Connection failed
//
//                // TO-DO: MAKE THIS A MODAL POPUP???
//                print("Connection failed. Make sure you're connected to the internet.")
//
//                self.refreshControl.endRefreshing()
//            }
//        }
//    }
    
//    func fetchRestaurantData() {
//
//        print("fetchRestaurantData() was called")
//
//        // Setup Moya provider and send network request
//        let provider = MoyaProvider<APICalls>()
//        provider.request(.fetchRestaurantData) { result in
//            switch result {
//            case let .success(moyaResponse):
//                do {
//
//                    print("Status code: \(moyaResponse.statusCode)")
//                    try moyaResponse.filterSuccessfulStatusCodes()
//
//                    let retrievedRestaurants = try moyaResponse.mapJSON() as! [AnyObject]
//
////                    DispatchQueue.global(qos: .background).async {
//
//                         self.createRealmModels(retrievedRestaurants: retrievedRestaurants)
////                    }
//                } catch {
//                    // Miscellaneous network error
//
//                    // TO-DO: MAKE THIS A MODAL POPUP???
//                    print("Network error")
//                    self.refreshControl.endRefreshing()
//                    self.showErrorView()
//
//                }
//            case .failure(_):
//                // Connection failed
//                // TO-DO: MAKE THIS A MODAL POPUP???
//                print("Connection failed. Make sure you're connected to the internet.")
//                self.refreshControl.endRefreshing()
//                self.showErrorView()
//
//            }
//        }
//    }
//
//    func createRealmModels(retrievedRestaurants: [AnyObject]) {
//
//        let realm = try! Realm() // Initialize Realm
//
//        print("createRealmModels was called.")
//
//        var restaurantIDs = [String]() // For cleanup
//        var menuCategoryIDs = [String]() // For cleanup
//        var menuItemIDs = [String]() // For cleanup
//        var sideIDs = [String]() // For cleanup
//
//        print("Retrieved Restaurants: \(retrievedRestaurants)")
//
//        try! realm.write {
//
//            for retrievedRestaurant in retrievedRestaurants {
//
//                let restaurant = Restaurant()
//                restaurant.id = retrievedRestaurant["id"] as! String
//                restaurant.email = retrievedRestaurant["email"] as! String
//                restaurant.name = retrievedRestaurant["name"] as! String
//                restaurant.cuisineType = retrievedRestaurant["cuisineType"] as! String
//                restaurant.deliveryFee = Double(retrievedRestaurant["deliveryFee"] as! String)!
//                restaurant.restaurantHours = retrievedRestaurant["restaurantHours"] as! String
//                restaurant.phoneNumber = (retrievedRestaurant["phoneNumber"] as! String)
//                restaurant.minimumPrice = Double(retrievedRestaurant["minimumPrice"] as! String)!
//
//                // Check if printer email exists
//                let printerEmail = retrievedRestaurant["printerEmail"]
//                restaurant.printerEmail = printerEmail as? String ?? ""
//
//                // Get image data
//                    let imagePath = retrievedRestaurant["image"] as! String
//                    let urlString = Constants.imagesPath + imagePath
//                    let url = URL(string: urlString)
//                    let imageData = NSData(contentsOf: url!)
//                    restaurant.image = imageData
//
//                print("Restaurant created")
//
//                restaurantIDs.append(restaurant.id) // For cleanup
//
//                let retrievedMenuCategories = retrievedRestaurant["menuCategories"] as! [AnyObject]
//
//
//                for retrievedMenuCategory in retrievedMenuCategories {
//
//                    let menuCategory = MenuCategory()
//                    menuCategory.id = retrievedMenuCategory["id"] as! String
//                    menuCategory.name = retrievedMenuCategory["name"] as! String
//
//                    menuCategoryIDs.append(menuCategory.id) // For cleanup
//
//                    print("Menu category created")
//
//                    let retrievedMenuItems = retrievedMenuCategory["menuItems"] as! [AnyObject]
//
//                    for retrievedMenuItem in retrievedMenuItems {
//
//                        let menuItem = MenuItem()
//                        menuItem.id = retrievedMenuItem["id"] as! String
//                        menuItem.name = retrievedMenuItem["name"] as! String
//                        menuItem.details = retrievedMenuItem["description"] as! String
//                        menuItem.price = Double(retrievedMenuItem["price"] as! String)!
//                        menuItem.groupings = Int(retrievedMenuItem["groupings"] as! String)!
//                        menuItem.numRequiredSides = Int(retrievedMenuItem["numRequiredSides"] as! String)!
//                        menuItem.isOfficialDescription = true
//
//                        if retrievedMenuItem["isFeatured"] as! String == "1" {
//                            menuItem.isFeatured = true
//                        } else {
//                            menuItem.isFeatured = false
//                        }
//
//                        // Get image data
//                        let imagePath = retrievedMenuItem["image"] as! String
//                        if imagePath != "" {
//                            let urlString = Constants.imagesPath + Constants.menuItemsPath + imagePath
//                            menuItem.imageURL = urlString
////                            let url = URL(string: urlString)
////                            let imageData = NSData(contentsOf: url!)
////                            menuItem.image = imageData
//                        }
//
//                        menuItemIDs.append(menuItem.id) // For cleanup
//
//                        print("Menu Item created")
//
//                        let retrievedSides = retrievedMenuItem["sides"] as! [AnyObject]
//
//                        for retrievedSide in retrievedSides {
//
//                            let side = Side()
//                            side.id = retrievedSide["id"] as! String
//                            if let name = retrievedSide["name"] as? String {
//                                side.name = name
//                            } else {
//                                side.name = "Error retrieving side. Please try again later."
//                            }
//                            if let isRequired = retrievedSide["isRequired"] as? String {
//                                if Int(isRequired) == 0 { side.isRequired = false } else { side.isRequired = true }
//                            } else {
//                                side.isRequired = false
//                            }
//
//                            if let sideCategory = retrievedSide["sideCategory"] as? String {
//                                if sideCategory == "" {
//                                    side.sideCategory = "Sides"
//                                } else {
//                                    side.sideCategory = sideCategory
//                                }
//                            } else {
//                                side.sideCategory = "Sides"
//                            }
//
//                            if let price = retrievedSide["price"] as? String {
//                                side.price = Double(price)!
//                            } else {
//                                side.price = 9999.99
//                            }
//
//                            sideIDs.append(side.id) // For cleanup
//
//                            print("Side created - id: \(side.id), name: \(side.name)")
//
//                            let predicate = NSPredicate(format: "id = %@ && isOfficialDescription = true", side.id)
//                            if let existingSide = realm.objects(Side.self).filter(predicate).first {
//                                realm.delete(existingSide)
//                                realm.add(side)
//                            }
//
//                            if side.isRequired && (side.price == 0 || side.price == 0.00) {
//                                menuItem.sides.append(side)
//                            } else {
//                                menuItem.extras.append(side)
//                            }
//
//                        }
//
//                        let predicate = NSPredicate(format: "id = %@ && isOfficialDescription = true", menuItem.id)
//                        let existingMenuItems = realm.objects(MenuItem.self).filter(predicate)
//                        if existingMenuItems.count > 0 {
//                            realm.delete(existingMenuItems)
//                        }
//
//                        menuCategory.menuItems.append(menuItem)
//                    }
//
//                        realm.add(menuCategory, update: true)
//                        if let existingMenuCategory = realm.object(ofType: MenuCategory.self, forPrimaryKey: menuCategory.id) {
//                            restaurant.menuCategories.append(existingMenuCategory)
//                        }
//
//                        realm.add(restaurant, update: true)
//                }
//
//            }
//        }
//
//        print("Finished creating Restaurant models. Cleaning up now.")
//
//        DispatchQueue.main.async {
//
//            self.refreshControl.endRefreshing()
//
//            if self.downloadingView.alpha == 1 {
//                print("Showing finished downloading view")
//                self.showFinishedDownloadingView()
//            }
//        }
//
//        cleanUpRealmRestaurantModels(restaurantIDs: restaurantIDs, menuCategoryIDs: menuCategoryIDs, menuItemIDs: menuItemIDs, sideIDs: sideIDs)
//    }
//
//    // Delete Realm objects for things which have been removed from the database
//    func cleanUpRealmRestaurantModels(restaurantIDs: [String], menuCategoryIDs: [String], menuItemIDs: [String], sideIDs: [String]) {
//
//        let realm = try! Realm() // Initialize Realm
//
//        print("Cleaning up restaurants")
//
//        let restaurants = realm.objects(Restaurant.self)
//
//        for restaurant in restaurants {
//            if !restaurantIDs.contains(restaurant.id) {
//                try! realm.write {
//                    realm.delete(restaurant)
//                    print("Deleted a restaurant")
//                }
//            }
//        }
//
//        print("Cleaning up menuCategories")
//
//        let menuCategories = realm.objects(MenuCategory.self)
//
//        for menuCategory in menuCategories {
//            if !menuCategoryIDs.contains(menuCategory.id) {
//                try! realm.write {
//                    realm.delete(menuCategory)
//                    print("Deleted a menu category")
//                }
//            }
//        }
//
//        print("Cleaning up menu items")
//
//        let menuItems = realm.objects(MenuItem.self)
//
//        for menuItem in menuItems {
//            if !menuItemIDs.contains(menuItem.id) {
//                try! realm.write {
//                    realm.delete(menuItem)
//                    print("Deleted a menu item")
//                }
//            }
//        }
//
//        print("Cleaning up sides")
//
//        let sides = realm.objects(Side.self)
//
//        for side in sides {
//            if !sideIDs.contains(side.id) {
//                try! realm.write {
//                    realm.delete(side)
//                    print("Deleted a side")
//                }
//            }
//        }
//
//        DispatchQueue.main.async {
//            self.myTableView.reloadData()
//        }
//    }
    
}

extension RestaurantDetailViewController {
    
    func fetchWaitTimeMessage(restaurantID: String) {
        
        let realm = try! Realm() // Initialize Realm
        
        print("fetchWaitTimeMessage() was called.")
        
        // Setup Moya provider and send network request
        let provider = MoyaProvider<APICalls>()
        provider.request(.fetchWaitTime(restaurantID: restaurantID)) { result in
            switch result {
            case let .success(moyaResponse):
                do {
                    
                    print("Status code for fetchWaitTimeMessage(): \(moyaResponse.statusCode)")
                    try moyaResponse.filterSuccessfulStatusCodes()
                    
                    let response = try moyaResponse.mapJSON() as! [String: Any]
                    
                    print("Retrieved Announcement: \(response)")
                    
                    let announcement = response["announcement"] as? String
                    
                    if announcement != nil {
                        try! realm.write {
                            self.restaurant.announcement = announcement ?? ""
                        }
                    }                    
                    
                    // Set correct indices for tableview
                    self.updateIndices()
                    
                    self.myTableView.reloadData()
                    
                } catch {
                    // Miscellaneous network error
                    print("Network error")
                    
                    //                    self.refreshControl.endRefreshing()
                }
            case .failure(_):
                // Connection failed
                
                // TO-DO: MAKE THIS A MODAL POPUP???
                print("Connection failed. Make sure you're connected to the internet.")
                
                //                self.refreshControl.endRefreshing()
            }
        }
    }
    
    func fetchMenuCategories(restaurantID: String) {
        
        let realm = try! Realm() // Initialize Realm
        
        print("fetchMenuCategories() was called.")
        
        // Setup Moya provider and send network request
        let provider = MoyaProvider<APICalls>()
        provider.request(.fetchMenuCategories(restaurantID: restaurantID)) { result in
            switch result {
            case let .success(moyaResponse):
                do {
                    
                    print("Status code for fetchMenuCategories(): \(moyaResponse.statusCode)")
                    try moyaResponse.filterSuccessfulStatusCodes()
                    
                    let retrievedMenuCategories = try moyaResponse.mapJSON() as! [AnyObject]
                    
                    print("Retrieved Menu Categories: \(retrievedMenuCategories)")
                    
                    try! realm.write {
                        
                        for retrievedMenuCategory in retrievedMenuCategories {
                            
                            let menuCategory = MenuCategory()
                            menuCategory.id = retrievedMenuCategory["id"] as! String
                            menuCategory.name = retrievedMenuCategory["name"] as! String
                            
                            self.menuCategories.append(menuCategory)
//                            realm.add(menuCategory, update: true)
                            //                        if let existingMenuCategory = realm.object(ofType: MenuCategory.self, forPrimaryKey: menuCategory.id) {
                            //                            restaurant.menuCategories.append(existingMenuCategory)
                            //                        }
                            
                            print("Retrived menu category: \(menuCategory.name)")
                            
                        }
                    }
                    
                    let sortedMenuCategories = self.menuCategories.sorted(by: {$0.name < $1.name})
                    self.menuCategories = sortedMenuCategories
                    
                    self.myTableView.hideSkeleton()
                    self.myTableView.reloadData()
                    
                } catch {
                    // Miscellaneous network error
                    print("Network error")
                    
//                    self.refreshControl.endRefreshing()
                }
            case .failure(_):
                // Connection failed
                
                // TO-DO: MAKE THIS A MODAL POPUP???
                print("Connection failed. Make sure you're connected to the internet.")
                
//                self.refreshControl.endRefreshing()
            }
        }
    }
    
    func fetchFeaturedDishes(restaurantID: String) {
        
        let realm = try! Realm() // Initialize Realm
        
        print("fetchFeaturedDishes() was called.")
        
        // Setup Moya provider and send network request
        let provider = MoyaProvider<APICalls>()
        provider.request(.fetchFeaturedDishes(restaurantID: restaurantID)) { result in
            switch result {
            case let .success(moyaResponse):
                do {
                    
                    print("Status code for fetchFeaturedDishes(): \(moyaResponse.statusCode)")
                    try moyaResponse.filterSuccessfulStatusCodes()
                    
                    let retrievedFeaturedDishes = try moyaResponse.mapJSON() as! [AnyObject]
                    
                    print("Retrieved Featured Dishes: \(retrievedFeaturedDishes)")
                    
                    try! realm.write {
                        
                        for retrievedFeaturedDish in retrievedFeaturedDishes {
                            
                            let menuItem = MenuItem()
                            menuItem.id = retrievedFeaturedDish["id"] as! String
                            menuItem.name = retrievedFeaturedDish["name"] as! String
                            menuItem.details = retrievedFeaturedDish["description"] as! String
                            menuItem.price = Double(retrievedFeaturedDish["price"] as! String)!
                            menuItem.groupings = Int(retrievedFeaturedDish["groupings"] as! String)!
                            menuItem.numRequiredSides = Int(retrievedFeaturedDish["numRequiredSides"] as! String)!
                            menuItem.isOfficialDescription = true
                            
                            if retrievedFeaturedDish["isFeatured"] as! String == "1" {
                                menuItem.isFeatured = true
                            } else {
                                menuItem.isFeatured = false
                            }
                            
                            // Get image data
                            let imagePath = retrievedFeaturedDish["image"] as! String
                            if imagePath != "" {
                                let urlString = Constants.imagesPath + Constants.menuItemsPath + imagePath
                                menuItem.imageURL = urlString
                            }
                            
                            print("Menu Item created")
                            
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
                                
                                //                                let predicate = NSPredicate(format: "id = %@ && isOfficialDescription = true", side.id)
                                //                                if let existingSide = realm.objects(Side.self).filter(predicate).first {
                                //                                    realm.delete(existingSide)
                                //                                    realm.add(side)
                                //                                }
                                
                                if side.isRequired && (side.price == 0 || side.price == 0.00) {
                                    menuItem.sides.append(side)
                                } else {
                                    menuItem.extras.append(side)
                                }
                                
                            }
                            
                            self.featuredDishes.append(menuItem)
                            
                        }
                    }
                    
                    // Set correct indices for tableview
                    self.updateIndices()
                    
                    self.myTableView.reloadData()
                    
                    
                } catch {
                    // Miscellaneous network error
                    print("Network error")
                    
                    //                    self.refreshControl.endRefreshing()
                }
            case .failure(_):
                // Connection failed
                
                // TO-DO: MAKE THIS A MODAL POPUP???
                print("Connection failed. Make sure you're connected to the internet.")
                
                //                self.refreshControl.endRefreshing()
            }
        }
    }
}

extension MenuCategoryViewController {
    
    func fetchMenuItems(menuCategoryID: String) {
        
        let realm = try! Realm() // Initialize Realm
        
        print("fetchMenuItems() was called.")
        
        // Setup Moya provider and send network request
        let provider = MoyaProvider<APICalls>()
        provider.request(.fetchMenuItems(categoryID: menuCategoryID)) { result in
            switch result {
            case let .success(moyaResponse):
                do {
                    
                    print("Status code for fetchMenuItems(): \(moyaResponse.statusCode)")
                    try moyaResponse.filterSuccessfulStatusCodes()
                    
                    let retrievedMenuItems = try moyaResponse.mapJSON() as! [AnyObject]
                    
                    print("Retrieved Menu Items: \(retrievedMenuItems)")
                    
                    try! realm.write {
                        
                        for retrievedMenuItem in retrievedMenuItems {
                            
                            let menuItem = MenuItem()
                            menuItem.id = retrievedMenuItem["id"] as! String
                            menuItem.name = retrievedMenuItem["name"] as! String
                            menuItem.details = retrievedMenuItem["description"] as! String
                            menuItem.price = Double(retrievedMenuItem["price"] as! String)!
                            menuItem.groupings = Int(retrievedMenuItem["groupings"] as! String)!
                            menuItem.numRequiredSides = Int(retrievedMenuItem["numRequiredSides"] as! String)!
                            menuItem.isOfficialDescription = true
                            
                            if retrievedMenuItem["isFeatured"] as! String == "1" {
                                menuItem.isFeatured = true
                            } else {
                                menuItem.isFeatured = false
                            }
                            
                            // Get image data
                            let imagePath = retrievedMenuItem["image"] as! String
                            if imagePath != "" {
                                let urlString = Constants.imagesPath + Constants.menuItemsPath + imagePath
                                menuItem.imageURL = urlString
                            }
                            
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
                                
                                print("Side created - id: \(side.id), name: \(side.name)")
                                
//                                let predicate = NSPredicate(format: "id = %@ && isOfficialDescription = true", side.id)
//                                if let existingSide = realm.objects(Side.self).filter(predicate).first {
//                                    realm.delete(existingSide)
//                                    realm.add(side)
//                                }
                                
                                if (side.isRequired) {
                                    menuItem.sides.append(side)
                                } else {
                                    menuItem.extras.append(side)
                                }
                                
                            }
                            
                            self.menuItems.append(menuItem)
                            
//                            let predicate = NSPredicate(format: "id = %@ && isOfficialDescription = true", menuItem.id)
//                            let existingMenuItems = realm.objects(MenuItem.self).filter(predicate)
//                            if existingMenuItems.count > 0 {
//                                realm.delete(existingMenuItems)
//                            }
//
//                            realm.add(menuItem)
                        }
                        
                        let sortedMenuItems = self.menuItems.sorted(by: {$0.name < $1.name})
                        
                        self.menuItems = sortedMenuItems
                    }
                    
                   

                    //                    self.menuItems = realm.objects(MenuItem.self).sorted(byKeyPath: "name")
                    DispatchQueue.main.async{
                        self.view.stopSkeletonAnimation()
                        self.view.hideSkeleton()
                        self.myTableView.rowHeight = UITableView.automaticDimension
                        self.myTableView.setNeedsLayout()
                        self.myTableView.layoutIfNeeded()
                        self.myTableView.reloadData()
                    }
                } catch {
                    // Miscellaneous network error
                    print("Network error")
                    
//                    self.refreshControl.endRefreshing()
                }
            case .failure(_):
                // Connection failed
                
                // TO-DO: MAKE THIS A MODAL POPUP???
                print("Connection failed. Make sure you're connected to the internet.")
                
//                self.refreshControl.endRefreshing()
            }
        }
    }
}


