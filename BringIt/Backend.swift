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
    case signUpUser(fullName: String, email: String, password: String, phoneNumber: String, gradYear: String)
    case fetchPromotions
    case fetchRestaurantData
    case fetchRestaurantsInfo
    case fetchMenuCategories(restaurantID: String)
    case fetchFeaturedDishes(restaurantID: String)
    case fetchMenuItems(categoryID: String)
    case updateCurrentAddress(uid: String, streetAddress: String, roomNumber: String)
    case addItemToCart(uid: String, quantity: Int, itemID: String, sideIDs: [String], specialInstructions: String)
    case addOrder(uid: String, restaurantID: String, payingWithCC: String, deliveryFee: String)
    case fetchAccountInfo(uid: String)
    case fetchAccountAddress(uid: String)
    case updateAccountInfo(uid: String, fullName: String, email: String, phoneNumber: String)
    case resetPassword(uid: String, oldPassword: String, newPassword: String)
    case fetchVersionNumber
    case fetchAPIKey
    case fetchWaitTime(restaurantID: String)
    case stripeAddCard(userID: String, cardNumber: String, expMonth: String, expYear: String, CVC: String)
    case stripeRetrieveCards(userID: String)
    case stripeCharge(userID: String, restaurantID: String, amount: String, cardID: String)
    case stripeEphemeralKeys(apiVersion: String, userID: String)
    case verifyAddress(addressString: String)
    case getDeliveryFee(addressString: String, restaurantID: String)
}

