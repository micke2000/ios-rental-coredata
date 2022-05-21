//
//  Rezerwacja+CoreDataProperties.swift
//  ios-rental-ver4
//
//  Created by user211681 on 5/21/22.
//
//

import Foundation
import CoreData


extension Rezerwacja {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Rezerwacja> {
        return NSFetchRequest<Rezerwacja>(entityName: "Rezerwacja")
    }

    @NSManaged public var beginDate: Date?
    @NSManaged public var endDate: Date?
    @NSManaged public var docType: String?
    @NSManaged public var docNumber: String?
    @NSManaged public var totalAmount: Double
    @NSManaged public var reservationItem: NSSet?
    public var itemsArray:[Equipment]{
        let set = reservationItem as? Set<Equipment> ?? []
        return set.sorted{
            $0.name! < $1.name!
        }
    }
}

// MARK: Generated accessors for reservationItem
extension Rezerwacja {

    @objc(addReservationItemObject:)
    @NSManaged public func addToReservationItem(_ value: Equipment)

    @objc(removeReservationItemObject:)
    @NSManaged public func removeFromReservationItem(_ value: Equipment)

    @objc(addReservationItem:)
    @NSManaged public func addToReservationItem(_ values: NSSet)

    @objc(removeReservationItem:)
    @NSManaged public func removeFromReservationItem(_ values: NSSet)

}

extension Rezerwacja : Identifiable {

}
