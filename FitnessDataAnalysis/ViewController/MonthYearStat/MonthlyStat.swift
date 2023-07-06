//
//  MonthlyStat.swift
//  FitnessDataAnalysis
//
//  Created by 十口V🌼 on 2023/3/19.
//

import UIKit
import HealthKit
import AAInfographics
import Fastis


class MonthlyStat: UIViewController {

    @IBOutlet weak var sView: UIScrollView!

    /// 本月日期
    @IBOutlet weak var thisMonthDateLabel: UILabel!
    

    @IBOutlet weak var predictionUIImage: UIImageView!
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var labelView: UIView!
    
    @IBOutlet var generalSmileyLabel: [UILabel]!
    @IBOutlet var SmileyLabelBigger: [UILabel]!
    @IBOutlet var footnoteSmileyLabel: [UILabel]!
    
    @IBOutlet var generalSmileyButton: [UIButton]!
    @IBOutlet var SmileyLabelBig: [UILabel]!
    
    @IBOutlet weak var datePickerBtn: UIButton!
    
    @IBOutlet var indicatorUIView: [UIView]!
    @IBOutlet var indicatorUILabel: [UILabel]!
    /// 所有Stack View
    @IBOutlet var allStackView: [UIStackView]!
    
    /// 绘制Style1图表的Button
    /// 0️⃣ 总距离
    @IBOutlet var style1PlotButton: [UIButton]!
    
    /// 展示sheet的按钮
    @IBOutlet var showSheetButtons: [UIButton]!
    
    
    // MARK: 各项指标 - Overview
    /// 累计里程
    @IBOutlet var accDistance: UILabel!
    /// 累计时间
    @IBOutlet var accTime: UILabel!
    /// 平均配速
    @IBOutlet var avgPace: UILabel!
    /// 跑步次数
    @IBOutlet var numOfRuns: UILabel!
    /// 最远距离
    @IBOutlet var maxDistance: UILabel!
    /// 最快配速
    @IBOutlet var maxPace: UILabel!
    /// 平均功率
    @IBOutlet var avgPower: UILabel!
    /// 平均步频
    @IBOutlet var avgCadence: UILabel!
    /// 平均心率
    @IBOutlet var avgHR: UILabel!
    /// 平均卡路里
    @IBOutlet var avgCalorie: UILabel!
    
    /// 数据来源
    @IBOutlet var dataSourceLabel: UILabel!
    
    @IBOutlet var tempView: UIView!
    
    // MARK: properties
    lazy var uniUISetting = UniversalUISettings()
    var workouts: [HKWorkout] = []

    var userDefineDateFlag: Bool = false
    /// 起始日期（默认本月初）
    var startDate: Date!
    /// 结束日期（默认现在）
    var endDate: Date!
    
    var result: (workoutDate: [String], accDistance: String, accTime: String, avgPace: String, numOfRuns: String, distanceArray: [Double], maxDistance: String, maxPace: String, avgPower: String, avgCadence: String, avgHR: String, avgCalorie: String, dataSource: Set<String>, maxDistanceDate: String, maxPaceDate: String, avgTime: String)!
    /// 运动类型
    var sportType: Int = 0
    
    // MARK: 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getAndSetDateTitle()
        
        self.setUpUI()
        
