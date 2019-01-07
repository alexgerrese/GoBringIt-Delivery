//
//  MyAPIClient.swift
//  BringIt
//
//  Created by Alexander's MacBook on 11/22/18.
//  Copyright © 2018 Campus Enterprises. All rights reserved.
//

import Foundation
import Stripe
import Moya
import RealmSwift

class MyAPIClient: NSObject, STPEphemeralKeyProvider {
    
    let defaults = UserDefaults.standard // Initialize UserDefaults
    
    static let sharedClient = MyAPIClient()
    
    func completeCharge(_ result: STPPaymentResult,
                        amount: Int,
                        completion: @escaping STPErrorBlock) {
        
        // Setup Moya provider and send network request
        let provider = MoyaProvider<APICalls>()
        provider.request(.stripeCharge(userID: "1", restaurantID: "1", amount: "1", cardID: "1")) { result in
            switch result {
            case let .success(moyaResponse):
                do {
                    
                    print("Status code: \(moyaResponse.statusCode)")
                    try moyaResponse.filterSuccessfulStatusCodes()
                    
                    let response = try moyaResponse.mapJSON() as! [String: Any]
                    
                    if response["success"] as! Int == 1 {
                        
                        print("Success")
                        completion(nil)
                    } else {
                        print("Failure")
                        completion(MoyaError.statusCode(moyaResponse))
                    }
                    
                } catch {
                    // Miscellaneous network error
                    print("Misc network error")
                    completion(MoyaError.statusCode(moyaResponse))
                }
            case .failure(let error):
                // Connection failed
                print("Connection failed. Network error")
                completion(error)
            }
        }
    }
    
    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
        
        let realm = try! Realm() // Initialize Realm
        var user = User()
        
        // Retrieve user
        if let loggedIn = defaults.object(forKey: "loggedIn") {
            if (loggedIn as! Bool) {
                // Check if user already exists in Realm
                let predicate = NSPredicate(format: "isCurrent = %@", NSNumber(booleanLiteral: true))
                user = realm.objects(User.self).filter(predicate).first!
            }
        }
        
        // Setup Moya provider and send network request
        let provider = MoyaProvider<APICalls>()
        provider.request(.stripeEphemeralKeys(apiVersion: apiVersion, userID: user.id)) { result in
            switch result {
            case let .success(moyaResponse):
                do {
                    
                    print("Status code: \(moyaResponse.statusCode)")
                    try moyaResponse.filterSuccessfulStatusCodes()
                    
                    let response = try moyaResponse.mapJSON() as! [String: Any]
                    completion(response, nil)
                    
                } catch {
                    // Miscellaneous network error
                    print("Misc network error")
                }
            case .failure(_):
                // Connection failed
                print("Connection failed. Network error")
            }
        }
    }
}
