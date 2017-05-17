////
////  MyAPIClient.swift
////  Stripe iOS Example (Simple)
////
////  Created by Alexander Gerrese on 4/15/16.
////  Copyright © 2016 Stripe. All rights reserved.
////
//
//import Foundation
//import Stripe
//
//class MyAPIClient: NSObject, STPBackendAPIAdapter {
//    
//    func selectDefaultCustomerSource(_ source: STPSourceProtocol, completion: @escaping STPErrorBlock) {
//        <#code#>
//    }
//
//    
//    static let sharedClient = MyAPIClient()
//    var customerID = ""
//    var defaultSource: STPCard? = nil
//    var sources: [STPCard] = []
//    
//    // Set up UserDefaults
//    let defaults = UserDefaults.standard
//    
//    func completeCharge(_ result: STPPaymentResult, amount: Int, completion: @escaping STPErrorBlock) {
//        
//        let params: [String: AnyObject] = [
//            "source": result.source.stripeID as AnyObject,
//            "amount": amount as AnyObject,
//            "customerID": customerID as AnyObject
//        ]
//        let URL = "http://www.gobringit.com/payment.php"
//        let manager = AFHTTPSessionManager()
//        manager.responseSerializer = AFHTTPResponseSerializer()
//        manager.post(URL, parameters: params, success: { (operation, responseObject) -> Void in
//            
//            if let response = responseObject as? [String: String] {
//                UIAlertView(title: response["status"],
//                    message: response["message"],
//                    delegate: nil,
//                    cancelButtonTitle: "OK").show()
//            }
//            
//        })
//    }
//    
//    func retrieveCustomer(_ completion: @escaping STPCustomerCompletionBlock) {
//        print("RETRIEVE CUSTOMER")
//        if let userID = defaults.object(forKey: "userID") {
//            print("USER HAS ALREADY LOGGED IN AND HAS USERID")
//            print(defaults.object(forKey: "stripeCustomerID"))
//            
//            let params = ["uid" : userID as! String,
//                          "customerID": customerID
//                ] as Dictionary<String,String>
//            print("PARAMS ARE \(params["uid"]) and \(params["customerID"])")
//            print(customerID)
//            let URL = "http://www.gobringit.com/STRIPEretrieve_customer.php"
//            let manager = AFHTTPSessionManager()
//            manager.responseSerializer = AFJSONResponseSerializer()
//            manager.requestSerializer = AFHTTPRequestSerializer()
//            manager.get(URL, parameters:
//                params,
//                        progress: .none,
//                        success: { (operation, responseObject) in
//                            print("RC success")
//                            let deserializer = STPCustomerDeserializer(jsonResponse: responseObject!)
//                            print(deserializer.customer?.stripeID)
//                            completion(deserializer.customer, nil)
//                            
//                            // Save customerID to userDefaults
//                            self.defaults.set(deserializer.customer?.stripeID, forKey: "stripeCustomerID")
//                            
//                })
//        }
//        
//        
//    }
//    
//    func selectDefaultCustomerSource(_ source: STPSource, completion: @escaping STPErrorBlock) {
//        
//        print("SELECT DEFAULT")
//        
//        let params: [String: AnyObject] = [
//            "customerID": customerID as AnyObject,
//            "source": source.stripeID as AnyObject
//        ]
//        let URL = "http://www.gobringit.com/STRIPEdefault_source.php"
//        let manager = AFHTTPSessionManager()
//        manager.responseSerializer = AFHTTPResponseSerializer()
//        manager.post(URL, parameters: params, success: { (operation, responseObject) -> Void in
//            
//            
//        })
//        
//    }
//    
//    func attachSource(toCustomer source: STPSource, completion: @escaping STPErrorBlock) {
//        
//        print("Attach SOURCE")
//        
//        let params: [String: AnyObject] = [
//            "customerID": customerID as AnyObject,
//            "source": source.stripeID as AnyObject
//        ]
//        let URL = "http://www.gobringit.com/STRIPEcreate_card.php"
//        let manager = AFHTTPSessionManager()
//        manager.responseSerializer = AFHTTPResponseSerializer()
//        manager.post(URL, parameters: params, success: { (operation, responseObject) -> Void in
//            completion(nil)
//        }) 
//    }
//    
//    func handleError(_ error: NSError) {
//        print(error)
//        UIAlertView(title: "Please Try Again",
//                    message: error.localizedDescription,
//                    delegate: nil,
//                    cancelButtonTitle: "OK").show()
//        
//    }
//    
//}
