//
//  CalculateInsulinCarbs.swift
//  Test
//
//  Created by Danielle on 3/30/17.
//  Copyright © 2017 Danielle. All rights reserved.
//

import Foundation
import CoreData
import HealthKit
import UIKit

//Singleton
class CurrentES {
    
    static let sharedInstance = CurrentES()
    
    var allCurrentES = [Double]()
    
    init() {}
    
    func appendCurrentES(targetLow: Double, targetHigh: Double, correctionFactor: Double, insulinCarbRatio: Double, currGlucose: Double){
        
        let tLow = targetLow
        let tHigh = targetHigh
        let cf = correctionFactor
        let icr = insulinCarbRatio
        let glucose = currGlucose
        
        allCurrentES.append(tLow)
        allCurrentES.append(tHigh)
        allCurrentES.append(cf)
        allCurrentES.append(icr)
        allCurrentES.append(glucose)
    }
    
    func clearES() {
        
        allCurrentES.removeAll()
    }
}


struct BreakdownInsulin {
    
    var insulin: Double
    var carbs: Double
    var coverCarbs: Double
    var coverGlucose: Double
    var activeInsulin: Double
    var exercise: Double
    
    init(recInsulin: Double, recCarbs: Double, carbAdj: Double, glucoseAdj: Double, iob: Double, exerAdj: Double)
    {
        insulin = recInsulin
        carbs = recCarbs
        coverCarbs = carbAdj
        coverGlucose = glucoseAdj
        activeInsulin = iob
        exercise = exerAdj
    }
}

class CalculateInsulinCarbs {
  
    var recommendations = [InsulinPlan]()
    var recommendation = BreakdownInsulin(recInsulin: 0.0, recCarbs: 0.0, carbAdj: 0.0, glucoseAdj: 0.0, iob: 0.0, exerAdj: 0.0)
    
 
    func idecideRecommendation(carbohydrates: Double, currentGlucose: Double, exerciseIntensity: String, exerciseDuration: Double, context: NSManagedObjectContext) -> BreakdownInsulin
    {
        let vContext = context
        let carbRatio = getICR(context: vContext)
        let corrFact = getCF(context: vContext)
        let targetLow = getLow(context: vContext)
        let targetHigh = getHigh(context: vContext)
        var activeInsulin = calcIOB()
        let weight = getWeight()
        let carbs = carbohydrates
        let glucose = currentGlucose
        let intensity = exerciseIntensity
        let duration = exerciseDuration
        let insulinReduction = 0.0
        var totalInsulin = 0.0
        let carbSuggestion = 0.0
      
        CurrentES.sharedInstance.appendCurrentES(targetLow: targetLow, targetHigh: targetHigh, correctionFactor: corrFact, insulinCarbRatio: carbRatio, currGlucose: glucose)
        
        let mealCorrection = carbs / carbRatio
        
        var glucoseCorrection = 0.0
        
        if glucose > 0.0
        {
            if glucose <= targetHigh
            {
                activeInsulin = 0.0
                
                if glucose < targetLow
                {
                    glucoseCorrection = (glucose - targetLow) / corrFact
                }
            }
            else if glucose > targetHigh
            {
                glucoseCorrection = (glucose - targetHigh) / corrFact
                
                if glucoseCorrection - activeInsulin < 0.0
                {
                    glucoseCorrection = 0.0
                    activeInsulin = 0.0
                }
            }
        }
        else { //do nothing
        }
        
        totalInsulin = mealCorrection + glucoseCorrection + activeInsulin
        
        if totalInsulin < 0.0
        {
            totalInsulin = 0.0
        }
        
        recommendation.insulin = totalInsulin
        recommendation.carbs = carbSuggestion
        recommendation.coverCarbs = mealCorrection
        recommendation.coverGlucose = glucoseCorrection
        recommendation.activeInsulin = activeInsulin
        recommendation.exercise = insulinReduction
        
        if exerciseDuration > 0.0
        {
            if totalInsulin > 0.0
            {
                //use duration & intensity to reduce insulin
                let exerciseReducePercentage = getInsulinReduction(duration: duration, intensity: intensity)
                let insulinReduction = -totalInsulin * exerciseReducePercentage
                totalInsulin = totalInsulin + insulinReduction
                recommendation.exercise = insulinReduction
                recommendation.insulin = totalInsulin
            }
            else
            {
               //use weight and duration to suggest carbs
                let carbSuggestion = getCarbRecommendation(duration: duration, intensity: intensity, weight: weight)
                totalInsulin = 0.0
                recommendation.carbs = carbSuggestion
            }
        }
        return recommendation
    }
    
