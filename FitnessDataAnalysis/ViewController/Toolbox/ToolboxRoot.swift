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
        DispatchQueue.main.async {
            self.setUpFontSmiley()
        }
        
        // 1. set up navigation
        self.setUpNav()
        // 2. set up background color
        self.setUpBKcolor()

    }
    
    
    func setUpFontSmiley(){
        if UserDefaults.standard.bool(forKey: "useSmiley") {
            paceCalcUIButton.titleLabel?.font = SmileyFontSize.getNormal()
            AILabButton.titleLabel?.font = SmileyFontSize.getNormal()
            // 标题
            let font = SmileyFontSize.getNormal()
            let attributes = [NSAttributedString.Key.font: font]
            
            // 副标题
            let footnoteFont = SmileyFontSize.getFootnote()
            let footnoteAtt = [NSAttributedString.Key.font: footnoteFont]
            
            // ------------
            
            let paceNSAStr = NSAttributedString(string: (self.paceCalcUIButton.titleLabel?.text)!, attributes: attributes)
            self.paceCalcUIButton.setAttributedTitle(paceNSAStr, for: .normal)
            self.paceCalcUIButton.setAttributedTitle(paceNSAStr, for: .highlighted)
            //
            
            let subtitle1Att = NSAttributedString(string: (self.paceCalcUIButton.subtitleLabel?.text)!, attributes: footnoteAtt)
            let attStr1 = AttributedString(subtitle1Att)
//            self.paceCalcUIButton.subtitleLabel?.attributedText = subtitle1Att
            self.paceCalcUIButton.configuration?.attributedSubtitle = attStr1
            // ------------
            
            let AINSAStr = NSAttributedString(string: (self.AILabButton.titleLabel?.text)!, attributes: attributes)
            
            self.AILabButton.setAttributedTitle(AINSAStr, for: .normal)
            self.AILabButton.setAttributedTitle(AINSAStr, for: .highlighted)

            let subtitle2Att = NSAttributedString(string: (self.AILabButton.subtitleLabel?.text)!, attributes: footnoteAtt)
            let attStr2 = AttributedString(subtitle2Att)
            self.AILabButton.configuration?.attributedSubtitle = attStr2
            
            
            
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

    
    
    @IBAction func AILabBtnPressed(_ sender: Any) {
        // TODO: 判断加上 否 !
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "AILabFunctions")
        self.navigationController?.pushViewController(vc, animated: true)
        
        
    }
    
}
