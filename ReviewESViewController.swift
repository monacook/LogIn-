//
//  ReviewESViewController.swift
//  Test
//
//  Created by Danielle on 2/8/17.
//  Copyright © 2017 Danielle. All rights reserved.
//

import UIKit
import CoreData
import HealthKit


//Singleton
class PersistUserEntry {
    
    static let sharedInstance = PersistUserEntry()
    
    var bg:String = ""
    var exerMin:String = ""
    var exerInt:String = ""
    var photo:UIImage?
    
    init() {}
    
    func persistExercise(curBG: String, minutes: String, intensity: String)
    {
        bg = curBG
        exerMin = minutes
        exerInt = intensity
    }
    
    func persistMeals(curBG: String, pict:UIImage)
    {
        bg = curBG
        photo = pict
    }
    
    func persistMealsNoPhoto(curBG: String)
    {
        bg = curBG
    }
   
    func clearUserEntry() {
        
        bg = ""
        exerMin = ""
        exerInt = ""
        photo = nil
    }
}


class EndocrineSettingsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var esValue: UILabel!
    @IBOutlet weak var esStart: UILabel!
    @IBOutlet weak var esEnd: UILabel!
}

struct EndoSetting {
    
    var type: String
    var value: String
    var startTime: String
    var endTime: String
    
    init(title: String, setting: String, timeStart: String, timeEnd: String)
    {
        type = title
        value = setting
        startTime = timeStart
        endTime = timeEnd
    }
}

class EndoSettingsCD {
    
