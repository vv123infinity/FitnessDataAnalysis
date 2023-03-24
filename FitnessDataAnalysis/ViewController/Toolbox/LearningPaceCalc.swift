//
//  LearningPaceCalc.swift
//  FitnessDataAnalysis
//
//  Created by 十口V🌼 on 2023/2/27.
//

import UIKit

class LearningPaceCalc: UIViewController {

    @IBOutlet weak var headerUIView: UIView!
    @IBOutlet weak var contentUIView: UIView!
    @IBOutlet var titleCollection: [GradientLabel]!
    @IBOutlet var contentCollection: [UITextView]!
    /// 其实是完成的button
    @IBOutlet var convertButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.uiSettings()
        // Do any additional setup after loading the view.
        
    }
    
    
    func setUpFontSmiley(){
        if UserDefaults.standard.bool(forKey: "useSmiley") {
            DispatchQueue.main.async {
                let font = SmileyFontSize.getNormal()
                let attributes = [NSAttributedString.Key.font: font]
                let attributedQuote = NSAttributedString(string: (self.convertButton.titleLabel?.text)!, attributes: attributes)
                self.convertButton.setAttributedTitle(attributedQuote, for: .normal)
                self.convertButton.setAttributedTitle(attributedQuote, for: .highlighted)
                
                
                for contentTxt in self.contentCollection {
                    contentTxt.font = SmileyFontSize.getNormal()
                }
                
                for ll in self.titleCollection {
                    ll.font = SmileyFontSize.getBigger()
                }
            }
        }
        
    }
    
    
    
    func uiSettings() {
        self.view.backgroundColor = ColorUtil.getBackgroundColorStyle1()
        self.headerUIView.backgroundColor = ColorUtil.getBackgroundColorStyle1()
        self.contentUIView.backgroundColor = ColorUtil.getBackgroundColorStyle1()
        titleForGrad()
        self.setUpFontSmiley()
    }
    
    func titleForGrad() {

        for titleLabel in titleCollection {
            titleLabel.gradientColors = ColorUtil.getGradTextStyle1().map{
                return $0.cgColor
            }
        }
        self.titleCollection[0].text = NSLocalizedString("learnPaceCalcSubTitle1", comment: "")
        self.contentCollection[0].text = NSLocalizedString("learnPaceCalcSubTitle1Content", comment: "")
    }
    
    @IBAction func closeBtnPressed(_ sender: UIButton){
        self.dismiss(animated: true)
    }

}
