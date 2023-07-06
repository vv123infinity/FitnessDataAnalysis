//
//  ViewController.swift
//  FitnessDataAnalysis
//
//  Created by 十口V🌼 on 2023/2/24.
//

import UIKit
import HealthKit
import MKRingProgressView
import CoreData

class RootViewController: UIViewController {

    
    /*
     @IBOutlet weak var lastMonthLabel: UILabel!
     @IBOutlet weak var myButton: UIButton!
     @IBOutlet weak var segImgView: UIImageView!
     /// 跑鞋图像
 //    @IBOutlet weak var runningShoeImg: UIImageView!
     @IBOutlet var runningFeelingStackView: UIStackView!
     @IBOutlet var dataStatUIView: DataStatUIView!
     @IBOutlet var runningLogUIView: RunningLogUIView!
     @IBOutlet var makePlanUIView: MakePlanUIView!
     /// 圆环UIView
 //    @IBOutlet weak var targetProgressCicleProgress: UIView!
     /// 本月目标跑量Label
 //    @IBOutlet weak var runningVolProgressLabel: UILabel!
     /// 本月跑量提示Label
 //    @IBOutlet weak var runningHintLabel: UILabel!
     
     
 //    @IBOutlet var rectIndicator: [UIView]!
     /// 第一个chart的UIView
 //    @IBOutlet weak var lineChartUIView: UIView!
     /// 第一个chart的作图区域View
 //    @IBOutlet weak var actualChartRegion: UIView!
     


 //    @IBOutlet weak var dateRangeLabel: UILabel!
 //    @IBOutlet weak var chartTotalDistance: UILabel!
     
     /// 正方形指标
 //    @IBOutlet var squareUIViews: [UIView]!
     

 //    @IBOutlet weak var recentWeekLabel: UILabel!
     /// 得意黑22
 //    @IBOutlet var generalSmileyBigger: [UILabel]!
     /// 修改月跑量目标Button
 //    @IBOutlet var changeMonTar: UIButton!
     @IBOutlet var authBtn: UIButton!
     */
    // MARK: - 接口

    @IBOutlet var sView: UIScrollView!
    /// 上个月跑量Label

    @IBOutlet var footnoteSmiley: [UILabel]!

    /// 设置logo
//    @IBOutlet weak var settingBarBtn: UIBarButtonItem!
    /// 工具logo
//    @IBOutlet weak var toolboxBarBtn: UIBarButtonItem!
    /// 控件
    @IBOutlet weak var recent7DaysSegControl: UISegmentedControl!
    /// 今天跑量
    @IBOutlet weak var todayLabel: UILabel!
    /// 今天计划的跑量
    @IBOutlet weak var todayPlanLabel: UILabel!
    /// 选择日子提示
    @IBOutlet var dateAndWeekLabel: [UILabel]!
    /// 跑步感受提示
    @IBOutlet var runningFeelingLabel: UILabel!
    /// 添加跑步日志
    @IBOutlet var addRunningNotesButton: UIButton!
    /// 本月跑量进度
    @IBOutlet var thisMonthProgressLabel: UILabel!
    
    
    /// 分栏控件——数据统计；跑步日志
    @IBOutlet var sectionTitlesSegControl: UISegmentedControl!

    /// UIView
    @IBOutlet var secSegControlUIView: UIView!
    /// 跑步统计；跑步日志；目标；
    @IBOutlet var myButtons: [UIButton]!
    /// 今天 - 按钮，如果今天没跑，按钮隐藏
    @IBOutlet weak var todayButton: UIButton!
    
    /// 提示用户打开权限
    @IBOutlet var hintForOpenPrivUIView: UIView!
    
    /// 得意黑17
    @IBOutlet var generalSmiley: [UILabel]!
    /// 更大的字体
    @IBOutlet var generalSmileyBigger: [UILabel]!

    /// UIView Style

    @IBOutlet var uiViewStyle: [UIView]!
    
    @IBOutlet weak var runningPersonImg: UIImageView!
    
    
    
    /// 测试Label
    @IBOutlet var testLabel: UILabel!
    // MARK: - 属性
    /// 所有的workout
    var workouts: [HKWorkout]!
    /// 最近最近日子的跑步距离
    var recent5MonRunningDistance: [Double] = []
    /// 全部距离
    var res: [Double] = []
    /// 本周的日期 格式dd
    var thisWeekDateStringIndd: [String] = []
    /// 本周训练的Date
    var thisWeekWKdate: [Date] = []
    /// ["22", 6.06] _ 22号有一个6.06的跑步训练
    var thisWeekDateToDist: [String: Double] = [:]
    /// 当前选择的有训练的日期
    var selectedDateToRunningFeeling: Date = Date()
    /// 实例
    var curOneDayPlan: OneDayPlan!
    /// 上下文
    var managedObjectContext: NSManagedObjectContext!
    /// 有训练的日子当前选择的距离 用于更好的转换单位
    var selectedDistance: Double = 0.0
    /// 有训练的日子的单位 _ 用于更好的转换单位
    var selectedDistanceUnit: Int = 0
    
    // MARK: - 重写函数
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // TODO: 判断是否修改了目标

  
        if UserDefaults.standard.bool(forKey: "UnitHasChanged")  {
            // 1. 更新计划
            self.showPlanedDistanceLabel()
            
            self.loadWorkoutsAndGetDistance()
            self.loadThisMonthAndSetLabel()
            
            /*
            // 更新实际跑量的单位
            if selectedDistanceUnit == 0 {
                // KM -> Mile
                let dstDistance = AssistantMethods.distanceKMtoMile(self.selectedDistance)
                DispatchQueue.main.async {
                    self.todayLabel.text = String(format: "%.2f", dstDistance) + " " + NSLocalizedString("distanceUnitMile", comment: "")
                    
                }
            }
            else {
                // Mile -> KM
                let dstDistance = AssistantMethods.distanceMileToKM(self.selectedDistance)
                DispatchQueue.main.async {
                    self.todayLabel.text = String(format: "%.2f", dstDistance) + " " + NSLocalizedString("distanceUnitKM", comment: "")
                }
            }
            */
            
            // 需要重新读取 处理数据
            UserDefaults.standard.setValue(false, forKey: "UnitHasChanged")
        }
        
