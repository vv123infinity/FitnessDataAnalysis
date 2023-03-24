//
//  PaceCalculator.swift
//  FitnessDataAnalysis
//
//  Created by 十口V🌼 on 2023/2/27.
//

import UIKit
import AAInfographics

class PaceCalculator: UIViewController {

    @IBOutlet weak var distanceUnitButton: UIButton!
    @IBOutlet weak var distanceTimeUIView: UIView!
    @IBOutlet weak var paceLabel: GradientLabel!
    @IBOutlet weak var paceUnitButton: UIButton!
    @IBOutlet var inputTextField: [UITextField]!
    @IBOutlet var generalSmileyLabel: [UILabel]!
    @IBOutlet var convertButton: UIButton!
    
    
    //"distanceUnitDefault" = "公里";
    var currDistanceUnit: String = NSLocalizedString("distanceUnitDefault", comment: "")
    lazy var distanceUnitToCalc: Int = 0
    var paceUnitSelected: PaceCalculatorMethods.ConvertMeterToPaceunit = .toKM
    var paceUnitToShow: String = NSLocalizedString("distanceUnitKM" , comment: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backItem = UIBarButtonItem()
        backItem.title = ""
        self.navigationItem.backBarButtonItem = backItem // This will
        
        self.uiSetting()
        
        // Do any additional setup after loading the view.
        
   
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setUpFontSmiley()
        
    }
    
    func setUpFontSmiley(){
        if UserDefaults.standard.bool(forKey: "useSmiley") {
            DispatchQueue.main.async {
                for ll in self.generalSmileyLabel {
                    ll.font = SmileyFontSize.getNormal()
                    
                }
                let font = SmileyFontSize.getNormal()
                let attributes = [NSAttributedString.Key.font: font]
                
                
                let distanceNSAStr = NSAttributedString(string: self.currDistanceUnit, attributes: attributes)
                self.distanceUnitButton.setAttributedTitle(distanceNSAStr, for: .normal)
                self.distanceUnitButton.setAttributedTitle(distanceNSAStr, for: .highlighted)
                
                let paceNSAStr = NSAttributedString(string: self.paceUnitToShow, attributes: attributes)
                self.paceUnitButton.setAttributedTitle(paceNSAStr, for: .normal)
                self.paceUnitButton.setAttributedTitle(paceNSAStr, for: .highlighted)


                let attributedQuote = NSAttributedString(string: (self.convertButton.titleLabel?.text)!, attributes: attributes)
                self.convertButton.setAttributedTitle(attributedQuote, for: .normal)
                self.convertButton.setAttributedTitle(attributedQuote, for: .highlighted)
                
                
                for tf in self.inputTextField {
                    tf.font = SmileyFontSize.getNormal()
                }
            }
        }
        
    }
    
    
    func uiSetting() {
        self.setUpFontSmiley()
        // 1. 导航栏颜色
        self.setUpNavigation()
        // 2. 距离单位菜单
        self.setUpDistanceUnitButton()
        // 3. 配速器的UIView，背景颜色
//        self.setUpDistTimeUIView()
        // 4. 配速结果，渐变
        self.setUpPaceLabel()
        // 5. 配速单位选择菜单
        self.setUpPaceUnitBtn()
        // 6. TextField 类型
        self.setUpTextFieldType()
        // 7. 背景颜色
        self.setUpBkColor()
    }
    
    
    @IBAction func doneEdit(_ sender: UITextField) {
        sender.resignFirstResponder()
        
    }
    