    func getCarbRecommendation(duration: Double, intensity: String, weight: Double) -> Double
    {
        var carbsRecommend:Double = 0.0
        var durationMultiplier:Int = 1
        
        if duration > 0 && duration <= 30
        {
            durationMultiplier = 1
        }
        else if duration > 30 && duration <= 60
        {
            durationMultiplier = 2
        }
        else if duration > 60 && duration <= 90
        {
            durationMultiplier = 3
        }
        
        if weight <= 34
        {
            if intensity == "Light"
            {
                carbsRecommend = 3
            }
            else if intensity == "Moderate"
            {
                carbsRecommend = 5
            }
            else if intensity == "Vigorous"
            {
                carbsRecommend = 8
            }
        }
        else if weight > 34 && weight <= 56
        {
            if intensity == "Light"
            {
                carbsRecommend = 5
            }
            else if intensity == "Moderate"
            {
                carbsRecommend = 8
            }
            else if intensity == "Vigorous"
            {
                carbsRecommend = 12
            }
        }
        else if weight > 56 && weight <= 79
        {
            if intensity == "Light"
            {
                carbsRecommend = 8
            }
            else if intensity == "Moderate"
            {
                carbsRecommend = 10
            }
            else if intensity == "Vigorous"
            {
                carbsRecommend = 18
            }
        }
        else if weight > 79 && weight <= 102
        {
            if intensity == "Light"
            {
                carbsRecommend = 10
            }
            else if intensity == "Moderate"
            {
                carbsRecommend = 12
            }
            else if intensity == "Vigorous"
            {
                carbsRecommend = 24
            }
        }
        else if weight > 102
        {
            if intensity == "Light"
            {
                carbsRecommend = 12
            }
            else if intensity == "Moderate"
            {
                carbsRecommend = 15
            }
            else if intensity == "Vigorous"
            {
                carbsRecommend = 30
            }
        }
        
        carbsRecommend = carbsRecommend * Double(durationMultiplier)
        return carbsRecommend
    }
    
    func getInsulinReduction(duration: Double, intensity: String) -> Double
    {
        var reducePercentage:Double = 0.0
        
        if duration < 20
        {
            reducePercentage = 0.0
        }
        else if duration >= 20 && duration < 40
        {
            if intensity == "Light"
            {
                reducePercentage = 0.1
            }
            else if intensity == "Moderate"
            {
                reducePercentage = 0.25
            }
            else if intensity == "Vigorous"
            {
                reducePercentage = 0.33
            }
            else
            {
                reducePercentage = 0.0
            }
        }
        else if duration >= 40 && duration < 60
        {
            if intensity == "Light"
            {
                reducePercentage = 0.2
            }
            else if intensity == "Moderate"
            {
                reducePercentage = 0.33
            }
            else if intensity == "Vigorous"
            {
                reducePercentage = 0.5
            }
            else
            {
                reducePercentage = 0.0
            }
        }
        else if duration >= 60 && duration < 90
        {
            if intensity == "Light"
            {
                reducePercentage = 0.3
            }
            else if intensity == "Moderate"
            {
                reducePercentage = 0.5
            }
            else if intensity == "Vigorous"
            {
                reducePercentage = 0.67
            }
            else
            {
                reducePercentage = 0.0
            }
        }
        else
        {
            reducePercentage = 0.0
        }
        return reducePercentage
    }
    
