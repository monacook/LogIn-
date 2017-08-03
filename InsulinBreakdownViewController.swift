//
//  InsulinBreakdownViewController.swift
//  Test
//
//  Created by Danielle on 3/29/17.
//  Copyright © 2017 Danielle. All rights reserved.
//

import UIKit
import CoreData
import HealthKit
import CloudKit

class InsulinBreakdownViewController: UIViewController, UITextFieldDelegate { // 1
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let publicDatabase = CKContainer.default().publicCloudDatabase
    
    @IBOutlet weak var insulinUnits: UILabel!
    @IBOutlet weak var carbsGrams: UILabel!
    @IBOutlet weak var overrideInsulin: UITextField!
    @IBOutlet weak var overrideCarbs: UITextField!
    @IBOutlet weak var coverCarbs: UILabel!
    @IBOutlet weak var glycemicExcursion: UILabel!
    @IBOutlet weak var activeInsulin: UILabel!
    @IBOutlet weak var exercise: UILabel!
    @IBOutlet weak var overrideSwitch: UISwitch!
    @IBOutlet weak var overrideLabel: UILabel!
    @IBOutlet weak var mealPhoto: UIImageView!
    @IBOutlet weak var carbsInfo: UIButton!
    
    @IBAction func insulinEditingChanged(_textField: UITextField){}
    @IBAction func carbsEditingChanged(_textField: UITextField){}
    
    @IBAction func carbInfoButton(_ sender: Any) { // clear
        
        var alertCarbs = UIAlertController(title: "Carbohydrate Snacks",
                                           message: "Consume a snack when you exercise.",
                                           preferredStyle: .alert)
        
        if let carbs = Double(carbsGrams.text!)
        { // hello
            print("**carbs: \(carbs)")
            
            if carbs <= 5
            {
                alertCarbs = UIAlertController(title: "Carbohydrate Snacks",
                                               message: "Examples of 5g snacks:\n1/2 small apple\n1/4 medium banana\n",
                                               preferredStyle: .alert)
            }
            else if carbs > 5 && carbs <= 10
            {
                alertCarbs = UIAlertController(title: "Carbohydrate Snacks",
                                               message: "Examples of 5-10 g snacks:\n1/4 large apple\n1/2 small banana\n",
                                               preferredStyle: .alert)
            }
            else if carbs > 10 && carbs <= 15
            {
                alertCarbs = UIAlertController(title: "Carbohydrate Snacks",
                                               message: "Examples of 10-15 g snacks:\n1/2 large apple\n1/2 large banana\n",
                                               preferredStyle: .alert)
            }
            else if carbs > 15 && carbs <= 20
            {
                alertCarbs = UIAlertController(title: "Carbohydrate Snacks",
                                               message: "Examples of 15-20 g snacks:\n1 small apple\n1 small banana\n",
                                               preferredStyle: .alert)
            }
            else if carbs > 20 && carbs <= 25
            {
                alertCarbs = UIAlertController(title: "Carbohydrate Snacks",
                                               message: "Examples of 20-25 g snacks:\n1 medium apple\n1 medium banana\n",
                                               preferredStyle: .alert)
            }
            else if carbs > 25 && carbs <= 30
            {
                alertCarbs = UIAlertController(title: "Carbohydrate Snacks",
                                               message: "Examples of 25-30 g snacks:\n1 large apple\n1 large banana\n",
                                               preferredStyle: .alert)
            }
        } // hello
        
        let stayInfo = UIAlertAction(title: "OK", style: .default, handler: {alert -> Void in})
        alertCarbs.addAction(stayInfo)
        present(alertCarbs, animated: true, completion: nil)
    } // clear
    
    var mealImage: UIImage = #imageLiteral(resourceName: "No_Image")
    var carbsInMeal: Double = 0.0
    var glucoseReading: String = "0.0"
    var recommendation:BreakdownInsulin?
    var previousVC:String = ""
    var exerInt = ""
    var exerDur = 0.0
    
