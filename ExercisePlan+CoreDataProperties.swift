//
//  ExercisePlan+CoreDataProperties.swift
//  Test
//
//  Created by Danielle on 4/4/17.
//  Copyright © 2017 Danielle. All rights reserved.
//

import Foundation
import CoreData


extension ExercisePlan {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ExercisePlan> {
        return NSFetchRequest<ExercisePlan>(entityName: "ExercisePlan");
    }

    @NSManaged public var duration: Double
    @NSManaged public var intensity: String?
    @NSManaged public var hasInsulinPlan: InsulinPlan?

}