        if UserDefaults.standard.bool(forKey: "monthTargetDidChange") {
            self.loadThisMonthAndSetLabel()
            UserDefaults.standard.set(false, forKey: "monthTargetDidChange")
        }
        
        if UserDefaults.standard.bool(forKey: "tintColorDidChange") {
            DispatchQueue.main.async {
//                self.settingBarBtn.tintColor = ColorUtil.getBarBtnColor()
//                self.toolboxBarBtn.tintColor = ColorUtil.getBarBtnColor()
                self.addRunningNotesButton.tintColor = ColorUtil.getBarBtnColor()
                self.addRunningNotesButton.configuration?.baseBackgroundColor = ColorUtil.getBarBtnColor()
                self.sectionTitlesSegControl.removeBorder()
                let colorSet = ColorUtil.getSegConColor()
                self.recent7DaysSegControl.selectedSegmentTintColor = colorSet.highlight
                UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor:  ColorUtil.getBarBtnColor(), NSAttributedString.Key.font: SmileyFontSize.getNormal()], for: UIControl.State.normal)
                
                UserDefaults.standard.setValue(false, forKey: "tintColorDidChange")
            }
        }
        

        if UserDefaults.standard.bool(forKey: "WeekStartDateHasChanged") {
            DispatchQueue.main.async {
                self.setUpSegControlContent()
                self.loadThisWeekDist()
                self.setSegWeekDistanceLabel()
                // 重新查询
                self.showPlanedDistanceLabel()
            }
            
            UserDefaults.standard.setValue(false, forKey: "WeekStartDateHasChanged")
        }
       
        WorkoutDataStore.loadLastWorkouts() { (res, error) in
            // 可以成功访问Workout类型的数据
            if res != nil && res!.count != 0 && error == nil{
//                self.loadWorkoutsAndGetDistance()
            }
            else {
//                self.sView.isHidden = true
//                self.dataStatUIView.isHidden = true
            }
            
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)


        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)
//        WorkoutDataStore.loadLastWorkouts_AnyType() { (wk, status) in
//            let firstWK = wk?.first!
//            let date = firstWK?.startDate
//            let dateInStr = AssistantMethods.getDateInFormatString(date!, "yyyy-MM-dd")
//            let type = firstWK?.workoutActivityType
//            print("??进来没？？")
//
//            self.testLabel.text = dateInStr + "\n" + "\(type)" + "\n" + String(format: "%.2f", (firstWK?.duration as? Double)!) + "\n" + ""
//
//        }
        

    }
    
    
    override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
    }
    // MARK: 浅深色模式
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        DispatchQueue.main.async {

//            self.gradient.animateChanges(to: ColorUtil.rootVCPurpleGradColor(), duration: 0.5)
            
            DispatchQueue.main.async {
                self.sectionTitlesSegControl.removeBorder()
//                self.todayLabel.gradientColors = ColorUtil.getGradTextStyle3()
//                self.todayPlanLabel.gradientColors = ColorUtil.getGradGray()
                
            }
//            for i in self.rectGrad {
//                i.animateChanges(to: ColorUtil.rootVCRectGradColor(), duration: 0.5)
//            }
//            self.chart.series = []
//            self.chart = Chart(frame: self.actualChartRegion.frame)
//            self.chart.center = self.actualChartRegion.center
            
//            self.chart.labelColor = ColorUtil.dynamicColor(dark: UIColor.white, light: UIColor.black)
            
//            self.chart.removeFromSuperview()
//            self.setUpFirstPurpleBarChart_Data()

        }
        
        
    }
    
    
    // MARK: -应用生命周期-
    override func viewDidLoad() {
        super.viewDidLoad()
        // 1. 程序配置的UI 设置
        self.uiSettings()
        
        // 2. 加载体能训练
            WorkoutDataStore.loadLastWorkouts() { (res, error) in
            // 测试是否可以成功访问Workout类型的数据（不可访问的情况：①用户没有Apple Watch②用户未授权给本应用）
            if res != nil && res!.count != 0 && error == nil{
                // 测试结果为可以访问，加载并处理相关的数据
                self.loadWorkoutsAndGetDistance()
                self.loadThisMonthAndSetLabel()
                
            }
            else {
                // 不能访问用户的数据，显示对应的提示
                self.addRunningNotesButton.isHidden = true
                self.todayLabel.text = "---"
            }
            
        }


        // 3. Fetch数据库内容
        self.loadWeekPlanCoreData()

    }
    
    
    
    // MARK: - 接口接口接口
