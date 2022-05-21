//
//  Equipment+CoreDataProperties.swift
//  ios-rental-ver4
//
//  Created by user211681 on 5/21/22.
//
//

import Foundation
import CoreData


extension Equipment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Equipment> {
        return NSFetchRequest<Equipment>(entityName: "Equipment")
    }

    @NSManaged public var name: String?
    @NSManaged public var price: Double
    @NSManaged public var reservation: Rezerwacja?

}

extension Equipment : Identifiable {

}
