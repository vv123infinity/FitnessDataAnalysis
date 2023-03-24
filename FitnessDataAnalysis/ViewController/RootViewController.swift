//
//  ViewController.swift
//  FitnessDataAnalysis
//
//  Created by 十口V🌼 on 2023/2/24.
//

import UIKit
import HealthKit
import MKRingProgressView


class RootViewController: UIViewController {

    // MARK: - 接口

    @IBOutlet var sView: UIScrollView!
    /// 上个月跑量Label
    @IBOutlet weak var lastMonthLabel: UILabel!
    @IBOutlet weak var myButton: UIButton!
    /// 跑鞋图像
//    @IBOutlet weak var runningShoeImg: UIImageView!
    /// 设置logo
    @IBOutlet weak var settingBarBtn: UIBarButtonItem!
    /// 工具logo
    @IBOutlet weak var toolboxBarBtn: UIBarButtonItem!
    
    /// 圆环UIView
    @IBOutlet weak var targetProgressCicleProgress: UIView!
    /// 本月目标跑量Label
    @IBOutlet weak var runningVolProgressLabel: UILabel!
    /// 本月跑量提示Label
    @IBOutlet weak var runningHintLabel: UILabel!
    
    
    @IBOutlet var rectIndicator: [UIView]!
    
    
    
    /// 第一个chart的UIView
    @IBOutlet weak var lineChartUIView: UIView!
    /// 第一个chart的作图区域View
    @IBOutlet weak var actualChartRegion: UIView!
    
    /// 第一个chart的显示更多指标
    @IBOutlet weak var showMoreLabel: UILabel!

    @IBOutlet weak var dateRangeLabel: UILabel!
    @IBOutlet weak var chartTotalDistance: UILabel!
    
    /// 正方形指标
    @IBOutlet var squareUIViews: [UIView]!
    
    /// 第一个正方形指标的menu button
    @IBOutlet weak var indicatorButton1: UIButton!
    /// 第二个正方形指标的menu button
    @IBOutlet weak var indicatorButton2: UIButton!
    /// 近一周跑量UILabel
    @IBOutlet weak var recentWeekLabel: UILabel!
    /// 今天跑量
    @IBOutlet weak var todayLabel: UILabel!
    /// 今天 - 按钮，如果今天没跑，按钮隐藏
    @IBOutlet weak var todayButton: UIButton!
    
    /// 得意黑17
    @IBOutlet var generalSmiley: [UILabel]!
    @IBOutlet var generalSmileyBig: [UILabel]!
    /// 得意黑22
    @IBOutlet var generalSmileyBigger: [UILabel]!
    
    // MARK: - 属性
    var loadedWorkouts: [HKWorkout]!
    lazy var gradient = CAGradientLayer()
    var squareGrad: [CAGradientLayer] = []
    var rectGrad: [CAGradientLayer] = []
    var chart: Chart!
    var currentIndicator1Title: String = ""
    var currentIndicator2Title: String = ""
    
    /// 所有的workout
    var workouts: [HKWorkout]!
    /// 最近六个月的跑步距离
    var recent5MonRunningDistance: [Double] = []
    /// 全部距离
    var res: [Double] = []
    /// 通用UI设置结构体
    var uniUISetting = UniversalUISettings()
    var ringProgressView: RingProgressView! = nil
    var initDistanceUnit: Int = -1
    
    var hasChanged: Bool = false
    
