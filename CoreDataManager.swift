//
//  CoreDataManager.swift
//  Test
//
//  Created by Danielle on 3/15/17.
//  Copyright © 2017 Danielle. All rights reserved.
//

import Foundation
import UIKit
import CoreData

let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

class CoreDataManager {
    
    var faveMeals = [NSManagedObject]()
    var endocrineSettings = [NSManagedObject]()
    var weight = [NSManagedObject]()
    var alcohol = [NSManagedObject]()
    var exercise = [NSManagedObject]()
    var insulin = [NSManagedObject]()
    var meals = [NSManagedObject]()
    
    
    func saveToFaveMeals(mealTitle: String, mealCarbs: Double, mealSize: Double, mealMetric: String)
    {
        let mealDesc = NSEntityDescription.insertNewObject(forEntityName: "FaveMeal", into: context) as! FaveMeal
        
        mealDesc.title = mealTitle
        mealDesc.carbs = mealCarbs
        mealDesc.size = mealSize
        mealDesc.metric = mealMetric
        
        do
        {
            faveMeals.append(mealDesc)
            try context.save()
        } catch {
            print("**Error: \(error)")
        }
    }
    
    func saveEndocrineSettings(settingType: String, setDate: Date, value24L: Int, value24H: Int, value1L: Int, value1H: Int, value2L: Int, value2H: Int, value3L: Int, value3H: Int, start1: Date, start2: Date, start3: Date, end1: Date, end2: Date, end3: Date)
    {
        let endoSetting = NSEntityDescription.insertNewObject(forEntityName: "EndocrineSettings", into: context) as! EndocrineSettings
        
        endoSetting.setDate = setDate as NSDate?
        let esSetting = settingType
        
        if esSetting == "CF"
        {
            endoSetting.isCF = true
            endoSetting.isICR = false
            endoSetting.isTBG = false
        }
        else if esSetting == "ICR"
        {
            endoSetting.isCF = false
            endoSetting.isICR = true
            endoSetting.isTBG = false
        }
        else if esSetting == "TBG"
        {
            endoSetting.isCF = false
            endoSetting.isICR = false
            endoSetting.isTBG = true
        }
        
        endoSetting.value24a = Int16(value24L)
        endoSetting.value24b = Int16(value24H)
        endoSetting.value1a = Int16(value1L)
        endoSetting.value1b = Int16(value1H)
        endoSetting.value2a = Int16(value2L)
        endoSetting.value2b = Int16(value2H)
        endoSetting.value3a = Int16(value3L)
        endoSetting.value3b = Int16(value3H)
        
        endoSetting.startTime1 = start1 as NSDate?
        endoSetting.endTime1 = end1 as NSDate?
        endoSetting.startTime2 = start2 as NSDate?
        endoSetting.endTime2 = end2 as NSDate?
        endoSetting.startTime3 = start3 as NSDate?
        endoSetting.endTime3 = end3 as NSDate?
        
        do
        {
            endocrineSettings.append(endoSetting)
            try context.save()
        } catch {
            print("**Error: \(error)")
        }
    }
    
    func saveWeight(weightValue: Double, date: Date){
        
        let weightSample = NSEntityDescription.insertNewObject(forEntityName: "BodyWeight", into: context) as! BodyWeight
        
        weightSample.setDate = date as NSDate?
        weightSample.currentWeight = weightValue
        
        do
        {
            weight.append(weightSample)
            try context.save()
        } catch {
            print("**Error: \(error)")
        }
    }
    