        WorkoutDataStore.loadLastWorkouts() { (res, error) in
            // 可以成功访问Workout类型的数据
            if res != nil && res!.count != 0 && error == nil{
                self.loadWorkoutsAndGetDistance()
            }
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: 接口接口
    @IBAction func choosePickerBtnPressed(_ sender: UIBarButtonItem) {
        chooseDate()
    }
    
    func chooseDate() {
        let fastisController = FastisController(mode: .range)
        fastisController.title = NSLocalizedString("datePickerChooseDateRange", comment: "")
        if UserDefaults.standard.bool(forKey: "useSmiley"){
            DispatchQueue.main.async {
                fastisController.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedString.Key.font: SmileyFontSize.getNormal()]
                
            }
        }
        
        fastisController.maximumDate = Date()
        fastisController.allowToChooseNilDate = true
        fastisController.shortcuts = [.lastWeek, .lastMonth, .thisYear]
        fastisController.dismissHandler = {
            fastisController.navigationController?.popViewController(animated: true)
        }
        fastisController.doneHandler = { resultRange in
            guard let fDate = resultRange?.fromDate,
                  let tDate = resultRange?.toDate else{
                return
            }
            self.startDate = resultRange?.fromDate
            self.endDate = resultRange?.toDate
            UserDefaults.standard.set(self.startDate!, forKey: "lastQueryDateStart")
            UserDefaults.standard.set(self.endDate!, forKey: "lastQueryDateEnd")
            self.userDefineDateFlag = true
            self.loadWorkoutsAndGetDistance()

            fastisController.navigationController?.popViewController(animated: true)
        }
        
//        fastisController.present(above: self)
        self.navigationController?.pushViewController(fastisController, animated: true)
        
    }
    
    
    func setUpUI() {
        if UserDefaults.standard.bool(forKey: "useSmiley"){
            DispatchQueue.main.async {
                self.setUpFontSmiley()
            }
        }

        
        else {
            // 字体
            for ll in self.SmileyLabelBig {
//                ll.font = SmileyFontSize.getInSize(19)
//                ll.font = UIFont.monospacedSystemFont(ofSize: 19, weight: .semibold)
//                ll.font = UIFont.italicSystemFont(ofSize: 19)
                ll.font = UIFont.monospacedDigitSystemFont(ofSize: 19, weight: .semibold)
//                ll.font = UIFo
            }
        }
        
        self.setUpContentView()
        self.setImageView()
        self.addBlurEffect()
        self.setUpIndicatorUIView()
        
        // 设置本月的日期

        self.thisMonthDateLabel.layer.cornerRadius = 10
        self.setDateRangeLabel()
        self.setUpFootnoteColor()
        self.datePickerBtn.configuration?.titleAlignment = .trailing
        // TODO: 删除-

//        self.tempView.backgroundColor = ColorUtil.getBarBtnColor_lowAlpha()
//        self.tempView.layer.cornerRadius = 10
        
        // 暂时 —— 纵向
//        for sv in self.allStackView {
//            sv.axis = .vertical
//        }
    }

    func setUpIndicatorUIView(){
        for vv in self.indicatorUIView {
            vv.layer.cornerRadius = 10
            vv.backgroundColor = UIColor.systemGray6
        }
    }
    func setUpFootnoteColor(){
        
        for ll in self.footnoteSmileyLabel{
            ll.textColor = UIColor.gray
        }
        
        
    }
    
    
    
    
    func setUpFontSmiley() {
        self.navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.label,
            .font: SmileyFontSize.getNormal()
        ]
        // Button
        
        
        for ll in self.footnoteSmileyLabel {
            ll.font = SmileyFontSize.getFootnote()
        }
        
        // Label 字体得意黑
        for ll in self.generalSmileyLabel {
            ll.font = SmileyFontSize.getNormal()
        }
        for ll in self.SmileyLabelBigger {
            ll.font = SmileyFontSize.getBigger()
        }