    // MARK: - 应用周期
    override func viewDidLoad() {
        super.viewDidLoad()
        // 2. UI 设置
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        self.uiSettings()
        let backItem = UIBarButtonItem()
        backItem.title = ""
        self.navigationItem.backBarButtonItem = backItem // This will
        
        // 3. 加载体能训练并更新各个label

        if UserDefaults.standard.bool(forKey: "ShowRunningOverviewChart"){
            
            WorkoutDataStore.loadLastWorkouts() { (res, error) in
                // 可以成功访问Workout类型的数据
                if res != nil && res!.count != 0 && error == nil{
                    self.loadWorkoutsAndGetDistance()
                    
                    
                }
                else {
                    self.sView.isHidden = true
                }
                
            }
        }

        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        


        
        if UserDefaults.standard.bool(forKey: "UnitHasChanged")  {
            self.chart.removeFromSuperview()
            self.ringProgressView.removeFromSuperview()
            
            self.ringProgressView = RingProgressView()

            self.chart.series = []
            chart = Chart(frame: self.actualChartRegion.frame)
            chart.center = self.actualChartRegion.center
            
            chart.labelColor = ColorUtil.dynamicColor(dark: UIColor.white, light: UIColor.black)
            self.setUpChartsAfterLoadingWorkouts()
            // 需要重新读取 处理数据
            UserDefaults.standard.setValue(false, forKey: "UnitHasChanged")
        }

       
        WorkoutDataStore.loadLastWorkouts() { (res, error) in
            // 可以成功访问Workout类型的数据
            if res != nil && res!.count != 0 && error == nil{
//                self.loadWorkoutsAndGetDistance()
            }
            else {
                self.sView.isHidden = true
            }
            
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        self.chart.removeFromSuperview()

        
//        self.ringProgressView.removeFromSuperview()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {

    }
    
    
    override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
    }
    
    
    func refreshCicleProgress() {
        DispatchQueue.main.async {
            
            UIView.animate(withDuration: 1) {
                self.ringProgressView.progress = UserDefaults.standard.double(forKey: "circleProgess")
            }
            
        }
        
    }
    // MARK: - 接口接口接口
    @IBAction func settingBtnPressed(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SettingRootTable") as! SettingRootTable
        self.hasChanged = true
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func toolBtnPressed(_ sender: UIBarButtonItem) {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ToolboxRoot") as! ToolboxRoot

        self.navigationController?.pushViewController(vc, animated: true)
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
    

    // MARK: - 初始化
    /// 应用初始化设置。
    /// - 用户偏好设置默认值设置。
    func initSetUp(){
        UserPreferenceSetting.setUpUserPreference()
    }
    

    // MARK: 基础UI的配置
    /// 基础UI的配置
    func uiSettings() {
        
        // 1. 得意黑
        if UserDefaults.standard.bool(forKey: "useSmiley"){
            self.setUpFontSmiley()
        }

        
        // 3. 背景颜色
        self.navigationController?.navigationBar.tintColor = ColorUtil.getBarBtnColor()
        
        
        
        self.setUpBKcolor()

        // 5. bar btn
        self.settingBarBtn.tintColor = ColorUtil.getBarBtnColor()
        self.toolboxBarBtn.tintColor = ColorUtil.getBarBtnColor()
        // 6.
        self.setUpFirstPurpleBarChart_UI()
        // 7. 正方形指标的背景渐变设置
        self.setUpSquareUIViews()
        
        // 8. 更新指标1的默认值
        self.updateIndicator1()
        // 配置menu菜单
        self.setUpIndicatorButton1()
        
//        self.setUpRectUIViews()
        self.showMoreLabel.textColor = ColorUtil.getBarBtnColor()
        

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
        for ll in self.generalSmileyBig {
            ll.font = SmileyFontSize.getBig()
            
        }
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedString.Key.font: SmileyFontSize.getNormal()]
        
        self.runningHintLabel.font = SmileyFontSize.getFootnote()
        
        self.showMoreLabel.font = SmileyFontSize.getNormal()
        
//        self.showMoreButton.setAttributedTitle([NSAttributedString.Key.foregroundColor: ColorUtil.getBarBtnColor(), NSAttributedString.Key.font : SmileyFontSize.getNormal()], for: .normal)
        
        
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
        
        self.squareUIViews[2].addSubview(ringProgressView)
        
    }
    
    
    // MARK: 浅深色模式
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        DispatchQueue.main.async {
//            self.lineChartUIView.willRemoveSubview(self.chart)
            self.gradient.animateChanges(to: ColorUtil.rootVCPurpleGradColor(), duration: 0.5)
            
            for (index, element) in self.squareGrad.enumerated() {
                switch index {
                case 0:
                    element.animateChanges(to: ColorUtil.rootVCSquareGradColorStyle1(), duration: 0.5)
                case 1:
                    element.animateChanges(to: ColorUtil.rootVCSquareGradColorStyle2(), duration: 0.5)
                default:
                    element.animateChanges(to: ColorUtil.rootVCSquareGradColorStyle2(), duration: 0.5)
                }
            }
            
            for i in self.rectGrad {
                i.animateChanges(to: ColorUtil.rootVCRectGradColor(), duration: 0.5)
            }
            self.chart.series = []
            self.chart = Chart(frame: self.actualChartRegion.frame)
            self.chart.center = self.actualChartRegion.center
            
            self.chart.labelColor = ColorUtil.dynamicColor(dark: UIColor.white, light: UIColor.black)
            
            self.chart.removeFromSuperview()
            self.setUpFirstPurpleBarChart_Data()

        }
        
        
    }
    // MARK: 加载体能训练
    func loadWorkoutsAndGetDistance() {
        WorkoutDataStore.loadWorkouts() { (workouts, error) in
            self.workouts = workouts
            // 得到距离，单位米
            let res = QueryWorkoutsAssistant.queryRecent5MonRunningDistance(workouts!, "zh_CN")
            self.res = res
            // 根据用户喜爱的单位
            self.setUpChartsAfterLoadingWorkouts()
            
        }
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
        
        self.runningVolProgressLabel.text = "\(Int(self.recent5MonRunningDistance.last!))" + "/" + "\(Int(UserDefaults.standard.double(forKey: keyString)))" + " " + UserDefaults.standard.string(forKey: "distanceUnitDefaultAb")!
        
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
        self.runningHintLabel.text = "\(Int(progressThisM*100))%" + NSLocalizedString("cicleProgressHint", comment: "")
        
        self.setUpFirstPurpleBarChart_Data()
        self.setUpWeekAndTodayLabel()
    }
    
