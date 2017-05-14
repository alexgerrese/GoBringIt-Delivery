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
class User: Object, Mappable {
    dynamic var id = ""
    dynamic var fullName = ""
    dynamic var email = ""
    // dynamic var password = "" // KEEP THIS???
    dynamic var phoneNumber = ""
    dynamic var addresses = List<Address>()
    dynamic var isFirstOrder = false
    dynamic var pastOrders = List<Order>()
    dynamic var paymentMethod = ""
    
    // TO-DO: Add more demographic data here if necessary
}

// Address Model
class Address: Object, Mappable {
    dynamic var user: User?
    dynamic var campus = ""
    dynamic var streetAddress = ""
    dynamic var roomNumber = ""
    dynamic var isCurrent = false
}


// Restaurant Model
class Restaurant: Object, Mappable {
    dynamic var id = ""
    dynamic var image: NSData?
    dynamic var name = ""
    dynamic var cuisineType = ""
    dynamic var restaurantHours = "" // TO-DO: Maybe change the formatting? Here or in a method
    dynamic var deliveryFee = "" // TO-DO: Should this be a string or a Double?
    dynamic var promotions = List<Promotion>()
    dynamic var mostPopularDishes = List<MenuItem>()
    dynamic var menuCategories = List<MenuCategory>()
}

// Promotions Model
class Promotion: Object, Mappable {
    dynamic var restaurant: Restaurant?
    dynamic var image: NSData?
    dynamic var title = ""
    dynamic var description = ""
    
    // TO-DO: Will need to add some sort of linking capability to go to the right VC upon tap
}

// Menu Category Model
class MenuCategory: Object, Mappable {
    dynamic var restaurant: Restaurant?
    dynamic var name = ""
    dynamic var menuItems = List<MenuItem>()
}

// Menu Item Model
class MenuItem: Object, Mappable {
    dynamic var id = ""
    dynamic var menuCategory: MenuCategory?
    dynamic var image: NSData?
    dynamic var name = ""
    dynamic var description = ""
    dynamic var price = "" // TO-DO: Should this be a string or a Double?
    dynamic var sides = List<SideCategory>()
    dynamic var extras = List<Side>()
    
    // For Cart items only
    dynamic var specialInstructions = ""
    dynamic var quantity = 1
    
    // TO-DO: Add a method to calculate and return total price??
}

// Side Category Model
class SideCategory: Object, Mappable {
    dynamic var menuItem: MenuItem?
    dynamic var name = ""
    dynamic var maxSelectable = 1
    dynamic var sides = List<Side>()
}

// Side Model
class Side: Object, Mappable {
    dynamic var id = ""
    dynamic var sideCategory: SideCategory?
    dynamic var price = "" // TO-DO: Should this be a string or a Double?
    dynamic var isSelected = false
}

// Order Model
class Order: Object, Mappable {
    dynamic var id = ""
    dynamic var restaurant: Restaurant? // TO-DO: Should I have this or just restaurantID?
    dynamic var orderTime: NSDate?
    dynamic var address: Address?
    dynamic var paymentMethod = ""
    dynamic var menuItems = List<MenuItem>()
    dynamic var subtotal = "" // TO-DO: Should this be a string or a Double?
    dynamic var isComplete = false
}



