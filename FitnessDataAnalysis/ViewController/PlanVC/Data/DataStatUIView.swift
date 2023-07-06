//
//  DataStatUIView.swift
//  FitnessDataAnalysis
//
//  Created by 十口V🌼 on 2023/3/26.
//

import UIKit
import HealthKit

class DataStatUIView: UIView {
    /// 第一个chart的显示更多指标
    @IBOutlet var myButtons: [UIButton]!
    
 
    

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        if UserDefaults.standard.bool(forKey: "useSmiley") {
            let font = SmileyFontSize.getNormal()
            let attributes = [NSAttributedString.Key.font: font]
            
            for btn in self.myButtons{
                let str = NSAttributedString(string: (btn.titleLabel?.text)!, attributes: attributes)
                btn.setAttributedTitle(str, for: .normal)
                btn.setAttributedTitle(str, for: .highlighted)
                
            }
        }
        
    }

    

    
    
    
}
