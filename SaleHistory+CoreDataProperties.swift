//
//  SaleHistory+CoreDataProperties.swift
//  CoreDataHomeReport
//
//  Created by Igor Korshunov on 26/12/2019.
//  Copyright © 2019 Igor Korshunov. All rights reserved.
//
//

import Foundation
import CoreData


extension SaleHistory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SaleHistory> {
        return NSFetchRequest<SaleHistory>(entityName: "SaleHistory")
    }

    @NSManaged public var soldPrice: Double
    @NSManaged public var soldDate: Date?
    @NSManaged public var home: Home?

}
