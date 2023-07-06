//
//  DaysDetails.swift
//  FitnessDataAnalysis
//
//  Created by 十口V🌼 on 2023/4/9.
//

import UIKit

class DaysDetails: UIViewController {

    var dateInStr: String!
    var infoStr: String!
    var emoji: String!
    
    
    @IBOutlet weak var inputDateLabel: GradientLabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var emojiLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.inputDateLabel.text = dateInStr
        self.inputDateLabel.gradientColors = ColorUtil.getGradTextStyle1().map{$0.cgColor}
        self.infoLabel.text = infoStr
        self.emojiLabel.text = emoji
        
        
        if UserDefaults.standard.bool(forKey: "useSmiley") {
            self.inputDateLabel.font = SmileyFontSize.getInSize(38)
            self.infoLabel.font = SmileyFontSize.getNormal()
            
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
