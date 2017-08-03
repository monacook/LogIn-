//
//  FavoritesTableViewController.swift
//  Test
//
//  Created by Danielle on 1/24/17.
//  Copyright © 2017 Danielle. All rights reserved.
//

import UIKit
import CoreData


class FavoritesTableViewController: UITableViewController {
 
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var faveMeals = [FaveMeal]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
 
        let fetchRequest = NSFetchRequest<FaveMeal>(entityName: "FaveMeal")
        let descriptor = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [descriptor]
        
        do{
            faveMeals = try context.fetch(fetchRequest) 
        } catch {
            print("ERROR \(error)")
        }
        self.tableView.reloadData()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return faveMeals.count
    }
  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoritesCell", for: indexPath)
        let meal = faveMeals[indexPath.row]
        
        if (meal.title != nil) {
  
            cell.textLabel?.text = meal.title
            cell.detailTextLabel?.text = String(meal.carbs) + " carbs"
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      
        if segue.identifier == "populateToFDHomeVC"
        {
            let selectedMeal = segue.destination as! FDHomeViewController
            let row = tableView.indexPathForSelectedRow?.row
            let meal = faveMeals[row!]
            selectedMeal.foodWasSelected(itemDesc: meal.title!, carbohydrates: meal.carbs, quantity: meal.size, units: meal.metric!)
        }
    }

}
