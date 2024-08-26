//
//  ViewController.swift
//  Measurement
//
//  Created by Webappclouds on 22/08/24.
//

import UIKit
import ARKit

class ViewController: UIViewController, MeasurementViewControllerDelegate {
    
    @IBOutlet weak var label:UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
    }

    @IBAction func compose(_ sender: UIBarButtonItem) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "MeasurementViewController") as! MeasurementViewController
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func getArea(area: Float) {
        
        let measurement = Measurement(value: Double(area), unit: UnitArea.squareMeters)
        
        let formatter = MeasurementFormatter()
        formatter.locale = .current
        
        label.text = "Enclosed area between points: \(formatter.string(from: measurement))"
    }
}

