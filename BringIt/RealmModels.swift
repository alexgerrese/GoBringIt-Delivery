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
    dynamic var isCurrent = false
    dynamic var id = ""
    dynamic var fullName = ""
    dynamic var email = ""
    dynamic var password = "" // KEEP THIS???
    dynamic var phoneNumber = ""
    let addresses = List<DeliveryAddress>()
    dynamic var isFirstOrder = false
    let pastOrders = List<Order>()
    let paymentMethods = List<PaymentMethod>()
    
    // TO-DO: Add more demographic data here if necessary
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

// Address Model
class DeliveryAddress: Object {
    dynamic var userID = ""
    dynamic var campus = ""
    dynamic var streetAddress = ""
    dynamic var roomNumber = ""
    dynamic var isCurrent = false
}

// Payment Method Model
class PaymentMethod: Object {
    dynamic var userID = ""
    dynamic var method = ""
    dynamic var isSelected = false
}


// Restaurant Model
class Restaurant: Object {
    dynamic var id = ""
    dynamic var image: NSData?
    dynamic var name = ""
    dynamic var cuisineType = ""
    dynamic var restaurantHours = ""
    dynamic var deliveryFee = 0.0
    let promotions = List<Promotion>()
    let mostPopularDishes = List<MenuItem>()
    let menuCategories = List<MenuCategory>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

// Menu Category Model
class MenuCategory: Object {
//    dynamic var restaurant: Restaurant?
    dynamic var id = ""
    dynamic var name = ""
    let menuItems = List<MenuItem>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

// Menu Item Model
class MenuItem: Object {
    dynamic var id = ""
//    dynamic var menuCategory: MenuCategory?
    dynamic var image: NSData?
    dynamic var name = ""
    dynamic var details = ""
    dynamic var price = 0.0
    dynamic var groupings = 0
    dynamic var numRequiredSides = 0
    let sides = List<Side>()
    let extras = List<Side>()
    
    // For Cart items only
    dynamic var specialInstructions = ""
    dynamic var quantity = 1
    dynamic var totalCost = 0.0
    dynamic var isInCart = false
    
    // TO-DO: Add a method to calculate and return total price??
    
//    override static func primaryKey() -> String? {
//        return "id"
//    }
}

// Side Model
class Side: Object {
    dynamic var id = ""
    dynamic var name = ""
    dynamic var isRequired = false
    dynamic var sideCategory = ""
    dynamic var price = 0.0 // TO-DO: Should this be a string or a Double?
    dynamic var isSelected = false
    dynamic var isInCart = false
    
//    override static func primaryKey() -> String? {
//        return "id"
//    }
}

// Promotions Model
class Promotion: Object {
    dynamic var id = ""
//    dynamic var restaurant: Restaurant?
    dynamic var image: NSData?
    dynamic var title = ""
    dynamic var details = ""
    
    // TO-DO: Will need to add some sort of linking capability to go to the right VC upon tap
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

// Order Model
class Order: Object {
    dynamic var id = 0
    dynamic var restaurantID = ""
    dynamic var orderTime: NSDate?
    dynamic var address: DeliveryAddress?
    dynamic var paymentMethod = ""
    let menuItems = List<MenuItem>()
    dynamic var subtotal = 0.0 
    dynamic var deliveryFee = 0.0
    dynamic var isComplete = false
}



