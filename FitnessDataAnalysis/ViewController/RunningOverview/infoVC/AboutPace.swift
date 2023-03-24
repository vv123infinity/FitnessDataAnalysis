//
//  AboutPace.swift
//  FitnessDataAnalysis
//
//  Created by 十口V🌼 on 2023/3/1.
//

import UIKit

class AboutPace: UIViewController {

    @IBOutlet weak var headerUIView: UIView!
    @IBOutlet weak var contentUIView: UIView!
    @IBOutlet var titleCollection: [GradientLabel]!
    @IBOutlet var contentCollection: [UITextView]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.uiSettings()
        // Do any additional setup after loading the view.
    }
    

    
    func uiSettings() {
        self.view.backgroundColor = ColorUtil.getBackgroundColorStyle1()
        self.headerUIView.backgroundColor = ColorUtil.getBackgroundColorStyle1()
        self.contentUIView.backgroundColor = ColorUtil.getBackgroundColorStyle1()
        titleForGrad()
    }
    
    func titleForGrad() {

        for titleLabel in titleCollection {
            titleLabel.gradientColors = ColorUtil.getGradTextStyle1().map{
                return $0.cgColor
            }
        }
        /**
         "aboutPaceTitle" = "About Pace";
         "aboutPaceContent" = "The vertical coordinates of this scatter plot are the rationing speed and the time units are minutes (with decimal parts). For example, 4.4 min/km is equivalent to 4 min (0.4 × 60 = 24) sec/km.";
         */
        self.titleCollection[0].text = NSLocalizedString("aboutPaceTitle", comment: "")
        self.contentCollection[0].text = NSLocalizedString("aboutPaceContent", comment: "")
    }
    
    @IBAction func closeBtnPressed(_ sender: UIButton){
        self.dismiss(animated: true)
    }

}
