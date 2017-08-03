//
//  FaveMeal+CoreDataProperties.swift
//  Test
//
//  Created by Danielle on 4/4/17.
//  Copyright © 2017 Danielle. All rights reserved.
//

import Foundation
import CoreData


extension FaveMeal {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FaveMeal> {
        return NSFetchRequest<FaveMeal>(entityName: "FaveMeal");
    }

    @NSManaged public var carbs: Double
    @NSManaged public var metric: String?
    @NSManaged public var size: Double
    @NSManaged public var title: String?

}
