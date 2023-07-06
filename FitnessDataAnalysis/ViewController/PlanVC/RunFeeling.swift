//
//  RunFeeling.swift
//  FitnessDataAnalysis
//
//  Created by 十口V🌼 on 2023/3/25.
//

import UIKit
import CoreData

class RunFeeling: UIViewController {

    @IBOutlet weak var largeTitle: UILabel!
    

    @IBOutlet weak var textField: UITextField!
    @IBOutlet var generalSmileyButton: [UIButton]!
    @IBOutlet var runningFeelingButton: [UIButton]!
    
    ///  跑步类型按钮
    @IBOutlet var runningTypeButton: UIButton!
    /// 跑步距离
    @IBOutlet weak var distanceLabel: GradientLabel!
    /// 日期选择
    @IBOutlet weak var datePicker: UIDatePicker!
    /// 副标题
    @IBOutlet var subheadLabels: [UILabel]!
    /// Switch
    @IBOutlet var switchSet: [UISwitch]!
    /// 底部保存按钮
    @IBOutlet weak var saveBottomButtom: UIButton!
    
    /// 从主页输入进来的距离
    var curDistance: Double = 0.0
    /// 从主页输入进来的日期
    var curDate: Date!
    
    /// Core Data上下文
    var managedObjectContext: NSManagedObjectContext!
    /// 当前的实例——查询是否已经有了实例在Core Data中，此实例一定是新增的。
    var entity: OneDayPlan!
    /// 跑步类型本地化字符串
    var runningTyleStrLocal: [String] = []
    /// 该页类型 0 - 来自运动页  1- 来自添加日志
    var typeID: Int = 0
    /// 是否需要删除记录
    var deleteEntity: Bool = true
    /// 输入的距离 字符串
    var inputDistanceInStr: String = ""
    /// 输入距离 Double
    var inputDistanceInDouble: Double = 0.0
    /// 输入距离的单位Int
    var inputDistanceUnit: Int = 0

    // MARK: - 需要存入数据库的值
    /// 跑步感受
    var feelingToStore: Int32 = 0
    /// 存储的跑步距离
    var typeToStore: Int32 = 0
    /// 是否跑前热身/拉伸
    var beforeRunToStore: Bool = false
    /// 是否跑后拉伸
    var afterRunToStore: Bool = false
    /// 存储的距离
    var distanceToStore: Double = 0.0
    /// 距离单位
    var unitToStore: Bool = true
    /// 碎碎念
    var notesToStore: String = ""
    /// 存储的日期
    var dateToStore: Date = Date()

    
    // MARK: - 生命周期 -
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.getTypeNameOfRun()
        
        // 获取完成跑步类型后再设置UI
        
        self.uiSetting()
        
        // 准备必要的数据
        self.prepareData()
        
