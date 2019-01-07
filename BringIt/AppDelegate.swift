//
//  AppDelegate.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/13/16.
//  Copyright © 2016 Campus Enterprises. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Stripe
import SendGrid
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Set up keyboard manager
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.keyboardDistanceFromTextField = CGFloat(80)
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.toolbarPreviousNextAllowedClasses.append(IQPreviousNextView.self)
        
        // Stripe Configuration
        Stripe.setDefaultPublishableKey("pk_live_UGdTD7Uq8SdIYMhknwzoH3ER")
        STPPaymentConfiguration.shared().publishableKey = "pk_live_UGdTD7Uq8SdIYMhknwzoH3ER"
        STPTheme.default().accentColor = Constants.green
        STPTheme.default().secondaryForegroundColor = UIColor.darkGray
        STPTheme.default().font = UIFont(name: "Avenir-Book", size: 17)!
        
        // Set default navigation bar attributes
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "BrandonGrotesque-Medium", size: 17)!, NSAttributedStringKey.foregroundColor: Constants.darkGray] // font color
        UINavigationBar.appearance().tintColor = UIColor.darkGray // button color
        UINavigationBar.appearance().barTintColor = UIColor.white // bar color
        
        print("Setting Realm schema and performing migrations.")
        
        // Configure Realm migrations
        var config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 16,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < 2) {
                    migration.enumerateObjects(ofType: Restaurant.className()) { oldObject, newObject in
                        newObject!["email"] = ""
                    }
                }
                if (oldSchemaVersion < 3) {
                    migration.enumerateObjects(ofType: Restaurant.className()) { oldObject, newObject in
                        newObject!["printerEmail"] = ""
                    }
                }
                if (oldSchemaVersion < 4) {
                    migration.enumerateObjects(ofType: MenuItem.className()) { oldObject, newObject in
                        newObject!["isOfficialDescription"] = false
                    }
                    migration.enumerateObjects(ofType: Side.className()) { oldObject, newObject in
                        newObject!["isOfficialDescription"] = false
                    }
                }
                if (oldSchemaVersion < 5) {
                    migration.enumerateObjects(ofType: Restaurant.className()) { oldObject, newObject in
                        newObject!["minimumPrice"] = 0.0
                    }
                }
                if (oldSchemaVersion < 6) {
                    migration.enumerateObjects(ofType: Restaurant.className()) { oldObject, newObject in
                        newObject!["imageURL"] = ""
                    }
                    migration.enumerateObjects(ofType: MenuItem.className()) { oldObject, newObject in
                        newObject!["imageURL"] = ""
                    }
                }
                if (oldSchemaVersion < 7) {
                }
                if (oldSchemaVersion < 8) {
                }
                if (oldSchemaVersion < 9) {
                    migration.enumerateObjects(ofType: Restaurant.className()) { oldObject, newObject in
                        newObject!["paymentOptions"] = ""
                    }
                }
                if (oldSchemaVersion < 10) {
                    migration.enumerateObjects(ofType: Restaurant.className()) { oldObject, newObject in
                        newObject!["deliveryOnly"] = true
                    }
                }
                if (oldSchemaVersion < 11) {
                    migration.enumerateObjects(ofType: Order.className()) { oldObject, newObject in
                        newObject!["isDelivery"] = true
                    }
                }
                if (oldSchemaVersion < 12) {
                    migration.enumerateObjects(ofType: PaymentMethod.className()) { oldObject, newObject in
                        newObject!["methodID"] = ""
                    }
                }
                if (oldSchemaVersion < 13) {
                    migration.enumerateObjects(ofType: PaymentMethod.className()) { oldObject, newObject in
                        newObject!["userID"] = ""
                    }
                }
                if (oldSchemaVersion < 14) {
                }
                if (oldSchemaVersion < 15) {
                    migration.enumerateObjects(ofType: Restaurant.className()) { oldObject, newObject in
                        newObject!["address"] = ""
                    }
                }
                if (oldSchemaVersion < 16) {
                    migration.enumerateObjects(ofType: Restaurant.className()) { oldObject, newObject in
                        newObject!["announcement"] = ""
                    }
                }
                if (oldSchemaVersion < 17) {
                    migration.enumerateObjects(ofType: Promotion.className()) { oldObject, newObject in
                        newObject!["imageURL"] = ""
                    }
                }
        })
        
        config.deleteRealmIfMigrationNeeded = true
        
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
        
        // Now that we've told Realm how to handle the schema change, opening the file
        // will automatically perform the migration
        _ = try! Realm()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

