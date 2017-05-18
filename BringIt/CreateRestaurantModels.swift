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
                    
                    print("Retrieved Version Number: \(versionNumber)")
                    completion(versionNumber)
                    
                } catch {
                    // Miscellaneous network error
                    
                    // TO-DO: MAKE THIS A MODAL POPUP???
                    print("Network error")
                }
            case .failure(_):
                // Connection failed
                
                // TO-DO: MAKE THIS A MODAL POPUP???
                print("Connection failed. Make sure you're connected to the internet.")
            }
        }
    }
    
    func fetchRestaurantData() {
        
        print("fetchRestaurantData() was called")
        
        var restaurantIDs = [String]() // For cleanup
        var menuCategoryIDs = [String]() // For cleanup
        var menuItemIDs = [String]() // For cleanup
        var sideIDs = [String]() // For cleanup
        
        // Setup Moya provider and send network request
        let provider = MoyaProvider<APICalls>()
        provider.request(.fetchRestaurantData) { result in
            switch result {
            case let .success(moyaResponse):
                do {
                    
                    print("Status code: \(moyaResponse.statusCode)")
                    try moyaResponse.filterSuccessfulStatusCodes()
                    
                    let retrievedRestaurants = try moyaResponse.mapJSON() as! [AnyObject]
                    
                    print("Retrieved Restaurants: \(retrievedRestaurants)")

                    for retrievedRestaurant in retrievedRestaurants {
                        
                        let restaurant = Restaurant()
                        restaurant.id = retrievedRestaurant["id"] as! String
                        restaurant.name = retrievedRestaurant["name"] as! String
                        restaurant.cuisineType = retrievedRestaurant["cuisineType"] as! String
                        restaurant.deliveryFee = retrievedRestaurant["deliveryFee"] as! String
                        restaurant.restaurantHours = retrievedRestaurant["restaurantHours"] as! String
                        
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
                                menuItem.price = retrievedMenuItem["price"] as! String
                                menuItem.groupings = Int(retrievedMenuItem["groupings"] as! String)!
                                menuItem.numRequiredSides = Int(retrievedMenuItem["numRequiredSides"] as! String)!
                                
                                menuItemIDs.append(menuItem.id) // For cleanup
                                
                                print("Menu Item created")
                                
                                let retrievedSides = retrievedMenuItem["sides"] as! [AnyObject]
                                
                                for retrievedSide in retrievedSides {
                                    
                                    let side = Side()
                                    side.id = retrievedSide["id"] as! String
                                    side.name = retrievedSide["name"] as! String
                                    let isRequired = Int(retrievedSide["isRequired"] as! String)
                                    if isRequired == 0 { side.isRequired = false } else { side.isRequired = true }
                                    side.sideCategory = retrievedSide["sideCategory"] as! String
                                    side.price = retrievedSide["price"] as! String
                                    
                                    sideIDs.append(side.id) // For cleanup
                                    
                                    print("Side created")
                                    
                                    try! self.realm.write {
                                        self.realm.add(side, update: true)
                                        if let existingSide = self.realm.object(ofType: Side.self, forPrimaryKey: side.id) {
                                            menuItem.sides.append(existingSide)
                                        }
                                    }
                                }
                                
                                try! self.realm.write {
                                    self.realm.add(menuItem, update: true)
                                    if let existingMenuItem = self.realm.object(ofType: MenuItem.self, forPrimaryKey: menuItem.id) {
                                        menuCategory.menuItems.append(existingMenuItem)
                                    }
                                }
                                
                            }
                            
                            try! self.realm.write {
                                self.realm.add(menuCategory, update: true)
                                if let existingMenuCategory = self.realm.object(ofType: MenuCategory.self, forPrimaryKey: menuCategory.id) {
                                    restaurant.menuCategories.append(existingMenuCategory)
                                }
                                
                                self.realm.add(restaurant, update: true)
                            }
                        }
                    }
                    
                    print("Finished creating Restaurant models. Cleaning up now.")
                    
                    self.cleanUpRealmRestaurantModels(restaurantIDs: restaurantIDs, menuCategoryIDs: menuCategoryIDs, menuItemIDs: menuItemIDs, sideIDs: sideIDs)
                    
                    self.myTableView.reloadData()

                } catch {
                    // Miscellaneous network error
                    
                    // TO-DO: MAKE THIS A MODAL POPUP???
                    print("Network error")
                    
                }
            case .failure(_):
                // Connection failed
                // TO-DO: MAKE THIS A MODAL POPUP???
                print("Connection failed. Make sure you're connected to the internet.")
            }
        }
    }
    
    // Delete Realm objects for things which have been removed from the database
    func cleanUpRealmRestaurantModels(restaurantIDs: [String], menuCategoryIDs: [String], menuItemIDs: [String], sideIDs: [String]) {
        
        print("Cleaning up restaurants")
        
        let restaurants = self.realm.objects(Restaurant.self)
        
        for restaurant in restaurants {
            if !restaurantIDs.contains(restaurant.id) {
                try! realm.write {
                    realm.delete(restaurant)
                    print("Deleted a restaurant")
                }
            }
        }
        
        print("Cleaning up menuCategories")
        
        let menuCategories = self.realm.objects(MenuCategory.self)
        
        for menuCategory in menuCategories {
            if !menuCategoryIDs.contains(menuCategory.id) {
                try! realm.write {
                    realm.delete(menuCategory)
                    print("Deleted a menu category")
                }
            }
        }
        
        print("Cleaning up menu items")
        
        let menuItems = self.realm.objects(MenuItem.self)
        
        for menuItem in menuItems {
            if !menuItemIDs.contains(menuItem.id) {
                try! realm.write {
                    realm.delete(menuItem)
                    print("Deleted a menu item")
                }
            }
        }
        
        print("Cleaning up sides")
        
        let sides = self.realm.objects(Side.self)
        
        for side in sides {
            if !sideIDs.contains(side.id) {
                try! realm.write {
                    realm.delete(side)
                    print("Deleted a side")
                }
            }
        }
        
    }
    
}