    @IBAction func onTopGestureRecognized(_ sender: Any) {
        // 点击空白处收起键盘
        for t in self.inputTextField {
            t.resignFirstResponder()
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
    
    @IBAction func convertBtnPressed(_ sender: ActualGradientButtonRedToBlueCR5){
        
        
        DispatchQueue.main.async {
            for t in self.inputTextField {
                t.resignFirstResponder()
            }
            
            

            self.getDataAndCalcPace()
            
        }
    }
    
    func getDataAndCalcPace() {
        let distanceText = self.inputTextField[0].text
        let inputDistance: Double = Double(distanceText!) ?? 0
        let hrs: Int = Int(self.inputTextField[1].text!) ?? 0
        let mins: Int = Int(self.inputTextField[2].text!) ?? 0
        let secs: Int = Int(self.inputTextField[3].text!) ?? 0

        if inputDistance != 0 && hrs >= 0 && mins >= 0 && secs >= 0 && (hrs+mins+secs>0) {
            let res = PaceCalculatorMethods.paceCalc(inputDistance, self.distanceUnitToCalc, hrs, mins, secs, self.paceUnitSelected)
            self.paceLabel.text = res
        }
        else{

            self.paceLabel.text = ""
        }
        
    }
    
    func setUpBkColor() {
        self.view.backgroundColor = ColorUtil.getBackgroundColorStyle1()
    }
    func setUpTextFieldType() {
        self.inputTextField[0].keyboardType = .decimalPad
        self.inputTextField[1].keyboardType = .numberPad
        self.inputTextField[2].keyboardType = .numberPad
        self.inputTextField[3].keyboardType = .numberPad
    }
    func setUpDistTimeUIView(){
        self.distanceTimeUIView.backgroundColor = ColorUtil.getBackgroundColorStyle2()
        self.distanceTimeUIView.layer.cornerRadius = 18
        self.distanceTimeUIView.layer.shadowColor = ColorUtil.getGeneralTintColorStyle1().cgColor
//        self.distanceTimeUIView.layer.shadowOpacity = 0.2
        self.distanceTimeUIView.layer.shadowOffset = .zero
        self.distanceTimeUIView.layer.shadowRadius = 1
//        self.distanceTimeUIView.layer.shouldRasterize = true
//        self.distanceTimeUIView.layer.rasterizationScale = UIScreen.main.scale
    }
    
    func setUpNavigation(){
//        self.navigationController?.navigationBar.tintColor = ColorUtil.getGeneralTintColorStyle1()
//        let appearance = UINavigationBarAppearance()
//        appearance.titleTextAttributes = [.foregroundColor: ColorUtil.getGeneralTintColorStyle1()]
//        appearance.largeTitleTextAttributes = [.foregroundColor: ColorUtil.getGeneralTintColorStyle1()]
//        navigationItem.standardAppearance = appearance
//        navigationItem.scrollEdgeAppearance = appearance
        self.navigationController?.navigationBar.tintColor = ColorUtil.getBarBtnColor()
        
    }
    
    func setUpPaceLabel(){
        self.paceLabel.gradientColors = ColorUtil.getGradTextStyle1().map{
            return $0.cgColor
        }
    }

    
    func setUpDistanceUnitButton(){
        let km = UIAction(title: NSLocalizedString("distanceUnitKM", comment: "")) { (action) in
                self.currDistanceUnit = NSLocalizedString("distanceUnitKM", comment: "")
            self.distanceUnitToCalc = 0
            self.updateDistanceUnit()
            self.getDataAndCalcPace()
            }

            let mile = UIAction(title: NSLocalizedString("distanceUnitMile", comment: "")) { (action) in
                self.currDistanceUnit = NSLocalizedString("distanceUnitMile", comment: "")
                self.distanceUnitToCalc = 1
                self.updateDistanceUnit()
                self.getDataAndCalcPace()
            }

            let meter = UIAction(title: NSLocalizedString("distanceUnitM", comment: "")) { (action) in
                self.currDistanceUnit = NSLocalizedString("distanceUnitM", comment: "")
                self.distanceUnitToCalc = 2
                self.updateDistanceUnit()
                self.getDataAndCalcPace()
            }

        let menuTitle = NSLocalizedString("distanceUnit", comment: "")
        let menu = UIMenu(title: menuTitle, options: .singleSelection, children: [km, mile, meter])

        self.distanceUnitButton.menu = menu
        self.distanceUnitButton.showsMenuAsPrimaryAction = true
        self.distanceUnitButton.setTitle(NSLocalizedString("distanceUnitDefault", comment: ""), for: .normal)
    }
    
    func setUpPaceUnitBtn(){
        let localKM = NSLocalizedString("distanceUnitKM", comment: "")
        let localMile = NSLocalizedString("distanceUnitMile", comment: "")
        let local1500 = NSLocalizedString("distance1500M", comment: "")
        let local800 = NSLocalizedString("distance800M", comment: "")
        let local400 = NSLocalizedString("distance400M", comment: "")
        let local200 = NSLocalizedString("distance200M", comment: "")

        
        
        let km = UIAction(title: localKM) { (action) in
            self.paceUnitToShow = localKM
            self.paceUnitSelected = .toKM
            self.updatePaceUnit()
            self.getDataAndCalcPace()
        }
        let mile = UIAction(title: localMile) { (action) in
            self.paceUnitToShow = localMile
            self.paceUnitSelected = .toMile
            self.updatePaceUnit()
            self.getDataAndCalcPace()
        }
        let meter1500 = UIAction(title: local1500) { (action) in
            self.paceUnitToShow = local1500
            self.paceUnitSelected = .to1500M
            self.updatePaceUnit()
            self.getDataAndCalcPace()
        }
        let meter800 = UIAction(title: local800) { (action) in
            self.paceUnitToShow = local800
            self.paceUnitSelected = .to800M
            self.updatePaceUnit()
            self.getDataAndCalcPace()
        }
        let meter400 = UIAction(title: local400) { (action) in
            self.paceUnitToShow = local400
            self.paceUnitSelected = .to400M
            self.updatePaceUnit()
            self.getDataAndCalcPace()
        }
        let meter200 = UIAction(title: local200) { (action) in
            self.paceUnitToShow = local200
            self.paceUnitSelected = .to200M
            self.updatePaceUnit()
            self.getDataAndCalcPace()
        }
        let menu = UIMenu(title: NSLocalizedString("paceUnitUnit" , comment: ""), options: .singleSelection, children: [km, mile, meter1500, meter800, meter400, meter200])
        self.paceUnitButton.menu = menu
        self.paceUnitButton.showsMenuAsPrimaryAction = true
        
    }
    
    

    func updatePaceUnit(){
        DispatchQueue.main.async {
            if !UserDefaults.standard.bool(forKey: "useSmiley") {
                self.paceUnitButton.setTitle(self.paceUnitToShow, for: .normal)
                
            }
            else {
                let font = SmileyFontSize.getNormal()
                let attributes = [NSAttributedString.Key.font: font]
                
                
                let paceNSAStr = NSAttributedString(string: self.paceUnitToShow, attributes: attributes)
                self.paceUnitButton.setAttributedTitle(paceNSAStr, for: .normal)
                self.paceUnitButton.setAttributedTitle(paceNSAStr, for: .highlighted)
            }
        }
    }
    
    func updateDistanceUnit() {
        DispatchQueue.main.async {
            if !UserDefaults.standard.bool(forKey: "useSmiley") {
                self.distanceUnitButton.setTitle(self.currDistanceUnit, for: .normal)
            }
            else{
                let font = SmileyFontSize.getNormal()
                let attributes = [NSAttributedString.Key.font: font]
                
                
                let distanceNSAStr = NSAttributedString(string: self.currDistanceUnit, attributes: attributes)
                self.distanceUnitButton.setAttributedTitle(distanceNSAStr, for: .normal)
                self.distanceUnitButton.setAttributedTitle(distanceNSAStr, for: .highlighted)
                

            }
            
        }
    }
    

}
