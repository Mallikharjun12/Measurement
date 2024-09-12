//
//  ViewController.swift
//  Measurement
//
//  Created by Webappclouds on 22/08/24.
//

import UIKit

 enum MeasurementType {
    case length
    case area
}

class ViewController: UIViewController, MeasurementViewControllerDelegate {
    
    
    let buttonTitles = ["Length on a wall","Area on a wall", "Length on a floor","Area on a floor"  ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        createButtons()
    }
    
    func createButtons() {
        var height:CGFloat = 100
        for i in 0..<buttonTitles.count {
            let btn = UIButton(type: .system)
            btn.setTitle(buttonTitles[i], for: .normal)
            btn.tag = i
            btn.addTarget(self, action: #selector(buttonTapped(sender: )), for: .touchUpInside)
            view.addSubview(btn)
            btn.frame = CGRect(x: 25, y: height, width: view.frame.width-50, height: 52)
            height += 52+16
            btn.backgroundColor = .link
            btn.tintColor = .label
            btn.layer.cornerRadius = 12
        }
    }
    
    
    @objc func buttonTapped(sender:UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "MeasurementViewController") as! MeasurementViewController
        vc.delegate = self
        if sender.tag == 1 || sender.tag == 0 {
            vc.planeDetection = .vertical
        } else {
            vc.planeDetection = .horizontal
        }
        if sender.tag == 0 || sender.tag == 2 {
            vc.type = .length
        } else {
            vc.type = .area
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func showMessage(with title: String) {
        let alert = UIAlertController(title: "", message: title, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        self.present(alert, animated: true)
    }
}