//    @IBAction func setUpRunningFeelingButtons(_ sender: UIButton) {
//        for btn in self.runningFeelingButton {
//            btn.layer.borderWidth = 0
//        }
//
//        sender.layer.cornerRadius = 15
//        let bc = UIColor.systemGray
//        sender.layer.borderColor = bc.cgColor
//        sender.layer.borderWidth = 2
//
//    }
    
    @IBAction func settingBtnPressed(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SettingRootTable") as! SettingRootTable
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func toolBtnPressed(_ sender: UIBarButtonItem) {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "ToolboxRoot") as! ToolboxRoot
        let vc = storyboard.instantiateViewController(withIdentifier: "ToolBoxTable") as! ToolBoxTable
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    

    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        self.updateDateWeekLabel()
        self.showPlanedDistanceLabel()
    }
    
    
    @IBAction func addRunningNotesBtnPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let runningFeelingVC = storyboard.instantiateViewController(identifier: "RunFeeling") as! RunFeeling
        // TODO: 将self.selectedDateToRunningFeeling作为curDate
        // Date()
        runningFeelingVC.curDate = self.selectedDateToRunningFeeling
        runningFeelingVC.typeID = 0
        runningFeelingVC.inputDistanceInStr = self.todayLabel.text!
        runningFeelingVC.inputDistanceInDouble = self.selectedDistance
        runningFeelingVC.inputDistanceUnit = self.selectedDistanceUnit
        
        self.present(runningFeelingVC, animated: true)
    }
    
    
    @IBAction func segmentedControlDidChange(_ sender: UISegmentedControl){
        DispatchQueue.main.async {
            self.sectionTitlesSegControl.changeUnderlinePosition()
            self.addSectionUIView()
            
        }
    }
    
    
    
    // MARK:  - 基础UI的配置-
    /// 基础UI的配置
    func uiSettings() {
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        // 1. 得意黑
        if UserDefaults.standard.bool(forKey: "useSmiley"){
            self.setUpFontSmiley()
        }

        self.addRunningNotesButton.tintColor = ColorUtil.getBarBtnColor()
        self.addRunningNotesButton.configuration?.baseBackgroundColor = ColorUtil.getBarBtnColor()
        // 3. 背景颜色
        self.navigationController?.navigationBar.tintColor = ColorUtil.getBarBtnColor()
//        self.navigationController?.
        // 4. 小节分段控件的标题
        self.setUpSectionTitlesSegControl()
        self.setUpSectionTitlesSeg()
        self.addSectionUIView()
        
        self.setUpBKcolor()

        // 5. bar btn
//        self.settingBarBtn.tintColor = ColorUtil.getBarBtnColor()
//        self.toolboxBarBtn.tintColor = ColorUtil.getBarBtnColor()
        
        for uiview in self.uiViewStyle {
            uiview.layer.cornerRadius = 10
            uiview.backgroundColor = ColorUtil.getBarBtnColor_lowAlpha()
            
        }
        
        self.runningPersonImg.tintColor = ColorUtil.getBarBtnColor()
        
        // 分段控件配置
        self.setUpThisWeekSegControlAndImgView()
        // 取消导航栏返回Button的文字
        let backItem = UIBarButtonItem()
        backItem.title = ""
        self.navigationItem.backBarButtonItem = backItem // This will
        
        
    }
    
    
    
    
    // MARK: -加载最近7天能训练-
    func loadWorkoutsAndGetDistance() {
        WorkoutDataStore.loadRecent15DaysWorkouts() { (workouts, error) in
            self.workouts = workouts
            // 得到距离，单位米
            let res = QueryWorkoutsAssistant.queryRecent5MonRunningDistance(workouts!, "zh_CN")
            self.res = res
            // 根据用户喜爱的单位
            self.setUpChartsAfterLoadingWorkouts()
            
        }
    }
    
    // MARK: - 加载本月初——now
    func loadThisMonthAndSetLabel() {
        WorkoutDataStore.loadThisMonthWorkouts() { (workouts_vv, error) in
            
            var totalDistance: Double = 0.0 // 单位米
            let runningType = HKQuantityType(.distanceWalkingRunning)
            for ii in workouts_vv! {
                guard let runningDistanceNewVersion = ii.statistics(for: runningType)?.sumQuantity()?.doubleValue(for: .meter()) else {
                    continue
                }
                totalDistance += runningDistanceNewVersion
            }
            self.thisMonthProgressLabel.text = "---"
            
            switch UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit") {
            case 0:
                let dis = AssistantMethods.convertMeterToUnit(0, totalDistance)
                let actDistance = String(format: "%.2f", dis)
                let targetDistance = String(format: "%.2f", UserDefaults.standard.double(forKey: "thisMonthTargetVolInKM"))
                let strToShow = actDistance + " / " + targetDistance + " " + NSLocalizedString("distanceUnitKM", comment: "")
                
                DispatchQueue.main.async {
                    self.thisMonthProgressLabel.text = strToShow
                }

            case 1:
                let dis = AssistantMethods.convertMeterToUnit(1, totalDistance)
                let actDistance = String(format: "%.2f", dis)
                let targetDistance = String(format: "%.2f", UserDefaults.standard.double(forKey: "thisMonthTargetVolInMile"))
                let strToShow = actDistance + " / " + targetDistance + " " + NSLocalizedString("distanceUnitMile", comment: "")
                
                DispatchQueue.main.async {
                    self.thisMonthProgressLabel.text = strToShow
                }
                
            default:
                self.thisMonthProgressLabel.text = "---"
            }
            
            
        }
    }
    
    //  MARK: -Core Data加载！！！-
    func loadWeekPlanCoreData(){
        // 1. 加载数据
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedObjectContext = appDelegate!.persistentContainer.viewContext
        
        
        // 2. 显示数据
        self.showPlanedDistanceLabel()
    }
    
    
    // MARK: - 分割线
    func setUpSectionTitlesSegControl() {
        self.sectionTitlesSegControl.removeBorder()
        self.sectionTitlesSegControl.addUnderlineForSelectedSegment()
        self.sectionTitlesSegControl.backgroundColor = UIColor.systemGroupedBackground
        
    }
    
    
    /// 控制各个按钮的出现或隐藏
    func addSectionUIView() {
        if self.sectionTitlesSegControl.selectedSegmentIndex == 0 {
            
            WorkoutDataStore.loadLastWorkouts() { (res, error) in
                // 可以成功访问Workout类型的数据
                if res != nil && res!.count != 0 && error == nil{
                    // 先全部隐藏
                    for i in 0..<self.myButtons.count{
                        self.myButtons[i].isHidden = true
                    }
                    AnimationMethods.buttonAnimationStyle1BottomUp(self.myButtons[0])
                    
                }
                else{
                    for i in 0..<self.myButtons.count{
                        self.myButtons[i].isHidden = true
                    }
                    // 提示用户打开体能训练权限
                    // 展示提示的UIView
                    self.hintForOpenPrivUIView.layer.cornerRadius = 10
                    self.hintForOpenPrivUIView.backgroundColor = ColorUtil.getBarBtnColor_lowAlpha()
                    self.hintForOpenPrivUIView.isHidden = false
                    
                }
            }
        }
        else if self.sectionTitlesSegControl.selectedSegmentIndex == 1 {
            // 先全部隐藏
            self.hintForOpenPrivUIView.isHidden = true
            for i in 0..<self.myButtons.count{
                self.myButtons[i].isHidden = true
            }
            
            AnimationMethods.buttonAnimationStyle1BottomUp(self.myButtons[1])
        }
        else if self.sectionTitlesSegControl.selectedSegmentIndex == 2{
            DispatchQueue.main.async {
                // 先全部隐藏
                self.hintForOpenPrivUIView.isHidden = true
                for i in 0..<self.myButtons.count{
                    self.myButtons[i].isHidden = true
                }
                AnimationMethods.buttonAnimationStyle1BottomUp(self.myButtons[2])
                AnimationMethods.buttonAnimationStyle1BottomUp(self.myButtons[3])
            }

        }
        else{
            
        }
        
    }
    /// 展示UIview
    func setView(view: UIView) {
        UIView.transition(with: view, duration: 0.7, options: .curveEaseInOut, animations: {
//            view.isHidden = hidden
            view.alpha = 1
        })
    }
    

    /// 更新yyyy-MM-dd和星期的Label
    func updateDateWeekLabel() {
        let res = AssistantMethods.getThisWeekDate()
        
        self.dateAndWeekLabel[0].text = res.yyyyMMdd[self.recent7DaysSegControl.selectedSegmentIndex]
        
        self.setSegWeekDistanceLabel()
        
        
    }
    /// 节标题的分段控件
    func setUpSectionTitlesSeg(){
        // 设置各个字符串

        self.sectionTitlesSegControl.setTitle(NSLocalizedString("sectionTitle1", comment: ""), forSegmentAt: 0)
        self.sectionTitlesSegControl.setTitle(NSLocalizedString("sectionTitle2", comment: ""), forSegmentAt: 1)
        self.sectionTitlesSegControl.setTitle(NSLocalizedString("sectionTitle3", comment: ""), forSegmentAt: 2)
        if UserDefaults.standard.bool(forKey: "useSmiley") {
            self.sectionTitlesSegControl.setTitleTextAttributes([NSAttributedString.Key.font: SmileyFontSize.getNormal()], for: .normal)
        }
        else{
            self.sectionTitlesSegControl.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .bold)], for: .normal)
        }
    }
    
    /*
    /// 更新跑后感受emoji
    func updateFeelingEmoji(){
        
        
        
        if self.curOneDayPlan.feeling != nil {
            let feeling = self.curOneDayPlan.feeling
            for (idx, btn) in self.runningFeelingButton.enumerated() {
                if idx == Int(feeling) {
                    btn.layer.cornerRadius = 15
                    let bc = UIColor.systemGray
                    btn.layer.borderColor = bc.cgColor
                    btn.layer.borderWidth = 2
                    
                }
                else{
                    btn.layer.borderWidth = 0
                }
               
            }
            
        }


        
    }
    */
    
    
    /// 分段控件配置
    func setUpThisWeekSegControlAndImgView() {
        // 格式设置
        let colorSet = ColorUtil.getSegConColor()
        self.recent7DaysSegControl.backgroundColor = UIColor.systemGroupedBackground
        self.recent7DaysSegControl.layer.borderColor = colorSet.border.cgColor
        self.recent7DaysSegControl.selectedSegmentTintColor = colorSet.highlight
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: colorSet.normalTxt]
        self.recent7DaysSegControl.setTitleTextAttributes(titleTextAttributes, for:.normal)

        let titleTextAttributes1 = [NSAttributedString.Key.foregroundColor: colorSet.selectedTxt]
        self.recent7DaysSegControl.setTitleTextAttributes(titleTextAttributes1, for:.selected)
        
        if UserDefaults.standard.bool(forKey: "useSmiley") {
            self.recent7DaysSegControl.setTitleTextAttributes([NSAttributedString.Key.font: SmileyFontSize.getNormal()], for: .normal)
        }
        
        
        // 内容设置
        self.setUpSegControlContent()
        
    }
    
    
    /// 设置分段控件的内容
    func setUpSegControlContent() {
        let res = AssistantMethods.getThisWeekDate()
        self.thisWeekDateStringIndd = res.dd
        let today = Date()
        let format = DateFormatter()
        format.dateFormat = "dd"
        let todayStr = format.string(from: today)
        let todayIndex = res.dd.enumerated().filter{
            $0.element == todayStr
        }
        // 设置各个字符串
        for i in 0..<7{
            self.recent7DaysSegControl.setTitle(res.dd[i], forSegmentAt: i)
        }
        
        self.recent7DaysSegControl.selectedSegmentIndex = (todayIndex.first?.offset)!
        self.updateDateWeekLabel()
//        self.todayLabel.gradientColors = ColorUtil.getGradTextStyle3()
//        self.todayPlanLabel.gradientColors = ColorUtil.getGradGray()
    }
    
    /// 分段控件的距离加载——在加载完体能训练之后执行
    func setSegWeekDistanceLabel() {
        if self.thisWeekDateToDist != [:] {
            let idx = self.recent7DaysSegControl.selectedSegmentIndex
            // 20 21 22 23
            let selectedDateStr = self.thisWeekDateStringIndd[idx]
            // [21, 23]
            var sportDate = Array(thisWeekDateToDist.keys)
            sportDate = sportDate.sorted()
            let curIndex = sportDate.enumerated().filter{
                $0.element == selectedDateStr
            }
            
            if sportDate.contains(selectedDateStr) {
                // 实际上这个单位就是用户偏好的单位
                let selectedDis = (self.thisWeekDateToDist[selectedDateStr])!
                self.selectedDistance = selectedDis
                
                
                var todayDistanceLabelTxt = ""
                
                switch UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit") {
                case 0:
                    todayDistanceLabelTxt = String(format: "%.2f", selectedDis) + " " + NSLocalizedString("distanceUnitKM", comment: "")
                    self.selectedDistanceUnit = 0
                case 1:
                    todayDistanceLabelTxt = String(format: "%.2f", selectedDis) + " " + NSLocalizedString("distanceUnitMile", comment: "")
                    self.selectedDistanceUnit = 1
                default:
                    todayDistanceLabelTxt = NSLocalizedString("noRunHint", comment: "")
                }
                
                self.todayLabel.text = todayDistanceLabelTxt

                self.runningFeelingLabel.isHidden = false
                self.addRunningNotesButton.isHidden = false

                // 给当前日期赋值
                self.selectedDateToRunningFeeling = self.thisWeekWKdate[curIndex.first!.offset as Int]
                
                // 查询
                let req: NSFetchRequest<OneDayPlan> = OneDayPlan.fetchRequest()
                let res = try! managedObjectContext.fetch(req)
                if let plan = res.first(where: {$0.runningDate == self.selectedDateToRunningFeeling}) {
                    self.curOneDayPlan = plan
                    print("从数据库中Fetch记录")
                }
                else {
                    
                }

                
            }
            else{
                
                self.todayLabel.text = NSLocalizedString("noRunToday", comment: "")
                self.runningFeelingLabel.isHidden = true
                self.addRunningNotesButton.isHidden = true
                // TODO: 隐藏 Done
                //                self.runningFeelingLabel.isHidden = true
                //                self.addRunningNotesButton.isHidden = true
            }
            
        }
        
    }
    

    
    /// 更新计划！！
    func showPlanedDistanceLabel() {
        // TODO: 从数据库中读取数据 Done
        let selected_dd = self.thisWeekDateStringIndd[self.recent7DaysSegControl.selectedSegmentIndex]
        
        let res = queryPlanInCoreData()
        var planedDistance: String = ""
        
        if res.resInStr.contains(selected_dd) {
            switch UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit") {
            case 0:
                if res.resInStrInt[selected_dd] == 0 {
                    planedDistance = String(format: "%.2f", res.resInStrDouble[selected_dd]!)
                }
                else{
                    planedDistance = String(format: "%.2f", AssistantMethods.distanceMileToKM(res.resInStrDouble[selected_dd]!))
                }
                
                planedDistance += (" " + NSLocalizedString("distanceUnitKM" , comment: ""))
                
                break
            case 1:
                if res.resInStrInt[selected_dd] == 0 {
                    planedDistance = String(format: "%.2f", AssistantMethods.distanceKMtoMile(res.resInStrDouble[selected_dd]!))
                }
                else{
                    planedDistance = String(format: "%.2f", res.resInStrDouble[selected_dd]!)
                }
                planedDistance += (" " + NSLocalizedString("distanceUnitMile" , comment: ""))
                
                break
            default: break
                
            }

            
        }
        else{
            planedDistance = NSLocalizedString("NoPlanToday", comment: "")
        }
        
        
        DispatchQueue.main.async {
            self.todayPlanLabel.text = planedDistance
            
        }
        
        
    }
    
    
    /// 查询计划Core Data
    func queryPlanInCoreData() -> (resInStr: [String], resInStrDouble: [String: Double],  resInStrInt: [String: Int] ) {
        let thisWeekDate = AssistantMethods.getThisWeekStartEndDate()
        // 1. 首先查询Core Data，看今日是否已经制定了目标
        let request: NSFetchRequest<RunningPlan> = RunningPlan.fetchRequest()
        let calendar = Calendar.current
        
        let startDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: thisWeekDate.start)
        let endDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: thisWeekDate.end)
        
        // 谓语——根据日期查询
        let predicate = NSPredicate(format: "targetDate >= %@ AND targetDate <= %@", argumentArray: [startDate, endDate])
        request.predicate = predicate
        var resInStrDouble: [String: Double] = [:]
        var resInStrInt: [String: Int] = [:]
        
        var resInStr: [String] = []
        
        let result = try! managedObjectContext.fetch(request)
        if result.count != 0 {
            for plan in result {
                let df = DateFormatter()
                df.dateFormat = "dd"
                let ddStr = df.string(from: plan.targetDate!)
                resInStr.append(ddStr)
                resInStrDouble[ddStr] = plan.targetDistance
                resInStrInt[ddStr] = Int(plan.distanceUnit)
            }
            return (resInStr, resInStrDouble, resInStrInt)
        }
        else{
            return (resInStr, resInStrDouble, resInStrInt)
        }
        
    }
    

    func setUpFontSmiley() {
        self.navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.label,
            .font: SmileyFontSize.getNormal()
        ]
        
        
        // Label 字体得意黑
        for ll in self.generalSmiley{
            ll.font = SmileyFontSize.getNormal()
        }

        for ll in self.generalSmileyBigger {
            ll.font = SmileyFontSize.getBigger()
        }
        
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedString.Key.font: SmileyFontSize.getNormal()]
        

        for ll in self.footnoteSmiley {
            ll.font = SmileyFontSize.getFootnote()
        }
        let font = SmileyFontSize.getNormal()
        let attributes = [NSAttributedString.Key.font: font]