extension APICalls : TargetType {
    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
    var baseURL: URL { return URL(string: Environment.appBackendURL.absoluteString)! }
    var path: String {
        switch self {
        case .signInUser(_,_):
            return "/signInUser.php"
        case .signUpUser(_,_,_,_,_):
            return "/signUpUser.php"
        case .fetchPromotions:
            return "/fetchPromotions.php"
        case .fetchRestaurantData:
            return "/fetchRestaurantData.php"
        case .fetchRestaurantsInfo:
            return "/fetchRestaurantsInfo.php"
        case .fetchMenuCategories(_):
            return "/fetchMenuCategories.php"
        case .fetchFeaturedDishes(_):
            return "/fetchFeaturedDishes.php"
        case .fetchMenuItems(_):
            return "/fetchMenuItems.php"
        case .updateCurrentAddress(_,_,_):
            return "/updateCurrentAddress.php"
        case .addItemToCart(_,_,_,_,_):
            return "/addItemToCart.php"
        case .addOrder(_,_,_,_):
            return "/addOrder.php"
        case .fetchAccountInfo(_):
            return "/fetchAccountInfo.php"
        case .fetchAccountAddress(_):
            return "/fetchAccountAddress.php"
        case .updateAccountInfo(_,_,_,_):
            return "/updateAccountInfo.php"
        case .resetPassword(_,_,_):
            return "/resetPassword.php"
        case .fetchVersionNumber:
            return "/fetchVersionNumber.php"
        case .fetchAPIKey:
            return "/fetchAPIKey.php"
        case .fetchWaitTime(_):
            return "/fetchWaitTime.php"
        case .stripeCharge(_,_,_,_):
            return "/stripeCharge.php"
        case .stripeEphemeralKeys(_,_):
            return "/stripeEphemeralKeys.php"
        case .stripeAddCard(_,_,_,_,_):
            return "/stripeAddCard.php"
        case .stripeRetrieveCards(_):
            return "/stripeRetrieveCards.php"
        case .verifyAddress(_):
            return "/verifyAddress.php"
        case .getDeliveryFee(_,_):
            return "/getDeliveryFee.php"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchPromotions, .fetchRestaurantData, .fetchRestaurantsInfo, .fetchVersionNumber, .fetchAPIKey:
            return .get
        case .signInUser, .signUpUser, .updateCurrentAddress, .addItemToCart, .addOrder, .updateAccountInfo, .resetPassword, .fetchAccountInfo, .fetchAccountAddress, .fetchMenuCategories, .fetchFeaturedDishes, .fetchMenuItems, .fetchWaitTime, .stripeAddCard, .stripeRetrieveCards, .stripeCharge, .stripeEphemeralKeys, .verifyAddress, .getDeliveryFee:
            return .post
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .fetchPromotions, .fetchRestaurantData, .fetchRestaurantsInfo, .fetchVersionNumber, .fetchAPIKey:
            return .requestPlain
        case .fetchMenuCategories(let restaurantID):
            return .requestParameters(parameters: ["restaurantID": restaurantID], encoding: JSONEncoding.default)
        case .fetchFeaturedDishes(let restaurantID):
            return .requestParameters(parameters: ["restaurantID": restaurantID], encoding: JSONEncoding.default)
        case .fetchMenuItems(let categoryID):
            return .requestParameters(parameters: ["categoryID": categoryID], encoding: JSONEncoding.default)
        case .signInUser(let email, let password):
            return .requestParameters(parameters: ["email": email,
            "password": password], encoding: JSONEncoding.default)
        case .signUpUser(let fullName, let email, let password, let phoneNumber, let gradYear):
            return .requestParameters(parameters: ["name": fullName,
                    "email": email,
                    "phone": phoneNumber,
                    "password": password,
                    "grad_year": gradYear], encoding: JSONEncoding.default) // Delete these from backend
        case .updateCurrentAddress(let uid, let streetAddress, let roomNumber):
            return .requestParameters(parameters: ["account_id": uid,
                    "street": streetAddress,
                    "apartment": roomNumber,
                    "city": "Durham",
                    "state": "NC",
                    "zip": "27705"], encoding: JSONEncoding.default)
        case .addItemToCart(let uid, let quantity, let itemID, let sideIDs, let specialInstructions):
            return .requestParameters(parameters: ["uid": uid,
                    "quantity": quantity,
                    "item_id": itemID,
                    "sides": sideIDs,
                    "instructions": specialInstructions], encoding: JSONEncoding.default)
        case .addOrder(let uid, let restaurantID, let payingWithCC, let deliveryFee):
            return .requestParameters(parameters: ["user_id": uid,
                    "service_id": restaurantID,
                    "payment_cc": payingWithCC,
                    "delivery_fee": deliveryFee], encoding: JSONEncoding.default)
        case .fetchAccountInfo(let uid):
            return .requestParameters(parameters: ["uid": uid], encoding: JSONEncoding.default)
        case .fetchAccountAddress(let uid):
            return .requestParameters(parameters: ["uid": uid], encoding: JSONEncoding.default)
        case .fetchWaitTime(let restaurantID):
            return .requestParameters(parameters: ["restaurant_id": restaurantID], encoding: JSONEncoding.default)
        case .updateAccountInfo(let uid, let fullName, let email, let phoneNumber):
            return .requestParameters(parameters: ["uid": uid,
                    "name": fullName,
                    "email": email,
                    "phone": phoneNumber], encoding: JSONEncoding.default)
        case .resetPassword(let uid, let oldPassword, let newPassword):
            return .requestParameters(parameters: ["uid": uid,
                    "old_pass": oldPassword,
                    "new_pass": newPassword], encoding: JSONEncoding.default)
        case .stripeAddCard(let userID, let cardNumber, let expMonth, let expYear, let CVC):
            return .requestParameters(parameters: ["user_id": userID,
                                                  "card_number": cardNumber,
                                                  "exp_month": expMonth,
                                                  "exp_year": expYear,
                                                  "cvc": CVC], encoding: JSONEncoding.default)
        case .stripeRetrieveCards(let userID):
            return .requestParameters(parameters: ["user_id": userID], encoding: JSONEncoding.default)
        case .stripeCharge(let userID, let restaurantID, let amount, let cardID):
            return .requestParameters(parameters: ["user_id": userID,
                                                   "restaurant_id": restaurantID,
                                                   "amount": amount,
                                                   "card_id": cardID], encoding: JSONEncoding.default)
        case .stripeEphemeralKeys(let apiVersion, let userID):
            return .requestParameters(parameters: ["api_version": apiVersion,
                                                   "user_id": userID], encoding: JSONEncoding.default)
        case .verifyAddress(let addressString):
            return .requestParameters(parameters: ["address_string": addressString], encoding: JSONEncoding.default)
        case .getDeliveryFee(let addressString, let restaurantID):
            return .requestParameters(parameters: ["user_address_string": addressString,
                                                   "restaurant_id": restaurantID], encoding: JSONEncoding.default)
        }
    }
}


