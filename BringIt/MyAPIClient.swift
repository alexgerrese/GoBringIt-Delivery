//
//  MyAPIClient.swift
//  Stripe iOS Example (Simple)
//
//  Created by Alexander Gerrese on 4/15/16.
//  Copyright © 2016 Stripe. All rights reserved.
//

import Foundation
import Stripe
import AFNetworking

class MyAPIClient: NSObject, STPBackendAPIAdapter {
    
    static let sharedClient = MyAPIClient()
    var customerID = ""
    var defaultSource: STPCard? = nil
    var sources: [STPCard] = []
    
    // Set up UserDefaults
    let defaults = NSUserDefaults.standardUserDefaults()
    
    func completeCharge(result: STPPaymentResult, amount: Int, completion: STPErrorBlock) {
        
        let params: [String: AnyObject] = [
            "source": result.source.stripeID,
            "amount": amount,
            "customerID": customerID
        ]
        let URL = "https://www.gobring.it/payment.php"
        let manager = AFHTTPSessionManager()
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.POST(URL, parameters: params, success: { (operation, responseObject) -> Void in
            
            if let response = responseObject as? [String: String] {
                UIAlertView(title: response["status"],
                    message: response["message"],
                    delegate: nil,
                    cancelButtonTitle: "OK").show()
            }
            
        }) { (operation, error) -> Void in
            self.handleError(error)
        }
    }
    
    func retrieveCustomer(completion: STPCustomerCompletionBlock) {
        print("RETRIEVE CUSTOMER")
        if let userID = defaults.objectForKey("userID") {
            print("USER HAS ALREADY LOGGED IN AND HAS USERID")
            print(defaults.objectForKey("stripeCustomerID"))
            
            let params = ["uid" : userID as! String,
                          "customerID": customerID
                ] as Dictionary<String,String>
            print("PARAMS ARE \(params["uid"]) and \(params["customerID"])")
            print(customerID)
            let URL = "https://www.gobring.it/STRIPEretrieve_customer.php"
            let manager = AFHTTPSessionManager()
            manager.responseSerializer = AFJSONResponseSerializer()
            manager.requestSerializer = AFHTTPRequestSerializer()
            manager.GET(URL, parameters:
                params,
                        progress: .None,
                        success: { (operation, responseObject) in
                            print("RC success")
                            let deserializer = STPCustomerDeserializer(JSONResponse: responseObject!)
                            print(deserializer.customer?.stripeID)
                            completion(deserializer.customer, nil)
                            
                            // Save customerID to userDefaults
                            self.defaults.setObject(deserializer.customer?.stripeID, forKey: "stripeCustomerID")
                            
                },
                        failure: { (operation, error) -> Void in
                            self.handleError(error)
            })
        }
        
        
    }
    
    func selectDefaultCustomerSource(source: STPSource, completion: STPErrorBlock) {
        
        print("SELECT DEFAULT")
        
        let params: [String: AnyObject] = [
            "customerID": customerID,
            "source": source.stripeID
        ]
        let URL = "https://www.gobring.it/STRIPEdefault_source.php"
        let manager = AFHTTPSessionManager()
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.POST(URL, parameters: params, success: { (operation, responseObject) -> Void in
            
            
        }) { (operation, error) -> Void in
            self.handleError(error)
        }
        
    }
    
    func attachSourceToCustomer(source: STPSource, completion: STPErrorBlock) {
        
        print("Attach SOURCE")
        
        let params: [String: AnyObject] = [
            "customerID": customerID,
            "source": source.stripeID
        ]
        let URL = "https://www.gobring.it/STRIPEcreate_card.php"
        let manager = AFHTTPSessionManager()
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.POST(URL, parameters: params, success: { (operation, responseObject) -> Void in
            completion(nil)
        }) { (operation, error) -> Void in
            self.handleError(error)
        }
    }
    
    func handleError(error: NSError) {
        print(error)
        UIAlertView(title: "Please Try Again",
                    message: error.localizedDescription,
                    delegate: nil,
                    cancelButtonTitle: "OK").show()
        
    }
    
}
