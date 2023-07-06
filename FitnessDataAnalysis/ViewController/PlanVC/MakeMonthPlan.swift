//
//  MakeMonthPlan.swift
//  FitnessDataAnalysis
//
//  Created by 十口V🌼 on 2023/3/28.
//

import UIKit

class MakeMonthPlan: UIViewController {
    @IBOutlet weak var largeTitle: UILabel!
    

    @IBOutlet weak var textField: UITextField!

    @IBOutlet var generalSmileyButton: [UIButton]!
    @IBOutlet var targetDistanceLabel: GradientLabel!
    @IBOutlet var footnoteSmiley: [UILabel]!
    

    var curDistanceUnit: String = "10"
    var initTargetDistance: Double = 0
    var curTargetDistance: Double = 0
    var curDistanceUnitInDouble: Double = 10
    
    var inputTarget: Double!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        uiSetting()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.inputTarget = UserDefaults.standard.double(forKey: "thisMonthTargetVolInKM")
        
    }
    

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.inputTarget != UserDefaults.standard.double(forKey: "thisMonthTargetVolInKM") {
            UserDefaults.standard.set(true, forKey: "monthTargetDidChange")
        }
        
    }
    
    func uiSetting() {
        self.largeTitle.text = NSLocalizedString("runningMonthTarget", comment: "")
        
        self.setUpButtonTxtColor()
        
        self.targetDistanceLabel.gradientColors = ColorUtil.getGradBluePink().map{$0.cgColor}
        
        self.setUpFont()
        
        self.setUpInitTargetLabel()
        
        self.setUpDistanceUnitButton()
        self.footnoteSmiley[2].isHidden = true
    }
    
    /// 初始化目标跑量
    func setUpInitTargetLabel(){
        if UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit") == 0 {
            // KM

            self.initTargetDistance = UserDefaults.standard.double(forKey: "thisMonthTargetVolInKM")
            self.targetDistanceLabel.text = String(format: "%.0f", initTargetDistance)
            self.footnoteSmiley[0].text = NSLocalizedString("monTargetUnitHintInKM", comment: "")
//            UserDefaults.standard.set(distanceToModify, forKey: "thisMonthTargetVolInKM")
            
            // KM -> Mile
//            UserDefaults.standard.set((distanceToModify*1000)*PaceCalculatorMethods.ConvertMeterToPaceunit.toMile.rawValue, forKey: "thisMonthTargetVolInMile")
            
        }
        else if UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit") == 1 {

            self.initTargetDistance = UserDefaults.standard.double(forKey: "thisMonthTargetVolInMile")
            self.targetDistanceLabel.text = String(format: "%.0f", initTargetDistance)
            self.footnoteSmiley[0].text = NSLocalizedString("monTargetUnitHintInMile", comment: "")
//            UserDefaults.standard.set(distanceToModify, forKey: "thisMonthTargetVolInMile")
            // Mile -> KM
