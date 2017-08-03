//
//  EndocrineSettings+CoreDataProperties.swift
//  Test
//
//  Created by Danielle on 4/4/17.
//  Copyright © 2017 Danielle. All rights reserved.
//

import Foundation
import CoreData


extension EndocrineSettings {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EndocrineSettings> {
        return NSFetchRequest<EndocrineSettings>(entityName: "EndocrineSettings");
    }

    @NSManaged public var endTime1: NSDate?
    @NSManaged public var endTime2: NSDate?
    @NSManaged public var endTime3: NSDate?
    @NSManaged public var isCF: Bool
    @NSManaged public var isICR: Bool
    @NSManaged public var isTBG: Bool
    @NSManaged public var setDate: NSDate?
    @NSManaged public var startTime1: NSDate?
    @NSManaged public var startTime2: NSDate?
    @NSManaged public var startTime3: NSDate?
    @NSManaged public var value1a: Int16
    @NSManaged public var value1b: Int16
    @NSManaged public var value2a: Int16
    @NSManaged public var value2b: Int16
    @NSManaged public var value3a: Int16
    @NSManaged public var value3b: Int16
    @NSManaged public var value24a: Int16
    @NSManaged public var value24b: Int16

}