enum CombinedAPICalls {
    case placeOrder(uid: String, restaurantID: String, paymentValue: String, isPickup: String, amount: String, deliveryFee: String, creditUsed: String, paymentType: String, name: String, rememberPayment: String, addressId: String)
    case sendPhoneVerification(phoneNumber: String)
    case checkPhoneVerificationCode(phoneNumber: String, code: String)
    case clearCart(uid: String)
    case retrieveDukeCards(uid: String)
    case deleteDukeCard(uid: String, cardId: String)
    case addAddress(uid: String, address: String, apartment: String, campus: String)
    case deleteAddress(uid: String, addressId: String)
}

extension CombinedAPICalls : TargetType {
    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
    var baseURL: URL { return URL(string: Environment.combinedBackendURL.absoluteString)! }
    var path: String {
        switch self {
        case .placeOrder(_,_,_,_,_,_,_,_,_,_,_):
            return "/placeOrder.php"
        case .sendPhoneVerification(_):
            return "/sendPhoneVerification.php"
        case .checkPhoneVerificationCode(_,_):
            return "/checkPhoneVerification.php"
        case .clearCart(_):
            return "/clearCart.php"
        case .retrieveDukeCards(_):
            return "/retrieveDukeCards.php"
        case .deleteDukeCard(_,_):
            return "/deleteDukeCard.php"
        case .addAddress(_,_,_,_):
            return "/addAddress.php"
        case .deleteAddress(_,_):
            return "/deleteAddress.php"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .placeOrder, .sendPhoneVerification, .checkPhoneVerificationCode, .clearCart, .retrieveDukeCards, .deleteDukeCard, .addAddress, .deleteAddress:
            return .post
        }

    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .placeOrder(let uid, let restaurantID, let payingWithCC, let isPickup, let amount, let deliveryFee, let creditUsed, let paymentType, let name, let rememberPayment, let addressId):
            return .requestParameters(parameters: ["uid": uid,
                                                   "cid": restaurantID,
                                                   "pmt": payingWithCC,
                                                   "pORd": isPickup,
                                                   "amount": amount,
                                                   "fee": deliveryFee,
                                                   "credit_used": creditUsed,
                                                   "payment_type": paymentType,
                                                   "name": name,
                                                   "mobile": "1",
                                                   "remember_payment": rememberPayment,
                                                   "address_id": addressId
                ], encoding: JSONEncoding.default)
        case .sendPhoneVerification(let phoneNumber):
            return .requestParameters(parameters: ["phoneNumber": phoneNumber], encoding: JSONEncoding.default)
        case .checkPhoneVerificationCode(let phoneNumber, let code):
            return .requestParameters(parameters: ["phoneNumber": phoneNumber,
                                                "verificationCode": code], encoding: JSONEncoding.default)
        case .clearCart(let uid):
            return .requestParameters(parameters: ["uid": uid], encoding: JSONEncoding.default)
        case .retrieveDukeCards(let uid):
            return .requestParameters(parameters: ["uid": uid], encoding: JSONEncoding.default)
        case .deleteDukeCard(let uid, let cardId):
            return .requestParameters(parameters: ["uid": uid, "cardId": cardId], encoding: JSONEncoding.default)
        case .addAddress(let uid, let address, let apartment, let campus):
            return .requestParameters(parameters: ["uid" : uid,
                                                   "address" : address,
                                                   "apartment" : apartment,
                                                   "campus" : campus
                ], encoding: JSONEncoding.default)
        case .deleteAddress(let uid, let addressId):
            return .requestParameters(parameters: ["uid": uid, "addressId": addressId], encoding: JSONEncoding.default)
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
