//
//  AILabGuide.swift
//  FitnessDataAnalysis
//
//  Created by 十口V🌼 on 2023/3/31.
//

import UIKit

class AILabGuide: UIViewController {

    /// 指导类型
    var typeID: Int = 0

    
    
    @IBOutlet weak var hintTitleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        switch typeID {
        case 0:
            self.hintTitleLabel.text = "深蹲指导"
        default:
            self.hintTitleLabel.text = "通用指导"
            break
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
    @IBAction func nextBtnPressed(_ sender: Any) {
        self.dismiss(animated: true)
        switch typeID {
        case 0:
            UserDefaults.standard.set(false, forKey: "noSquatHint")
        default:
            break
        }
        
    }
    
    
    
    @IBAction func noHintPressed(_ sender: Any) {
        self.dismiss(animated: true)
        switch typeID {
        case 0:
            UserDefaults.standard.set(true, forKey: "noSquatHint")
        default:
            break
        }
        
    }
    
    
    
    
}