        // Core Data 配置
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedObjectContext = appDelegate!.persistentContainer.viewContext
        self.entity = OneDayPlan(context: managedObjectContext)
        
    }
    /// 准备必要的数据
    func prepareData() {
        if typeID == 0 {
            self.distanceToStore = self.inputDistanceInDouble
            self.unitToStore = self.inputDistanceUnit == 0 ? true : false
        }

        
        
    }
    
    
    
    func uiSetting() {
        self.distanceLabel.gradientColors = ColorUtil.getGradBluePink().map{$0.cgColor}
        
        if typeID == 0 {
            self.datePicker.isUserInteractionEnabled = false

            self.distanceLabel.text = self.inputDistanceInStr
        }
        
        else if typeID == 1 {
            if UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit") == 0 {
                self.distanceLabel.text = "Test 5.0" + " " + NSLocalizedString("distanceUnitKM", comment: "")
                
            }
            else {
                self.distanceLabel.text = "Test 5.0" + " " + NSLocalizedString("distanceUnitMile", comment: "")
            }
            
        }
        else {}
        
        self.largeTitle.text = NSLocalizedString("runningFeelingTitle", comment: "")

        self.datePicker.maximumDate = Date()
        self.datePicker.date = curDate
        self.datePicker.tintColor = ColorUtil.getBarBtnColor()
        for ss in self.switchSet {
            ss.onTintColor = ColorUtil.getBarBtnColor()
        }
        
        self.setUpFont()
        self.setUpButtonTxtColor()
        self.setUpRunningTypeBtn()
        
        if UIScreen.main.bounds.size.height > 680 {
            self.saveBottomButtom.isHidden = false
        }
        else{
            self.saveBottomButtom.isHidden = true
        }
        
    }

    
    
    /// 配置跑步类型按钮的菜单
    func setUpRunningTypeBtn() {
        var allRunTypeAction: [UIAction] = []
        
        for (idx, typeInstr) in runningTyleStrLocal.enumerated() {
            let curAction = UIAction(title: typeInstr) { (action) in
                // 更新Label
                self.updateRunTypeButton(idx)
                // 更新Int
                self.typeToStore = Int32(idx)
                print("当前选择类型：\(idx)\n")
            }
            allRunTypeAction.append(curAction)
        }
        
    
        let menuTitle = NSLocalizedString("runningTypeSelection", comment: "")
        let menu = UIMenu(title: menuTitle, options: .singleSelection, children: allRunTypeAction)
        self.runningTypeButton.menu = menu
        self.runningTypeButton.showsMenuAsPrimaryAction = true
        // 先随机选择一个
        
        self.updateRunTypeButton(UserDefaults.standard.integer(forKey: "PreferredRunType"))
        
    }
    
    /// 根据plist获取设置列表的sec标题和内容
    func getTypeNameOfRun() {
        let plistURL = Bundle.main.url(forResource: "RunType", withExtension: "plist")
        // 设置各个var的值
        do {
            let data = try Data(contentsOf: plistURL!)
            let plistData = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
            let dataDictionary = plistData as! [String: Any]
            // 各个跑步类型
            let runTypeList = dataDictionary["RunningTypeArray"]! as! [String]
            self.runningTyleStrLocal = runTypeList
            
            print(self.runningTyleStrLocal)
        }
        catch{
            
        }
        
    }
    
    
    
    func updateRunTypeButton(_ idx: Int) {
        if !UserDefaults.standard.bool(forKey: "useSmiley") {
            DispatchQueue.main.async {
                self.runningTypeButton.setTitle(self.runningTyleStrLocal[idx], for: .normal)
                self.runningTypeButton.setTitle(self.runningTyleStrLocal[idx], for: .highlighted)
                
            }
        }
        else {
            // 使用得意黑
            let font = SmileyFontSize.getNormal()
            let att = [NSAttributedString.Key.font: font]
            let showStr = NSAttributedString(string: self.runningTyleStrLocal[idx], attributes: att)
            DispatchQueue.main.async {
                self.runningTypeButton.setAttributedTitle(showStr, for: .normal)
                self.runningTypeButton.setAttributedTitle(showStr, for: .highlighted)
            }
        }
    }
    
    
    
    func setUpFont(){
        if UserDefaults.standard.bool(forKey: "useSmiley") {
            // Label
            self.largeTitle.font = SmileyFontSize.getInSize(CGFloat(17))
            self.distanceLabel.font = SmileyFontSize.getInSize(CGFloat(28))
            for myLabel in self.subheadLabels {
                myLabel.font = SmileyFontSize.getNormal()
            }
            
            // Textfield
            textField.font = SmileyFontSize.getNormal()
            
            // Button
            let font = SmileyFontSize.getNormal()
            let attributes = [NSAttributedString.Key.font: font]
            let doneStr = NSAttributedString(string: NSLocalizedString("savesave", comment: ""), attributes: attributes)
            let cancelStr = NSAttributedString(string: NSLocalizedString("cancelcancel", comment: ""), attributes: attributes)
            
            self.generalSmileyButton[0].setAttributedTitle(doneStr, for: .normal)
            self.generalSmileyButton[0].setAttributedTitle(doneStr, for: .highlighted)
            
            
            self.generalSmileyButton[1].setAttributedTitle(cancelStr, for: .normal)
            self.generalSmileyButton[1].setAttributedTitle(cancelStr, for: .highlighted)
            
            self.saveBottomButtom.setAttributedTitle(doneStr, for: .normal)
            self.saveBottomButtom.setAttributedTitle(doneStr, for: .highlighted)
            
            // 跑步感受button
            let feelingFont = SmileyFontSize.getFootnote()
            let feelingAtt = [NSAttributedString.Key.font: feelingFont]
            
            for btn in self.runningFeelingButton {
                let str = NSAttributedString(string: (btn.configuration?.subtitle)!, attributes: feelingAtt)
                let attStr2 = AttributedString(str)
                btn.configuration?.attributedSubtitle = attStr2

            }
            
        }
        
        
    }
    
    @IBAction func runTypeButtonValChanged(_ sender: UIButton) {
//        self.typeToStore = 0
//        let plistURL = Bundle.main.url(forResource: "RunType", withExtension: "plist")
//        // 设置各个var的值
//        do {
//            let data = try Data(contentsOf: plistURL!)
//            let plistData = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
//            let dataDictionary = plistData as! [String: Any]
//            // 各个跑步类型
//            let runTypeList = dataDictionary["RunningTypeArray"]! as! [String]
//            let idx = runTypeList.firstIndex(of: <#T##String#>)
//            self.typeToStore = Int32()
//        }
//
    }

    
    
    @IBAction func feelingBtnPressed(_ sender: Any) {
        for btn in self.runningFeelingButton {
            btn.layer.borderWidth = 0
        }
        
        var feeling: Int = 0
        if sender as! NSObject == self.runningFeelingButton[0] {
            feeling = 0
            self.runningFeelingButton[0].layer.masksToBounds = false
            self.runningFeelingButton[0].layer.borderColor = UIColor.darkGray.cgColor
            self.runningFeelingButton[0].layer.borderWidth = 1.5
            self.runningFeelingButton[0].layer.cornerRadius = 10
        }
        else if sender as! NSObject == self.runningFeelingButton[1] {
            feeling = 1
            self.runningFeelingButton[1].layer.masksToBounds = true
            self.runningFeelingButton[1].layer.borderColor = UIColor.darkGray.cgColor
            self.runningFeelingButton[1].layer.borderWidth = 1.5
            self.runningFeelingButton[1].layer.cornerRadius = 10
        }
        else{
            feeling = 2
            self.runningFeelingButton[2].layer.masksToBounds = true
            self.runningFeelingButton[2].layer.borderColor = UIColor.darkGray.cgColor
            self.runningFeelingButton[2].layer.borderWidth = 1.5
            self.runningFeelingButton[2].layer.cornerRadius = 10
        }
        
        self.feelingToStore = Int32(feeling)
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if deleteEntity {
            do {
                try! managedObjectContext.delete(self.entity)
            }
        }
    }
    
    
    
    @IBAction func beforeRunSwitchChanged(_ sender: UISwitch) {
        print("当前的值！")
        if sender == self.switchSet[0] {
            if sender.isOn {
                self.beforeRunToStore = true
            }
            else {
                self.beforeRunToStore = false
            }
        }
        else {
            if sender.isOn {
                self.afterRunToStore = true
            }
            else {
                self.afterRunToStore = false
            }
        }
        
    }
    
    @IBAction func textFieldDidBeginEditing(_ textField: UITextField) {
        self.textField.layer.masksToBounds = false
        self.textField.layer.shadowColor = ColorUtil.getTextFieldHighlightColor().cgColor
        self.textField.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.textField.layer.shadowOpacity = 1
        self.textField.layer.shadowRadius = 3
    }
    
    @IBAction func textFieldDidEndEditing(_ textField: UITextField) {
        self.textField.layer.shadowOpacity = 0
        // 赋值
        self.notesToStore = self.textField.text!
    }
    
    
    
    
    @IBAction func doneBtnPressed(_ sender: Any) {
        // TODO: 保存备注至数据库
        self.confirmSaveToCoreData()
        self.dismiss(animated: true)
    }
    
    
    @IBAction func cancelBtnPressed(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    
    @IBAction func endEdit(_ sender: Any) {
        self.textField.resignFirstResponder()
    }
    
    
    /// 确认保存数据到数据库
    func confirmSaveToCoreData() {
        self.deleteEntity = false
        
        
        if typeID == 0  {
            self.dateToStore = self.curDate
        }
        else {
            self.dateToStore = self.datePicker.date
            // TODO: 用户输入的距离
            self.distanceToStore = 5.0
            if UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit") == 0 {
                self.unitToStore = true
                
            }
            else {
                self.unitToStore = false
            }
            
        }

        // TODO: - 修改日期
        self.entity.runningDate = self.dateToStore
        self.entity.runningDistance = distanceToStore
        self.entity.note = notesToStore
        self.entity.unitIsKM = unitToStore
        self.entity.feeling = feelingToStore
        self.entity.runType = typeToStore
        self.entity.beforeRun = beforeRunToStore
        self.entity.afterRun = self.afterRunToStore
        do {
            try! managedObjectContext.save()
        }
        
    }
    
    func setUpButtonTxtColor() {
        for btn in self.generalSmileyButton {
            btn.tintColor = ColorUtil.getBarBtnColor()
        }
    }
    
}