    func getICR(context: NSManagedObjectContext) -> Double {
  
        let now = NSDate() as Date
        let calendar = Calendar.current
        let nowHour = calendar.component(.hour, from: now)
        let vContext = context
        var icr:EndocrineSettings = NSEntityDescription.insertNewObject(forEntityName: "EndocrineSettings", into: vContext) as! EndocrineSettings
        var icrD:Double = 0.0
        let dateDescriptor = NSSortDescriptor(key: "setDate", ascending: false)
        let icrRequest = NSFetchRequest<EndocrineSettings>(entityName: "EndocrineSettings")
        let icrDesc = NSSortDescriptor(key: "isICR", ascending: false)
        icrRequest.sortDescriptors = [icrDesc, dateDescriptor]
        
        do {
            let results = try vContext.fetch(icrRequest)
            icr = results.first!
        } catch {
            print("Error \(error)")
        }
        
        if icr.value24a > 0
        {
            icrD = Double(icr.value24a)
        }
        else if icr.value3a > 0
        {
            let end1Hour = calendar.component(.hour, from: icr.endTime1! as Date)
            let start2Hour = calendar.component(.hour, from: icr.startTime2! as Date)
            let end2Hour = calendar.component(.hour, from: icr.endTime2! as Date)
            let start3Hour = calendar.component(.hour, from: icr.startTime3! as Date)
            
            if nowHour <= end1Hour
            {
                icrD = Double(icr.value1a)
            }
            else if nowHour >= start2Hour && nowHour <= end2Hour
            {
               icrD = Double(icr.value2a)
            }
            else if nowHour >= start3Hour
            {
                icrD = Double(icr.value3a)
            }
            else
            {
                print("Error")
            }
        }
        else
        {
            if icr.endTime1 != nil
            {
                let end1Hour = calendar.component(.hour, from: icr.endTime1! as Date)
                let start2Hour = calendar.component(.hour, from: icr.startTime2! as Date)
                
                if nowHour <= end1Hour
                {
                    icrD = Double(icr.value1a)
                }
                else if nowHour >= start2Hour
                {
                    icrD = Double(icr.value2a)
                }
                else
                {
                    print("Error")
                }
            }
            else
            {
                icrD = 0.0
            }
        }
        return icrD
    }
    
    func getCF(context: NSManagedObjectContext) -> Double {
        
        let now = NSDate() as Date
        let calendar = Calendar.current
        let nowHour = calendar.component(.hour, from: now)
        let vContext = context
        var cf:EndocrineSettings = NSEntityDescription.insertNewObject(forEntityName: "EndocrineSettings", into: vContext) as! EndocrineSettings
        var cfD:Double = 0.0
        let dateDescriptor = NSSortDescriptor(key: "setDate", ascending: false)
        let cfRequest = NSFetchRequest<EndocrineSettings>(entityName: "EndocrineSettings")
        let cfDesc = NSSortDescriptor(key: "isCF", ascending: false)
        cfRequest.sortDescriptors = [cfDesc, dateDescriptor]
        
        do {
            let results = try vContext.fetch(cfRequest)
            cf = results.first!
        } catch {
            print("Error \(error)")
        }
        
        if cf.value24a > 0
        {
            cfD = Double(cf.value24a)
        }
        else if cf.value3a > 0
        {
            let end1Hour = calendar.component(.hour, from: cf.endTime1! as Date)
            let start2Hour = calendar.component(.hour, from: cf.startTime2! as Date)
            let end2Hour = calendar.component(.hour, from: cf.endTime2! as Date)
            let start3Hour = calendar.component(.hour, from: cf.startTime3! as Date)
            
            if nowHour <= end1Hour
            {
                cfD = Double(cf.value1a)
            }
            else if nowHour >= start2Hour && nowHour <= end2Hour
            {
                cfD = Double(cf.value2a)
            }
            else if nowHour >= start3Hour
            {
                cfD = Double(cf.value3a)
            }
            else
            {
                print("Error")
            }
        }
        else
        {
            if cf.endTime1 != nil
            {
                let end1Hour = calendar.component(.hour, from: cf.endTime1! as Date)
                let start2Hour = calendar.component(.hour, from: cf.startTime2! as Date)
                
                if nowHour <= end1Hour
                {
                    cfD = Double(cf.value1a)
                }
                else if nowHour >= start2Hour
                {
                    cfD = Double(cf.value2a)
                }
                else
                {
                    print("Error")
                }
            }
            else
            {
                cfD = 0.0
            }
        }
        return cfD
    }
    
