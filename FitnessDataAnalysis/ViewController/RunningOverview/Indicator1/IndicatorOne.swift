//
//  IndicatorOne.swift
//  FitnessDataAnalysis
//
//  Created by Infinity vv123 on 2023/3/13.
//

import UIKit

class IndicatorOne: UIViewController {

    /// 指标的类型
    var indicatorType: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 1. basic UI
        
        // 2. indicator
        self.configIndicatorType()
    }
    
    
    func configIndicatorType(){
//        UserDefaults.standard.set(0, forKey: "IndicatorOneType")
        switch UserDefaults.standard.integer(forKey: "IndicatorOneType") {
        case 0:
            self.title = NSLocalizedString("indicator_1_pace", comment: "")
        case 1:
            self.title = NSLocalizedString("indicator_1_action2", comment: "")
        default:
            self.title = "????"
        }
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
