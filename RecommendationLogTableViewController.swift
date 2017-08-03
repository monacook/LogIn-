//
//  RecommendationLogTableViewController.swift
//  Test
//
//  Created by Danielle on 4/4/17.
//  Copyright © 2017 Danielle. All rights reserved.
//

import UIKit
import CoreData


class RecommendationsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var line1: UILabel!
    @IBOutlet weak var line2: UILabel!
    @IBOutlet weak var foodPic: UIImageView!
}

class RecommendationLogTableViewController: UITableViewController {

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var recommendations = [InsulinPlan]()
    var exerciseEvent = [ExercisePlan]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let fetch = NSFetchRequest<InsulinPlan>(entityName: "InsulinPlan")
        let descriptor = NSSortDescriptor(key: "timeStamp", ascending: false)
        fetch.sortDescriptors = [descriptor]
        
        var unSortedRecs = [InsulinPlan]()
        
        do
        {
            unSortedRecs = try context.fetch(fetch)
        }
        catch
        {
            print("Error: \(error)")
        }
 
        for unSortedRec in unSortedRecs
        {
            if unSortedRec.timeStamp != nil
            {
                recommendations.append(unSortedRec)
            }
            else { //do nothing 
            }
        }
        
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
       return recommendations.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "recommendationCell", for: indexPath) as! RecommendationsTableViewCell
        
        let plan = recommendations[indexPath.row]
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        var stringDate:String = ""
        
        stringDate = dateFormatter.string(from: plan.timeStamp! as Date)
        cell.timeStamp?.text = stringDate
        let delIns = String(plan.deliveredInsulin)
   
        if plan.hasMealItems?.foodName != ""
        {
            let cCarbs = String(format: "%.1f", plan.carbsConsumed)
            let fImageData:NSData? = plan.foodPhoto!
            let fImage = UIImage(data: fImageData! as Data, scale: 1.0)
            
            cell.line1?.text = "\(cCarbs) g carbs"
            cell.line2?.text = "\(delIns) U insulin"
            cell.foodPic!.image = fImage
        }
        else if plan.hasExercisePlan?.intensity != ""
        {
            let duration:Double = (plan.hasExercisePlan?.duration)!
            let sDuration = String(format: "%.0f", duration)
            let intensity:String = (plan.hasExercisePlan?.intensity)!
            let detailString = "\(sDuration) minutes"
            let cCarbs = String(plan.carbsConsumed)
            
            if intensity == "Light"
            {
                cell.foodPic!.image = #imageLiteral(resourceName: "Exercise_Light")
            }
            else if intensity == "Moderate"
            {
                cell.foodPic!.image = #imageLiteral(resourceName: "Exercise_Moderate")
            }
            else if intensity == "Vigorous"
            {
                cell.foodPic!.image = #imageLiteral(resourceName: "Exercise_Vigorous")
            }
        
            if  let dCCarbs:Double = Double(cCarbs)
            {
                if dCCarbs > 0.0
                {
                    cell.line1?.text = "\(cCarbs) g carbs"
                }
                else
                {
                    cell.line1?.text = "\(delIns) U insulin"
                }
            }
            else
            {
                cell.line1?.text = "\(delIns) U insulin"
            }
            cell.line2?.text = detailString
        }
        
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