        for ll in self.SmileyLabelBig {
            ll.font = SmileyFontSize.getBig()
        }
        let font = SmileyFontSize.getNormal()
        let att = [NSAttributedString.Key.font: font]
        for btn in self.generalSmileyButton {
            let str = NSAttributedString(string: btn.titleLabel!.text!, attributes: att)
            btn.setAttributedTitle(str, for: .normal)
            btn.setAttributedTitle(str, for: .highlighted)
        }
        
    }
    
    func setDateRangeLabel(){
        let calendar = Calendar.current
        // 设置要展现的日期形式
        let dateFormatter4 = DateFormatter()
        dateFormatter4.locale = Locale(identifier: "en")
        dateFormatter4.dateFormat = "yyyy-MM-dd"
        // 获取字符串
        let startDateInString = dateFormatter4.string(from: self.startDate)
//        let actualEndDate = calendar.date(byAdding: .day, value: -1, to: self.endDate)!
        let actualEndDate = self.endDate
        let endDateInString = dateFormatter4.string(from: actualEndDate!)
        var dateToShow = ""
        if startDateInString == endDateInString {
            dateToShow = startDateInString
        }
        else {
            dateToShow = startDateInString + NSLocalizedString("dateTo", comment: "") + endDateInString
        }
        
        // 赋值给Label
        
        if self.workouts.count > 0 {
            self.thisMonthDateLabel.text = dateToShow
        }
        else {
            self.thisMonthDateLabel.text = NSLocalizedString("noRunRecordsP0", comment: "") + dateToShow + NSLocalizedString("noRunRecordsP1", comment: "") + "🥹"
        }
        
    }

    func getAndSetDateTitle() {
        let dateFormatter4 = DateFormatter()
        dateFormatter4.locale = Locale(identifier: "en")
        dateFormatter4.dateFormat = "yyyy-MM"
        let res = AssistantMethods.getThisMonthStartEndDate(Date.init(), Date.init(), self.userDefineDateFlag)
        self.startDate = res.startDate
        self.endDate = res.endDate
    }
    


    func setUpContentView() {
        
        self.navigationController?.navigationBar.tintColor = ColorUtil.getBarBtnColor()
        
    }
    
    func setImageView(){
        self.predictionUIImage.layer.cornerRadius = uniUISetting.cornerRadius
        self.predictionUIImage.layer.masksToBounds = true
        
    }
    func addBlurEffect(){
        //首先创建一个模糊效果
        let blurEffect = UIBlurEffect(style: .light)
        //接着创建一个承载模糊效果的视图
        let blurView = UIVisualEffectView(effect: blurEffect)
        //设置模糊视图的大小（全屏）

        self.blurView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: uniUISetting.cornerRadius)
        
        blurView.frame.size = CGSize(width: self.blurView.frame.width, height: self.blurView.frame.height)
        blurView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: uniUISetting.cornerRadius)
        
        //创建并添加vibrancy视图
        let vibrancyView = UIVisualEffectView(effect:
                                                UIVibrancyEffect(blurEffect: blurEffect))
        vibrancyView.frame.size = CGSize(width: self.blurView.frame.width, height: self.blurView.frame.height)
        
        vibrancyView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: uniUISetting.cornerRadius)
        
        //将文本标签添加到vibrancy视图中
        let label = UILabel(frame: self.labelView.frame)
        label.text = "跑量预测（beta）"
        label.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        label.textAlignment = .left
        label.textColor = UIColor.black
        
//        vibrancyView.contentView.addSubview(label)
        
//        vibrancyView.addSubview(<#T##view: UIView##UIView#>)
        
        blurView.contentView.addSubview(vibrancyView)
        blurView.contentView.addSubview(label)
        self.blurView.addSubview(blurView)
        
