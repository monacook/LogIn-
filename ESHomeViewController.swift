//
//  ESHomeViewController.swift
//  Test
//
//  Created by Danielle on 3/2/17.
//  Copyright © 2017 Danielle. All rights reserved.
//

import UIKit
import HealthKit

var healthStore = HKHealthStore()
let coreData = CoreDataManager()

class ESHomeViewController: UIViewController {
    
    
    override func viewDidLoad() {
        
        healthKitMessage.isHidden = true
       
        super.viewDidLoad()
        if (!HKHealthStore.isHealthDataAvailable())
        {
            healthKitMessage.text = "HealthKit is not available on this device"
            healthKitMessage.isHidden = false
        }
        
        var shareTypes = Set<HKSampleType>()
        var readTypes = Set<HKSampleType>()
        
        shareTypes.insert(HKSampleType.quantityType(forIdentifier: .bloodGlucose)!)
        shareTypes.insert(HKSampleType.quantityType(forIdentifier: .bodyMass)!)
        shareTypes.insert(HKSampleType.quantityType(forIdentifier: .dietaryCarbohydrates)!)
        
        readTypes.insert(HKSampleType.quantityType(forIdentifier: .bloodGlucose)!)
        readTypes.insert(HKSampleType.quantityType(forIdentifier: .bodyMass)!)
        readTypes.insert(HKSampleType.quantityType(forIdentifier: .dietaryCarbohydrates)!)

        healthStore.requestAuthorization(toShare: shareTypes, read: readTypes)
        {
            (success, error)-> Void in
            
            if success {}
            else {
                print("HK Failure")
            }
        }
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        MealBuilder.sharedInstance.clearBuilder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var healthKitMessage: UILabel!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toReviewES"
        {
            let controller = segue.destination as? ReviewESViewController
            controller?.previousVC = "ESHome"
        }
    }
}
