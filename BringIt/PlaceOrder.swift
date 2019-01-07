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
                        
                        // COMMENT NEXT LINE OUT TO TEST ORDERS (Won't be emailed to restaurant)
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
    
    func chargeCard() {
        
        let realm = try! Realm() // Initialize Realm
        
        let paymentMethod = realm.objects(PaymentMethod.self).filter(NSPredicate(format: "method = %@ AND userID = %@", order.paymentMethod, user.id))
        if paymentMethod.count != 1 || paymentMethod.first == nil {
            checkoutButton.isEnabled = false
            checkoutButtonView.backgroundColor = Constants.red
            cartTotal.isHidden = true
            checkoutButton.setTitle("Failed to calculate delivery fee.", for: .normal)
            
            return
        }
        
        let cardID = paymentMethod.first!.methodID
        
        print("ABOUT TO CHARGE CREDIT CARD: \(cardID). AMOUNT = \(calculateTotal() * 100.00)")
        
        // Setup Moya provider and send network request
        let provider = MoyaProvider<APICalls>()
        provider.request(.stripeCharge(userID: user.id, restaurantID: restaurant.id, amount: "\(calculateTotal() * 100.00)", cardID: cardID)) { result in
            switch result {
            case let .success(moyaResponse):
                do {
                    
                    print("Status code: \(moyaResponse.statusCode)")
                    try moyaResponse.filterSuccessfulStatusCodes()
                    
                    let response = try moyaResponse.mapJSON() as! [String: Any]
                    
                    if response["success"] as! Int == 1 {
                        
                        print("Success charging the card!")
                        
                        // Actually place order
                        self.placeOrder()
                    }
                } catch {
                    // Miscellaneous network error
                    self.checkoutButton.isEnabled = false
                    self.checkoutButtonView.backgroundColor = Constants.red
                    self.cartTotal.isHidden = true
                    self.checkoutButton.setTitle("Network Error. Please try again.", for: .normal)
                    
                    return
                }
            case .failure(_):
                // Connection failed
                self.checkoutButton.isEnabled = false
                self.checkoutButtonView.backgroundColor = Constants.red
                self.cartTotal.isHidden = true
                self.checkoutButton.setTitle("Connection Failed. Please try again.", for: .normal)
                
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
