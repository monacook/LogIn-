//
//  BodyWeight+CoreDataProperties.swift
//  Test
//
//  Created by Danielle on 4/4/17.
//  Copyright © 2017 Danielle. All rights reserved.
//

import Foundation
import CoreData


extension BodyWeight {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BodyWeight> {
        return NSFetchRequest<BodyWeight>(entityName: "BodyWeight");
    }

    @NSManaged public var currentWeight: Double
    @NSManaged public var setDate: NSDate?

}
