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
import Stripe

extension CheckoutVC {
    func clearCart(completion: @escaping (_ result: Int) -> Void) {
        // Setup Moya provider and send network request
        let provider = MoyaProvider<CombinedAPICalls>()
        provider.request(.clearCart(uid: user.id)) { result in
            switch result {
            case let .success(moyaResponse):
                do {
                    
                    print("Status code for clearCart(): \(moyaResponse.statusCode)")
                    try moyaResponse.filterSuccessfulStatusCodes()
                    
                    let response = try moyaResponse.mapJSON() as! [String: Any]
                    
                    if response["success"] as! Int == 1 {
                        
                        print("Success clearing cart!")
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
    
    func addAllToCart(completion: @escaping (_ result: Int) -> Void) {
        
        for item in order.menuItems {
            
            print("Adding to cart")
            
            var sideIDs = [String]()
            for side in item.sides {
                if side.isSelected {
                    sideIDs.append(side.id)
                }
            }
            for extra in item.extras {
                if extra.isSelected {
                    sideIDs.append(extra.id)
                }
            }
            
            // Setup Moya provider and send network request
            let provider = MoyaProvider<APICalls>()
            provider.request(.addItemToCart(uid: user.id, quantity: item.quantity, itemID: item.id, sideIDs: sideIDs, specialInstructions: item.specialInstructions)) { result in
                switch result {
                case let .success(moyaResponse):
                    do {
                        
                        print("Status code for addAllToCart(): \(moyaResponse.statusCode)")
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
        
        var paymentMethodValueString = order.paymentMethod!.paymentValue
        if order.paymentMethod?.paymentMethodID == 0 || order.paymentMethod?.paymentMethodID == 5 {
            paymentMethodValueString += "-" + order.paymentMethod!.paymentPin
        }
        
        // Setup Moya provider and send network request
        let provider = MoyaProvider<CombinedAPICalls>()
        provider.request(.placeOrder(
            uid: user.id,
            restaurantID: order.restaurantID,
            paymentValue: paymentMethodValueString,
            isPickup: order.isDelivery ? "0" : "1",
            amount: "\(order.subtotal*100)",
            deliveryFee: "\(order.deliveryFee*100)",
            creditUsed: "\(order.gbiCreditUsed*100)",
            paymentType: "\(order.paymentMethod!.paymentMethodID)",
            name: user.fullName,
            rememberPayment: order.paymentMethod!.unsaved ? "1" : "-1",
            addressId:  "\(order.address!.id)"
        )) { result in
            switch result {
            case let .success(moyaResponse):
                do {
                    
                    print("Status code for addOrder(): \(moyaResponse.statusCode)")
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
                        print(self.order.paymentMethod!.paymentString)
                        print(self.order.subtotal)
                        print(self.order.deliveryFee)
                        print(self.order.isComplete)
                        
                        let paymentMethods = realm.objects(PaymentMethod.self).filter(NSPredicate(format: "userID = %@", self.user.id))
                        
                        try! realm.write {
                            realm.delete(paymentMethods)
                        }
                        
                        // COMMENT NEXT LINE OUT TO TEST ORDERS (Won't be emailed to restaurant)
//                        self.sendRestaurantConfirmationEmail()
//                        self.sendUserConfirmationEmail()
//                        self.dispatch_group.wait(timeout: .distantFuture)
                        
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
    
    func chargeCard() {
        
        let realm = try! Realm() // Initialize Realm
        
        let paymentMethod = realm.objects(PaymentMethod.self).filter(NSPredicate(format: "paymentValue = %@ AND userID = %@", order.paymentMethod!.paymentValue, user.id))
        if paymentMethod.count != 1 || paymentMethod.first == nil {
            checkoutButton.isEnabled = false
            checkoutButtonView.backgroundColor = Constants.red
            cartTotal.isHidden = true
            checkoutButton.setTitle("Failed to calculate delivery fee.", for: .normal)
            
            return
        }
        
        let cardID = paymentMethod.first!.paymentValue
        
        print("ABOUT TO CHARGE CREDIT CARD: \(cardID). AMOUNT = \(Int(calculateTotal() * 100))")
        
        // Setup Moya provider and send network request
        let provider = MoyaProvider<APICalls>()
        provider.request(.stripeCharge(userID: user.id, restaurantID: restaurant.id, amount: "\(Int(calculateTotal() * 100))", cardID: cardID)) { result in
            switch result {
            case let .success(moyaResponse):
                do {
                    
                    print("Status code for chargeCard(): \(moyaResponse.statusCode)")
                    try moyaResponse.filterSuccessfulStatusCodes()
                    
                    let response = try moyaResponse.mapJSON() as! [String: Any]
                    print("RESPONSE FROM CHARGE: \(response)")
                    
                    if response["success"] as! Int == 1 {
                        
                        print("Success charging the card!")
                        
                        // Actually place order
                        self.placeOrder()
                        
                    } else if response["success"] as! Int == 0 {
                        
                        print("Card could not be charged.")
                        
                        self.showConfirmViewError(errorTitle: "Credit Card Error", errorMessage: "Something went wrong 😱 Your card could not be charged, please try again.")
                        
                        return
                        
                    } else if response["success"] as! Int == -1 {
                        
                        print("Card was declined.")
                        
                        self.showConfirmViewError(errorTitle: "Credit Card Declined", errorMessage: "Something went wrong 😱 Please add a new credit card and please try again.")
                        
                        return
                    }
                } catch {
                    // Miscellaneous network error
                   self.showConfirmViewError(errorTitle: "Network Error", errorMessage: "Something went wrong 😱 Make sure you're connected to the internet and please try again.")
                    
                    return
                }
            case .failure(_):
                // Connection failed
                self.showConfirmViewError(errorTitle: "Network Error", errorMessage: "Something went wrong 😱 Make sure you're connected to the internet and please try again.")
                
                return
            }
        }
        
    }
    
    
    
}

//extension CheckoutVC: STPPaymentContextDelegate {
//
//    // MARK: STPPaymentContextDelegate
//
//    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
//        let alertController = UIAlertController(
//            title: "Uh oh, an error occurred!",
//            message: "Please try again.",
//            preferredStyle: .alert
//        )
//        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
//            // Need to assign to _ because optional binding loses @discardableResult value
//            // https://bugs.swift.org/browse/SR-1681
//            _ = self.navigationController?.popViewController(animated: true)
//        })
//        let retry = UIAlertAction(title: "Retry", style: .default, handler: { action in
//            self.paymentContext.retryLoading()
//        })
//        alertController.addAction(cancel)
//        alertController.addAction(retry)
//        self.present(alertController, animated: true, completion: nil)
//    }
//
//    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
//        switch status {
//        case .error:
//            print("Error")
//            return
//        case .success:
//            print("Success")
//            placeOrder()
//        case .userCancellation:
//            return
//        }
//    }
//
//    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPErrorBlock) {
//        MyAPIClient.sharedClient.completeCharge(paymentResult,
//                                                amount: self.paymentContext.paymentAmount,
//                                                completion: completion)
//    }
//
//    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
//        //        self.paymentRow.loading = paymentContext.loading
//        //        if let paymentMethod = paymentContext.selectedPaymentMethod {
//        //            self.paymentRow.detail = paymentMethod.label
//        //        }
//        //        else {
//        //            self.paymentRow.detail = "Select Payment"
//        //        }
//        //        self.totalRow.detail = self.numberFormatter.string(from: NSNumber(value: Float(self.paymentContext.paymentAmount)/100))!
//    }
//}
