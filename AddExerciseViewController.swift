//
//  AddExerciseViewController.swift
//  Test
//
//  Created by Danielle on 4/25/17.
//  Copyright © 2017 Danielle. All rights reserved.
//

import UIKit
import HealthKit


class AddExerciseViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var currentBG: UITextField!
    @IBOutlet weak var light: UIButton!
    @IBOutlet weak var moderate: UIButton!
    @IBOutlet weak var vigorous: UIButton!
    @IBOutlet weak var exerStartTime: UIDatePicker!
    @IBOutlet weak var exerDuration: UITextField!
    @IBOutlet weak var glucoseLabel: UILabel!
    
    var exerciseIntensity:String = ""
    var currentGlucose: Double = 0.0
    
    @IBAction func textEditingChanged(_textField: UITextField){}
    @IBAction func minutesEditingChanged(_textField: UITextField){}
    
    @IBAction func exerInfoButton(_ sender: Any) {
        
        let alertExerInfo = UIAlertController(title: "Exercise Intensity",
                                            message: "To determine the intensity of your exercise use the talk test. \n\nLIGHT: Your breath is mostly normal, you can still talk and sing.\n\nMODERATE: Your breathing is faster, you can still talk, but can't sing.\n\nVIGOROUS: Your breathing is deep and rapid, you can't talk very well.\n\nFor more information click \n'Mayo Clinic Link' below.",
                                            preferredStyle: .alert)
        let websiteInfo = UIAlertAction(title: "Mayo Clinic Link", style: .default, handler: {alert -> Void in
            
            let targetURL = "http:www.mayoclinic.org/healthy-lifestyle/fitness/in-depth/exercise-intensity/art-20046887"
            
            if let url = NSURL(string: targetURL)
            {
                UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
            }
        })
        
        let stayInfo = UIAlertAction(title: "OK", style: .default, handler: {alert -> Void in})
        
        alertExerInfo.addAction(websiteInfo)
        alertExerInfo.addAction(stayInfo)
        present(alertExerInfo, animated: true, completion: nil)
    }
    
    @IBAction func glucoseTouchDown(_ sender: Any) {
        
        glucoseLabel.isHidden = false
    }
    
    @IBAction func glucoseTouchUp(_ sender: Any) {
        
        glucoseLabel.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        checkES()
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        glucoseLabel.isHidden = true
        
        if let bg = Double(PersistUserEntry.sharedInstance.bg)
        {
            if bg > 0.0
            {
                currentBG.text = PersistUserEntry.sharedInstance.bg
            }
            else
            {
                currentBG.text = "0.0"
            }
        }
        
        if let minutes = Double(PersistUserEntry.sharedInstance.exerMin)
        {
            if minutes > 0.0
            {
                exerDuration.text = PersistUserEntry.sharedInstance.exerMin
            }
            else
            {
                exerDuration.text = "0.0"
            }
        }
        
        exerciseIntensity = PersistUserEntry.sharedInstance.exerInt
        
        if exerciseIntensity == "Light"
        {
            light.backgroundColor = UIColor.init(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)
            vigorous.backgroundColor = UIColor.init(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
            moderate.backgroundColor = UIColor.init(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        }
        else if exerciseIntensity == "Moderate"
        {
            moderate.backgroundColor = UIColor.init(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)
            vigorous.backgroundColor = UIColor.init(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
            light.backgroundColor = UIColor.init(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        }
        else if exerciseIntensity ==  "Vigorous"
        {
            vigorous.backgroundColor = UIColor.init(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)
            moderate.backgroundColor = UIColor.init(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
            light.backgroundColor = UIColor.init(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        }
        
        hideKeyboard()
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
      
        exerStartTime.backgroundColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 1)
        
        var shareTypes = Set<HKSampleType>()
        var readTypes = Set<HKSampleType>()
        shareTypes.insert(HKSampleType.quantityType(forIdentifier: .bloodGlucose)!)
        readTypes.insert(HKSampleType.quantityType(forIdentifier: .bloodGlucose)!)
        
        healthStore.requestAuthorization(toShare: shareTypes, read: readTypes)
        {
            (success, error)-> Void in
            
            if success {}
            else {
                print("HK Failure")
            }
        }
        showRecentBG()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func actionVigorous(_ sender: Any) {
        
        exerciseIntensity = "Vigorous"
        
        vigorous.backgroundColor = UIColor.init(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)
        moderate.backgroundColor = UIColor.init(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        light.backgroundColor = UIColor.init(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
    }
    
    @IBAction func actionModerate(_ sender: Any) {
        
       exerciseIntensity = "Moderate"
        
        moderate.backgroundColor = UIColor.init(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)
        vigorous.backgroundColor = UIColor.init(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        light.backgroundColor = UIColor.init(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
    }
  
    
    @IBAction func actionLight(_ sender: Any) {
        
        exerciseIntensity = "Light"
        
        light.backgroundColor = UIColor.init(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)
        vigorous.backgroundColor = UIColor.init(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        moderate.backgroundColor = UIColor.init(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
    }
    
    
    func showRecentBG()
    {
        var bgValue:String = "0.0"
        let past = NSDate.distantPast as Date
        let now = NSDate() as Date
        let thrityMinutes = now.addingTimeInterval(-30.0 * 60.0)
        let bgReadingType = HKSampleType.quantityType(forIdentifier: .bloodGlucose)
        let predicate = HKQuery.predicateForSamples(withStart: past, end: now, options: .strictStartDate)
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: bgReadingType!, predicate: predicate, limit: 1, sortDescriptors: [sort])
        {
            query, results, error in
            
            let bgReading = results?.first as? HKQuantitySample
            if let bgTime = bgReading?.startDate
            {
                if bgTime > thrityMinutes
                {
                    if let bgText = bgReading?.quantity
                    {
                        let bgSample = String(describing: bgText)
                        let endIndex = bgSample.index(bgSample.endIndex, offsetBy: -6)
                        bgValue = bgSample.substring(to: endIndex)
                        self.currentGlucose = Double(bgValue)!
                        
                        if self.currentGlucose > 0.0
                        {
                            self.currentBG.text = String(self.currentGlucose)
                        }
                        else
                        {
                            self.currentBG.text = "0.0"
                        }
                    }
                }
            }
        }
        healthStore.execute(query)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ExerciseToReviewES"
        {
            let controller = segue.destination as? ReviewESViewController
            controller?.previousVC = "AddExercise"
            
            PersistUserEntry.sharedInstance.persistExercise(curBG: currentBG.text!, minutes: exerDuration.text!, intensity: exerciseIntensity)
        }
        else if segue.identifier == "saveExerciseToRecommendation"
        {
            var bg:Double = 0.0
            
            if Double(currentBG.text!) != nil
            {
                bg = Double(currentBG.text!)!
            }

            let alertContBG = UIAlertController(title: "Blood Glucose Missing",
                                                 message: "Please enter a BG reading.",
                                                 preferredStyle: .alert)
            let stayActionBG = UIAlertAction(title: "UPDATE BG", style: .default, handler: {alert -> Void in})
            let segueActionBG = UIAlertAction(title: "BG OK", style: .default, handler: {alert -> Void in
                
                self.checkDuration()
                self.checkIntensity()
                let controller = segue.destination as? InsulinBreakdownViewController
                
                controller?.previousVC = "AddExercise"
                controller?.exerInt = self.exerciseIntensity
                controller?.exerDur = Double(self.exerDuration.text!)!
                controller?.glucoseReading = self.currentBG.text!
                
                let glucose:Double = Double(self.currentBG.text!)!
                let now:Date = NSDate() as Date
                
                let glucoseType = HKSampleType.quantityType(forIdentifier: .bloodGlucose)
                let glucoseQty = HKQuantity(unit: HKUnit.init(from: "mg/dl"), doubleValue: glucose)
                
                let glucoseSample = HKQuantitySample(type: glucoseType!, quantity: glucoseQty, start: now, end: now)
                
                healthStore.save(glucoseSample, withCompletion: { (success, error) -> Void in
                    if (error != nil) {
                        print("Error: \(String(describing: error))")
                    } else {}
                })
                
                PersistUserEntry.sharedInstance.clearUserEntry()

            })
            
            if bg <= 0.0
            {
                alertContBG.addAction(stayActionBG)
                alertContBG.addAction(segueActionBG)
                present(alertContBG, animated: true, completion: nil)
            }
            
            checkDuration()
            checkIntensity()
            
            let controller = segue.destination as? InsulinBreakdownViewController
            
            controller?.previousVC = "AddExercise"
            controller?.exerInt = exerciseIntensity
            controller?.exerDur = Double(exerDuration.text!)!
            controller?.glucoseReading = currentBG.text!
            
            let glucose:Double = Double(currentBG.text!)!
            let now:Date = NSDate() as Date
            
            let glucoseType = HKSampleType.quantityType(forIdentifier: .bloodGlucose)
            let glucoseQty = HKQuantity(unit: HKUnit.init(from: "mg/dl"), doubleValue: glucose)
            
            let glucoseSample = HKQuantitySample(type: glucoseType!, quantity: glucoseQty, start: now, end: now)
            
            healthStore.save(glucoseSample, withCompletion: { (success, error) -> Void in
                if (error != nil) {
                    print("Error: \(String(describing: error))")
                } else {}
            })
            
            PersistUserEntry.sharedInstance.clearUserEntry()
        }
    }
    
    func checkES() {
        
        let calculation = CalculateInsulinCarbs()
        
        let corrFact = calculation.getCF(context: context)
        let insCarbRat = calculation.getICR(context: context)
        let weight = calculation.getWeight()
        let tbgLow = calculation.getLow(context: context)
        let tbgHigh = calculation.getHigh(context: context)
        
        let alertES = UIAlertController(title: "Endocrine Settings Missing",
                                        message: "One or more of your endocrine settings are missing or are set to zero.\n\niDECIDE can't make accurate recommendations when endocrine settings are missing.",
                                        preferredStyle: .alert)
        let stayActionES = UIAlertAction(title: "OK", style: .default, handler: {alert -> Void in})
        
        if corrFact <= 0.0 || insCarbRat <= 0.0 || weight <= 0.0 || tbgLow <= 0.0 || tbgHigh <= 0.0
        {
            alertES.addAction(stayActionES)
            self.present(alertES, animated: true, completion: nil)
        }
    }
    
    func checkDuration() {
        
        let alertContDur = UIAlertController(title: "Duration Missing",
                                             message: "Please enter exercise duration.",
                                             preferredStyle: .alert)
        let segueActionDur = UIAlertAction(title: "OK", style: .default, handler: {alert -> Void in})
        
        var duration:Double = 0.0
        
        if Double(exerDuration.text!) != nil
        {
            duration = Double(exerDuration.text!)!
        }
        
        if duration <= 0.0
        {
            alertContDur.addAction(segueActionDur)
            present(alertContDur, animated: true, completion: nil)
        }
    }
    
    func checkIntensity(){
        
        let alertContInt = UIAlertController(title: "Intesnity Missing",
                                             message: "Please select exercise intensity.",
                                             preferredStyle: .alert)
        let segueActionInt = UIAlertAction(title: "OK", style: .default, handler: {alert -> Void in})
        
        if exerciseIntensity == ""
        {
            alertContInt.addAction(segueActionInt)
            present(alertContInt, animated: true, completion: nil)
        }
    }


    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    
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
        }
        else
        {
            return true
        }
    }
}
