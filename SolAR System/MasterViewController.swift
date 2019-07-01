//
//  MasterViewController.swift
//  SolAR System
//
//  Created by Andika on 29/06/19.
//  Copyright © 2019 Andika. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {
    
    var detailViewController: DetailViewController? = nil
    var arrayDict = NSMutableArray()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationController?.navigationBar.prefersLargeTitles = true
        
        self.getJson()

        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let array = ((arrayDict[indexPath.row]) as AnyObject)
                let data = [array.value(forKey: "image") as! String, array.value(forKey: "name") as! String, array.value(forKey: "about") as! String, array.value(forKey: "life") as! Bool, array.value(forKey: "temprature") as! Int] as [Any]
                
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = data
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    // MARK: - JSON
    func getJson() {
        let path: NSString = Bundle.main.path(forResource: "planets",  ofType: "json")! as NSString
        let data: NSData = try! NSData(contentsOfFile: path as String,  options: NSData.ReadingOptions.dataReadingMapped)
        self.parseJson(data: data)
    }
    
    func parseJson(data :NSData) {
        let dict: NSDictionary! = (try! JSONSerialization.jsonObject (with: data as Data, options: JSONSerialization.ReadingOptions.mutableContainers)) as? NSDictionary
        for i in 0..<(dict.value(forKey: "solar_system") as! NSArray).count {
            arrayDict.add((dict.value(forKey: "solar_system") as! NSArray) .object(at: i))
        }
        tableView.reloadData()
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayDict.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PlanetCustomCell
        
        let strImage = ((arrayDict[indexPath.row]) as AnyObject).value(forKey: "image") as? String
        let strTitle = ((arrayDict[indexPath.row]) as AnyObject).value(forKey: "name") as? String
        let strDescription = ((arrayDict[indexPath.row] as AnyObject).value(forKey: "about")) as? String

        cell.planetImage!.image = UIImage(named: strImage!)
        cell.planetName!.text = strTitle
        cell.planetDescription!.text = strDescription
        return cell
    }

}

class PlanetCustomCell: UITableViewCell {
    @IBOutlet weak var planetImage: UIImageView!
    @IBOutlet weak var planetName: UILabel!
    @IBOutlet weak var planetDescription: UILabel!
}