    @IBAction func overrideRecommendations(_ sender: Any) { // clear
        
        if(overrideSwitch.isOn)
        {
            insulinUnits.isHidden = false
            carbsGrams.isHidden = false
            overrideInsulin.isHidden = true
            overrideCarbs.isHidden = true
            overrideInsulin.text! = insulinUnits.text!
            overrideCarbs.text! = carbsGrams.text!
            overrideLabel.text = "Retain"
        }
        else
        {
            insulinUnits.isHidden = true
            carbsGrams.isHidden = true
            overrideInsulin.isHidden = false
            overrideCarbs.isHidden = false
            overrideInsulin.text = insulinUnits.text
            overrideCarbs.text = carbsGrams.text
            overrideLabel.text = "Override"
        }
    } //clear
    
    override func viewDidLoad() { //clear
        
        super.viewDidLoad()
        
        hideKeyboard()
        
        overrideInsulin.isHidden = true
        overrideCarbs.isHidden = true
        overrideSwitch.layer.cornerRadius = 16
        mealPhoto.image = mealImage
        carbsInfo.isHidden = true
        
        if previousVC == "AddExercise"
        {
            if exerInt == "Light"
            {
                mealPhoto.image = #imageLiteral(resourceName: "Exercise_Light")
            }
            else if exerInt == "Moderate"
            {
                mealPhoto.image = #imageLiteral(resourceName: "Exercise_Moderate")
            }
            else if exerInt == "Vigorous"
            {
                mealPhoto.image = #imageLiteral(resourceName: "Exercise_Vigorous")
            }
        }
        
        let calculation = CalculateInsulinCarbs()
        let carbs = carbsInMeal
        let glucose = Double(glucoseReading)
        
        recommendation = calculation.idecideRecommendation(carbohydrates: carbs, currentGlucose: glucose!, exerciseIntensity: exerInt, exerciseDuration: exerDur, context: context)
        
        insulinUnits.text = String(format: "%.1f", calculation.recommendation.insulin)
        
        let recCarbs = calculation.recommendation.carbs
        
        if recCarbs > 0
        {
            let carbRec = String(format: "%.1f", recCarbs)
            carbsGrams.text = carbRec
            exercise.text = carbRec + " g"
            
            carbsInfo.isHidden = false
        }
        else
        {
            carbsGrams.text = String(carbs)
            let insReduce = String(format: "%.1f", calculation.recommendation.exercise)
            exercise.text = insReduce + " U"
        }
        
        coverCarbs.text = String(format: "%.1f", calculation.recommendation.coverCarbs) + " U"
        glycemicExcursion.text = String(format: "%.1f", calculation.recommendation.coverGlucose) + " U"
        activeInsulin.text = String(format: "%.1f", calculation.recommendation.activeInsulin) + " U"
    } // clear
    