//        let str = NSAttributedString(string: (self.changeMonTar.titleLabel?.text)!, attributes: attributes)
//        self.changeMonTar.setAttributedTitle(str, for: .normal)
//        self.changeMonTar.setAttributedTitle(str, for: .highlighted)
        for btn in self.myButtons{
            let str = NSAttributedString(string: (btn.titleLabel?.text)!, attributes: attributes)
            btn.setAttributedTitle(str, for: .normal)
            btn.setAttributedTitle(str, for: .highlighted)
        }
        
        /*
        self.runningHintLabel.font = SmileyFontSize.getFootnote()
        
        self.showMoreLabel.font = SmileyFontSize.getNormal()
        
        for ll in self.generalSmileyBigger {
            ll.font = SmileyFontSize.getBigger()
        }
        */
    }

    

    
    

    
    
    func setUpChartsAfterLoadingWorkouts() {
        // 用户偏好的距离单位
        let defaultUnit = UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit")
        // 转换单位 & 保留两位小数
        let d = res.map{
            return AssistantMethods.convertMeterToUnit(defaultUnit, $0)
        }
        self.recent5MonRunningDistance = d
        
        var keyString = ""
        if UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit") == 0
        {
            keyString = "thisMonthTargetVolInKM"
        }
        else if UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit") == 1{
            keyString = "thisMonthTargetVolInMile"
        }
        
        /*
//        self.runningVolProgressLabel.text = "\(Int(self.recent5MonRunningDistance.last!))" + "/" + "\(Int(UserDefaults.standard.double(forKey: keyString)))" + " " + UserDefaults.standard.string(forKey: "distanceUnitDefaultAb")!
        
        // 本月跑量进度
        let progressThisM = Double(self.recent5MonRunningDistance.last!) / Double(UserDefaults.standard.double(forKey: keyString))
        // "circleProgessLatest"
        
        // 如果现在fetch的进度不同于上一次的进度，那么更新"circleProgess"的值
        let oldVal = UserDefaults.standard.double(forKey: "circleProgess")
        if oldVal != progressThisM {
            self.setUpCircleProgress()
            
            UserDefaults.standard.set(progressThisM, forKey: "circleProgess")
            self.refreshCicleProgress()
        }
        else {
            self.setUpCircleProgress()
        }
//        self.runningHintLabel.text = "\(Int(progressThisM*100))%" + NSLocalizedString("cicleProgressHint", comment: "")
        */
