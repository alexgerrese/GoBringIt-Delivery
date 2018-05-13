//
//  RealmModels.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/14/17.
//  Copyright © 2017 Campus Enterprises. All rights reserved.
//

import Foundation
import RealmSwift

// User Model
class User: Object {
    @objc dynamic var isCurrent = false
    @objc dynamic var id = ""
    @objc dynamic var fullName = ""
    @objc dynamic var email = ""
    @objc dynamic var password = "" // KEEP THIS???
    @objc dynamic var phoneNumber = ""
    let addresses = List<DeliveryAddress>()
    @objc dynamic var isFirstOrder = false
    let pastOrders = List<Order>()
    let paymentMethods = List<PaymentMethod>()
    
    // TO-DO: Add more demographic data here if necessary
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

// Address Model
class DeliveryAddress: Object {
    @objc dynamic var userID = ""
    @objc dynamic var campus = ""
    @objc dynamic var streetAddress = ""
    @objc dynamic var roomNumber = ""
    @objc dynamic var isCurrent = false
}

// Payment Method Model
class PaymentMethod: Object {
    @objc dynamic var userID = ""
    @objc dynamic var method = ""
    @objc dynamic var isSelected = false
}

// Restaurant Model
class Restaurant: Object {
    @objc dynamic var id = ""
    @objc dynamic var email = ""
    @objc dynamic var printerEmail = ""
    @objc dynamic var imageURL = ""
    @objc dynamic var image: NSData?
    @objc dynamic var name = ""
    @objc dynamic var cuisineType = ""
    @objc dynamic var restaurantHours = ""
    @objc dynamic var phoneNumber = ""
    @objc dynamic var deliveryFee = 0.0
    @objc dynamic var minimumPrice = 0.0
    let promotions = List<Promotion>()
    let mostPopularDishes = List<MenuItem>()
    let menuCategories = List<MenuCategory>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func isOpen() -> Bool {
        return restaurantHours.getOpenHoursString().isRestaurantOpen()
    }
}

// Menu Category Model
class MenuCategory: Object {
    @objc dynamic var id = ""
    @objc dynamic var name = ""
    let menuItems = List<MenuItem>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

// Menu Item Model
class MenuItem: Object {
    @objc dynamic var id = ""
    @objc dynamic var isFeatured = false
    @objc dynamic var imageURL = ""
    @objc dynamic var image: NSData?
    @objc dynamic var name = ""
    @objc dynamic var details = ""
    @objc dynamic var price = 0.0
    @objc dynamic var groupings = 0
    @objc dynamic var numRequiredSides = 0
    let sides = List<Side>()
    let extras = List<Side>()
    
    // For Cart items only
    @objc dynamic var specialInstructions = ""
    @objc dynamic var quantity = 1
    @objc dynamic var totalCost = 0.0
    @objc dynamic var isInCart = false
    
    @objc dynamic var isOfficialDescription = false
    
    // TO-DO: Add a method to calculate and return total price??
    
//    override static func primaryKey() -> String? {
//        return "id"
//    }
}

// Side Model
class Side: Object {
    @objc dynamic var id = ""
    @objc dynamic var name = ""
    @objc dynamic var isRequired = false
    @objc dynamic var sideCategory = ""
    @objc dynamic var price = 0.0 // TO-DO: Should this be a string or a Double?
    @objc dynamic var isSelected = false
    @objc dynamic var isInCart = false
    
    @objc dynamic var isOfficialDescription = false
    
//    override static func primaryKey() -> String? {
//        return "id"
//    }
}

// Promotions Model
class Promotion: Object {
    @objc dynamic var id = ""
    @objc dynamic var restaurantID = ""
    @objc dynamic var image: NSData?
    @objc dynamic var details = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

// Order Model
class Order: Object {
    @objc dynamic var id = 0
    @objc dynamic var restaurantID = ""
    @objc dynamic var orderTime: NSDate?
    @objc dynamic var address: DeliveryAddress?
    @objc dynamic var paymentMethod = ""
    let menuItems = List<MenuItem>()
    @objc dynamic var subtotal = 0.0 
    @objc dynamic var deliveryFee = 0.0
    @objc dynamic var isComplete = false
}
