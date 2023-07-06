//
//  YearlyStat.swift
//  FitnessDataAnalysis
//
//  Created by 十口V🌼 on 2023/3/19.
//

import UIKit

class YearlyStat: UIViewController {

    @IBOutlet var tempTxtView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if UserDefaults.standard.bool(forKey: "useSmiley") {
            self.tempTxtView.font = SmileyFontSize.getNormal()
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