    override func didReceiveMemoryWarning() { //clear
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func returnToPreviousVC(_ sender: Any) { // clear
        
        if previousVC == "AddExercise"
        {
            self.performSegue(withIdentifier: "cancelInsulinToAddEx", sender: nil)
        }
        else if previousVC == "ReviewMeal"
        {
            self.performSegue(withIdentifier: "cancelInsulinToRevMeal", sender: nil)
            recommendation = nil
        }
    } // clear
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //  1
        
        if segue.identifier == "saveToCDshowLog"
        { // 2
            let mealComponents = MealBuilder.sharedInstance.allMealItems
            let endoSettings = CurrentES.sharedInstance.allCurrentES
            
            let imageData = NSData(data: UIImageJPEGRepresentation(mealImage, 0.5)!)
            
            var recommendation = NSEntityDescription.insertNewObject(forEntityName: "InsulinPlan", into: context) as! InsulinPlan
            var alcoholPlan = NSEntityDescription.insertNewObject(forEntityName: "AlcoholPlan", into: context) as! AlcoholPlan
            
            let sIOB:String = String(activeInsulin.text!.characters.dropLast(2))
            let sInsulinRec:String = String(insulinUnits.text!)
            let sCarbsRec:String = String(carbsGrams.text!)
            let tLow = endoSettings[0]
            let tHigh = endoSettings[1]
            let corrFactor = endoSettings[2]
            let carbRatio = endoSettings[3]
            let currGluc = endoSettings[4]
            let now = NSDate() as Date
            let iob = Double(sIOB)
            let insulinRec = Double(sInsulinRec)
            let carbsRec = Double(sCarbsRec)
            let totalCarbs:Double = carbsInMeal
            var sInsulinDel:String = "0.0"
            var insulinDel:Double = 0.0
            var sCarbsCons:String = "0"
            var carbsCons:Double = 0.0
            var mealContents:MealItems?
            var exerPlan:ExercisePlan?
            
            mealContents = coreData.saveOneMealItemtoRecommendation(description: "", carbs: 0.0, amount: 0.0, measure: "")
            exerPlan = coreData.saveExercise(durationMin: 0.0, intensity3: "", hasRecommendation: recommendation)
            
            sInsulinDel = insulinUnits.text!
            insulinDel = Double(sInsulinDel)!
            sCarbsCons = carbsGrams.text!
            carbsCons = Double(sCarbsCons)!
            
            if !(overrideSwitch.isOn)
            { // 3
                let stringInsulinOver:String = overrideInsulin.text!
                let stringCarbsOver:String = overrideCarbs.text!
                
                sInsulinDel = stringInsulinOver
                insulinDel = Double(sInsulinDel)!
                sCarbsCons = stringCarbsOver
                carbsCons = Double(sCarbsCons)!
            } //3
            
            for mealComponent in mealComponents
            { // 6
                let name = mealComponent[0]
                let carb = mealComponent[1]
                let dCarb = Double(carb) ?? 0.0
                let qty = mealComponent[2]
                let dQty = Double(qty) ?? 0.0
                let measure = mealComponent[3]
                let alcohol = mealComponent[4]
                let alcGrams = Double(mealComponent[5]) ?? 0.0
                
                let mealStore = CKRecord(recordType: "InsulinPlan")
                
                if alcohol == "true"
                { //4
                    alcoholPlan = coreData.saveAlcohol(typeDrink: name, carbs: dCarb, alcContent: alcGrams)
                    mealContents = coreData.saveOneMealItemtoRecommendation(description: name, carbs: dCarb, amount: dQty, measure: measure)
                    
                    mealStore.setObject(name as CKRecordValue?, forKey: "drinkType")
                    mealStore.setObject(carb as CKRecordValue?, forKey: "drinkCarbs")
                    mealStore.setObject(qty as CKRecordValue?, forKey: "foodAmount")
                    mealStore.setObject(measure as CKRecordValue?, forKey: "foodMeasure")
                    
                } //4
                else
                { //5
                    coreData.saveMealItems(description: name, carbs: dCarb, amount: dQty, measure: measure, hasAlcohol: alcoholPlan, hasInsulin: recommendation)
                    mealContents = coreData.saveOneMealItemtoRecommendation(description: name, carbs: dCarb, amount: dQty, measure: measure)
                    
                    mealStore.setObject(name as CKRecordValue?, forKey: "foodName")
                    mealStore.setObject(carb as CKRecordValue?, forKey: "foodCarbs")
                    mealStore.setObject(qty as CKRecordValue?, forKey: "foodAmount")
                    mealStore.setObject(measure as CKRecordValue?, forKey: "foodMeasure")
                } //5
                
                publicDatabase.save(mealStore){ (success, error) -> Void in
                    if(success != nil)
                    {
                        print("Saved meal item to CK")
                    } else {
                        print("CK Save Error")
                    }
                }
            } //6
            
            
            if exerDur > 0.0
            { //8
                exerPlan = coreData.saveExercise(durationMin: exerDur, intensity3: exerInt, hasRecommendation: recommendation)
            } //8
            
            recommendation = coreData.saveRecommendation(cf: corrFactor, icr: carbRatio, tLow: tLow, tHigh: tHigh, glucose: currGluc, iob: iob!, totalCarbs: totalCarbs, date: now, insulinRec: insulinRec!, carbsRec: carbsRec!, insulinDel: insulinDel, carbsDel: carbsCons, foodPic: imageData, mealItems: mealContents!, exercise: exerPlan!)
            
            let cDate:Date = NSDate() as Date
            
            let carbReadType = HKSampleType.quantityType(forIdentifier: .dietaryCarbohydrates)
            let carbMetricType = HKQuantity(unit: HKUnit.gram(), doubleValue: carbsCons)
            let carbSample = HKQuantitySample(type: carbReadType!, quantity: carbMetricType, start: cDate, end: cDate)
            
            healthStore.save(carbSample, withCompletion: { (success, error) -> Void in
                if (error != nil){ //9
                    print("HK Save Error: \(String(describing: error))")
                } else {}
            }) // 9
            
            let bodyWeight = CalculateInsulinCarbs()
            let weight = bodyWeight.getWeight()
            
            let insulinStore = CKRecord(recordType: "InsulinPlan")
            
            insulinStore.setObject("003" as CKRecordValue?, forKey: "participantID")
            insulinStore.setObject(insulinRec as CKRecordValue?, forKey: "recommendedInsulin")
            insulinStore.setObject(carbsRec as CKRecordValue?, forKey: "recommendedCarbs")
            insulinStore.setObject(insulinDel as CKRecordValue?, forKey: "deliveredInsulin")
            insulinStore.setObject(carbsCons as CKRecordValue?, forKey: "carbsConsumed")
            insulinStore.setObject(tLow as CKRecordValue?, forKey: "targetBG_Low")
            insulinStore.setObject(tHigh as CKRecordValue?, forKey: "targetBG_High")
            insulinStore.setObject(corrFactor as CKRecordValue?, forKey: "correctionFactor")
            insulinStore.setObject(carbRatio as CKRecordValue?, forKey: "insulinCarbRatio")
            insulinStore.setObject(currGluc as CKRecordValue?, forKey: "currentBG")
            insulinStore.setObject(now as CKRecordValue?, forKey: "timestamp")
            insulinStore.setObject(iob as CKRecordValue?, forKey: "insulinOnBoard")
            insulinStore.setObject(totalCarbs as CKRecordValue?, forKey: "totalMealCarbs")
            insulinStore.setObject(exerInt as CKRecordValue?, forKey: "intensity")
            insulinStore.setObject(exerDur as CKRecordValue?, forKey: "duration")
            insulinStore.setObject(weight as CKRecordValue?, forKey: "bodyWeight")
            //here
            
            // Image to store in cloud
            let photoImageData = UIImageJPEGRepresentation(mealPhoto.image!, 1)
            
            // Unique file name string
            let tempPhotoImageFileName = ProcessInfo.processInfo.globallyUniqueString + ".jpg"
            
            // Retrieve temporary directory path. Cast to NSURL, then append `tempPhotoImageFileName`.
            let photoImageURL = NSURL.fileURL(withPath: NSTemporaryDirectory()).appendingPathComponent(tempPhotoImageFileName)
            
            do {
                // Map `photoImageData` to `photoImageURL`
                try photoImageData?.write(to: photoImageURL, options: .atomicWrite)
            } catch {
                print("Error writing image data", error)
            }
            
            // Cast image to CKAsset
            let photoImageAsset = CKAsset(fileURL: photoImageURL)
            
            // Store image in cloud
            insulinStore.setObject(photoImageAsset, forKey: "foodPhoto")
        
            publicDatabase.save(insulinStore) { success, error -> Void in
                if error != nil {
                    print("CK Save Error")
                } else {
                    print("Saved insulin plan to CK")
                }
            }
            
            MealBuilder.sharedInstance.clearBuilder()
            CurrentES.sharedInstance.clearES()
        }
    }

        
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool { // clear
        
        let existingTextHasDecimalSeparator = textField.text?.range(of: ".")
        let replacementTextHasDecimalSeparator = string.range(of: ".")
        
        let letters = NSCharacterSet.letters
        var punctuation = NSCharacterSet.punctuationCharacters
        punctuation.insert(charactersIn: "`~$^=+|<>")
        punctuation.remove(charactersIn: ".")
        
        if (existingTextHasDecimalSeparator != nil) &&
            (replacementTextHasDecimalSeparator != nil) ||
            (string.rangeOfCharacter(from: punctuation) != nil) ||
            (string.rangeOfCharacter(from: letters) != nil)
        {
            return false
        }else{
            return true
        }
    }
 }
