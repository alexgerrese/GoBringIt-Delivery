//
//  Order+CoreDataProperties.swift
//  BringIt
//
//  Created by Alexander's MacBook on 7/24/16.
//  Copyright © 2016 Campus Enterprises. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Order {

    @NSManaged var isActive: NSNumber?
    @NSManaged var id: String?
    @NSManaged var totalPrice: NSNumber?
    @NSManaged var dateOrdered: NSDate?
    @NSManaged var deliveryFee: NSNumber?
    @NSManaged var restaurant: String?
    // TODO: Alex, I tried this but got an error.
    //@NSManaged var restaurantID: String?
    @NSManaged var items: NSSet?

}
