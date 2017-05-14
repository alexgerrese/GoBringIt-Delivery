//
//  Backend.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/14/17.
//  Copyright © 2017 Campus Enterprises. All rights reserved.
//

// THOUGHTS: 
// What if I download all the data immediately at first startup and save it to Realm, and subsequently check for updated data only? This would eliminate lots of redundancy since most menu data will rarely/never change.
// EXCEPTIONS: 
    // fetchPromotions <-- This should be called every time since it should be updated frequently
// This would remove the following methods and replace it with fetchRestaurantData:
    // fetchAllRestaurants
    // fetchRestaurant
    // fetchMenuCategory
    // fetchMenuItem
//


// VERY IMPORTANT IDEA: Have a counter in the backend for updateVersion, and increment it manually when changes are made. Have the app check that value against its internal version, and only call the backend when that version is inconsistent, then update it to be the same.

import Foundation

enum APICalls {
    case signInUser(email: String, password: String)
    case signUpUser(fullName: String, email: String, password: String, phoneNumber: String, campus: String, streetAddress: String, roomNumber: String)
    case fetchPromotions
    case fetchRestaurantData
//    case fetchAllRestaurants
//    case fetchRestaurant(id: Int)
//    case fetchMenuCategory(restaurantID: Int, menuCategoryID: Int)
//    case fetchMenuItem(restaurantID: Int, menuCategoryID: Int, itemID: Int)
    case updateCurrentAddress(uid: String, streetAddress: String, roomNumber: String)
    case addItemToCart(uid: String, quantity: Int, itemID: String, sideIDs: [String], specialInstructions: String)
    case placeOrder(uid: String, restaurantID: Int, payingWith: String, deliveryFee: String)
    //case fetchOrderHistory
    case fetchAccountInfo
    case updateAccountInfo(fullName: String, email: String, phoneNumber: String)
    case resetPassword(oldPassword: String, newPassword: String)
}

extension APICalls : TargetType {
    var baseURL: URL { return URL(string: "http://www.gobringit.com")! }
    var path: String {
        switch self {
        case .signInUser(_,_):
            return "/CHADservice.php" //TO-DO: Change on backend
        case .signUpUser(_,_,_,_,_,_,_):
            return "/CHADaddUser.php" //TO-DO: Change on backend
        case .fetchPromotions:
            return "" //TO-DO: Add on backend
        case .fetchRestaurantData:
            return "" //TO-DO: Add on backend
//        case .fetchAllRestaurants:
//            return "" //TO-DO: Add on backend
//        case .fetchRestaurant(_):
//            return "" //TO-DO: Add on backend
//        case .fetchMenuCategory(_,_):
//            return "" //TO-DO: Add on backend
//        case .fetchMenuItem(_,_,_):
//            return "" //TO-DO: Add on backend
        case .updateCurrentAddress(_,_,_):
            return "" //TO-DO: Add on backend
        case .addItemToCart(_,_,_,_,_):
            return "" //TO-DO: Add on backend
        case .placeOrder(_,_,_,_):
            return "" //TO-DO: Add on backend
        case . fetchAccountInfo:
            return "" //TO-DO: Add on backend
        case .updateAccountInfo(_,_,_):
            return "" //TO-DO: Add on backend
        case .resetPassword(_,_):
            return "" //TO-DO: Add on backend
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .signInUser, .fetchPromotions, .fetchRestaurantData, .fetchAccountInfo: //.fetchAllRestaurants, .fetchRestaurant, .fetchMenuCategory, .fetchMenuItem:
            return .get
        case .signUpUser, .updateCurrentAddress, addItemToCart, .placeOrder, .updateAccountInfo, .resetPassword:
            return .post
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .signInUser(email: String, password: String):
            return ["email": email] // Suggestion: in backend, just retrieve the pass hash and salt from database and return those, and then authenticate with SHA512 locally
        case .signUpUser(fullName: String, email: String, password: String, phoneNumber: String, campus: String, streetAddress: String, roomNumber: String):
            return ["name": fullName,
                "email": email,
                "phone": phoneNumber,
                "password": password,
                "address": streetAddress,
                "apartment": roomNumber, // NOTE: MISSING FIELD FOR CAMPUS
                "city": "Durham", // Delete these from backend
                "state": "NC", // Delete these from backend
                "zip": "27705"] // Delete these from backend
        case .fetchRestaurantData:
            
//        case .fetchAllRestaurants
//        case .fetchRestaurant(id: Int):
//            return ["restaurant_id": id]
//        case .fetchMenuCategory(restaurantID: Int, menuCategoryID: Int):
//            return ["restaurant_id": id, "menu_category_id": menuCategoryID]
//        case .fetchMenuItem(restaurantID: Int, menuCategoryID: Int, itemID: Int):
//            return []
        case updateCurrentAddress(uid: String, streetAddress: String, roomNumber: String)
        case addItemToCart(uid: String, quantity: Int, itemID: String, sideIDs: [String], specialInstructions: String)
        case placeOrder(uid: String, restaurantID: Int, payingWith: String, deliveryFee: String)
        //case fetchOrderHistory
        case fetchAccountInfo
        case updateAccountInfo(fullName: String, email: String, phoneNumber: String)
        case resetPassword(oldPassword: String, newPassword: String)
        case .fetchPromotions, .fetchAllRestaurants:
            return nil
        }
    }
    
    var parameterEncoding: ParameterEncoding {
        switch self {
        case .zen, .showUser, .showAccounts, .updateUser:
            return URLEncoding.default // Send parameters in URL
        case .createUser:
            return JSONEncoding.default // Send parameters as JSON in request body
        }
    }
}

// MARK: - Helpers
private extension String {
    var urlEscaped: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    var utf8Encoded: Data {
        return self.data(using: .utf8)!
    }
}