    func getLow(context: NSManagedObjectContext) -> Double {
        
        let now = NSDate() as Date
        let calendar = Calendar.current
        let nowHour = calendar.component(.hour, from: now)
        let vContext = context
        var tbg:EndocrineSettings = NSEntityDescription.insertNewObject(forEntityName: "EndocrineSettings", into: vContext) as! EndocrineSettings
        var tbgD:Double = 0.0
        let dateDescriptor = NSSortDescriptor(key: "setDate", ascending: false)
        let tbgRequest = NSFetchRequest<EndocrineSettings>(entityName: "EndocrineSettings")
        let tbgDesc = NSSortDescriptor(key: "isTBG", ascending: false)
        tbgRequest.sortDescriptors = [tbgDesc, dateDescriptor]
        
        do {
            let results = try vContext.fetch(tbgRequest)
            tbg = results.first!
        } catch {
            print("Error \(error)")
        }
        
        if tbg.value24a > 0
        {
            tbgD = Double(tbg.value24a)
        }
        else if tbg.value3a > 0
        {
            let end1Hour = calendar.component(.hour, from: tbg.endTime1! as Date)
            let start2Hour = calendar.component(.hour, from: tbg.startTime2! as Date)
            let end2Hour = calendar.component(.hour, from: tbg.endTime2! as Date)
            let start3Hour = calendar.component(.hour, from: tbg.startTime3! as Date)
            
            if nowHour <= end1Hour
            {
                tbgD = Double(tbg.value1a)
            }
            else if nowHour >= start2Hour && nowHour <= end2Hour
            {
                tbgD = Double(tbg.value2a)
            }
            else if nowHour >= start3Hour
            {
                tbgD = Double(tbg.value3a)
            }
            else
            {
                print("Error")
            }
        }
        else
        {
            if tbg.endTime1 != nil
            {
                let end1Hour = calendar.component(.hour, from: tbg.endTime1! as Date)
                let start2Hour = calendar.component(.hour, from: tbg.startTime2! as Date)
                
                if nowHour <= end1Hour
                {
                    tbgD = Double(tbg.value1a)
                }
                else if nowHour >= start2Hour
                {
                    tbgD = Double(tbg.value2a)
                }
                else
                {
                    print("Error")
                }
            }
            else
            {
                tbgD = 0.0
            }
        }
        return tbgD
    }
    
    func getHigh(context: NSManagedObjectContext) -> Double {
        
        let now = NSDate() as Date
        let calendar = Calendar.current
        let nowHour = calendar.component(.hour, from: now)
        let vContext = context
        var tbg:EndocrineSettings = NSEntityDescription.insertNewObject(forEntityName: "EndocrineSettings", into: vContext) as! EndocrineSettings
        var tbgD:Double = 0.0
        let dateDescriptor = NSSortDescriptor(key: "setDate", ascending: false)
        let tbgRequest = NSFetchRequest<EndocrineSettings>(entityName: "EndocrineSettings")
        let tbgDesc = NSSortDescriptor(key: "isTBG", ascending: false)
        tbgRequest.sortDescriptors = [tbgDesc, dateDescriptor]
        
        do {
            let results = try vContext.fetch(tbgRequest)
            tbg = results.first!
        } catch {
            print("Error \(error)")
        }
        
        if tbg.value24a > 0
        {
            tbgD = Double(tbg.value24b)
        }
        else if tbg.value3a > 0
        {
            let end1Hour = calendar.component(.hour, from: tbg.endTime1! as Date)
            let start2Hour = calendar.component(.hour, from: tbg.startTime2! as Date)
            let end2Hour = calendar.component(.hour, from: tbg.endTime2! as Date)
            let start3Hour = calendar.component(.hour, from: tbg.startTime3! as Date)
            
            if nowHour <= end1Hour
            {
                tbgD = Double(tbg.value1b)
            }
            else if nowHour >= start2Hour && nowHour <= end2Hour
            {
                tbgD = Double(tbg.value2b)
            }
            else if nowHour >= start3Hour
            {
                tbgD = Double(tbg.value3b)
            }
            else
            {
                print("Error")
            }
        }
        else
        {
            if tbg.endTime1 != nil
            {
                let end1Hour = calendar.component(.hour, from: tbg.endTime1! as Date)
                let start2Hour = calendar.component(.hour, from: tbg.startTime2! as Date)
                
                if nowHour <= end1Hour
                {
                    tbgD = Double(tbg.value1b)
                }
                else if nowHour >= start2Hour
                {
                    tbgD = Double(tbg.value2b)
                }
                else
                {
                    print("Error")
                }
            }
            else
            {
                tbgD = 0.0
            }
        }
        return tbgD
    }
    
