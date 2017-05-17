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


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Set up keyboard manager
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().keyboardDistanceFromTextField = CGFloat(80)
        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = true
//        IQKeyboardManager.sharedManager().enableAutoToolbar = true
        IQKeyboardManager.sharedManager().preventShowingBottomBlankSpace = true
        
        // Stripe Configuration
        Stripe.setDefaultPublishableKey("pk_live_UGdTD7Uq8SdIYMhknwzoH3ER")
        STPTheme.default().accentColor = Constants.green
        STPTheme.default().secondaryForegroundColor = UIColor.darkGray
        STPTheme.default().font = UIFont(name: "Avenir-Book", size: 17)!
        
        // Set default navigation bar attributes
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont(name: "BrandonGrotesque-Medium", size: 17)!, NSForegroundColorAttributeName: Constants.darkGray] // font color
        UINavigationBar.appearance().tintColor = UIColor.darkGray // button color
        UINavigationBar.appearance().barTintColor = UIColor.white // bar color
//        UINavigationBar.appearance().isOpaque = true // bar translucency
//        UINavigationBar.appearance().layer.shadowColor = Constants.lightGray.cgColor // shadow color
//        UINavigationBar.appearance().layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
//        UINavigationBar.appearance().layer.shadowRadius = 4.0
//        UINavigationBar.appearance().layer.shadowOpacity = 1.0
//        UINavigationBar.appearance().layer.masksToBounds = false
        
        
        
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

