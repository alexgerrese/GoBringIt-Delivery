//
//  Backend.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/14/17.
//  Copyright © 2017 Campus Enterprises. All rights reserved.
//

// VERY IMPORTANT IDEA: Have a counter in the backend for updateVersion, and increment it manually when changes are made. Have the app check that value against its internal version, and only call the backend when that version is inconsistent, then update it to be the same.

import Foundation
import Moya

enum APICalls {
    case signInUser(email: String, password: String)
    case signUpUser(fullName: String, email: String, password: String, phoneNumber: String, campus: String, streetAddress: String, roomNumber: String)
    case fetchPromotions
    case fetchRestaurantData
    case updateCurrentAddress(uid: String, streetAddress: String, roomNumber: String)
    case addItemToCart(uid: String, quantity: Int, itemID: String, sideIDs: [String], specialInstructions: String)
    case addOrder(uid: String, restaurantID: String, payingWithCC: String)
    //case fetchOrderHistory
    case fetchAccountInfo(uid: String)
    case updateAccountInfo(uid: String, fullName: String, email: String, phoneNumber: String)
    case resetPassword(uid: String, oldPassword: String, newPassword: String)
    case fetchVersionNumber
    case fetchAPIKey
}

extension APICalls : TargetType {
    var baseURL: URL { return URL(string: "https://www.gobringit.com/includes/app")! }
    var path: String {
        switch self {
        case .signInUser(_,_):
            return "/signInUser.php"
        case .signUpUser(_,_,_,_,_,_,_):
            return "/signUpUser.php"
        case .fetchPromotions:
            return "/fetchPromotions.php"
        case .fetchRestaurantData:
            return "/fetchRestaurantData.php"
        case .updateCurrentAddress(_,_,_):
            return "/updateCurrentAddress.php"
        case .addItemToCart(_,_,_,_,_):
            return "/addItemToCart.php"
        case .addOrder(_,_,_):
            return "/addOrder.php"
        case .fetchAccountInfo(_):
            return "/fetchAccountInfo.php"
        case .updateAccountInfo(_,_,_,_):
            return "/updateAccountInfo.php"
        case .resetPassword(_,_,_):
            return "/resetPassword.php"
        case .fetchVersionNumber:
            return "/fetchVersionNumber.php"
        case .fetchAPIKey:
            return "/fetchAPIKey.php"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchPromotions, .fetchRestaurantData, .fetchVersionNumber, .fetchAPIKey:
            return .get
        case .signInUser, .signUpUser, .updateCurrentAddress, .addItemToCart, .addOrder, .updateAccountInfo, .resetPassword, .fetchAccountInfo:
            return .post
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .signInUser(let email, let password):
            return ["email": email,
                    "password": password]
        case .signUpUser(let fullName, let email, let password, let phoneNumber, let campus, let streetAddress, let roomNumber):
            return ["name": fullName,
                "email": email,
                "phone": phoneNumber,
                "password": password,
                "street": streetAddress,
                "apartment": roomNumber, // NOTE: MISSING FIELD FOR CAMPUS
                "city": "Durham", // Delete these from backend
                "state": "NC", // Delete these from backend
                "zip": "27705"] // Delete these from backend
        case .updateCurrentAddress(let uid, let streetAddress, let roomNumber):
            return ["account_id": uid,
                    "street": streetAddress,
                    "apartment": roomNumber,
                    "city": "Durham",
                    "state": "NC",
                    "zip": "27705"]
        case .addItemToCart(let uid, let quantity, let itemID, let sideIDs, let specialInstructions):
            return ["uid": uid,
                    "quantity": quantity,
                    "item_id": itemID,
                    "sides": sideIDs,
                    "instructions": specialInstructions]
        case .addOrder(let uid, let restaurantID, let payingWithCC):
            return ["user_id": uid,
                    "service_id": restaurantID,
                    "payment_cc": payingWithCC]
        //case fetchOrderHistory
        case .fetchAccountInfo(let uid):
            return ["uid": uid]
        case .updateAccountInfo(let uid, let fullName, let email, let phoneNumber):
            return ["uid": uid,
                    "name": fullName,
                    "email": email,
                    "phone": phoneNumber]
        case .resetPassword(let uid, let oldPassword, let newPassword):
            return ["uid": uid,
                    "old_pass": oldPassword,
                    "new_pass": newPassword]
        case .fetchPromotions, .fetchRestaurantData, .fetchVersionNumber, .fetchAPIKey:
            return nil
        }
    }
    
    var parameterEncoding: ParameterEncoding {
        return JSONEncoding.default // Send parameters as JSON in request body
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        return .request
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
