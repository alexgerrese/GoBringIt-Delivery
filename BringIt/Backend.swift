//
//  Backend.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/14/17.
//  Copyright © 2017 Campus Enterprises. All rights reserved.
//

import Foundation

enum APICalls {
    case signInUser(email: String, password: String)
    case signUpUser(fullName: String, email: String, password: String, phoneNumber: String, campus: String, streetAddress: String, roomNumber: String)
    case fetchPromotions
    case fetchAllRestaurants
    case fetchRestaurant(id: Int)
    case fetchMenuCategory(restaurantID: Int, menuCategoryID: Int)
    case fetchMenuItem(restaurantID: Int, menuCategoryID: Int, itemID: Int)
    case updateCurrentAddress(uid: String, streetAddress: String, roomNumber: String)
    case addItemToCart(uid: String, quantity: Int, itemID: String, sideIDs: [String], specialInstructions: String)
    case placeOrder(uid: String, restaurantID: Int, payingWith: String, deliveryFee: String)
    //case fetchOrderHistory
    case fetchAccountInfo
    case updateAccountInfo(fullName: String, email: String, phoneNumber: String)
    case resetPassword(oldPassword: String, newPassword: String)
    
}
