//
//  Helper.swift
//  BringIt
//
//  Created by Joshua Young on 5/17/19.
//  Copyright © 2019 Campus Enterprises. All rights reserved.
//

import Foundation
import RealmSwift
import Moya

class Helper {
    static var app: Helper = {
        return Helper()
    }()
    
    func updateUser(user: User) {
        let realm = try! Realm() // Initialize Realm

        // Setup Moya provider and send network request
        let provider = MoyaProvider<APICalls>()
        provider.request(.fetchAccountInfo(uid: user.id)) { result in
            switch result {
            case let .success(moyaResponse):
                do {
                    
                    print("Status code: \(moyaResponse.statusCode)")
                    
                    let response = try moyaResponse.mapJSON() as! [String: Any]
                    
                    print("User ID: \(user.id)")
                    print("Retrieved Response: \(response)")
                    
                    try! realm.write {
                        user.fullName = response["name"] as! String
                        user.email = response["email"] as! String
                        user.phoneNumber = response["phone"] as! String
                        user.gbiCredit = Double(response["gbi_credit"] as! String)!/100
                        if (response["already_ordered"] as? Int == 1) {
                            user.isFirstOrder = false
                        } else {
                            user.isFirstOrder = true
                        }
                    }
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
}

