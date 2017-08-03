//
//  ViewController.swift
//  Test
//
//  Created by Danielle on 1/24/17.
//  Copyright © 2017 Danielle. All rights reserved.
//

import UIKit
import CoreData


//Singleton
class MealBuilder {
    
    static let sharedInstance = MealBuilder()
    
    var allMealItems = [[String]]()
    
    init() {}
    
    func appendMealItem(name: String, carbs: String, quantity: String, metric: String, isAlcohol: String, alcoholContent: String, drinkType: String)
    {
        let desc:String = name
        let carb:String = carbs
        let qty:String = quantity
        let size:String = metric
        let alcohol:String = isAlcohol
        let content:String = alcoholContent
        let type:String = drinkType
        
        let mealItem = [desc, carb, qty, size, alcohol, content, type]
        
        allMealItems.append(mealItem)
    }
    
    func clearBuilder() {
        
        allMealItems.removeAll()
    }
}


class FDHomeViewController: UIViewController, BarcodeDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.hideKeyboard()
        
        foodSearch.text = food
        foodCarbs.text = String(carbos)
        foodQty.text = String(qty)
        
        foodSizePicker.dataSource = self
        foodSizePicker.delegate = self
        self.foodSizePicker.selectRow(4, inComponent: 0, animated: false)
        
        alcoholPicker.dataSource = self
        alcoholPicker.delegate = self
        
        carbsLabel.isHidden = true
        measureLabel.isHidden = true
        alcholLabel.isHidden = true
        
        UIApplication.shared.keyWindow!.bringSubview(toFront: measureLabel)
   
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        PersistUserEntry.sharedInstance.clearUserEntry()
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var faveMeals = [NSManagedObject]()
    var alcoholDrink:String = ""

    @IBOutlet weak var foodSearch: UITextField!
    @IBOutlet weak var foodCarbs: UITextField!
    @IBOutlet weak var foodQty: UITextField!
    @IBOutlet weak var foodSizePicker: UIPickerView!
    @IBOutlet weak var alcoholPicker: UIPickerView!
    @IBOutlet weak var carbsLabel: UILabel!
    @IBOutlet weak var measureLabel: UILabel!
    @IBOutlet weak var alcholLabel: UILabel!
    
    var food: String = ""
    var carbos: Double = 0.0
    var qty: Double = 0.0
    var size: String = "servings"
  
    var foodPickerData = ["servings", "ounces", "grams", "tsp", "TBS", "cups", "pints", "slices", "pieces"]
    var alcoholPickerData = ["no alcohol", "beer", "light beer", "red wine", "white wine", "mixed drink", "mixed drink - sugar free", "hard cider", "spirits/liquor"]
    
    @IBAction func carbsEditingChanged(_textField: UITextField){}
    
    @IBAction func qtyEditingChanged(_textField: UITextField){}
    
    
    @IBAction func toFavorites(_ sender: UIButton) {
        
        faveMeals = fetchFaveMeals()
        
        if faveMeals.isEmpty {
            seedFaveMeal()
        }
    }
    
    @IBAction func carbsTouchDown(_ sender: Any) {
        
        carbsLabel.isHidden = false
    }
  
    @IBAction func carbsTouchUp(_ sender: Any) {
        
        carbsLabel.isHidden = true
    }
    
    @IBAction func measureTouchDown(_ sender: Any) {
        
        measureLabel.isHidden = false
    }
    
    @IBAction func measureTouchUp(_ sender: Any) {
        
        measureLabel.isHidden = true
    }
    
    @IBAction func alcoholTouchDown(_ sender: Any) {
        
        alcholLabel.isHidden = false
    }
    
    @IBAction func alcoholTouchUp(_ sender: Any) {
        
        alcholLabel.isHidden = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toFoodSearchList"
        {
            let trimmedString = self.foodSearch.text!.trimmingCharacters(in: .whitespaces)
            let viewCont = segue.destination as! UINavigationController
            let addFoodTableView = viewCont.topViewController as! FoodTableViewController
            addFoodTableView.stringPassed = trimmedString
        }
        else if segue.identifier == "toBarcodeScan"
        {
            let bcViewCont: BarcodeViewController = segue.destination as! BarcodeViewController
            bcViewCont.delegate = self
        }
        else if segue.identifier == "reviewLogSegue"
        {
            //do nothing
        }
        else if segue.identifier == "cancelAddMeals"
        {
           MealBuilder.sharedInstance.clearBuilder()
        }
    }
    
    
    @IBAction func alertMoreOrContinue(_ sender: Any)
    {
        let name = self.foodSearch.text ?? self.food
        let carbs = self.foodCarbs.text ?? String(self.carbos)
        let qty = self.foodQty.text ?? String(self.qty)
        let size = self.size
        var isAlcohol = "false"
        let alcContent = "0.0"
        var drinkType = "no alcohol"
 
        if (alcoholDrink.isEmpty) || (alcoholDrink == "no alcohol")
        {
            //do nothing
        }
        else
        {
            isAlcohol = "true"
            drinkType = alcoholDrink
        }
        
        //Food Description Missing
        let alertContDesc = UIAlertController(title: "Food Description Missing",
                                             message: "Please enter a food description.",
                                             preferredStyle: .alert)
        let segueActionDesc = UIAlertAction(title: "OK", style: .default, handler: {alert -> Void in})
        
        if name == ""
        {
            alertContDesc.addAction(segueActionDesc)
            present(alertContDesc, animated: true, completion: nil)
        }
        
        // Carbs missing
        var carbos:Double = 0.0
        
        if Double(carbs) != nil
        {
            carbos = Double(carbs)!
        }
        
        let alertContCarbs = UIAlertController(title: "Carbs Missing",
                                              message: "Please enter carbohydrates.",
                                              preferredStyle: .alert)
        let stayActionCarbs = UIAlertAction(title: "UPDATE CARBS", style: .default, handler: {alert -> Void in})
        let segueActionCarbs = UIAlertAction(title: "CARBS OK", style: .default, handler: {alert -> Void in
        
            self.checkQty(desc: name, carbos: carbs, quant: qty, measure: size, alc: isAlcohol, alcCont: alcContent, typeDrink: drinkType)
            self.segue(desc: name, carbos: carbs, quant: qty, measure: size, alc: isAlcohol, alcCont: alcContent, typeDrink: drinkType)
        })
        
        if carbos <= 0.0
        {
            alertContCarbs.addAction(stayActionCarbs)
            alertContCarbs.addAction(segueActionCarbs)
            present(alertContCarbs, animated: true, completion: nil)
        }
        
        self.checkQty(desc: name, carbos: carbs, quant: qty, measure: size, alc: isAlcohol, alcCont: alcContent, typeDrink: drinkType)
        self.segue(desc: name, carbos: carbs, quant: qty, measure: size, alc: isAlcohol, alcCont: alcContent, typeDrink: drinkType)
    }
    
    private func checkQty(desc: String, carbos: String, quant: String, measure: String, alc: String, alcCont: String, typeDrink: String)
    {
        var qty:Double = 0.0
        
        if Double(quant) != nil
        {
            qty = Double(quant)!
        }
     
        let alertContQty = UIAlertController(title: "Quantity Missing",
                                             message: "Please enter quantity of food.",
                                             preferredStyle: .alert)
        let stayActionQty = UIAlertAction(title: "UPDATE QTY", style: .default, handler: {alert -> Void in})
        let segueActionQty = UIAlertAction(title: "QTY OK", style: .default, handler: {alert -> Void in
        
            self.segue(desc: desc, carbos: carbos, quant: quant, measure: measure, alc: alc, alcCont: alcCont, typeDrink: typeDrink)
        })
        
        if qty <= 0.0
        {
            alertContQty.addAction(stayActionQty)
            alertContQty.addAction(segueActionQty)
            present(alertContQty, animated: true, completion: nil)
        }
    }
    
    private func segue(desc: String, carbos: String, quant: String, measure: String, alc: String, alcCont: String, typeDrink: String){
        
        let alertCont = UIAlertController(title: " Are you finished adding food items to your meal?",
                                          message: "\nClick 'YES' to enter glucose. \n\nClick 'NO' to add more items\n to this meal",
                                          preferredStyle: .alert)
        
        let segueAction = UIAlertAction(title: "YES", style: .default, handler: {alert -> Void in
            
            MealBuilder.sharedInstance.appendMealItem(name: desc, carbs: carbos, quantity: quant, metric: measure, isAlcohol: alc, alcoholContent: alcCont, drinkType: typeDrink)
            self.performSegue(withIdentifier: "reviewLogSegue", sender: self)
        })
        
        let moreFoodAction = UIAlertAction(title: "NO", style: .default, handler: {alert -> Void in
            
            MealBuilder.sharedInstance.appendMealItem(name: desc, carbs: carbos, quantity: quant, metric: measure, isAlcohol: alc, alcoholContent: alcCont, drinkType: typeDrink)
            
            self.foodSearch.text = ""
            self.foodCarbs.text = "0.0"
            self.foodQty.text = "0.0"
            self.alcoholPicker.selectRow(0, inComponent: 0, animated: true)
        })
        
        alertCont.addAction(moreFoodAction)
        alertCont.addAction(segueAction)
        present(alertCont, animated: true, completion: nil)
    }
    
    
    private func seedFaveMeal() {
        
        let meals = [(name: "My salad", carbs: 15.0, qty: 12.0, size: "ounces")]
        
        for meal in meals {
            let mealDesc = NSEntityDescription.insertNewObject(forEntityName: "FaveMeal", into: context) as! FaveMeal
            mealDesc.title = meal.name
            mealDesc.carbs = meal.carbs
            mealDesc.size = meal.qty
            mealDesc.metric = meal.size
            
            do
            {
                faveMeals.append(mealDesc)
                try context.save()
            } catch {
                print("Error: \(error)")
            }
        }
    }
    
    private func fetchFaveMeals() -> Array<FaveMeal> {
        
        let fetchRequest = NSFetchRequest<FaveMeal>(entityName: "FaveMeal")
        let descriptor = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [descriptor]
        
        do{
            faveMeals = try context.fetch(fetchRequest)
        } catch {
            print("ERROR \(error)")
        }
        
        return faveMeals as! Array<FaveMeal>
    }
    
    func foodWasSelected(itemDesc: String!, carbohydrates: Double!, quantity: Double!, units: String!) {
        
        if let desc = itemDesc,
            let carbs = carbohydrates,
            let quant = quantity,
            let metric = units
        {
            food = desc
            carbos = carbs
            qty = quant
            size = metric
        } else {
            food = "Error"
            carbos = 0.0
            qty = 0.0
            size = "servings"
        }
    }
    
    func barcodeWasRead(itemDesc: String, carbohydrates: Double, quantity: Double, units: String) {
       
        foodSearch.text = itemDesc
        foodCarbs.text = String(carbohydrates)
        foodQty.text = String(quantity)
    }

    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView == foodSizePicker
        {
            return foodPickerData.count
        }
        else
        {
            return alcoholPickerData.count
        }
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == foodSizePicker
        {
            return foodPickerData[row]
        }
        else
        {
            return alcoholPickerData[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let pickerString = UILabel()
        
        if pickerView == foodSizePicker
        {
            pickerString.text = foodPickerData[row]
        }
        else
        {
            pickerString.text = alcoholPickerData[row]
        }
        
        pickerString.font = UIFont(name: "AvenirNext-Medium", size: 17.0)
        pickerString.textAlignment = NSTextAlignment.center
        return pickerString
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == foodSizePicker
        {
            let fSize = foodPickerData[row]
            
            if fSize != ""
            {
                self.size = fSize
            }
            else
            {
                self.size = "servings"
            }
        }
        else
        {
            alcoholDrink = alcoholPickerData[row]
            
            if alcoholDrink == "no alcohol"
            {
                foodSearch.text = ""
            }
            else
            {
                foodSearch.text = alcoholDrink
            }
        }
        
        if pickerView == alcoholPicker
        {
            alcoholDrink = alcoholPickerData[row]
            
            self.foodSizePicker.selectRow(1, inComponent: 0, animated: true)
            
            switch alcoholDrink {
                
            case "no alcohol":
                foodCarbs.text = "0.0"
                foodQty.text = "0.0"
                self.foodSizePicker.selectRow(4, inComponent: 0, animated: true)
                
            case "beer":
                foodCarbs.text = "13"
                foodQty.text = "12"
                
            case "light beer":
                foodCarbs.text = "6"
                foodQty.text = "12"
                
            case "red wine":
                foodCarbs.text = "4"
                foodQty.text = "5"
                
            case "white wine":
                foodCarbs.text = "4"
                foodQty.text = "5"
                
            case "mixed drink":
                foodCarbs.text = "18"
                foodQty.text = "8"
                
            case "mixed drink - sugar free":
                foodCarbs.text = "0"
                foodQty.text = "8"
                
            case "hard cider":
                foodCarbs.text = "18"
                foodQty.text = "12"
                
            case "spirits/liquor":
                foodCarbs.text = "0"
                foodQty.text = "1.5"
                
            default:
                foodCarbs.text = "0"
                foodQty.text = "0"
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

