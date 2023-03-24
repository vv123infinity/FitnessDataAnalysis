//
//  Calories.swift
//  FitnessDataAnalysis
//
//  Created by Infinity vv123 on 2023/3/22.
//

import UIKit

class Calories: UIViewController {

    @IBOutlet weak var useMode: UIButton!
    
    @IBOutlet weak var unuseMode: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func usePressed(_ sender: UIButton) {
        self.unuseMode.layer.borderWidth = 0
//        self.unuseMode.layer.shadowOpacity = 0
        
        UserDefaults.standard.set(true, forKey: "careActiveEnergy")
        self.useMode.layer.borderWidth = 1.5
        let bc = ColorUtil.dynamicColor(dark: UIColor.white, light: UIColor.black)
        self.useMode.layer.borderColor = bc.cgColor
        self.useMode.layer.cornerRadius = 20

//        self.useMode.layer.shadowOpacity = 0.6
//        self.useMode.layer.shadowColor = ColorUtil.dynamicColor(dark: UIColor.white, light: UIColor.black).cgColor
//        self.useMode.layer.shadowRadius = 2
//
//        self.useMode.layer.shadowOffset = .zero
    }
    
    @IBAction func unusePressed(_ sender: UIButton) {
        self.useMode.layer.borderWidth = 0
//        self.useMode.layer.shadowOpacity = 0
        
        UserDefaults.standard.set(false, forKey: "careActiveEnergy")
        self.unuseMode.layer.borderWidth = 1.5
        let bc = ColorUtil.dynamicColor(dark: UIColor.white, light: UIColor.black)
        self.unuseMode.layer.borderColor = bc.cgColor
        self.unuseMode.layer.cornerRadius = 20
        
//        self.unuseMode.layer.shadowOpacity = 0.6
//        self.unuseMode.layer.shadowColor = ColorUtil.dynamicColor(dark: UIColor.white, light: UIColor.black).cgColor
//        self.unuseMode.layer.shadowRadius = 2
//
//        self.unuseMode.layer.shadowOffset = .zero

    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
     人体活动能量代谢是指人体活动所引起的营养物质氧化产生能量的过程，其消耗的能量称为活动能量消耗。
     
    */

}
