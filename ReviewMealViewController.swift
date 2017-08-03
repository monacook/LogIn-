//
//  ReviewMealViewController.swift
//  Test
//
//  Created by Danielle on 2/3/17.
//  Copyright © 2017 Danielle. All rights reserved.
//

import UIKit
import CoreData
import CoreImage
import HealthKit

class ReviewMealViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var currentBG: UITextField!
    @IBOutlet weak var totalCarbs: UITextField!
    @IBOutlet weak var mealItems: UITableView!
    @IBOutlet weak var foodPhoto: UIImageView!
    @IBOutlet weak var takePhoto: UIButton!
    @IBOutlet weak var glucoseLabel: UILabel!
    @IBOutlet weak var carbsLabel: UILabel!
    
    @IBAction func bgEditingChanged(_textField: UITextField){}
    
    @IBAction func carbsEditingChanged(_textField: UITextField){}
    
    var foodImage: UIImage?
    var totalMealCarbs: Double = 0.0
    var currentGlucose: Double = 0.0
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        checkES()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.hideKeyboard()
        mealItems.delegate = self
        mealItems.dataSource = self
        
        glucoseLabel.isHidden = true
        carbsLabel.isHidden = true
        
        if let originalImage = foodPhoto.image
        {
            let ciimage = CIImage(image: originalImage)
            let context = CIContext()
            let rect = CGRect(x: 0, y: 0, width: 200, height: 200)
            let resultImage = context.createCGImage(ciimage!, from: rect)
            foodPhoto.image = UIImage(cgImage: resultImage!, scale: 1.0, orientation: originalImage.imageOrientation)
        }
        
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
        
        if let picture = PersistUserEntry.sharedInstance.photo
        {
            foodPhoto.image = picture
            takePhoto.isHidden = true
        }
        
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
        totalCarbs.text = getTotalCarbs()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func glucoseTouchDown(_ sender: Any) {
        
        glucoseLabel.isHidden = false
    }
    
    @IBAction func glucoseTouchUp(_ sender: Any) {
       
        glucoseLabel.isHidden = true
    }
    
    @IBAction func carbsTouchDown(_ sender: Any) {
        
        carbsLabel.isHidden = false
    }
    
    @IBAction func carbsTouchUp(_ sender: Any) {
    
        carbsLabel.isHidden = true
    }
    
    @IBAction func showCamera(_ sender: Any) {
        
        let photoPicker = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(.camera)
        {
            photoPicker.sourceType = .camera
            takePhoto.isHidden = true
            foodPhoto.backgroundColor = UIColor.init(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        }
        else
        {
           // noImage.text = "Can't get camera"
            photoPicker.sourceType = .photoLibrary
        }
        photoPicker.delegate = self
        present(photoPicker, animated: true, completion: nil)
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
    
    
    func getTotalCarbs() -> String
    {
        let carbItems = MealBuilder.sharedInstance.allMealItems
        var totalCarbs:Double = 0.0
        
        for x in 0 ..< carbItems.count
        {
            let carbs = Double(carbItems[x][1])
            totalCarbs = totalCarbs + carbs!
        }
        totalMealCarbs = totalCarbs
        return String(totalCarbs)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerOriginalImage]
        foodPhoto.image = image as! UIImage?
        dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return MealBuilder.sharedInstance.allMealItems.count
    }
 
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MealItem", for: indexPath)
        let meal = MealBuilder.sharedInstance.allMealItems[indexPath.row]
        
        cell.textLabel?.text = meal[0]
        cell.detailTextLabel?.text = meal[1] + " carbs"
        
        return cell
    }
    
  
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        if segue.identifier == "cancelReviewToAdd"
        {
            MealBuilder.sharedInstance.clearBuilder()
        }
        else if segue.identifier == "saveReviewToRecommend"
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
                
                let controller = segue.destination as? InsulinBreakdownViewController
                
                controller?.previousVC = "ReviewMeal"
                
                if self.foodPhoto.image != nil
                {
                    self.foodImage = self.foodPhoto.image!
                }
                else
                {
                    self.foodImage = #imageLiteral(resourceName: "No_Image")
                }
                
                controller?.mealImage = self.foodImage!
                controller?.carbsInMeal = self.totalMealCarbs
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
            
            let controller = segue.destination as? InsulinBreakdownViewController
            
            controller?.previousVC = "ReviewMeal"
            
            if self.foodPhoto.image != nil
            {
                self.foodImage = self.foodPhoto.image!
            }
            else
            {
                self.foodImage = #imageLiteral(resourceName: "No_Image")
            }
            
            controller?.mealImage = self.foodImage!
            controller?.carbsInMeal = self.totalMealCarbs
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
        }
        else if segue.identifier == "reviewMealToReviewES"
        {
            let controller = segue.destination as? ReviewESViewController
            controller?.previousVC = "ReviewMeal"
            
            if foodPhoto.image == nil
            {
                PersistUserEntry.sharedInstance.persistMealsNoPhoto(curBG: currentBG.text!)
            }
            else
            {
              PersistUserEntry.sharedInstance.persistMeals(curBG: currentBG.text!, pict: foodPhoto.image!)
            }   
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
