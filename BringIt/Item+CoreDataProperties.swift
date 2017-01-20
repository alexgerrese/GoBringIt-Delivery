//
//  Item+CoreDataProperties.swift
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

extension Item {

    @NSManaged var name: String?
    @NSManaged var dbDescription: String?
    @NSManaged var price: NSNumber?
    @NSManaged var id: String?
    @NSManaged var selectedFoodSidesNum: NSNumber?
    @NSManaged var specialInstructions: String?
    @NSManaged var order: Order?
    @NSManaged var sides: NSSet?
    @NSManaged var quantity: NSNumber?

}