//
//  Condo+CoreDataProperties.swift
//  CoreDataHomeReport
//
//  Created by Igor Korshunov on 26/12/2019.
//  Copyright © 2019 Igor Korshunov. All rights reserved.
//
//

import Foundation
import CoreData


extension Condo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Condo> {
        return NSFetchRequest<Condo>(entityName: "Condo")
    }

    @NSManaged public var unitsPerBuilding: Int16

}
