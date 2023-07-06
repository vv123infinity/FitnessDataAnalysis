//
//  MakeDayPlan.swift
//  FitnessDataAnalysis
//
//  Created by 十口V🌼 on 2023/3/28.
//

import UIKit
import CoreData


class MakeDayPlan: UIViewController {
    @IBOutlet weak var largeTitle: UILabel!
    
    @IBOutlet var generalSmileyButton: [UIButton]!
    @IBOutlet var targetDistanceLabel: GradientLabel!
    @IBOutlet var footnoteSmiley: [UILabel]!
    
    
    
    var curDistanceUnit: String = "1"
    lazy var initTargetDistance: Double = 5
    var curDistanceUnitInDouble: Double = 1
    
    
    var inputDateInDate: Date!
    
    var inputDateInString: String!
    
    var alreadyExist: Bool = false
    var managedObjectContext: NSManagedObjectContext!
    
    /// 新建的实例 或者 从数据库中取出
    var curRunningPlan: RunningPlan!
    
    var newAPlan: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedObjectContext = appDelegate!.persistentContainer.viewContext
        
        self.inputDateInString = AssistantMethods.getDateInFormatString(self.inputDateInDate, "yyyy-MM-dd")
        self.uiSetting()
        
        self.setUpInitTargetLabel()
        
    }
    
    
    func uiSetting() {
        
        self.largeTitle.text = inputDateInString + " " + NSLocalizedString("runningDayTarget", comment: "")
        
        self.setUpButtonTxtColor()
        
        self.targetDistanceLabel.gradientColors = ColorUtil.getGradBluePink().map{$0.cgColor}
        
        self.setUpFont()
        
        self.setUpDistanceUnitButton()
        self.footnoteSmiley[2].isHidden = true
        
    }
    
    /// 初始化yyyy-MM-dd 的目标跑量
    func setUpInitTargetLabel() {
        // 1. 首先查询Core Data，看今日是否已经制定了目标
        let request: NSFetchRequest<RunningPlan> = RunningPlan.fetchRequest()
        // 谓语——根据日期查询
        let calendar = Calendar.current
        let startDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: self.inputDateInDate)
        let endDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: self.inputDateInDate)
        let predicate = NSPredicate(format: "targetDate >= %@ AND targetDate <= %@", argumentArray: [startDate, endDate])

        request.predicate = predicate
        do {
            let result = try! managedObjectContext.fetch(request)
            
            if result.count != 0 {
                
                // 为了区分，加上渐变颜色！
                self.setGradientBackground(colorTop: ColorUtil.getBarBtnColor_lowAlpha(), colorBottom: UIColor.clear)
                
                // 显示用户已经设定的目标
                self.alreadyExist = true
                self.generalSmileyButton.last!.setTitle(NSLocalizedString("modifyDayTarget" , comment: ""), for: .normal)
                self.curRunningPlan = result.first
                self.initTargetDistance = self.curRunningPlan.targetDistance
                
                if UserDefaults.standard.bool(forKey: "useSmiley") {
                    let font = SmileyFontSize.getNormal()
                    let attributes = [NSAttributedString.Key.font: font]
                    let str = NSAttributedString(string: NSLocalizedString("modifyDayTarget" , comment: ""), attributes: attributes)
                    
                    self.generalSmileyButton.last!.setAttributedTitle(str, for: .normal)
                    self.generalSmileyButton.last!.setAttributedTitle(str, for: .highlighted)
                    
                }
                
                
            }
            else{
                
                self.alreadyExist = false
                print("需要新建一个记录")
                // 目标距离初始化为 5km 再等待用户修改
                self.generalSmileyButton.last!.setTitle(NSLocalizedString("addDayTarget" , comment: ""), for: .normal)
                
                if UserDefaults.standard.bool(forKey: "useSmiley") {
                    let font = SmileyFontSize.getNormal()
                    let attributes = [NSAttributedString.Key.font: font]
                    let str = NSAttributedString(string: NSLocalizedString("addDayTarget" , comment: ""), attributes: attributes)
                    
                    self.generalSmileyButton.last!.setAttributedTitle(str, for: .normal)
                    self.generalSmileyButton.last!.setAttributedTitle(str, for: .highlighted)
                    
                }
                

            }

            
            
            
        }catch{

        }
        
        
        self.targetDistanceLabel.text = String(format: "%.0f", initTargetDistance)
        
        switch UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit") {
        case 0:
            self.footnoteSmiley[0].text = NSLocalizedString("monTargetUnitHintInKM", comment: "")
        case 1:
            self.footnoteSmiley[0].text = NSLocalizedString("monTargetUnitHintInMile", comment: "")
        default:
            print("")
        }
        
    }
    
    
    /// 更新记录的目标跑量&日期并保存
    func savePlanDistance() {
        self.curRunningPlan.targetDistance = self.initTargetDistance
    }
    
    /// 保存新建的实例的日期
    func savePlanDate() {
        self.curRunningPlan.targetDate = self.inputDateInDate
        
    }
    
    /// 保存新建的实例的距离单位
    func savePlanUnit() {
        self.curRunningPlan.distanceUnit = Int16(UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit"))
    
    }
    
    func saveAll() {
        if alreadyExist{
            self.savePlanUnit()
            self.savePlanDistance()
        }
        else{
            self.curRunningPlan = RunningPlan(context: managedObjectContext)
            self.savePlanDate()
            self.savePlanUnit()
            self.savePlanDistance()
        }
        do {
            try managedObjectContext.save()
            self.newAPlan = true
            
        }catch{}
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
    
    func setUpDistanceUnitButton(){
        let unit10 = UIAction(title: "1") { (action) in
            self.curDistanceUnit = "1"
            self.curDistanceUnitInDouble = 1
            self.updateDistanceUnit()

        }

            let unit5 = UIAction(title: "5") { (action) in
                self.curDistanceUnit = "5"
                self.curDistanceUnitInDouble = 5
                self.updateDistanceUnit()
            }

        let unit1 = UIAction(title: "10") { (action) in
            self.curDistanceUnit = "10"
            self.curDistanceUnitInDouble = 10
            self.updateDistanceUnit()
        }

        let menuTitle = NSLocalizedString("monthTargetUnit", comment: "")
        let menu = UIMenu(title: menuTitle, options: .singleSelection, children: [unit10, unit5, unit1])

        self.generalSmileyButton[2].menu = menu
        self.generalSmileyButton[2].showsMenuAsPrimaryAction = true
//        self.generalSmileyButton[2].setTitle(self.curDistanceUnit, for: .normal)
    }
    
    
    func setGradientBackground(colorTop: UIColor, colorBottom: UIColor){
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop.cgColor, colorBottom.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.locations = [NSNumber(floatLiteral: 0.0), NSNumber(floatLiteral: 1.0)]
        gradientLayer.frame = self.view.bounds

        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    
    
    @IBAction func cancelBtnPressed(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    
    @IBAction func addBtnPressed() {
        
        self.initTargetDistance += Double(self.curDistanceUnitInDouble)
        self.targetDistanceLabel.text = String(format: "%.0f", initTargetDistance)
        
        self.targetLabel()
    }
    
    func targetLabel() {
        DispatchQueue.main.async {
            if UserDefaults.standard.bool(forKey: "useSmiley"){
                self.targetDistanceLabel.font = SmileyFontSize.getHuge()
            }
        }

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
    
    
    @IBAction func doneBtnPressed(_ sender: Any) {
        // TODO: 保存备注至数据库
        self.saveAll()
        self.navigationController?.popViewController(animated: true)
        
//        self.dismiss(animated: true)
    }
    
    
    func setUpButtonTxtColor() {
        for btn in self.generalSmileyButton {
            btn.tintColor = ColorUtil.getBarBtnColor()
        }
    }
    
}
