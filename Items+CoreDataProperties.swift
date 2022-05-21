//
//  Items+CoreDataProperties.swift
//  ios-rental-ver4
//
//  Created by user211681 on 5/20/22.
//
//

import Foundation
import CoreData


extension Items {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Items> {
        return NSFetchRequest<Items>(entityName: "Items")
    }

    @NSManaged public var name: String?
    @NSManaged public var image: String?
    @NSManaged public var price: Double
    @NSManaged public var category: String?

}

extension Items : Identifiable {

}