//        vibrancyView.contentView.addSubview(label)

        
    }
    
    
    // MARK: 加载体能训练
    func loadWorkoutsAndGetDistance() {
        WorkoutDataStore.loadThisMonthWorkouts(self.startDate, self.endDate, self.userDefineDateFlag) { (workouts, error) in
            
            // 判断所选日期区间是否进行了体能训练，也就是workouts的长度
            if workouts!.count > 0 {
                // 得到距离，单位米
                self.workouts = workouts!
                let result = MonthlyStatMethods.calcIndicatorInUserUnit(self.workouts)
                self.result = result
                self.setUpAllIndicators(false)
                

            }
            
            else{
                
                self.workouts = []
                self.setUpAllIndicators(true)

            }


            self.setDateRangeLabel()
            
            // 用于绘制图像
//            self.thisMonthDistanceArray = result.distanceArray
            
//            self.setUpLineChartView()
            
        }
    }
    /// 各项指标
    func setUpAllIndicators(_ empty: Bool) {
        if !empty{
            // 总里程
            self.accDistance.text = self.result.accDistance
            // 总时间
            self.accTime.text = self.result.accTime
            // 平均配
            self.avgPace.text = self.result.avgPace

            // 跑步次数
            self.numOfRuns.text = self.result.numOfRuns
            // 最远距离
            self.maxDistance.text = self.result.maxDistance
            // 最快配速
            self.maxPace.text = self.result.maxPace
            
            // 平均心率
            if self.result.avgHR != "---" {
                self.avgHR.text = self.result.avgHR
                self.indicatorUIView[6].isHidden = false
            }
            else {
                self.indicatorUIView[6].isHidden = true
            }
            
            // 跑步功率 avg power
            if self.result.avgPower != "---" {
                self.avgPower.text = self.result.avgPower
                self.indicatorUIView[8].isHidden = false
            }
            else {
                self.indicatorUIView[8].isHidden = true
            }
            

            // 平均步频
            if self.result.avgCadence != "---" {
                self.avgCadence.text = self.result.avgCadence
                self.indicatorUIView[9].isHidden = false
            }
            else {
                self.indicatorUIView[9].isHidden = true
            }
            

            // Active Energy Burned
            self.avgCalorie.text = self.result.avgCalorie
//
//            // 平均消耗
//            if self.result.avgCadence != "---" {
//                self.avgCadence.text = self.result.avgCadence
//                self.indicatorUIView[7].isHidden = false
//            }
//            else {
//                self.indicatorUIView[7].isHidden = true
//            }

            
            
            
            // 数据来源
            var sourceInStr = NSLocalizedString("runningDataSource", comment: "")
             
            for runningDataSource in self.result.dataSource {
                sourceInStr += (runningDataSource + "\n")
            }
            
            self.dataSourceLabel.text = sourceInStr
            
            if self.workouts.count > 0 {
                for btn in self.style1PlotButton {
                    btn.isHidden = false
                }
            }
            else{
                for btn in self.style1PlotButton {
                    btn.isHidden = true
                }
            }
        }
        else {
            for (i, ll) in self.indicatorUILabel.enumerated() {
                if i % 2 == 0 {
                    ll.text = "🏃‍♀️"
                }
                else {
                    ll.text = "🏃"
                }
            }
            
            // 隐藏所有Button
            for btn in self.style1PlotButton {
                btn.isHidden = true
            }
        }
    }
    

    @IBAction func style1PlotBtnPressed(_ sender: UIButton) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let plotStyle1VC = sb.instantiateViewController(withIdentifier: "PlotStyle1") as? PlotStyle1
        // MARK: 指定类型1 ____ 距离
        if sender == self.style1PlotButton[0] {
            if self.result.distanceArray != [0.0] && self.result.distanceArray.count != 0 {
                
                plotStyle1VC?.typeID = 1
                plotStyle1VC?.startDate = self.startDate
                plotStyle1VC?.endDate = self.endDate
                plotStyle1VC?.dataArray = self.result.distanceArray
                plotStyle1VC?.runningDates = self.result.workoutDate
                plotStyle1VC?.theTitle = NSLocalizedString("totalDistance_v0001", comment: "") + " " + self.accDistance.text!
                plotStyle1VC?.dateLabelTxt = self.generalSmileyLabel.first!.text!
                plotStyle1VC?.subTitles = [NSLocalizedString("detailInfo", comment: ""),
                                           NSLocalizedString("classificationDistance", comment: "")
                ]
                self.present(plotStyle1VC!, animated: true)
            }
            
        }
        // MARK: 指定类型2 ____ 功率
        else if sender == self.style1PlotButton[1] {
            plotStyle1VC?.typeID = 2
            plotStyle1VC?.startDate = self.startDate
            plotStyle1VC?.endDate = self.endDate
//            plotStyle1VC?.runningDates = self.result.workoutDate
            plotStyle1VC?.dateLabelTxt = self.generalSmileyLabel.first!.text!
            plotStyle1VC?.theTitle = NSLocalizedString("avgPowerTitle", comment: "") + " " + self.avgPower.text! + NSLocalizedString("powerUnit" , comment: "")
            plotStyle1VC?.subTitles = [NSLocalizedString("powerDetailInfo", comment: "")]
            
            self.present(plotStyle1VC!, animated: true)
        }
        // MARK: 指定类型3____ 步频
        else if sender == self.style1PlotButton[2] {
            plotStyle1VC?.typeID = 3
            plotStyle1VC?.startDate = self.startDate
            plotStyle1VC?.endDate = self.endDate
//            plotStyle1VC?.runningDates = self.result.workoutDate
            plotStyle1VC?.dateLabelTxt = self.generalSmileyLabel.first!.text!
            plotStyle1VC?.theTitle = NSLocalizedString("avgCadenceTitle", comment: "") + " " + self.avgCadence.text! + NSLocalizedString("cadenceUnit" , comment: "")
            plotStyle1VC?.subTitles = [NSLocalizedString("cadenceDetailInfo", comment: "")]
            
            self.present(plotStyle1VC!, animated: true)
            
        }
        // MARK: 指定类型4____ 平均配速
        else if sender == self.style1PlotButton[3] {
            plotStyle1VC?.typeID = 4
            plotStyle1VC?.startDate = self.startDate
            plotStyle1VC?.endDate = self.endDate

            
            plotStyle1VC?.dateLabelTxt = self.generalSmileyLabel.first!.text!
            
            plotStyle1VC?.theTitle = NSLocalizedString("avgPaceTitle", comment: "") + " " + self.avgPace.text!
            
            plotStyle1VC?.subTitles = [NSLocalizedString("paceDetailInfo", comment: ""), NSLocalizedString("learnPaceCalcSubTitle2", comment: "")]
            
            self.present(plotStyle1VC!, animated: true)
            
        }
        // MARK: typeID = 5 ____ 平均Heart Rate
        else if sender == self.style1PlotButton[4] {
            plotStyle1VC?.typeID = 5
            plotStyle1VC?.startDate = self.startDate
            plotStyle1VC?.endDate = self.endDate
//            plotStyle1VC?.runningDates = self.result.workoutDate
            
            plotStyle1VC?.dateLabelTxt = self.generalSmileyLabel.first!.text!
            
            plotStyle1VC?.theTitle = NSLocalizedString("avgHRTitle", comment: "") + " " + self.avgHR.text!
            
            plotStyle1VC?.subTitles = [NSLocalizedString("HR_DetailInfo", comment: ""), NSLocalizedString("yourHRZone", comment: "")]
            
            
            self.present(plotStyle1VC!, animated: true)
            
        }
        // MARK: typeID =6  ____ 平均Energy
        else if sender == self.style1PlotButton[5] {
            plotStyle1VC?.typeID = 6
            plotStyle1VC?.startDate = self.startDate
            plotStyle1VC?.endDate = self.endDate
            
            plotStyle1VC?.dateLabelTxt = self.generalSmileyLabel.first!.text!
            
            plotStyle1VC?.theTitle = NSLocalizedString("avgEnergyTitle", comment: "") + " " + self.avgCalorie.text!
            
            plotStyle1VC?.subTitles = [NSLocalizedString("avgEnergyDetail", comment: ""),
            NSLocalizedString("cumuKCAL" , comment: "")]
            
            
            self.present(plotStyle1VC!, animated: true)
            
        }

        
        else{
            
        }
        


        
    }
    

    @IBAction func showSheetBtnPressed(_ sender: UIButton) {
        if sender == self.showSheetButtons[0] {
            // max distance
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "DaysDetails") as! DaysDetails
            vc.dateInStr = self.result.maxDistanceDate
            vc.emoji = " "
            vc.infoStr = " "
            let nav = UINavigationController(rootViewController: vc)
            if let sheet = nav.sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.prefersGrabberVisible = true
            }

            self.present(nav, animated: true)
        }
        else if sender == self.showSheetButtons[1] {
            // max Pace
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "DaysDetails") as! DaysDetails
            vc.dateInStr = self.result.maxPaceDate
            vc.emoji = " "
            vc.infoStr = " "
            let nav = UINavigationController(rootViewController: vc)
            if let sheet = nav.sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.prefersGrabberVisible = true
            }

            self.present(nav, animated: true)
        }
    }
    
    // MARK: - Dark/Light
    /// 设备外观设置
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        // 刷新
//        self.setUpLineChartView()
        if self.workouts.count > 0 {
            self.setUpAllIndicators(false)
        }
        else{
            self.setUpAllIndicators(true)
        }
        
        
    }
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
    }
    

    

}

extension UIView {
   func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
