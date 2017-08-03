//
//  InsulinPlan+CoreDataProperties.swift
//  Test
//
//  Created by Danielle on 4/20/17.
//  Copyright © 2017 Danielle. All rights reserved.
//

import Foundation
import CoreData


extension InsulinPlan {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<InsulinPlan> {
        return NSFetchRequest<InsulinPlan>(entityName: "InsulinPlan");
    }

    @NSManaged public var carbsConsumed: Double
    @NSManaged public var correctionFactor: Double
    @NSManaged public var currentBG: Double
    @NSManaged public var deliveredInsulin: Double
    @NSManaged public var foodPhoto: NSData?
    @NSManaged public var insulinCarbRatio: Double
    @NSManaged public var insulinOnBoard: Double
    @NSManaged public var recommendedCarbs: Double
    @NSManaged public var recommendedInsulin: Double
    @NSManaged public var targetBG_High: Double
    @NSManaged public var targetBG_Low: Double
    @NSManaged public var timeStamp: NSDate?
    @NSManaged public var totalMealCarbs: Double
    @NSManaged public var hasExercisePlan: ExercisePlan?
    @NSManaged public var hasMealItems: MealItems?

}
