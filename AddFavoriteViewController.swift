//
//  AddFavoriteViewController.swift
//  Test
//
//  Created by Danielle on 1/24/17.
//  Copyright © 2017 Danielle. All rights reserved.
//

import UIKit
import CoreData


class AddFavoriteViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        
        foodSize.dataSource = self
        foodSize.delegate = self
        
        qtyLabel.isHidden = true
        sizeLabel.isHidden = true
        foodQty.isHidden = true
        foodSize.isHidden = true

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBOutlet weak var foodDescription: UITextField!
    @IBOutlet weak var foodCarbs: UITextField!
    @IBOutlet weak var foodQty: UITextField!
    @IBOutlet weak var foodSize: UIPickerView!
    @IBOutlet weak var qtyLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    
    @IBAction func carbsEditingChanged(_textField: UITextField){}
    @IBAction func qtyEditingChanged(_textField: UITextField){}
    
    var pickerData = ["servings", "ounces", "grams", "tsp", "TBS", "cups", "pints"]
    var pickedFoodSize: String = "servings"
    
    @IBAction func saveToDB(_ sender: UIBarButtonItem) {
        
        coreData.saveToFaveMeals(mealTitle: foodDescription.text!, mealCarbs: Double(foodCarbs.text!)!, mealSize: 1, mealMetric: "servings")
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "FavesNavController") as! UINavigationController
        self.present(controller, animated: true, completion: nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let pickerString = UILabel()
        pickerString.text = pickerData[row]
        pickerString.font = UIFont(name: "AvenirNext-Regular", size: 20.0)
        pickerString.textAlignment = NSTextAlignment.center
        return pickerString
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        self.pickedFoodSize = pickerData[row]
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
