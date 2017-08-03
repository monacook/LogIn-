//
//  WeightViewController.swift
//  Test
//
//  Created by Danielle on 2/8/17.
//  Copyright © 2017 Danielle. All rights reserved.
//

import UIKit
import HealthKit
import CoreData

class WeightViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        showRecentWeight()
        
        weightPicker.dataSource = self
        weightPicker.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var weightPicker: UIPickerView!
    @IBOutlet weak var bodyWeight: UITextField!
    
    @IBAction func weightEditingChanged(_textField: UITextField){}
    
    var weightMetric = ["lbs", "kg"]
    var selectedMetric:String = ""
    
    var bWeight = [NSManagedObject]()
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return weightMetric.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return weightMetric[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let string = UILabel()
        string.text = weightMetric[row]
        string.font = UIFont(name: "AvenirNext-Medium", size: 17.0)
        string.textAlignment = NSTextAlignment.center
        return string
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        selectedMetric = weightMetric[row]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //Weight Missing
        let alertContWeight = UIAlertController(title: "Weight Missing",
                                              message: "Please enter your body weight.",
                                              preferredStyle: .alert)
        let segueActionWeight = UIAlertAction(title: "OK", style: .default, handler: {alert -> Void in})
        
        var bdWeight = 0.0
        
        if Double(bodyWeight.text!) != nil
        {
            bdWeight = Double(bodyWeight.text!)!
        }
        
        if bdWeight <= 0.0
        {
            alertContWeight.addAction(segueActionWeight)
            present(alertContWeight, animated: true, completion: nil)
        }
        else
        {
            if segue.identifier == "SaveToESHome"
            {
                var weight:Double = bdWeight
                let date = NSDate() as Date
                
                if selectedMetric == "kg"
                {
                    weight = weight * 2.205
                }
                coreData.saveWeight(weightValue: weight, date: date)
                saveToHK(weight: weight, date: date as NSDate)
            }
        }
    }

    
    func saveToHK(weight: Double, date: NSDate)
    {
        let bWeight = weight
        let cDate:Date = date as Date
        
        let weightReadType = HKSampleType.quantityType(forIdentifier: .bodyMass)
        let weightMetricType = HKQuantity(unit: HKUnit.pound(), doubleValue: bWeight)
        let weightSample = HKQuantitySample(type: weightReadType!, quantity: weightMetricType, start: cDate, end: cDate)
        
        healthStore.save(weightSample, withCompletion: { (success, error) -> Void in
            if (error != nil){
                print("HK Save Error: \(String(describing: error))")
            } else {}
        })
    }
    
    
    func showRecentWeight()
    {
        var sWeightHK:String?
        var dateHK:Date?
        var sWeightCD:String?
        var dateCD:Date?
        
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            
            if (sWeightHK != nil) && (sWeightCD != nil)
            {
                if dateHK! > dateCD!
                {
                    self.bodyWeight.text = sWeightHK
                }
                else
                {
                    self.bodyWeight.text = sWeightCD
                }
            }
            else if (sWeightCD != nil)
            {
                self.bodyWeight.text = sWeightCD
            }
            else
            {
                self.bodyWeight.text = ""
            }
        })
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
