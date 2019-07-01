//
//  DetailViewController.swift
//  SolAR System
//
//  Created by Andika on 29/06/19.
//  Copyright © 2019 Andika. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var planetImage: UIImageView!
    @IBOutlet weak var lifeLabel: UILabel!
    @IBOutlet weak var tempratureLabel: UILabel!
    
    func configureView() {
        // Update the user interface for the detail item.\
        navigationItem.largeTitleDisplayMode = .never
        
        if let detail = detailItem {
            if let label = detailDescriptionLabel {
                planetImage.image = UIImage(named: (detail[0] as? String)!)
                self.title = detail[1] as? String
                label.text = detail[2] as? String
                label.sizeToFit()
                
                if (detail[3] as? Bool == true) {
                    lifeLabel.textColor = .green
                    lifeLabel.text = "Intelegent Life"
                } else {
                    lifeLabel.textColor = .red
                    lifeLabel.text = "No Life has been detected."
                }
                
                let temp = (detail[4] as! Int)
                tempratureLabel.text = String(temp) + "°C"
                if (temp < 10) {
                    tempratureLabel.textColor = .blue
                } else if (temp > 10 && temp < 30) {
                    tempratureLabel.textColor = .green
                } else if (temp > 30) {
                    tempratureLabel.textColor = .red
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }
    
    var detailItem: [Any]? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "playAR" {
            let controller = segue.destination as! ARSceneViewController
            if let detail = detailItem {
                controller.planetName = (detail[0] as! String)
            }
        }
    }
    
    
}