//        self.setUpFirstPurpleBarChart_Data()
        self.loadThisWeekDist()
        self.setSegWeekDistanceLabel()
        
    }
    
    func loadThisWeekDist() {
        guard let wk = self.workouts else {return }
        if self.workouts != [] && !self.workouts.isEmpty && self.workouts != nil {
            let res = QueryWorkoutsAssistant.getRecentSevenDaysDistance(self.workouts)
            let defaultUnit = UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit")
            // 转换单位 & 保留两位小数
            let disInUnit = res.dis.map {
                return AssistantMethods.convertMeterToUnit(defaultUnit, $0)
            }
            
            var dateToDis: [String: Double] = [:]
            
            for i in 0..<res.dateArray.count {
                dateToDis[res.dateArray[i]] = disInUnit[i]
            }
            self.thisWeekDateToDist = dateToDis
            self.thisWeekWKdate = res.dateInDate
        }
        
        
    }
    

    
    


    
    @IBAction func addButtonClicked(sender : AnyObject){
        let alertController = UIAlertController(title: NSLocalizedString("targetVolTextFieldTitle", comment: ""), message: NSLocalizedString("targetVolTextFieldMessage", comment: ""), preferredStyle: .alert)
        
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = NSLocalizedString("validValHint_v001" , comment: "") + UserDefaults.standard.string(forKey: "distanceUnitDefaultAb")!
        }
        
        let saveAction = UIAlertAction(title: NSLocalizedString("targetVolTextFieldSave", comment: ""), style: .default, handler: { alert -> Void in
            let firstTextField = alertController.textFields![0] as UITextField
            
        
            if let distanceToModify = Double(firstTextField.text!) {
                if distanceToModify > 0.0 {
                    // 修改目标值
                    if UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit") == 0 {
                        // KM
                        UserDefaults.standard.set(distanceToModify, forKey: "thisMonthTargetVolInKM")
                        
                        // KM -> Mile
                        UserDefaults.standard.set((distanceToModify*1000)*PaceCalculatorMethods.ConvertMeterToPaceunit.toMile.rawValue, forKey: "thisMonthTargetVolInMile")
                        
                    }
                    else if UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit") == 1 {
                        // Mile
                        UserDefaults.standard.set(distanceToModify, forKey: "thisMonthTargetVolInMile")
                        // Mile -> KM
                        let convertConstantMileToKM: Double = 1.609344
                        UserDefaults.standard.set(distanceToModify*convertConstantMileToKM, forKey: "thisMonthTargetVolInKM")
                    }
                    else{}
                    
                    
                    // 更新UI
                    /*
                    DispatchQueue.main.async {
                        // XX/YY 公里
                        if UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit") == 0
                        {
                            self.runningVolProgressLabel.text = "\(Int(self.recent5MonRunningDistance.last!))" + "/" + "\(Int(UserDefaults.standard.double(forKey: "thisMonthTargetVolInKM")))" + " " + UserDefaults.standard.string(forKey: "distanceUnitDefaultAb")!
                            
                            // 本月跑量进度
                            let progressThisM = Double(self.recent5MonRunningDistance.last!) / Double(UserDefaults.standard.double(forKey: "thisMonthTargetVolInKM"))
                            UserDefaults.standard.set(progressThisM, forKey: "circleProgess")
                            
                            self.runningHintLabel.text = "\(Int(progressThisM*100))%" + NSLocalizedString("cicleProgressHint", comment: "")
                        }
                        else if UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit") == 1 {
                            self.runningVolProgressLabel.text = "\(Int(self.recent5MonRunningDistance.last!))" + "/" + "\(Int(UserDefaults.standard.double(forKey: "thisMonthTargetVolInMile")))" + " " + UserDefaults.standard.string(forKey: "distanceUnitDefaultAb")!
                            
                            // 本月跑量进度
                            let progressThisM = Double(self.recent5MonRunningDistance.last!) / Double(UserDefaults.standard.double(forKey: "thisMonthTargetVolInMile"))
                            UserDefaults.standard.set(progressThisM, forKey: "circleProgess")
                            
                            self.runningHintLabel.text = "\(Int(progressThisM*100))%" + NSLocalizedString("cicleProgressHint", comment: "")
                        }
                        else {
                            
                        }
                        
                        self.refreshCicleProgress()
                    }
                    */
                }

            }
            else{
                print("NO")
            }
            
        })
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("targetVolTextFieldCancel", comment: ""), style: .cancel, handler: {
            (action : UIAlertAction!) -> Void in })
        
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    

    func setUpBKcolor(){
//        self.view.backgroundColor = ColorUtil.getBackgroundColorStyle1()
//        self.sView.backgroundColor = ColorUtil.getBackgroundColorStyle1()
    }
    
    func setUpNavigationUI(){
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [.foregroundColor: ColorUtil.getGeneralTintColorStyle1()]
        appearance.largeTitleTextAttributes = [.foregroundColor: ColorUtil.getGeneralTintColorStyle1()]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
    }
}


