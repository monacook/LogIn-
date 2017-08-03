//
//  ICRViewController.swift
//  Test
//
//  Created by Danielle on 2/8/17.
//  Copyright © 2017 Danielle. All rights reserved.
//

import UIKit
import CoreData

let vContext = context


class ICRViewController: UIViewController, UITextFieldDelegate {
    
    var coreData = CoreDataManager()
    
    var icr:EndocrineSettings = NSEntityDescription.insertNewObject(forEntityName: "EndocrineSettings", into: vContext) as! EndocrineSettings
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.hideKeyboard()
     
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let dateDescriptor = NSSortDescriptor(key: "setDate", ascending: false)
        let icrRequest = NSFetchRequest<EndocrineSettings>(entityName: "EndocrineSettings")
        let icrDesc = NSSortDescriptor(key: "isICR", ascending: false)
        icrRequest.sortDescriptors = [icrDesc, dateDescriptor]
        
        do
        {
            let results = try vContext.fetch(icrRequest)
            let flag = results.first!
            
            if flag.isICR == true
            {
                icr = results.first!
            }
            
        } catch {
            print("Error \(error)")
        }
        print("**ICR: \(icr)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        pickerStart1.backgroundColor = UIColor.init(red: 1, green: 220/255, blue: 220/255, alpha: 1)
        pickerEnd1.backgroundColor = UIColor.init(red: 1, green: 220/255, blue: 220/255, alpha: 1)
        
        pickerStart2.backgroundColor = UIColor.init(red: 220/255, green: 1, blue: 1, alpha: 1)
        pickerEnd2.backgroundColor = UIColor.init(red: 220/255, green: 1, blue: 1, alpha: 1)
        
        pickerStart3.backgroundColor = UIColor.init(red: 220/255, green: 1, blue: 220/255, alpha: 1)
        pickerEnd3.backgroundColor = UIColor.init(red: 220/255, green: 1, blue: 220/255, alpha: 1)
        
      
        if icr.value24a > 0
        {
            timeSwitch.isOn = true
            is24hoursSwitch.textColor = UIColor.blue
            icr24Hours.isHidden = false
            metricLabel.isHidden = false
            icr24Hours.text = String(icr.value24a)
            
            pickerStart1.isHidden = true
            pickerEnd1.isHidden = true
            pickerStart2.isHidden = true
            pickerEnd2.isHidden = true
            pickerStart3.isHidden = true
            pickerEnd3.isHidden = true
            
            icr1.isHidden = true
            icr2.isHidden = true
            icr3.isHidden = true
        }
        else if (icr.value1a > 0) && (icr.value3a <= 0)
        {
            timeSwitch.isOn = false
            icr24Hours.isHidden = true
            metricLabel.isHidden = false
            icr1.isHidden = false
            icr2.isHidden = false
            icr3.isHidden = true
            pickerStart1.isHidden = false
            pickerEnd1.isHidden = false
            pickerStart2.isHidden = false
            pickerEnd2.isHidden = false
            pickerStart3.isHidden = true
            pickerEnd3.isHidden = true
            
            icr1.text = String(icr.value1a)
            icr2.text = String(icr.value2a)
            
            pickerEnd1.date = icr.endTime1! as Date
            pickerStart2.date = icr.startTime2! as Date
            
            metricLabel.frame = CGRect(x: 16, y: 80, width: 76, height: 31)
            is24hoursSwitch.textColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
        }
        else if (icr.value1a > 0) && (icr.value3a > 0)
        {
            timeSwitch.isOn = false
            metricLabel.isHidden = false
            pickerEnd1.date = icr.endTime1! as Date
            pickerStart2.date = icr.startTime2! as Date
            pickerEnd2.date = icr.endTime2! as Date
            pickerStart3.date = icr.startTime3! as Date
            
            icr1.text = String(icr.value1a)
            icr2.text = String(icr.value2a)
            icr3.text = String(icr.value3a)
            
            icr24Hours.isHidden = true
            icr1.isHidden = false
            icr2.isHidden = false
            icr3.isHidden = false
            pickerStart1.isHidden = false
            pickerEnd1.isHidden = false
            pickerStart2.isHidden = false
            pickerEnd2.isHidden = false
            pickerStart3.isHidden = false
            pickerEnd3.isHidden = false
            
            metricLabel.frame = CGRect(x: 16, y: 80, width: 76, height: 31)
            is24hoursSwitch.textColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
        }
        else if (icr.value24a <= 0) && (icr.value1a <= 0)
        {
            timeSwitch.isOn = true
            icr24Hours.isHidden = false
            pickerStart1.isHidden = true
            pickerEnd1.isHidden = true
            pickerStart2.isHidden = true
            pickerEnd2.isHidden = true
            pickerStart3.isHidden = true
            pickerEnd3.isHidden = true
            
            icr1.isHidden = true
            icr2.isHidden = true
            icr3.isHidden = true
            
        }
        metricLabel.translatesAutoresizingMaskIntoConstraints = true
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    
    @IBOutlet weak var icr24Hours: UITextField!
    @IBOutlet weak var metricLabel: UILabel!
    
    
    @IBOutlet weak var timeSwitch: UISwitch!
    @IBOutlet weak var is24hoursSwitch: UILabel!
    
    @IBOutlet weak var icr1: UITextField!
    @IBOutlet weak var icr2: UITextField!
    @IBOutlet weak var icr3: UITextField!
    
    @IBOutlet weak var pickerStart1: UIDatePicker!
    @IBOutlet weak var pickerEnd1: UIDatePicker!
    @IBOutlet weak var pickerStart2: UIDatePicker!
    @IBOutlet weak var pickerEnd2: UIDatePicker!
    @IBOutlet weak var pickerStart3: UIDatePicker!
    @IBOutlet weak var pickerEnd3: UIDatePicker!
    
    @IBAction func icrEditingChanged(_textField: UITextField){}
    @IBAction func icr1EditingChanged(_textField: UITextField){}
    @IBAction func icr2EditingChanged(_textField: UITextField){}
    @IBAction func icr3EditingChanged(_textField: UITextField){}
 
    //for getting HH:mm AM/PM from datepickers
    let dateFormatter = DateFormatter()
    
    //for setting HH:mm AM/PM to first and last datepickers
    let formatter = DateFormatter()
 
    
  
    @IBAction func visibilityICR3(_ sender: Any) {
 
        dateFormatter.timeStyle = DateFormatter.Style.short
        let stringDate = dateFormatter.string(from: pickerEnd2.date)
        is1159PM(dateString: stringDate)
    }
    
    @IBAction func timeSwitchTapped(_ sender: Any) {
      
       if !(timeSwitch.isOn) && (icr.value2a > 0) && !(icr.value3a > 0)
        {
            is24hoursSwitch.textColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
            icr24Hours.isHidden = true
            metricLabel.frame = CGRect(x: 16, y: 80, width: 76, height: 31)
            
            icr1.isHidden = false
            icr2.isHidden = false
            icr3.isHidden = true
            pickerStart3.isHidden = true
            pickerEnd3.isHidden = true
            
            icr1.text = String(icr.value1a)
            icr2.text = String(icr.value2a)
            
            pickerEnd1.date = icr.endTime1! as Date
            pickerStart2.date = icr.startTime2! as Date
            
            pickerStart1.isHidden = false
            pickerEnd1.isHidden = false
            pickerStart2.isHidden = false
            pickerEnd2.isHidden = false
        
        }
        else if !(timeSwitch.isOn) && (icr.value3a > 0)
        {
            is24hoursSwitch.textColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
            icr24Hours.isHidden = true
            metricLabel.frame = CGRect(x: 16, y: 80, width: 76, height: 31)
            
            icr1.isHidden = false
            icr2.isHidden = false
            icr3.isHidden = false
            
            icr1.text = String(icr.value1a)
            icr2.text = String(icr.value2a)
            icr3.text = String(icr.value3a)
            
            pickerEnd1.date = icr.endTime1! as Date
            pickerStart2.date = icr.startTime2! as Date
            pickerEnd2.date = icr.endTime2! as Date
            pickerStart3.date = icr.startTime3! as Date
            
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
            icr24Hours.isHidden = true
            metricLabel.frame = CGRect(x: 16, y: 80, width: 76, height: 31)
            
            icr1.isHidden = false
            icr2.isHidden = false
            icr3.isHidden = true
            
            icr1.text = String(icr.value1a)
            icr2.text = String(icr.value2a)
            
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
            
            icr24Hours.isHidden = false
            icr24Hours.text = String(icr.value24a)
            metricLabel.frame = CGRect(x: 84, y: 80, width: 76, height: 31)
            
            pickerStart1.isHidden = true
            pickerEnd1.isHidden = true
            pickerStart2.isHidden = true
            pickerEnd2.isHidden = true
            pickerStart3.isHidden = true
            pickerEnd3.isHidden = true
            
            icr1.isHidden = true
            icr2.isHidden = true
            icr3.isHidden = true
        }
        
       // dateFormatter.timeStyle = DateFormatter.Style.short
       // let stringDate = dateFormatter.string(from: pickerEnd2.date)
      //  is1159PM(dateString: stringDate)
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
    
    @IBAction func saveToDB(_ sender: Any) {
        
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        let now = NSDate() as Date
        let am:Date = formatter.date(from: "2001-01-01 07:00:00 +0000")!
        let pm:Date = formatter.date(from: "2001-01-02 06:59:00 +0000")!
        
        if timeSwitch.isOn
        {
            var icr:Int = 0
            
            if Int(icr24Hours.text!) != nil
            {
                icr = Int(icr24Hours.text!)!
            }
            
            let alertContICR = UIAlertController(title: "Value Missing",
                                                 message: "Please enter an insulin to carb ratio.",
                                                 preferredStyle: .alert)
            let stayActionICR = UIAlertAction(title: "OK", style: .default, handler: {alert -> Void in})
            
            if icr <= 0
            {
                alertContICR.addAction(stayActionICR)
                present(alertContICR, animated: true, completion: nil)
            }
            else
            {
                coreData.saveEndocrineSettings(settingType: "ICR", setDate: now, value24L: icr, value24H: 0, value1L: 0, value1H: 0, value2L: 0, value2H: 0, value3L: 0, value3H: 0, start1: now, start2: now, start3: now, end1: now, end2: now, end3: now)
            }
        }
        else
        {
            if pickerStart3.isHidden == true
            {
                var one:Int = 0
                var two:Int = 0
                
                if Int(icr1.text!) != nil
                {
                    one = Int(icr1.text!)!
                }
                if Int(icr2.text!) != nil
                {
                    two = Int(icr2.text!)!
                }
                
                let alertContICR = UIAlertController(title: "Value Missing",
                                                     message: "Please enter an insulin to carb ratio.",
                                                     preferredStyle: .alert)
                let stayActionICR = UIAlertAction(title: "OK", style: .default, handler: {alert -> Void in})
                
                if one <= 0 || two <= 0
                {
                    alertContICR.addAction(stayActionICR)
                    present(alertContICR, animated: true, completion: nil)
                }
                else
                {
                    let oneEnd:Date = pickerEnd1.date
                    let twoStart:Date = pickerStart2.date
                    
                    coreData.saveEndocrineSettings(settingType: "ICR", setDate: now, value24L: 0, value24H: 0, value1L: one, value1H: 0, value2L: two, value2H: 0, value3L: 0, value3H: 0, start1: am, start2: twoStart, start3: now, end1: oneEnd, end2: pm, end3: now)
                }
            }
            else if pickerStart3.isHidden == false
            {
                var one:Int = 0
                var two:Int = 0
                var three:Int = 0
                
                if Int(icr1.text!) != nil
                {
                    one = Int(icr1.text!)!
                }
                if Int(icr2.text!) != nil
                {
                    two = Int(icr2.text!)!
                }
                if Int(icr3.text!) != nil
                {
                    three = Int(icr3.text!)!
                }
                
                let alertContICR = UIAlertController(title: "Value Missing",
                                                     message: "Please enter an insulin to carb ratio.",
                                                     preferredStyle: .alert)
                let stayActionICR = UIAlertAction(title: "OK", style: .default, handler: {alert -> Void in})
                
                if one <= 0 || two <= 0 || three <= 0
                {
                    alertContICR.addAction(stayActionICR)
                    present(alertContICR, animated: true, completion: nil)
                }
                else
                {
                    let oneEnd:Date = pickerEnd1.date
                    let twoStart:Date = pickerStart2.date
                    let twoEnd:Date = pickerEnd2.date
                    let threeStart:Date = pickerStart3.date
                    
                    coreData.saveEndocrineSettings(settingType: "ICR", setDate: now, value24L: 0, value24H: 0, value1L: one, value1H: 0, value2L: two, value2H: 0, value3L: three, value3H: 0, start1: am, start2: twoStart, start3: threeStart, end1: oneEnd, end2: twoEnd, end3: pm)
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
    
    func keyboardWillShow(notification: NSNotification) {
        
        if icr3.isEditing
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
            icr3.isHidden = true
        }
        else
        {
            pickerStart3.isHidden = false
            pickerEnd3.isHidden = false
            icr3.isHidden = false
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