    func getESFromCD(context: NSManagedObjectContext) -> Array<EndoSetting> {
        
        let df = DateFormatter()
        df.timeStyle = .short
        
        var esArray = Array<EndoSetting>()
        var icrSetting:EndoSetting
        var icr1Setting:EndoSetting
        var icr2Setting:EndoSetting
        var icr3Setting:EndoSetting
        var cfSetting:EndoSetting
        var cf1Setting:EndoSetting
        var cf2Setting:EndoSetting
        var cf3Setting:EndoSetting
        var tbgSetting:EndoSetting
        var tbg1Setting:EndoSetting
        var tbg2Setting:EndoSetting
        var tbg3Setting:EndoSetting
        var weightSetting:EndoSetting = EndoSetting(title: "BodyWeight", setting: "", timeStart: "", timeEnd: "")
        let vContext:NSManagedObjectContext = context
        
        var icr:EndocrineSettings = NSEntityDescription.insertNewObject(forEntityName: "EndocrineSettings", into: vContext) as! EndocrineSettings
        var cf: EndocrineSettings = NSEntityDescription.insertNewObject(forEntityName: "EndocrineSettings", into: vContext) as! EndocrineSettings
        var tbg:EndocrineSettings = NSEntityDescription.insertNewObject(forEntityName: "EndocrineSettings", into: vContext) as! EndocrineSettings
        
        //ICR
        let dateDescriptor = NSSortDescriptor(key: "setDate", ascending: false)
        let icrRequest = NSFetchRequest<EndocrineSettings>(entityName: "EndocrineSettings")
        let icrDesc = NSSortDescriptor(key: "isICR", ascending: false)
        icrRequest.sortDescriptors = [icrDesc, dateDescriptor]
    
        do
        {
            let results = try vContext.fetch(icrRequest)
            
            icr = results.first!
            
        } catch {
            print("Error \(error)")
        }
        
        if icr.value24a > 0
        {
            let vString = String(icr.value24a) + " mg/dL"
            icrSetting = EndoSetting(title: "Insulin-Carb Ratio", setting: vString, timeStart: "12:00 AM", timeEnd: "11:59 PM")
            esArray.append(icrSetting)
        }
        else if icr.value3a > 0
        {
            let v1String = String(icr.value1a) + " mg/dL"
            let v2String = String(icr.value2a) + " mg/dL"
            let v3String = String(icr.value3a) + " mg/dL"
            
            let end1 = icr.endTime1
            let start2 = icr.startTime2
            let end2 = icr.endTime2
            let start3 = icr.startTime3
            
            let sEnd1:String = df.string(from: end1! as Date)
            let sStart2:String = df.string(from: start2! as Date)
            let sEnd2:String = df.string(from: end2! as Date)
            let sStart3:String = df.string(from: start3! as Date)
  
            icr1Setting = EndoSetting(title: "Insulin-Carb Ratio", setting: v1String, timeStart: "12:00 AM", timeEnd: sEnd1)
            icr2Setting = EndoSetting(title: "Insulin-Carb Ratio", setting: v2String, timeStart: sStart2, timeEnd: sEnd2)
            icr3Setting = EndoSetting(title: "Insulin-Carb Ratio", setting: v3String, timeStart: sStart3, timeEnd: "11:59 PM")
            
            esArray.append(icr1Setting); esArray.append(icr2Setting); esArray.append(icr3Setting)
        }
        else
        {
            let v1String = String(icr.value1a) + " mg/dL"
            let v2String = String(icr.value2a) + " mg/dL"
            
            let end1 = icr.endTime1
            let start2 = icr.startTime2
            
            if (end1 != nil) && (start2 != nil)
            {
                let sEnd1:String = df.string(from: end1! as Date)
                let sStart2:String = df.string(from: start2! as Date)
                
                icr1Setting = EndoSetting(title: "Insulin-Carb Ratio", setting: v1String, timeStart: "12:00 AM", timeEnd: sEnd1)
                icr2Setting = EndoSetting(title: "Insulin-Carb Ratio", setting: v2String, timeStart: sStart2, timeEnd: "11:59 PM")
            }
            else
            {
                icr1Setting = EndoSetting(title: "Insulin-Carb Ratio", setting: "Value Missing", timeStart: "", timeEnd: "")
                icr2Setting = EndoSetting(title: "Insulin-Carb Ratio", setting: "Value Missing", timeStart: "", timeEnd: "")
            }
      
            esArray.append(icr1Setting); esArray.append(icr2Setting)
        }

        //CF
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
            let vString = String(cf.value24a) + " units/gram"
            cfSetting = EndoSetting(title: "Correction Factor", setting: vString, timeStart: "12:00 AM", timeEnd: "11:59 PM")
            esArray.append(cfSetting)
        }
        else if cf.value3a > 0
        {
            let v1String = String(cf.value1a) + " units/gram"
            let v2String = String(cf.value2a) + " units/gram"
            let v3String = String(cf.value3a) + " units/gram"
            
            let end1 = cf.endTime1
            let start2 = cf.startTime2
            let end2 = cf.endTime2
            let start3 = cf.startTime3
            
            let sEnd1:String = df.string(from: end1! as Date)
            let sStart2:String = df.string(from: start2! as Date)
            let sEnd2:String = df.string(from: end2! as Date)
            let sStart3:String = df.string(from: start3! as Date)
            
            cf1Setting = EndoSetting(title: "Correction Factor", setting: v1String, timeStart: "12:00 AM", timeEnd: sEnd1)
            cf2Setting = EndoSetting(title: "Correction Factor", setting: v2String, timeStart: sStart2, timeEnd: sEnd2)
            cf3Setting = EndoSetting(title: "Correction Factor", setting: v3String, timeStart: sStart3, timeEnd: "11:59 PM")
            
            esArray.append(cf1Setting); esArray.append(cf2Setting); esArray.append(cf3Setting)
        }
        else
        {
            let v1String = String(cf.value1a) + " units/gram"
            let v2String = String(cf.value2a) + " units/gram"
            
            let end1 = cf.endTime1
            let start2 = cf.startTime2
   
            if (end1 != nil) && (start2 != nil)
            {
                let sEnd1:String = df.string(from: end1! as Date)
                let sStart2:String = df.string(from: start2! as Date)
                
                cf1Setting = EndoSetting(title: "Correction Factor", setting: v1String, timeStart: "12:00 AM", timeEnd: sEnd1)
                cf2Setting = EndoSetting(title: "Correction Factor", setting: v2String, timeStart: sStart2, timeEnd: "11:59 PM")
            }
            else
            {
                cf1Setting = EndoSetting(title: "Correction Factor", setting: "Value Missing", timeStart: "", timeEnd: "")
                cf2Setting = EndoSetting(title: "Correction Factor", setting: "Value Missing", timeStart: "", timeEnd: "")
            }
  
            esArray.append(cf1Setting); esArray.append(cf2Setting)
        }