// MARK: - UI
/*
extension RootViewController{
 /// 刷新圆环进度
 func refreshCicleProgress() {
     DispatchQueue.main.async {
         UIView.animate(withDuration: 1) {
             self.ringProgressView.progress = UserDefaults.standard.double(forKey: "circleProgess")
         }
         
     }
     
 }
    // MARK: 图像配置
    func setUpFirstPurpleBarChart_Data() {

        let data = self.recent5MonRunningDistance.enumerated().map{
            return (x: $0, y: $1)
        }
        
        let monName = AssistantMethods.getRecent5MonName() as Array<String>

        
        chart.xLabelsFormatter = { (labelIndex: Int, labelValue: Double) -> String in
            return monName[labelIndex]
        }

        let series = ChartSeries(data: data)
        series.area = true
        
        series.color = ColorUtil.getSeriesColor()
        
        
        chart.add(series)

        self.lineChartUIView.addSubview(chart)
        
    }

    
    
    func setUpFirstPurpleBarChart_UI() {
        let vv: UIView = self.lineChartUIView
//        vv.layer.shadowColor = ColorUtil.runningOverviewLayerShadowColor()
//        vv.layer.cornerRadius = uniUISetting.cornerRadius
//        vv.layer.shadowOffset = uniUISetting.shadowOffset
//        vv.layer.shadowRadius = uniUISetting.shadowRadius
//        vv.layer.shadowOpacity = uniUISetting.shadowOpcacity
//        gradient.frame = self.lineChartUIView.bounds
//        vv.clipsToBounds = true
//        gradient.colors = ColorUtil.rootVCPurpleGradColor().map{$0.cgColor}
//
//        self.lineChartUIView.layer.insertSublayer(gradient, at: 0)
        vv.layer.cornerRadius = uniUISetting.cornerRadius
        vv.layer.shadowColor = uniUISetting.shadowColor
        vv.layer.shadowOffset = uniUISetting.shadowOffset
        vv.layer.shadowRadius = uniUISetting.shadowRadius
        vv.layer.shadowOpacity = uniUISetting.shadowOpcacity
        vv.backgroundColor = ColorUtil.getMonthlyStatViewBKColor()
        chart = Chart(frame: self.actualChartRegion.frame)
        chart.center = self.actualChartRegion.center
        
        chart.labelColor = ColorUtil.dynamicColor(dark: UIColor.white, light: UIColor.black)
        
    }
    

    
    
    /// 正方形指标的UIviews 样式 渐变设置
    func setUpSquareUIViews() {
        
        for (index, element) in self.squareUIViews.enumerated() {
            let vv = element
            vv.layer.cornerRadius = uniUISetting.cornerRadius
            vv.layer.shadowColor = uniUISetting.shadowColor
            vv.layer.shadowOffset = uniUISetting.shadowOffset
            vv.layer.shadowRadius = uniUISetting.shadowRadius
            vv.layer.shadowOpacity = uniUISetting.shadowOpcacity
            vv.clipsToBounds = true
            vv.backgroundColor = ColorUtil.rootVCSquareGradColorStyle2()
//            let gradient = CAGradientLayer()
//            gradient.frame = vv.bounds
//
//            switch index {
//            case 0:
//                gradient.colors = ColorUtil.rootVCSquareGradColorStyle2().map{$0.cgColor}
//            case 1:
//                gradient.colors = ColorUtil.rootVCSquareGradColorStyle2().map{$0.cgColor}
//            default:
//                gradient.colors = ColorUtil.rootVCSquareGradColorStyle2().map{$0.cgColor}
//            }
//            self.squareGrad.append(gradient)
//            vv.layer.insertSublayer(gradient, at: 0)
        }
        
        
    }
    
    

    

    func updateIndicatorVal() {
        let userUnit = UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit")
        var totalDistanceToShow: String = " "
        switch userUnit {
        case 0:
            totalDistanceToShow = UserDefaults.standard.string(forKey: "lastMonthRunningDistanceInKM")!
        case 1:
            totalDistanceToShow = UserDefaults.standard.string(forKey: "lastMonthRunningDistanceInMile")!
        case 2:
            totalDistanceToShow = UserDefaults.standard.string(forKey: "lastMonthRunningDistanceInMeter")!
        default:
            totalDistanceToShow = UserDefaults.standard.string(forKey: "lastMonthRunningDistanceInKM")!
        }
        self.lastMonthLabel.text = totalDistanceToShow
    }
    
    

    
    
    func setUpRectUIViews() {
        
        for vv in self.rectIndicator {
            vv.layer.shadowColor = uniUISetting.shadowColor
            vv.layer.shadowOffset = uniUISetting.shadowOffset
            vv.layer.shadowRadius = uniUISetting.shadowRadius
            vv.layer.shadowOpacity = uniUISetting.shadowOpcacity
            
            vv.clipsToBounds = true
            
            let gradient = CAGradientLayer()
            gradient.frame = vv.bounds
            gradient.colors = ColorUtil.rootVCRectGradColor().map{$0.cgColor}
            self.rectGrad.append(gradient)
            vv.layer.insertSublayer(gradient, at: 0)
        }
    }
    
    func setUpCircleProgress() {
        ringProgressView = RingProgressView(frame: CGRect(x: 10, y: 10, width: 150, height: 150))
        let colors = [
            UIColor(red: 0.976, green: 0.831, blue: 0.137, alpha: 1),
            UIColor(red: 0.902, green: 0.361, blue: 0.000, alpha: 1)
            
            ]

        ringProgressView.startColor = colors[0]
        ringProgressView.endColor = colors[1]
        ringProgressView.ringWidth = 25
        ringProgressView.progress = UserDefaults.standard.double(forKey: "circleProgess")
        
        self.squareUIViews[0].addSubview(ringProgressView)
        
    }


    
    
    
}
*/

