//
//  SingleFamily+CoreDataProperties.swift
//  CoreDataHomeReport
//
//  Created by Igor Korshunov on 26/12/2019.
//  Copyright © 2019 Igor Korshunov. All rights reserved.
//
//

import Foundation
import CoreData


extension SingleFamily {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SingleFamily> {
        return NSFetchRequest<SingleFamily>(entityName: "SingleFamily")
    }

    @NSManaged public var lotSize: Int16

}
