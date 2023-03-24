//
//  ModifyTargetRunVol.swift
//  FitnessDataAnalysis
//
//  Created by 十口V🌼 on 2023/3/20.
//

import UIKit

class ModifyTargetRunVol: UIViewController {

    
    @IBOutlet weak var targetTextField: UITextField!
    
    var distanceToModify: Double = 0.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.targetTextField.keyboardType = .default
        
    }
    

    @IBAction func finishEnter(_ sender: UITextField) {
        self.targetTextField.resignFirstResponder()
        
    }
    
    
    
    @IBAction func doneBtnPressed(_ sender: UIButton) {
        
        self.distanceToModify = Double(self.targetTextField.text!)!
        
        UserDefaults.standard.set(self.distanceToModify, forKey: "thisMonthTargetVol")
        
        self.targetTextField.resignFirstResponder()
        
        self.dismiss(animated: true)
    }
    
    
    
}