extension CAGradientLayer
{
    func animateChanges(to colors: [UIColor],
                        duration: TimeInterval)
    {
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            // Set to final colors when animation ends
            self.colors = colors.map{ $0.cgColor }
        })
        let animation = CABasicAnimation(keyPath: "colors")
        animation.duration = duration
        animation.toValue = colors.map{ $0.cgColor }
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.isRemovedOnCompletion = false
        add(animation, forKey: "changeColors")
        CATransaction.commit()
    }
}



extension UISegmentedControl{
    func removeBorder(){
        let backgroundImage = UIImage.getColoredRectImageWith(color: UIColor.systemGroupedBackground.cgColor, andSize: self.bounds.size)
        self.setBackgroundImage(backgroundImage, for: .normal, barMetrics: .default)
        self.setBackgroundImage(backgroundImage, for: .selected, barMetrics: .default)
        self.setBackgroundImage(backgroundImage, for: .highlighted, barMetrics: .default)

//        let deviderImage = UIImage.getColoredRectImageWith(color: UIColor.systemGroupedBackground.cgColor, andSize: CGSize(width: 1, height: self.bounds.size.height))
        let deviderImage = UIImage.getColoredRectImageWith(color: UIColor.systemGray5.cgColor, andSize: CGSize(width: 1, height: self.bounds.size.height))
        self.setDividerImage(deviderImage, forLeftSegmentState: .selected, rightSegmentState: .normal, barMetrics: .default)
        self.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.gray], for: .normal)
        self.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: ColorUtil.getBarBtnColor()], for: .selected)
        if UserDefaults.standard.bool(forKey: "useSmiley") {
            self.setTitleTextAttributes([NSAttributedString.Key.font: SmileyFontSize.getNormal()], for: .normal)
        }
        else{
            self.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .bold)], for: .normal)
        }
        
    }

    func addUnderlineForSelectedSegment(){
        removeBorder()
        let underlineWidth: CGFloat = self.bounds.size.width / CGFloat(self.numberOfSegments)
        let underlineHeight: CGFloat = 2.0
        let underlineXPosition = CGFloat(selectedSegmentIndex * Int(underlineWidth))
        let underLineYPosition = self.bounds.size.height - 1.0
        let underlineFrame = CGRect(x: underlineXPosition, y: underLineYPosition, width: underlineWidth, height: underlineHeight)
        let underline = UIView(frame: underlineFrame)
        underline.backgroundColor = UIColor.label
        underline.tag = 1
        self.addSubview(underline)
    }

    
    func deleteUnderlineForSelectedSegment(){
        removeBorder()
        let underlineWidth: CGFloat = self.bounds.size.width / CGFloat(self.numberOfSegments)
        let underlineHeight: CGFloat = 2.0
        let underlineXPosition = CGFloat(selectedSegmentIndex * Int(underlineWidth))
        let underLineYPosition = self.bounds.size.height - 1.0
        let underlineFrame = CGRect(x: underlineXPosition, y: underLineYPosition, width: underlineWidth, height: underlineHeight)
        let underline = UIView(frame: underlineFrame)
        underline.backgroundColor = ColorUtil.getBarBtnColor()
        underline.tag = 1
        underline.removeFromSuperview()
    }
    
    
    func changeUnderlinePosition(){
        guard let underline = self.viewWithTag(1) else {return}
        let underlineFinalXPosition = (self.bounds.width / CGFloat(self.numberOfSegments)) * CGFloat(selectedSegmentIndex)
        UIView.animate(withDuration: 0.1, animations: {
            underline.frame.origin.x = underlineFinalXPosition
        })
    }
}

extension UIImage{

    class func getColoredRectImageWith(color: CGColor, andSize size: CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let graphicsContext = UIGraphicsGetCurrentContext()
        graphicsContext?.setFillColor(color)
        let rectangle = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        graphicsContext?.fill(rectangle)
        let rectangleImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return rectangleImage!
    }
}




