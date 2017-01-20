//
//  Side+CoreDataProperties.swift
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

extension Side {

    @NSManaged var name: String?
    @NSManaged var id: String?
    @NSManaged var price: NSNumber?
    @NSManaged var isRequired: NSNumber?
    @NSManaged var item: NSManagedObject?

}
