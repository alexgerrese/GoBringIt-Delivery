//
//  CreateMenuItemsModels.swift
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

extension MenuCategoryViewController {
    
    func fetchMenuItems() {
        
        print("fetchMenuItems() was called")
        
        // Setup Moya provider and send network request
        let provider = MoyaProvider<APICalls>()
        provider.request(.fetchMenuItems(categoryID: menuCategoryID)) { result in
            switch result {
            case let .success(moyaResponse):
                do {
                    
                    print("Status code: \(moyaResponse.statusCode)")
                    try moyaResponse.filterSuccessfulStatusCodes()
                    
                    let retrievedMenuItems = try moyaResponse.mapJSON() as! [AnyObject]
                    
                    print("Retrieved Restaurants: \(retrievedMenuItems)")
                    
                    DispatchQueue.global(qos: .background).async {
                        self.createMenuItems(retrievedMenuItems: retrievedMenuItems)
                    }
                } catch {
                    // Miscellaneous network error
                    
                    // TO-DO: MAKE THIS A MODAL POPUP???
                    print("Network error")
//                    self.myActivityIndicator.stopAnimating()
//                    self.loadingLabel.text = "Network error. Please try again."
                    
                }
            case .failure(_):
                // Connection failed
                // TO-DO: MAKE THIS A MODAL POPUP???
                print("Connection failed. Make sure you're connected to the internet.")
//                self.myActivityIndicator.stopAnimating()
//                self.loadingLabel.text = "Connection failed. Make sure you're connected to the internet."
                
            }
        }
    }
    
    func createMenuItems(retrievedMenuItems: [AnyObject]) {
        
        let realm = try! Realm() // Initialize Realm
        
        print("createMenuItems() was called.")
        
        try! realm.write {
            
            
            for retrievedMenuItem in retrievedMenuItems {
                
                // If menu item already exists, delete
                let predicate = NSPredicate(format: "id = %@ && isOfficialDescription = true", retrievedMenuItem["id"] as! String)
                let existingMenuItems = realm.objects(MenuItem.self).filter(predicate)
                if existingMenuItems.count > 0 {
                    realm.delete(existingMenuItems)
                }

                // Create new menu item
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
                    let url = URL(string: urlString)
                    let imageData = NSData(contentsOf: url!)
                    menuItem.image = imageData
                }
                
                print("Menu Item created: \(menuItem)")
                
                let retrievedSides = retrievedMenuItem["sides"] as! [AnyObject]
                
                for retrievedSide in retrievedSides {
                    
                    // If side already exists, delete
                    let predicate = NSPredicate(format: "id = %@ && isOfficialDescription = true", retrievedSide["id"] as! String)
                    let existingSides = realm.objects(Side.self).filter(predicate)
                    if existingSides.count > 0 {
                        realm.delete(existingSides)
                    }
                    
                    // Create new side
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
                    
                    side.isOfficialDescription = true
                    
                    print("Side created - id: \(side.id), name: \(side.name)")
                    
                    
                    if side.isRequired && (side.price == 0 || side.price == 0.00) {
                        menuItem.sides.append(side)
                    } else {
                        menuItem.extras.append(side)
                    }
                    
                }
                
                // Have to add in main thread to avoid fatal errors
                DispatchQueue.main.async {
                    let realm = try! Realm() // Initialize Realm
                    
                    try! realm.write {
                        self.menuCategory.menuItems.append(menuItem)
                    }
                }
            }
        }
        
        print("Finished creating Menu Item models.")
        
        DispatchQueue.main.async {
            self.menuItems = self.menuCategory.menuItems.sorted(byKeyPath: "name")
//            self.refreshControl.endRefreshing()
            self.myTableView.reloadData()
        }
    }
    
    
}
