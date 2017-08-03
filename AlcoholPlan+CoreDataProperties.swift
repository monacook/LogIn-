//
//  AlcoholPlan+CoreDataProperties.swift
//  Test
//
//  Created by Danielle on 4/4/17.
//  Copyright © 2017 Danielle. All rights reserved.
//

import Foundation
import CoreData


extension AlcoholPlan {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AlcoholPlan> {
        return NSFetchRequest<AlcoholPlan>(entityName: "AlcoholPlan");
    }

    @NSManaged public var alcoholContent: Double
    @NSManaged public var drinkType: String?
    @NSManaged public var totalCarbs: Double
    @NSManaged public var hasMealPlan: MealItems?

}
