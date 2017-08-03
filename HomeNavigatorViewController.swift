//
//  HomeNavigatorViewController.swift
//  Test
//
//  Created by Danielle on 4/27/17.
//  Copyright © 2017 Danielle. All rights reserved.
//

import UIKit
import HealthKit

class HomeNavigatorViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()

        var shareTypes = Set<HKSampleType>()
        var readTypes = Set<HKSampleType>()
        
        shareTypes.insert(HKSampleType.quantityType(forIdentifier: .bloodGlucose)!)
        shareTypes.insert(HKSampleType.quantityType(forIdentifier: .bodyMass)!)
        shareTypes.insert(HKSampleType.quantityType(forIdentifier: .dietaryCarbohydrates)!)
        
        readTypes.insert(HKSampleType.quantityType(forIdentifier: .bloodGlucose)!)
        readTypes.insert(HKSampleType.quantityType(forIdentifier: .bodyMass)!)
        readTypes.insert(HKSampleType.quantityType(forIdentifier: .dietaryCarbohydrates)!)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        healthStore.requestAuthorization(toShare: shareTypes, read: readTypes)
        {
            (success, error)-> Void in
            
            if success {}
            else {
                print("HK Failure")
            }
        }
        
        PersistUserEntry.sharedInstance.clearUserEntry()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
