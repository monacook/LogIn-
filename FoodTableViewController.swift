//
//  FoodTableViewController.swift
//  Test
//
//  Created by Danielle on 1/27/17.
//  Copyright © 2017 Danielle. All rights reserved.
//

import UIKit

class FoodTableViewController: UITableViewController {
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var rows: [String]! = nil
    
    func startActInd()
    {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    func stopActInd()
    {
        activityIndicator.stopAnimating()
    }
    
    @IBOutlet weak var searchString: UILabel!
    
    var stringPassed: String!
    
    var arrayFoodItems = [String]()
    var arrayCarbContent = [Double]()
    var arrayServingQty = [Double]()
    var arrayServingUnit = [String]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        searchString.text = stringPassed.capitalized
        stringPassed = stringPassed.replacingOccurrences(of: " ", with: "")

        self.startActInd()
        
        let requestURL = URL(string: "https://api.nutritionix.com/v1_1/search/\(stringPassed!)?results=0%3A15&fields=item_name%2Cbrand_name%2Cnf_total_carbohydrate&appId=2e1ad004&appKey=744f09ee806ceea50112f27ef99440d3")!
        
        var urlRequest = URLRequest(url: requestURL)
        urlRequest.httpMethod = "GET"
        
        let session = URLSession.shared
      
        let task = session.dataTask(with: urlRequest)
        {
            (data, response, error) -> Void in
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any]
                
                if let hits = json["hits"] as? Array<AnyObject>
                {
                    for hit in hits
                    {
                        if let fields = hit["fields"] as? Dictionary<String, AnyObject>
                        {
                            var itemName = fields["item_name"] as? String ?? "unknown"
                            let totalCarbs = fields["nf_total_carbohydrate"] as? Double ?? 0.0
                            let servingSizeQty = fields["nf_serving_size_qty"] as? Double ?? 1.0
                            let servingUnit = fields["nf_serving_size_unit"] as? String ?? "serving"
                            let brand = fields["brand_name"] as? String ?? "ZZ"
                            
                            itemName = itemName + " " + brand
                            
                            self.arrayFoodItems.append(itemName)
                            self.arrayCarbContent.append(totalCarbs)
                            self.arrayServingQty.append(servingSizeQty)
                            self.arrayServingUnit.append(servingUnit)
                        }
                    }
                }
                
                DispatchQueue.main.async(execute: { () -> Void in
                    self.tableView.reloadData()
                    self.stopActInd()
                })
                
            } catch {
                print("JSON error: \(error)")
            }
        }
        task.resume()
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
        return arrayFoodItems.count
    }
    
    
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
  
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoodCell", for: indexPath)
        cell.textLabel?.text = arrayFoodItems[indexPath.row]
        cell.detailTextLabel?.text = String(arrayCarbContent[indexPath.row]) + " carbs"
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let selectedItem = segue.destination as! FDHomeViewController
        
        if segue.identifier == "populateToFDHomeVC"
        {
           let row = tableView.indexPathForSelectedRow?.row
            selectedItem.foodWasSelected(itemDesc: arrayFoodItems[row!], carbohydrates: arrayCarbContent[row!], quantity: arrayServingQty[row!], units: arrayServingUnit[row!])
        }
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
