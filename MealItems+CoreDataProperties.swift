//
//  MealItems+CoreDataProperties.swift
//  Test
//
//  Created by Danielle on 4/4/17.
//  Copyright © 2017 Danielle. All rights reserved.
//

import Foundation
import CoreData


extension MealItems {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MealItems> {
        return NSFetchRequest<MealItems>(entityName: "MealItems");
    }

    @NSManaged public var foodAmount: Double
    @NSManaged public var foodCarbs: Double
    @NSManaged public var foodMeasure: String?
    @NSManaged public var foodName: String?
    @NSManaged public var hasAlcoholPlan: AlcoholPlan?
    @NSManaged public var hasInsulinPlan: InsulinPlan?

}