        //Target Blood Glucose
        let tbgRequest = NSFetchRequest<EndocrineSettings>(entityName: "EndocrineSettings")
        let tbgDesc = NSSortDescriptor(key: "isTBG", ascending: false)
        tbgRequest.sortDescriptors = [tbgDesc, dateDescriptor]
        tbgRequest.fetchLimit = 1
        
        do {
            let results = try vContext.fetch(tbgRequest)
            tbg = results.first!
 
        } catch {
            print("Error \(error)")
        }
        
        if tbg.value24a > 0
        {
            let vString = String(tbg.value24a) + " to " + String(tbg.value24b) + " mg/dL"
            tbgSetting = EndoSetting(title: "Target Blood Glucose", setting: vString, timeStart: "12:00 AM", timeEnd: "11:59 PM")
            esArray.append(tbgSetting)
        }
        else if tbg.value3a > 0
        {
            let v1String = String(tbg.value1a) + " to " + String(tbg.value1b) + " mg/dL"
            let v2String = String(tbg.value2a) + " to " + String(tbg.value2b) + " mg/dL"
            let v3String = String(tbg.value3a) + " to " + String(tbg.value3b) + " mg/dL"
   
            let end1 = tbg.endTime1
            let start2 = tbg.startTime2
            let end2 = tbg.endTime2
            let start3 = tbg.startTime3
      
            let sEnd1:String = df.string(from: end1! as Date)
            let sStart2:String = df.string(from: start2! as Date)
            let sEnd2:String = df.string(from: end2! as Date)
            let sStart3:String = df.string(from: start3! as Date)
            
            tbg1Setting = EndoSetting(title: "Target Blood Glucose", setting: v1String, timeStart: "12:00 AM", timeEnd: sEnd1)
            tbg2Setting = EndoSetting(title: "Target Blood Glucose", setting: v2String, timeStart: sStart2, timeEnd: sEnd2)
            tbg3Setting = EndoSetting(title: "Target Blood Glucose", setting: v3String, timeStart: sStart3, timeEnd: "11:59 PM")
            
            esArray.append(tbg1Setting); esArray.append(tbg2Setting); esArray.append(tbg3Setting)
        }
        else
        {
            let v1String = String(tbg.value1a) + " to " + String(tbg.value1b) + " mg/dL"
            let v2String = String(tbg.value2a) + " to " + String(tbg.value2b) + " mg/dL"
            
            let end1 = tbg.endTime1
            let start2 = tbg.startTime2
            
            if (end1 != nil) && (start2 != nil)
            {
                let sEnd1:String = df.string(from: end1! as Date)
                let sStart2:String = df.string(from: start2! as Date)
                
                tbg1Setting = EndoSetting(title: "Target Blood Glucose", setting: v1String, timeStart: "12:00 AM", timeEnd: sEnd1)
                tbg2Setting = EndoSetting(title: "Target Blood Glucose", setting: v2String, timeStart: sStart2, timeEnd: "11:59 PM")
            }
            else
            {
                tbg1Setting = EndoSetting(title: "Target Blood Glucose", setting: "Value Missing", timeStart: "", timeEnd: "")
                tbg2Setting = EndoSetting(title: "Target Blood Glucose", setting: "Value Missing", timeStart: "", timeEnd: "")
            }
        
            esArray.append(tbg1Setting); esArray.append(tbg2Setting)
        }
        
