//
//  PlaceOrder.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/22/17.
//  Copyright © 2017 Campus Enterprises. All rights reserved.
//

import Foundation
import Moya
import Alamofire
import RealmSwift

extension CheckoutVC {
    
    func addAllToCart(completion: @escaping (_ result: Int) -> Void) {
        
        for item in order.menuItems {
            
            print("Adding to cart")
            
            var sideIDs = [String]()
            for side in item.sides {
                sideIDs.append(side.id)
            }
            for extra in item.extras {
                sideIDs.append(extra.id)
            }
            
            // Setup Moya provider and send network request
            let provider = MoyaProvider<APICalls>()
            provider.request(.addItemToCart(uid: user.id, quantity: item.quantity, itemID: item.id, sideIDs: sideIDs, specialInstructions: item.specialInstructions)) { result in
                switch result {
                case let .success(moyaResponse):
                    do {
                        
                        print("Status code: \(moyaResponse.statusCode)")
                        try moyaResponse.filterSuccessfulStatusCodes()
                        
                        let response = try moyaResponse.mapJSON() as! [String: Any]
                        
                        if response["success"] as! Int == 1 {
                            
                            print("Success adding item with id: \(item.id)!")
                        }
                        
                        completion(1)
                        
                    } catch {
                        // Miscellaneous network error
                        self.showConfirmViewError(errorTitle: "Network Error", errorMessage: "Something went wrong 😱 Make sure you're connected to the internet and please try again.")
                    }
                case .failure(_):
                    // Connection failed
                    self.showConfirmViewError(errorTitle: "Network Error", errorMessage: "Something went wrong 😱 Make sure you're connected to the internet and please try again.")
                }
            }
        }
    }
    
    func addOrder() {
        
        let realm = try! Realm() // Initialize Realm
        
        print("Adding to order")
        
        let filteredPaymentMethods = realm.objects(PaymentMethod.self).filter("userID = %@ AND isSelected = %@", user.id, NSNumber(booleanLiteral: true))
        
        // Setup Moya provider and send network request
        let provider = MoyaProvider<APICalls>()
        provider.request(.addOrder(uid: user.id, restaurantID: order.restaurantID, payingWithCC: filteredPaymentMethods.first!.method)) { result in
            switch result {
            case let .success(moyaResponse):
                do {
                    
                    print("Status code: \(moyaResponse.statusCode)")
                    try moyaResponse.filterSuccessfulStatusCodes()
                    
                    let response = try moyaResponse.mapJSON() as! [String: Any]
                    
                    if response["success"] as! Int == 1 {
                        
                        print("Success adding order to database)!")
                        
                        try! realm.write {
                            self.order.id = response["orderID"] as! Int
                            self.order.isComplete = true
                            self.order.orderTime = NSDate()
                            self.user.pastOrders.append(self.order)
                        }
                        
                        self.myActivityIndicator.stopAnimating()
                        
                        print(self.order.id)
                        print(self.order.restaurantID)
                        print(self.order.paymentMethod)
                        print(self.order.subtotal)
                        print(self.order.deliveryFee)
                        print(self.order.isComplete)
                        print(self.order.orderTime)
                        
                        self.sendRestaurantConfirmationEmail()
                        self.sendUserConfirmationEmail()
                        self.dispatch_group.wait(timeout: .distantFuture)
                        
                        self.performSegue(withIdentifier: "toOrderPlaced", sender: self)
                    }
                    
                } catch {
                    // Miscellaneous network error
                    self.showConfirmViewError(errorTitle: "Network Error", errorMessage: "Something went wrong 😱 Make sure you're connected to the internet and please try again.")
                }
            case .failure(_):
                // Connection failed
                self.showConfirmViewError(errorTitle: "Network Error", errorMessage: "Something went wrong 😱 Make sure you're connected to the internet and please try again.")
            }
        }
        
    }
    
}
