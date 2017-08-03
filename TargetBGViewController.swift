//
//  TargetBGViewController.swift
//  Test
//
//  Created by Danielle on 2/8/17.
//  Copyright © 2017 Danielle. All rights reserved.
//

import UIKit
import CoreData

let tContext = context

class TargetBGViewController: UIViewController, UITextFieldDelegate {
    
    var coreData = CoreDataManager()
    
    var tbg:EndocrineSettings = NSEntityDescription.insertNewObject(forEntityName: "EndocrineSettings", into: tContext) as! EndocrineSettings

    override func viewDidLoad() {
       
        super.viewDidLoad()
        
        self.hideKeyboard()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let dateDescriptor = NSSortDescriptor(key: "setDate", ascending: false)
        let tbgRequest = NSFetchRequest<EndocrineSettings>(entityName: "EndocrineSettings")
        let tbgDesc = NSSortDescriptor(key: "isTBG", ascending: false)
        tbgRequest.sortDescriptors = [tbgDesc, dateDescriptor]
        
        do
        {
            let results = try tContext.fetch(tbgRequest)
            let flag = results.first!
            
            if flag.isTBG == true
            {
                tbg = results.first!
            }
            
        } catch {
            print("Error \(error)")
        }
        print("**TBG: \(tbg)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
    
        pickerStart1.backgroundColor = UIColor.init(red: 1, green: 220/255, blue: 220/255, alpha: 1)
        pickerEnd1.backgroundColor = UIColor.init(red: 1, green: 220/255, blue: 220/255, alpha: 1)
        
        pickerStart2.backgroundColor = UIColor.init(red: 220/255, green: 1, blue: 1, alpha: 1)
        pickerEnd2.backgroundColor = UIColor.init(red: 220/255, green: 1, blue: 1, alpha: 1)
        
        pickerStart3.backgroundColor = UIColor.init(red: 220/255, green: 1, blue: 220/255, alpha: 1)
        pickerEnd3.backgroundColor = UIColor.init(red: 220/255, green: 1, blue: 220/255, alpha: 1)
        
        if tbg.value24a > 0
        {
            timeSwitch.isOn = true
            is24hoursSwitch.textColor = UIColor.blue
            tbgLow24Hours.isHidden = false
            tbgHigh24Hours.isHidden = false
            metricLabel.isHidden = false
            tbgLow24Hours.text = String(tbg.value24a)
            tbgHigh24Hours.text = String(tbg.value24b)
            
            pickerStart1.isHidden = true
            pickerEnd1.isHidden = true
            pickerStart2.isHidden = true
            pickerEnd2.isHidden = true
            pickerStart3.isHidden = true
            pickerEnd3.isHidden = true
            
            tbgLow1.isHidden = true
            tbgLow2.isHidden = true
            tbgLow3.isHidden = true
            tbgHigh1.isHidden = true
            tbgHigh2.isHidden = true
            tbgHigh3.isHidden = true
        }
        else if (tbg.value1a > 0) && (tbg.value3a <= 0)
        {
            timeSwitch.isOn = false
            tbgLow24Hours.isHidden = true
            tbgHigh24Hours.isHidden = true
            metricLabel.isHidden = false
            tbgLow1.isHidden = false
            tbgLow2.isHidden = false
            tbgLow3.isHidden = true
            tbgHigh1.isHidden = false
            tbgHigh2.isHidden = false
            tbgHigh3.isHidden = true
            pickerStart1.isHidden = false
            pickerEnd1.isHidden = false
            pickerStart2.isHidden = false
            pickerEnd2.isHidden = false
            pickerStart3.isHidden = true
            pickerEnd3.isHidden = true
            
            tbgLow1.text = String(tbg.value1a)
            tbgLow2.text = String(tbg.value2a)
            tbgHigh1.text = String(tbg.value1b)
            tbgHigh2.text = String(tbg.value2b)
            
            pickerEnd1.date = tbg.endTime1! as Date
            pickerStart2.date = tbg.startTime2! as Date
            
            metricLabel.frame = CGRect(x: 84, y: 80, width: 76, height: 31)
            is24hoursSwitch.textColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
        }
        else if (tbg.value1a > 0) && (tbg.value3a > 0)
        {
            timeSwitch.isOn = false
            metricLabel.isHidden = false
            tbgLow24Hours.isHidden = true
            tbgHigh24Hours.isHidden = true
            
            pickerEnd1.date = tbg.endTime1! as Date
            pickerStart2.date = tbg.startTime2! as Date
            pickerEnd2.date = tbg.endTime2! as Date
            pickerStart3.date = tbg.startTime3! as Date
            
            tbgLow1.text = String(tbg.value1a)
            tbgLow2.text = String(tbg.value2a)
            tbgLow3.text = String(tbg.value3a)
            tbgHigh1.text = String(tbg.value1b)
            tbgHigh2.text = String(tbg.value2b)
            tbgHigh3.text = String(tbg.value3b)
            
            tbgLow1.isHidden = false
            tbgLow2.isHidden = false
            tbgLow3.isHidden = false
            tbgHigh1.isHidden = false
            tbgHigh2.isHidden = false
            tbgHigh3.isHidden = false
            
            pickerStart1.isHidden = false
            pickerEnd1.isHidden = false
            pickerStart2.isHidden = false
            pickerEnd2.isHidden = false
            pickerStart3.isHidden = false
            pickerEnd3.isHidden = false
            
            metricLabel.frame = CGRect(x: 84, y: 80, width: 76, height: 31)
            is24hoursSwitch.textColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
        }
        else if (tbg.value24a <= 0) && (tbg.value1a <= 0)
        {
            timeSwitch.isOn = true
            tbgLow24Hours.isHidden = false
            tbgHigh24Hours.isHidden = false
            
            tbgLow1.isHidden = true
            tbgLow2.isHidden = true
            tbgLow3.isHidden = true
            tbgHigh1.isHidden = true
            tbgHigh2.isHidden = true
            tbgHigh3.isHidden = true
            
            pickerStart1.isHidden = true
            pickerEnd1.isHidden = true
            pickerStart2.isHidden = true
            pickerEnd2.isHidden = true
            pickerStart3.isHidden = true
            pickerEnd3.isHidden = true
            
        }
        metricLabel.translatesAutoresizingMaskIntoConstraints = true
    }
    

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    
    @IBOutlet weak var tbgLow24Hours: UITextField!
    @IBOutlet weak var tbgHigh24Hours: UITextField!
    @IBOutlet weak var metricLabel: UILabel!
   
    @IBOutlet weak var metricLabel1: UILabel!

    @IBOutlet weak var timeSwitch: UISwitch!
    @IBOutlet weak var is24hoursSwitch: UILabel!
    
    @IBOutlet weak var tbgLow1: UITextField!
    @IBOutlet weak var tbgHigh1: UITextField!
    @IBOutlet weak var tbgLow2: UITextField!
    @IBOutlet weak var tbgHigh2: UITextField!
    @IBOutlet weak var tbgLow3: UITextField!
    @IBOutlet weak var tbgHigh3: UITextField!
    
    @IBOutlet weak var pickerStart1: UIDatePicker!
    @IBOutlet weak var pickerEnd1: UIDatePicker!
    @IBOutlet weak var pickerStart2: UIDatePicker!
    @IBOutlet weak var pickerEnd2: UIDatePicker!
    @IBOutlet weak var pickerStart3: UIDatePicker!
    @IBOutlet weak var pickerEnd3: UIDatePicker!
    
    @IBAction func tbgSEditingChanged(_textField: UITextField){}
    @IBAction func tbgEEditingChanged(_textField: UITextField){}
    @IBAction func tbgS1EditingChanged(_textField: UITextField){}
    @IBAction func tbgE1EditingChanged(_textField: UITextField){}
    @IBAction func tbgS2EditingChanged(_textField: UITextField){}
    @IBAction func tbgE2EditingChanged(_textField: UITextField){}
    @IBAction func tbgS3EditingChanged(_textField: UITextField){}
    @IBAction func tbgE3EditingChanged(_textField: UITextField){}
    
    //for getting HH:mm AM/PM from datepickers
    let dateFormatter = DateFormatter()
    
    //for setting HH:mm AM/PM to first and last datepickers
    let formatter = DateFormatter()
    
    @IBAction func visibilityTBG3(_ sender: Any) {
    
        dateFormatter.timeStyle = DateFormatter.Style.short
        let stringDate = dateFormatter.string(from: pickerEnd2.date)
        is1159PM(dateString: stringDate)
    }
    
    
    @IBAction func timeSwitchTapped(_ sender: Any) {
        
        if !(timeSwitch.isOn) && (tbg.value2a > 0) && !(tbg.value3a > 0)
        {
            is24hoursSwitch.textColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
            tbgLow24Hours.isHidden = true
            tbgHigh24Hours.isHidden = true
            metricLabel.frame = CGRect(x: 16, y: 80, width: 76, height: 31)
            
            tbgLow1.isHidden = false
            tbgLow2.isHidden = false
            tbgLow3.isHidden = true
            tbgHigh1.isHidden = false
            tbgHigh2.isHidden = false
            tbgHigh3.isHidden = true
            
            pickerStart3.isHidden = true
            pickerEnd3.isHidden = true
            
            tbgLow1.text = String(tbg.value1a)
            tbgLow2.text = String(tbg.value2a)
            tbgHigh1.text = String(tbg.value1b)
            tbgHigh2.text = String(tbg.value2b)
            
            pickerEnd1.date = tbg.endTime1! as Date
            pickerStart2.date = tbg.startTime2! as Date
            
            pickerStart1.isHidden = false
            pickerEnd1.isHidden = false
            pickerStart2.isHidden = false
            pickerEnd2.isHidden = false
            
        }
        else if !(timeSwitch.isOn) && (tbg.value3a > 0)
        {
            is24hoursSwitch.textColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
            tbgLow24Hours.isHidden = true
            tbgHigh24Hours.isHidden = true
            metricLabel.frame = CGRect(x: 16, y: 80, width: 76, height: 31)
            
            tbgLow1.isHidden = false
            tbgLow2.isHidden = false
            tbgLow3.isHidden = false
            tbgHigh1.isHidden = false
            tbgHigh2.isHidden = false
            tbgHigh3.isHidden = false
            
            tbgLow1.text = String(tbg.value1a)
            tbgLow2.text = String(tbg.value2a)
            tbgLow3.text = String(tbg.value3a)
            tbgHigh1.text = String(tbg.value1b)
            tbgHigh2.text = String(tbg.value2b)
            tbgHigh3.text = String(tbg.value3b)
            
            pickerEnd1.date = tbg.endTime1! as Date
            pickerStart2.date = tbg.startTime2! as Date
            pickerEnd2.date = tbg.endTime2! as Date
            pickerStart3.date = tbg.startTime3! as Date
            
            pickerStart1.isHidden = false
            pickerEnd1.isHidden = false
            pickerStart2.isHidden = false
            pickerEnd2.isHidden = false
            pickerStart3.isHidden = false
            pickerEnd3.isHidden = false
        }
        else if !(timeSwitch.isOn)
        {
            is24hoursSwitch.textColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
            tbgLow24Hours.isHidden = true
            tbgHigh24Hours.isHidden = true
            metricLabel.frame = CGRect(x: 16, y: 80, width: 76, height: 31)
            
            tbgLow1.isHidden = false
            tbgLow2.isHidden = false
            tbgLow3.isHidden = true
            tbgHigh1.isHidden = false
            tbgHigh2.isHidden = false
            tbgHigh3.isHidden = true
            
            tbgLow1.text = String(tbg.value1a)
            tbgLow2.text = String(tbg.value2a)
            tbgHigh1.text = String(tbg.value1b)
            tbgHigh2.text = String(tbg.value2b)
            
            pickerStart1.isHidden = false
            pickerEnd1.isHidden = false
            pickerStart2.isHidden = false
            pickerEnd2.isHidden = false
            pickerStart3.isHidden = true
            pickerEnd3.isHidden = true
            
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
            pickerEnd1.date = formatter.date(from: "2001-01-01 13:59:00 +0000")!
            pickerStart2.date = formatter.date(from: "2001-01-01 14:00:00 +0000")!
            pickerEnd2.date = formatter.date(from: "2001-01-02 6:59:00 +0000")!
        }
        else if (timeSwitch.isOn)
        {
            is24hoursSwitch.text = "24 Hrs"
            is24hoursSwitch.textColor = UIColor.blue
            
            tbgLow24Hours.isHidden = false
            tbgHigh24Hours.isHidden = false
            
            tbgLow24Hours.text = String(tbg.value24a)
            tbgHigh24Hours.text = String(tbg.value24b)
            metricLabel.frame = CGRect(x: 84, y: 80, width: 76, height: 31)
            
            pickerStart1.isHidden = true
            pickerEnd1.isHidden = true
            pickerStart2.isHidden = true
            pickerEnd2.isHidden = true
            pickerStart3.isHidden = true
            pickerEnd3.isHidden = true
            
            tbgLow1.isHidden = true
            tbgLow2.isHidden = true
            tbgLow3.isHidden = true
            tbgHigh1.isHidden = true
            tbgHigh2.isHidden = true
            tbgHigh3.isHidden = true
        }
        
    }
    
    
    @IBAction func updatePS1(_ sender: Any) {
   
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        pickerStart1.date = formatter.date(from: "2001-01-01 07:00:00 +0000")!
    }
    
    @IBAction func updatePE3(_ sender: Any) {
       
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        pickerEnd3.date = formatter.date(from: "2001-01-02 6:59:00 +0000")!
    }
    
    @IBAction func updatePS2(_ sender: Any) {
      
        pickerStart2.date = pickerEnd1.date.addingTimeInterval(60)
        
        if pickerEnd1.date > pickerEnd2.date
        {
            pickerEnd2.date = pickerEnd1.date.addingTimeInterval(120)
            pickerStart3.date = pickerEnd1.date.addingTimeInterval(180)
        }
    }
    
    @IBAction func updatePE2_A(_ sender: Any) {
        
        if pickerStart2.date > pickerEnd2.date.addingTimeInterval(-60)
        {
            pickerEnd2.date = pickerStart2.date.addingTimeInterval(60)
        }
    }
    
    @IBAction func updatePE1(_ sender: Any) {
       
        pickerEnd1.date = pickerStart2.date.addingTimeInterval(-60)
        
        if pickerStart2.date >= pickerEnd2.date
        {
            pickerEnd2.date = pickerStart2.date.addingTimeInterval(60)
        }
        
        if pickerStart2.date > pickerStart3.date
        {
            pickerStart3.date = pickerStart2.date.addingTimeInterval(120)
        }
    }
    
    @IBAction func updatePE2(_ sender: Any) {
      
        pickerEnd2.date = pickerStart3.date.addingTimeInterval(-60)
        
        if pickerStart2.date >= pickerStart3.date.addingTimeInterval(-120)
        {
            pickerEnd2.date = pickerStart2.date.addingTimeInterval(60)
            pickerStart3.date = pickerStart2.date.addingTimeInterval(120)
        }
    }
    
   
    @IBAction func saveTBGtoDB(_ sender: Any) {
        
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        let now = NSDate() as Date
        let am:Date = formatter.date(from: "2001-01-01 07:00:00 +0000")!
        let pm:Date = formatter.date(from: "2001-01-02 06:59:00 +0000")!
        
        if timeSwitch.isOn
        {
            var tbgLow:Int = 0
            var tbgHigh:Int = 0
            
            if Int(tbgLow24Hours.text!) != nil
            {
                tbgLow = Int(tbgLow24Hours.text!)!
            }
            
            if Int(tbgHigh24Hours.text!) != nil
            {
                tbgHigh = Int(tbgHigh24Hours.text!)!
            }
            
            let alertContTBG = UIAlertController(title: "Value Missing",
                                                 message: "Please enter a target blood glucose.",
                                                 preferredStyle: .alert)
            let stayActionTBG = UIAlertAction(title: "OK", style: .default, handler: {alert -> Void in})
            
            if tbgLow <= 0 || tbgHigh <= 0
            {
                alertContTBG.addAction(stayActionTBG)
                present(alertContTBG, animated: true, completion: nil)
            }
            else
            {
               coreData.saveEndocrineSettings(settingType: "TBG", setDate: now, value24L: tbgLow, value24H: tbgHigh, value1L: 0, value1H: 0, value2L: 0, value2H: 0, value3L: 0, value3H: 0, start1: now, start2: now, start3: now, end1: now, end2: now, end3: now)
            }
        }
        else
        {
            if pickerStart3.isHidden == true
            {
                var oneLow:Int = 0
                var oneHigh:Int = 0
                var twoLow:Int = 0
                var twoHigh:Int = 0
                
                if Int(tbgLow1.text!) != nil
                {
                    oneLow = Int(tbgLow1.text!)!
                }
                if Int(tbgHigh1.text!) != nil
                {
                    oneHigh = Int(tbgHigh1.text!)!
                }
                if Int(tbgLow2.text!) != nil
                {
                    twoLow = Int(tbgLow2.text!)!
                }
                if Int(tbgHigh2.text!) != nil
                {
                    twoHigh = Int(tbgHigh2.text!)!
                }
                
                let alertContTBG = UIAlertController(title: "Value Missing",
                                                     message: "Please enter a target blood glucose.",
                                                     preferredStyle: .alert)
                let stayActionTBG = UIAlertAction(title: "OK", style: .default, handler: {alert -> Void in})
                
                if oneLow <= 0 || oneHigh <= 0 || twoLow <= 0 || twoHigh <= 0
                {
                    alertContTBG.addAction(stayActionTBG)
                    present(alertContTBG, animated: true, completion: nil)
                }
                else
                {
                    let oneEnd:Date = pickerEnd1.date
                    let twoStart:Date = pickerStart2.date
                    
                    coreData.saveEndocrineSettings(settingType: "TBG", setDate: now, value24L: 0, value24H: 0, value1L: oneLow, value1H: oneHigh, value2L: twoLow, value2H: twoHigh, value3L: 0, value3H: 0, start1: am, start2: twoStart, start3: now, end1: oneEnd, end2: pm, end3: now)
                }
            }
            else if pickerStart3.isHidden == false
            {
                var oneLow:Int = 0
                var oneHigh:Int = 0
                var twoLow:Int = 0
                var twoHigh:Int = 0
                var threeLow:Int = 0
                var threeHigh:Int = 0
                
                if Int(tbgLow1.text!) != nil
                {
                    oneLow = Int(tbgLow1.text!)!
                }
                if Int(tbgHigh1.text!) != nil
                {
                    oneHigh = Int(tbgHigh1.text!)!
                }
                if Int(tbgLow2.text!) != nil
                {
                    twoLow = Int(tbgLow2.text!)!
                }
                if Int(tbgHigh2.text!) != nil
                {
                    twoHigh = Int(tbgHigh2.text!)!
                }
                if Int(tbgLow3.text!) != nil
                {
                    threeLow = Int(tbgLow3.text!)!
                }
                if Int(tbgHigh3.text!) != nil
                {
                    threeHigh = Int(tbgHigh3.text!)!
                }
                
                let alertContTBG = UIAlertController(title: "Value Missing",
                                                     message: "Please enter a target blood glucose.",
                                                     preferredStyle: .alert)
                let stayActionTBG = UIAlertAction(title: "OK", style: .default, handler: {alert -> Void in})
                
                if oneLow <= 0 || oneHigh <= 0 || twoLow <= 0 || twoHigh <= 0 || threeLow <= 0 || threeHigh <= 0
                {
                    alertContTBG.addAction(stayActionTBG)
                    present(alertContTBG, animated: true, completion: nil)
                }
                else
                {
                    let oneEnd:Date = pickerEnd1.date
                    let twoStart:Date = pickerStart2.date
                    let twoEnd:Date = pickerEnd2.date
                    let threeStart:Date = pickerStart3.date
                    
                    coreData.saveEndocrineSettings(settingType: "TBG", setDate: now, value24L: 0, value24H: 0, value1L: oneLow, value1H: oneHigh, value2L: twoLow, value2H: twoHigh, value3L: threeLow, value3H: threeHigh, start1: am, start2: twoStart, start3: threeStart, end1: oneEnd, end2: twoEnd, end3: pm)
                }
            }
            else
            {
                print("**ERROR")
            }
        }
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ESHomeViewController") as! ESHomeViewController
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func lowTBGsetText(_ sender: Any) {
       
        setTextField(textField: sender as! UITextField, textFieldString: tbgLow24Hours.text!, compareString: "low")
    }
    
    @IBAction func lowTBGupdateText(_ sender: Any) {
        
       updateTextField(textField: sender as! UITextField, textFieldString: tbgLow24Hours.text!, compareString: "low")
    }
    
    @IBAction func lowTBGresetText(_ sender: Any) {
     
       resetTextField(textField: sender as! UITextField, textFieldString: tbgLow24Hours.text!, compareString: "low")
    }
    
    @IBAction func highTBGsetText(_ sender: Any) {
      
        setTextField(textField: sender as! UITextField, textFieldString: tbgHigh24Hours.text!, compareString: "high")
    }
    
    @IBAction func highTBGupdateText(_ sender: Any) {
      
       updateTextField(textField: sender as! UITextField, textFieldString: tbgHigh24Hours.text!, compareString: "high")
    }
    
    @IBAction func highTBGresetText(_ sender: Any) {
       
      resetTextField(textField: sender as! UITextField, textFieldString: tbgHigh24Hours.text!, compareString: "high")
    }
    
    @IBAction func setTBGlow1(_ sender: Any) {
        
        setTextField(textField: sender as! UITextField, textFieldString: tbgLow1.text!, compareString: "low")
    }
    
    @IBAction func updateTBGlow1(_ sender: Any) {
        
        updateTextField(textField: sender as! UITextField, textFieldString: tbgLow1.text!, compareString: "low")
    }
    
    @IBAction func resestTBGlow1(_ sender: Any) {
        
        resetTextField(textField: sender as! UITextField, textFieldString: tbgLow1.text!, compareString: "low")
    }
    
    @IBAction func setTBGhigh1(_ sender: Any) {
        
        setTextField(textField: sender as! UITextField, textFieldString: tbgHigh1.text!, compareString: "high")
    }
    
    @IBAction func updateTBGhigh1(_ sender: Any) {
        
        updateTextField(textField: sender as! UITextField, textFieldString: tbgHigh1.text!, compareString: "high")
    }
    
    @IBAction func resetTBGhigh1(_ sender: Any) {
        
        resetTextField(textField: sender as! UITextField, textFieldString: tbgHigh1.text!, compareString: "high")
    }
    
    @IBAction func setTBGlow2(_ sender: Any) {
        
        setTextField(textField: sender as! UITextField, textFieldString: tbgLow2.text!, compareString: "low")
    }
    
    @IBAction func updateTBGlow2(_ sender: Any) {
        
        updateTextField(textField: sender as! UITextField, textFieldString: tbgLow2.text!, compareString: "low")
    }
    
    @IBAction func resetTBGlow2(_ sender: Any) {
        
        resetTextField(textField: sender as! UITextField, textFieldString: tbgLow2.text!, compareString: "low")
    }
    
    @IBAction func setTBGhigh2(_ sender: Any) {
        
        setTextField(textField: sender as! UITextField, textFieldString: tbgHigh2.text!, compareString: "high")
    }
    
    @IBAction func updateTBGhigh2(_ sender: Any) {
        
        updateTextField(textField: sender as! UITextField, textFieldString: tbgHigh2.text!, compareString: "high")
    }
    
    @IBAction func resetTBGhigh2(_ sender: Any) {
        
        resetTextField(textField: sender as! UITextField, textFieldString: tbgHigh2.text!, compareString: "high")
    }
    
    @IBAction func setTBGlow3(_ sender: Any) {
        
        setTextField(textField: sender as! UITextField, textFieldString: tbgLow3.text!, compareString: "low")
    }
    
    @IBAction func updateTBGlow3(_ sender: Any) {
        
        updateTextField(textField: sender as! UITextField, textFieldString: tbgLow3.text!, compareString: "low")
    }
    
    @IBAction func resetTBGlow3(_ sender: Any) {
        
        resetTextField(textField: sender as! UITextField, textFieldString: tbgLow3.text!, compareString: "low")
    }
    
    @IBAction func setTBGhigh3(_ sender: Any) {
        
        setTextField(textField: sender as! UITextField, textFieldString: tbgHigh3.text!, compareString: "high")
    }
    
    @IBAction func updateTBGhigh3(_ sender: Any) {
        
        updateTextField(textField: sender as! UITextField, textFieldString: tbgHigh3.text!, compareString: "high")
    }
    
    @IBAction func resetTBGhigh3(_ sender: Any) {
        
        resetTextField(textField: sender as! UITextField, textFieldString: tbgHigh3.text!, compareString: "high")
    }
    
    func setTextField(textField: UITextField, textFieldString: String, compareString: String)
    {
        let string = textFieldString
        let field = textField
        let compString = compareString
        
        if string == compString
        {
            field.textColor = UIColor.init(red: 130/255, green: 130/255, blue: 130/255, alpha: 1)
        }
        else
        {
            field.textColor = UIColor.black
        }
    }
    
    func updateTextField(textField: UITextField, textFieldString: String, compareString: String)
    {
        let string = textFieldString
        let field = textField
        let compString = compareString
        
        if string == compString
        {
            field.textColor = UIColor.init(red: 130/255, green: 130/255, blue: 130/255, alpha: 1)
        }
        else
        {
            field.textColor = UIColor.black
        }
    }
    
    func resetTextField(textField: UITextField, textFieldString: String, compareString: String)
    {
        let string = textFieldString
        let field = textField
        let compString = compareString
        
        if string == ""
        {
            field.text = compString
            field.textColor = UIColor.init(red: 130/255, green: 130/255, blue: 130/255, alpha: 1)
        }
        else if string == compString
        {
            field.textColor = UIColor.init(red: 130/255, green: 130/255, blue: 130/255, alpha: 1)
        }
        else
        {
            field.textColor = UIColor.black
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if tbgLow2.isEditing || tbgHigh2.isEditing || tbgLow3.isEditing || tbgHigh3.isEditing
        {
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
            {
                if self.view.frame.origin.y == 0
                {
                    self.view.frame.origin.y -= keyboardSize.height
                }
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        {
            if self.view.frame.origin.y != 0
            {
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    func is1159PM(dateString: String)
    {
        if dateString == "11:59 PM"
        {
            pickerStart3.isHidden = true
            pickerEnd3.isHidden = true
            tbgLow3.isHidden = true
            tbgHigh3.isHidden = true
        }
        else
        {
            pickerStart3.isHidden = false
            pickerEnd3.isHidden = false
            tbgLow3.isHidden = false
            tbgHigh3.isHidden = false
            pickerStart3.date = pickerEnd2.date.addingTimeInterval(60)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let existingTextHasDecimalSeparator = textField.text?.range(of: ".")
        let replacementTextHasDecimalSeparator = string.range(of: ".")
        
        let letters = NSCharacterSet.letters
        var punctuation = NSCharacterSet.punctuationCharacters
        punctuation.insert(charactersIn: "`~$^=+|<>")
        
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