    func getWeight() -> Double {
        
        var sWeightHK:String?
        var dateHK:Date?
        var sWeightCD:String?
        var dateCD:Date?
        var weight:Double = 0.0
        
        let past = NSDate.distantPast as Date
        let now = NSDate() as Date
        let weightReadType = HKSampleType.quantityType(forIdentifier: .bodyMass)
        let predicate = HKQuery.predicateForSamples(withStart: past, end: now, options: .strictStartDate)
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: weightReadType!, predicate: predicate, limit: 1, sortDescriptors: [sort])
        {
            query, results, error in
            
            if results?.first != nil
            {
                let bWeight = results?.first as! HKQuantitySample
                
                let kiloWeight = bWeight.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
                let lbWeight = kiloWeight * 2.205
                let intWeight = Double(round(1 * lbWeight)/1)
                
                sWeightHK = String(intWeight)
                dateHK = bWeight.startDate
            }
        }
        healthStore.execute(query)
        
        let cdWeights = coreData.getWeight()
        for cdWeight in cdWeights
        {
            sWeightCD = String(cdWeight.currentWeight)
            dateCD = cdWeight.setDate as Date?
        }
        
        if (sWeightHK != nil) && (sWeightCD != nil)
        {
            if dateHK! > dateCD!
            {
                weight = Double(sWeightHK!)!
            }
        }
        else if sWeightCD != nil
        {
            weight = Double(sWeightCD!)!
        }
        else
        {
            weight = 0.0
        }
        weight = weight * 0.45
        return weight
    }
    
    func calcIOB() -> Double {
        
        struct PreviousBoluses {
            var date:Date
            var amount:Double
        }
        
        var preBolusFlag:Bool = false
        var boluses = [PreviousBoluses]()
        var prevBolusIOBs = [Double]()
        var iob:Double = 0.0
        let now:Date = NSDate() as Date
        let sixHours = now.addingTimeInterval(60 * 60 * -6)
        let fetch = NSFetchRequest<InsulinPlan>(entityName: "InsulinPlan")
        let descriptor = NSSortDescriptor(key: "timeStamp", ascending: false)
        fetch.sortDescriptors = [descriptor]
        var previousInsulins = [InsulinPlan]()
        
        do
        {
            previousInsulins = try context.fetch(fetch)
        }
        catch
        {
            print("Error: \(error)")
        }
        
        for previousInsulin in previousInsulins
        {
            if previousInsulin.timeStamp != nil
            {
                if previousInsulin.timeStamp! as Date > sixHours
                {
                    boluses.append(PreviousBoluses(date: previousInsulin.timeStamp! as Date, amount: previousInsulin.deliveredInsulin))
                    preBolusFlag = true
                }
            }
        }
        
        if preBolusFlag == true
        {
            for bolus in boluses
            {
                let prevBolusDate = bolus.date
                let prevBolusAmt = bolus.amount
                var percentUsed:Double = 0.0
                var tempIOB:Double = 0.0
                
                var timeDiff = now.timeIntervalSince(prevBolusDate)
                timeDiff = timeDiff / 3600
                let sqTD = timeDiff * timeDiff
                
                if timeDiff <= 0.33
                {
                    percentUsed = (90.1 * sqTD)
                }
                else if timeDiff > 0.33 && timeDiff <= 0.49
                {
                    percentUsed = (38.5 * timeDiff) + (33.5 * sqTD) + 9.9 - 16.2
                }
                else if timeDiff > 0.49 && timeDiff <= 0.65
                {
                    percentUsed = (60.5 * timeDiff) + (10.75 * sqTD) + 9.9 + 10.42 - 40.18
                }
                else if timeDiff > 0.65 && timeDiff <= 2.5
                {
                    percentUsed = (88.5 * timeDiff) - (10.75 * sqTD) + 9.9 + 10.42 + 13.04 - 52.98
                }
                else if timeDiff > 2.5 && timeDiff <= 4.0
                {
                    percentUsed = (65 * timeDiff) - (6 * sqTD) + 9.9 + 10.42 + 13.04 + 123.88 - 125
                }
                else if timeDiff > 4.0 && timeDiff <= 6.0
                {
                    percentUsed = (50.5 * timeDiff) - (4.21 * sqTD) + 9.9 + 10.42 + 13.04 + 123.88 + 38.65 - 134.64
                }
                
                percentUsed = percentUsed / 212.52
                tempIOB = prevBolusAmt - (prevBolusAmt * percentUsed)
                prevBolusIOBs.append(tempIOB)
            }
            
            for prevBolusIOB in prevBolusIOBs
            {
                iob = iob + prevBolusIOB
            }
            iob = -iob
        }
        return iob
    }
}