    func getWeight() -> [BodyWeight] {
        
        let fetch:NSFetchRequest = NSFetchRequest<BodyWeight>(entityName: "BodyWeight")
        fetch.sortDescriptors = [NSSortDescriptor(key: "setDate", ascending:false)]
        fetch.fetchLimit = 1
        let past = NSDate.distantPast as Date
        var tempWeight = NSEntityDescription.insertNewObject(forEntityName: "BodyWeight", into: context) as! BodyWeight
        tempWeight.currentWeight = 0.0
        tempWeight.setDate = past as NSDate?
        
        do
        {
            let results = try context.fetch(fetch)
            for result in results
            {
                tempWeight = result
            }
        }
        catch
        {
            print("**Error: \(error)")
        }
        return [tempWeight]
    }
    
    
    func saveAlcohol(typeDrink: String, carbs: Double, alcContent: Double) -> AlcoholPlan {
        
        let beverage = NSEntityDescription.insertNewObject(forEntityName: "AlcoholPlan", into: context) as! AlcoholPlan
        
        beverage.drinkType = typeDrink
        beverage.totalCarbs = carbs
        beverage.alcoholContent = alcContent
        
        do
        {
            alcohol.append(beverage)
            try context.save()
        } catch {
            print("**Error: \(error)")
        }
        return beverage
    }

    
    func saveExercise(durationMin: Double, intensity3: String, hasRecommendation: InsulinPlan) -> ExercisePlan {
        
        let exerciseEvent = NSEntityDescription.insertNewObject(forEntityName: "ExercisePlan", into: context) as! ExercisePlan
        
        exerciseEvent.duration = durationMin
        exerciseEvent.intensity = intensity3
        exerciseEvent.hasInsulinPlan = hasRecommendation
        
        do
        {
            exercise.append(exerciseEvent)
            try context.save()
        } catch {
            print("**Error: \(error)")
        }
        return exerciseEvent
    }
    
    func saveRecommendation(cf: Double, icr: Double, tLow: Double, tHigh: Double, glucose: Double, iob: Double, totalCarbs: Double, date: Date, insulinRec: Double, carbsRec: Double, insulinDel: Double, carbsDel: Double, foodPic: NSData, mealItems: MealItems, exercise: ExercisePlan) -> InsulinPlan {
        
        let recommendation = NSEntityDescription.insertNewObject(forEntityName: "InsulinPlan", into: context) as! InsulinPlan
        
        recommendation.correctionFactor = cf
        recommendation.insulinCarbRatio = icr
        recommendation.targetBG_Low = tLow
        recommendation.targetBG_High = tHigh
        recommendation.currentBG = glucose
        recommendation.insulinOnBoard = iob
        recommendation.totalMealCarbs = totalCarbs
        recommendation.timeStamp = date as NSDate
        recommendation.recommendedInsulin = insulinRec
        recommendation.recommendedCarbs = carbsRec
        recommendation.deliveredInsulin = insulinDel
        recommendation.carbsConsumed = carbsDel
        recommendation.foodPhoto = foodPic
        recommendation.hasMealItems = mealItems
        recommendation.hasExercisePlan = exercise
        
        do
        {
            insulin.append(recommendation)
            try context.save()
        } catch {
            print("**Error: \(error)")
        }
        return recommendation
    }
    
    
    func saveMealItems(description: String, carbs: Double, amount: Double, measure: String, hasAlcohol: AlcoholPlan, hasInsulin: InsulinPlan){
        
        let mealDetails = NSEntityDescription.insertNewObject(forEntityName: "MealItems", into: context) as! MealItems
        
        mealDetails.foodName = description
        mealDetails.foodCarbs = carbs
        mealDetails.foodAmount = amount
        mealDetails.foodMeasure = measure
        mealDetails.hasAlcoholPlan = hasAlcohol
        mealDetails.hasInsulinPlan = hasInsulin
        
        do
        {
            meals.append(mealDetails)
            try context.save()
        } catch {
            print("**Error: \(error)")
        }
    }
    
    func saveOneMealItemtoRecommendation(description: String, carbs: Double, amount: Double, measure: String) -> MealItems
    {
        let mealItem = NSEntityDescription.insertNewObject(forEntityName: "MealItems", into: context) as! MealItems
        
        mealItem.foodName = description
        mealItem.foodCarbs = carbs
        mealItem.foodAmount = amount
        mealItem.foodMeasure = measure
        
        return mealItem
    }
}