    func setUpWeekAndTodayLabel() {
        let defaultUnit = UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit")
        
        let res = QueryWorkoutsAssistant.getTodayDistance(self.workouts)
        let resSeven = QueryWorkoutsAssistant.getRecentSevenDaysDistance(self.workouts)
        let sevenD = AssistantMethods.convertMeterToUnit(defaultUnit, resSeven.sevenDays)
        let todayD = AssistantMethods.convertMeterToUnit(defaultUnit, res)
        
        if todayD == 0.0 {
            self.todayLabel.text = NSLocalizedString("todayComeOn", comment: "")
            self.todayButton.isHidden = true
        }
        else{
            self.todayLabel.text = String(format: "%.2f", todayD) + " " + UserDefaults.standard.string(forKey: "distanceUnitDefaultAb")!
            self.todayButton.isHidden = false
        }

        self.recentWeekLabel.text = String(format: "%.2f", sevenD) + " " + UserDefaults.standard.string(forKey: "distanceUnitDefaultAb")!
        
    }
    
    // MARK: 图像配置
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
            let gradient = CAGradientLayer()
            gradient.frame = vv.bounds
            
            switch index {
            case 0:
                gradient.colors = ColorUtil.rootVCSquareGradColorStyle1().map{$0.cgColor}
            case 1:
                gradient.colors = ColorUtil.rootVCSquareGradColorStyle2().map{$0.cgColor}
            default:
                gradient.colors = ColorUtil.rootVCSquareGradColorStyle2().map{$0.cgColor}
            }
            self.squareGrad.append(gradient)
            vv.layer.insertSublayer(gradient, at: 0)
        }
        
        
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
    
    func setUpIndicatorButton1(){
        let a1 = UIAction(title: NSLocalizedString("indicator_1_pace", comment: "")) { (action) in
            UserDefaults.standard.set(NSLocalizedString("indicator_1_pace", comment: ""), forKey: "indicator_1_selection")
            UserDefaults.standard.set(0, forKey: "IndicatorOneType")
            self.updateIndicator1()
            }
        let a2 = UIAction(title: NSLocalizedString("indicator_1_action2", comment: "")) { (action) in
            UserDefaults.standard.set(NSLocalizedString("indicator_1_action2", comment: ""), forKey: "indicator_1_selection")
            UserDefaults.standard.set(1, forKey: "IndicatorOneType")
            
            self.updateIndicator1()
            }

        let menuTitle = NSLocalizedString("indicator_1_title", comment: "")
        let menu = UIMenu(title: menuTitle, options: .singleSelection, children: [a1, a2])

        self.indicatorButton1.menu = menu
        self.indicatorButton1.showsMenuAsPrimaryAction = true
        // 对齐情况
        self.indicatorButton1.configuration?.titleAlignment = .trailing
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
    }
    
    

    
}


// MARK: - UI
extension RootViewController{
    
    func updateIndicator1(){
        self.indicatorButton1.setTitle(UserDefaults.standard.string(forKey: "indicator_1_selection"), for: .normal)
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
    
    
    func setUpBKcolor(){
        self.view.backgroundColor = ColorUtil.getBackgroundColorStyle1()
        self.sView.backgroundColor = ColorUtil.getBackgroundColorStyle1()
    }
    
    func setUpNavigationUI(){
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [.foregroundColor: ColorUtil.getGeneralTintColorStyle1()]
        appearance.largeTitleTextAttributes = [.foregroundColor: ColorUtil.getGeneralTintColorStyle1()]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
    }
    
    
    

    
    
    
}

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