        //Body Weight
        let past = NSDate.distantPast as Date
        let now = NSDate() as Date
        
        var sWeightHK:String = "0.0"
        var dateHK:Date = past
        var sWeightCD:String = "0.0"
        var dateCD:Date = now
        
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
            dateCD = (cdWeight.setDate as Date?)!
        }
        
        if (sWeightHK != "0.0") && (sWeightCD != "0.0")
        {
            if dateHK > dateCD
            {
                weightSetting = EndoSetting(title: "Body Weight", setting: sWeightHK + " lbs", timeStart: "", timeEnd: "")
            }
            else
            {
                weightSetting = EndoSetting(title: "Body Weight", setting: sWeightCD + " lbs", timeStart: "", timeEnd: "")
            }
        }
        else if (sWeightCD != "0.0")
        {
           weightSetting = EndoSetting(title: "Body Weight", setting: sWeightCD + " lbs", timeStart: "", timeEnd: "")
        }
        else
        {
            weightSetting = EndoSetting(title: "Body Weight", setting: "0.0 lbs", timeStart: "", timeEnd: "")
        }
        
        esArray.append(weightSetting)
        
        return esArray
    }
}

    

class ReviewESViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var endoSettings: UITableView!
    
    var previousVC:String = ""
    
    var sections = Dictionary<String, Array<EndoSetting>>()
    var sortedSections = [String]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.hideKeyboard()

        let esSettings = EndoSettingsCD().getESFromCD(context: self.context)
        
            for esSetting in esSettings {
                let settingType = esSetting.type
                let settingValue = esSetting.value
                let settingStart = esSetting.startTime
                let settingEnd = esSetting.endTime
                
                if self.sections.index(forKey: settingType) == nil
                {
                    self.sections[settingType] = [EndoSetting(title: settingType, setting: settingValue, timeStart: settingStart, timeEnd: settingEnd)]
                }
                else
                {
                    self.sections[settingType]!.append(EndoSetting(title: settingType, setting: settingValue, timeStart: settingStart, timeEnd: settingEnd))
                }
            }
        
        self.sortedSections = ["Target Blood Glucose", "Correction Factor", "Insulin-Carb Ratio", "Body Weight"]
        self.endoSettings.reloadData()
        endoSettings.delegate = self
        endoSettings.dataSource = self
    }


    @IBAction func returnToPreviousVC(_ sender: Any) {
        
        if previousVC == "ESHome"
        {
            self.performSegue(withIdentifier: "reviewESToESHome", sender: nil)
        }
        else if previousVC == "ReviewMeal"
        {
            self.performSegue(withIdentifier: "reviewESToReviewMeal", sender: nil)
        }
        else if previousVC == "AddExercise"
        {
            self.performSegue(withIdentifier: "ReviewEStoAddExercise", sender: nil)
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let title = UILabel()
        title.font = UIFont(name: "Avenir Next Bold", size: 20)
        title.textColor = UIColor.black
        
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        
        header.contentView.backgroundColor = UIColor(colorLiteralRed: 220/255, green: 220/255, blue: 220/255, alpha: 1)
        header.textLabel!.font = title.font
        header.textLabel?.textColor = title.textColor
        header.textLabel?.text = header.textLabel!.text?.localizedCapitalized
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
         return self.sections[self.sortedSections[section]]!.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 40.0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return sortedSections[section]
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "EndoSettings", for: indexPath) as! EndocrineSettingsTableViewCell
        
        let tableSection = sections[sortedSections[indexPath.section]]
        let tableItem = tableSection![indexPath.row]
        
        cell.esValue?.text = tableItem.value
        cell.esStart?.text = tableItem.startTime
        cell.esEnd?.text = tableItem.endTime
        
        return cell
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
