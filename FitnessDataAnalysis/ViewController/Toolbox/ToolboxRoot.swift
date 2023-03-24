//
//  ToolboxRoot.swift
//  FitnessDataAnalysis
//
//  Created by 十口V🌼 on 2023/2/27.
//

import UIKit

class ToolboxRoot: UIViewController {

    
    @IBOutlet weak var sView: UIView!
    
    @IBOutlet weak var paceCalcUIButton: UIButton!
    @IBOutlet weak var AILabButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backItem = UIBarButtonItem()
        backItem.title = ""
        self.navigationItem.backBarButtonItem = backItem // This will
        // Do any additional setup after loading the view.
        initUISetting()
        
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setUpFontSmiley()
    }
    
    
    func initUISetting() {
        // 1. set up navigation
        self.setUpNav()
        // 2. set up background color
        self.setUpBKcolor()
        self.setUpFontSmiley()
    }
    
    
    func setUpFontSmiley(){
        if UserDefaults.standard.bool(forKey: "useSmiley") {
            paceCalcUIButton.titleLabel?.font = SmileyFontSize.getNormal()
            AILabButton.titleLabel?.font = SmileyFontSize.getNormal()
            
            let font = SmileyFontSize.getNormal()
            let attributes = [NSAttributedString.Key.font: font]
            
            
            let paceNSAStr = NSAttributedString(string: (self.paceCalcUIButton.titleLabel?.text)!, attributes: attributes)
            
            self.paceCalcUIButton.setAttributedTitle(paceNSAStr, for: .normal)
            self.paceCalcUIButton.setAttributedTitle(paceNSAStr, for: .highlighted)
            
            
            let AINSAStr = NSAttributedString(string: (self.AILabButton.titleLabel?.text)!, attributes: attributes)
            
            self.AILabButton.setAttributedTitle(AINSAStr, for: .normal)
            self.AILabButton.setAttributedTitle(AINSAStr, for: .highlighted)
            
            
            
        }
        
    }
    
    func setUpNav(){
        
        self.navigationController?.navigationBar.tintColor = ColorUtil.getBarBtnColor()
        self.navigationController?.navigationBar.backItem?.title = ""
        
    }
    
    func setUpBKcolor(){
        self.view.backgroundColor = ColorUtil.getBackgroundColorStyle1()
        self.sView.backgroundColor = ColorUtil.getBackgroundColorStyle1()
    }

    
}