//            let convertConstantMileToKM: Double = 1.609344
//            UserDefaults.standard.set(distanceToModify*convertConstantMileToKM, forKey: "thisMonthTargetVolInKM")
        }
        else{}
        
    }
    
    func updateDistanceUnit() {
        DispatchQueue.main.async {
            if UserDefaults.standard.bool(forKey: "useSmiley") {
                let font = SmileyFontSize.getNormal()
                let attributes = [NSAttributedString.Key.font: font]
                
                self.generalSmileyButton[2].setAttributedTitle(NSAttributedString(string: self.curDistanceUnit, attributes: attributes), for: .normal)
                self.generalSmileyButton[2].setAttributedTitle(NSAttributedString(string: self.curDistanceUnit, attributes: attributes), for: .highlighted)
            }
            else {
                self.generalSmileyButton[2].setTitle(self.curDistanceUnit, for: .normal)
            }
            
        }

    }
    
    
    func targetLabel() {
        DispatchQueue.main.async {
            if UserDefaults.standard.bool(forKey: "useSmiley"){
                self.targetDistanceLabel.font = SmileyFontSize.getHuge()
            }
        }

    }
    
    
    func setUpDistanceUnitButton(){
        let unit10 = UIAction(title: "10") { (action) in
            self.curDistanceUnit = "10"
            self.curDistanceUnitInDouble = 10
            self.updateDistanceUnit()

        }

            let unit5 = UIAction(title: "5") { (action) in
                self.curDistanceUnit = "5"
                self.curDistanceUnitInDouble = 5
                self.updateDistanceUnit()
            }

        let unit1 = UIAction(title: "1") { (action) in
            self.curDistanceUnit = "1"
            self.curDistanceUnitInDouble = 1
            self.updateDistanceUnit()
        }

        let menuTitle = NSLocalizedString("monthTargetUnit", comment: "")
        let menu = UIMenu(title: menuTitle, options: .singleSelection, children: [unit10, unit5, unit1])

        self.generalSmileyButton[2].menu = menu
        self.generalSmileyButton[2].showsMenuAsPrimaryAction = true
//        self.generalSmileyButton[2].setTitle(self.curDistanceUnit, for: .normal)
    }
    
    

    func setUpFont(){
        if UserDefaults.standard.bool(forKey: "useSmiley") {
            self.largeTitle.font = SmileyFontSize.getLarge()
            self.targetDistanceLabel.font = SmileyFontSize.getHuge()
            let font = SmileyFontSize.getNormal()
            let attributes = [NSAttributedString.Key.font: font]
            let doneStr = NSAttributedString(string: NSLocalizedString("modifymodify", comment: ""), attributes: attributes)
            let cancelStr = NSAttributedString(string: NSLocalizedString("cancelcancel", comment: ""), attributes: attributes)

            
            self.generalSmileyButton[0].setAttributedTitle(doneStr, for: .normal)
            self.generalSmileyButton[0].setAttributedTitle(doneStr, for: .highlighted)
            self.generalSmileyButton[1].setAttributedTitle(cancelStr, for: .normal)
            self.generalSmileyButton[1].setAttributedTitle(cancelStr, for: .highlighted)
            
            self.generalSmileyButton[2].setAttributedTitle(NSAttributedString(string: self.curDistanceUnit, attributes: attributes), for: .normal)
            self.generalSmileyButton[2].setAttributedTitle(NSAttributedString(string: self.curDistanceUnit, attributes: attributes), for: .highlighted)

            
            for ll in self.footnoteSmiley {
                ll.font = SmileyFontSize.getFootnote()
            }
        }
        else{
            self.generalSmileyButton[0].setTitle(NSLocalizedString("modifymodify", comment: ""), for: .normal)
            self.generalSmileyButton[1].setTitle(NSLocalizedString("cancelcancel", comment: ""), for: .normal)
        }
        
        
    }
    
    
    func setUpButtonTxtColor() {
        for btn in self.generalSmileyButton {
            btn.tintColor = ColorUtil.getBarBtnColor()
        }
    }

    @IBAction func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.masksToBounds = false
        textField.layer.shadowColor = ColorUtil.getTextFieldHighlightColor().cgColor
        textField.layer.shadowOffset = CGSize(width: 0, height: 0)
        textField.layer.shadowOpacity = 1
        textField.layer.shadowRadius = 3
    }
    
    @IBAction func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.shadowOpacity = 0
    }
    
    @IBAction func doneBtnPressed(_ sender: Any) {
        // TODO: 保存备注至数据库
        if UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit") == 0 {
            // KM
            UserDefaults.standard.set(self.initTargetDistance, forKey: "thisMonthTargetVolInKM")
            
            // KM -> Mile
            UserDefaults.standard.set(AssistantMethods.distanceKMtoMile(self.initTargetDistance), forKey: "thisMonthTargetVolInMile")
            
        }
        else if UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit") == 1 {
            // Mile
            UserDefaults.standard.set(self.initTargetDistance, forKey: "thisMonthTargetVolInMile")
            // Mile -> KM
            UserDefaults.standard.set(AssistantMethods.distanceMileToKM(self.initTargetDistance), forKey: "thisMonthTargetVolInKM")
        }
        else{}
        
        
        self.dismiss(animated: true)
    }
    
    @IBAction func cancelBtnPressed(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    
    @IBAction func addBtnPressed() {
        
        self.initTargetDistance += Double(self.curDistanceUnitInDouble)
        self.targetDistanceLabel.text = String(format: "%.0f", initTargetDistance)
        
        self.targetLabel()
    }
    
    
    @IBAction func decreaseBtnPressed() {
        if self.initTargetDistance - self.curDistanceUnitInDouble < 0 {
            self.footnoteSmiley[2].isHidden = false

            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.footnoteSmiley[2].isHidden = true
            }
            
        }
        else{
            self.initTargetDistance -= Double(self.curDistanceUnitInDouble)
            self.targetDistanceLabel.text = String(format: "%.0f", initTargetDistance)
            self.targetLabel()
        }
        

    }
    
    
    

}
