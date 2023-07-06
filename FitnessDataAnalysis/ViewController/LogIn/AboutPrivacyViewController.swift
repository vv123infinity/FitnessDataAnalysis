//
//  AboutPrivacyViewController.swift
//  FitnessDataAnalysis
//
//  Created by 十口V🌼 on 2023/3/18.
//

import UIKit
import HealthKit

class AboutPrivacyViewController: UIViewController {
    var window: UIWindow?
    @IBOutlet weak var synHealthDataButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        self.navigationItem.backBarButtonItem = backItem
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        UserPreferenceSetting.setUpUserPreference()
        
    }
    
    
    

    
}



