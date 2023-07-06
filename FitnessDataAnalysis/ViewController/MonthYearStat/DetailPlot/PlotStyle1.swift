//
//  PlotStyle1.swift
//  FitnessDataAnalysis
//
//  Created by 十口V🌼 on 2023/3/29.
//

import UIKit
import AAInfographics
import HealthKit


class PlotStyle1: UIViewController, ChartDelegate {

    /// 滑动View
    @IBOutlet weak var scrollView: UIView!
    /// 真正的内容的UIView
    @IBOutlet weak var actualContentUIView: UIView!
    
    /// 大标题
    @IBOutlet weak var mediumTitle: UILabel!
    /// 输入进来的概览数据
    @IBOutlet weak var inputData: UILabel!
    /// 收藏这个指标是
    @IBOutlet weak var favoriteButton: UIButton!
    
    /// 具体分级内容View
    @IBOutlet var contentView: [UIView]!
    
    /// 图表的vIew
    @IBOutlet var allChartView: [UIView]!
    /// Bigger 标题
    @IBOutlet var biggerTitleLabel: [UILabel]!
    /// 日期Label
    @IBOutlet var dateLabel: UILabel!
    /// 脚注标签 0: 室内跑步/室外跑步提示
    @IBOutlet var generalFootnoteLabels: [UILabel]!
    /// subtitle 1的详细信息
    @IBOutlet var subtitle1ButtonInfo: UIButton!
    /// subtitle 2 的详细信息
    @IBOutlet var subtitle2ButtonInfo: UIButton!
    /// Heart Rate Zone
    @IBOutlet var HRZoneUIView: UIView!
    /// 心率区间Label名称——在Main.strings 定义
    @IBOutlet var zoneNameList: [UILabel]!
    /// 百分比
    @IBOutlet var HRPortionList: [UILabel]!
    /// 心率阈值
    @IBOutlet var HRThresholdList: [UILabel]!
    /// 累计动态千卡渐变Label
    @IBOutlet var cumuActiveKCAL: GradientLabel!
    /// 累计动态千卡UIView
    @IBOutlet var cumuKCALUIView: UIView!
    
    
    /// 输入进来的标题
    var theTitle: String = ""
    /// 输入进来的数据
    var inputOverviewData: String = ""
    /// 跑步日期数组——一般是横坐标
    var runningDates: [String] = []
    /// 跑步距离数组（km）或者其他类型的数据
    var dataArray: [Double] = []
    /// 分类数组 —— 运动强度
    lazy var classificationArray: [Double] = self.dataArray.map{
        if $0 < 5.5 {
            return Double(3)
        }
        else if $0 >= 5.5 && $0 < 7 {
            return Double(2)
        }
        else {
            return Double(1)
        }
    }
    
    /// 图的背景颜色
    var bgColor: String!
    /// Chart中文字的颜色
    var chartTextColor: String!
    /// 定义chart
    var chart: Chart!
    /// 小标题
    var subTitles: [String] = []

    /// 圆饼图数据
    var pieChartData: [[Any]] = []
    
    /// 起始日期
    var startDate: Date!
    /// 结束日期
    var endDate: Date!
    /// 类型 0 - 未指定；1-距离详细，需要加载workout；
    var typeID: Int = 0
    /// 输入日期范围
    var dateLabelTxt: String = ""
    lazy var uniUISetting = UniversalUISettings()
    
    var pieView: AAChartView!
    var bandView: AAChartView!
    var dataToolLabel: Bool = true
    
    /// typeID对应的是否收藏
    lazy var typeIDToFavorite: [Int: Bool] = [1: UserDefaults.standard.bool(forKey: "FavRunDistance"),
                                              2: UserDefaults.standard.bool(forKey: "FavRunPower"),
                                              3: UserDefaults.standard.bool(forKey: "FavRunCadence"),
                                              4: UserDefaults.standard.bool(forKey: "FavRunPace"),
                                              5: UserDefaults.standard.bool(forKey: "FavRunHR"),
                                              6: UserDefaults.standard.bool(forKey: "FavRunEnergy")
    ]


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setUpUI()
        
        // 加载收藏 按钮
        self.loadFavoriteButton()
        
        switch typeID {
        case 0:
            print("?")
            
        case 1:
            // 1 ____ 距离
            self.showAllOutlets()
            self.showLineChart()
            // load WK
            self.loadWK()
        case 2:
            // 2 ____ 功率
            self.actualContentUIView.setHeight(400)
            self.showFirstOutlets()
            self.loadWK()
        case 3:
            // 3 ____ 步频
            self.actualContentUIView.setHeight(400)
            self.showFirstOutlets()
            self.loadWK()
        case 4:
            // 4 ____ 配速 + 运动强度
//            self.actualContentUIView.setHeight(1000)

            self.showAllOutlets()
//            self.showFirstOutlets()
            // 设置View的长度
//            self.showFirstOutlets()
            self.loadWK()
        case 5:
            // 5 ____ 心率 + Zone
            // TODO: Zone
            self.showAllOutlets()
            self.loadWK()
        case 6:
            self.showAllOutlets()
            self.loadWK()
        default:
            break
        }
        
    }
    
    /// 配速分析按钮
    @IBAction func paceAnalysisBtnPressed(_sender: UIButton) {
//        if self.typeID == 4 {
//
//        }

    }
    
    /// 加载体能训练——圆饼图 & 展示圆饼
    func loadWK() {
        WorkoutDataStore.loadLastWorkouts() { (res, error) in
            // 可以成功访问Workout类型的数据
            // 5 ____ Energy
            self.showAllOutlets()
            if res != nil && res!.count != 0 && error == nil{
                WorkoutDataStore.loadThisMonthWorkouts(self.startDate, self.endDate, true) { (workouts, error) in
                    // 判断所选日期区间是否进行了体能训练，也就是workouts的长度
                    if workouts!.count > 0 {
                        switch self.typeID {
                        case 1:
                            // 用户偏好的距离单位
                            let pieData = QueryWorkoutsAssistant.getAllDistAndPaceInDouble(workouts!, 2)
                            self.pieChartData = AssistantMethods.classifyRunningDistance(pieData.wDist)
                            
                            // 2. pie
                            if self.pieChartData.count != 0{
                                self.setUpPieChartView(1)
                            }
                            // 计算平均每次跑步距离
                            // UserDefaults.standard.strin g(forKey: "distanceUnitDefaultAb")!
                            
                            let avgDisEachTime = Double(self.dataArray.reduce(0.0, +) / Double(self.dataArray.count))
                            let avgDisEachTime2Deci = AssistantMethods.convert(avgDisEachTime, maxDecimals: 2)
                            
//                            self.generalFootnoteLabels[0].text = NSLocalizedString("avgDisPerRun", comment: "") + "\(avgDisEachTime2Deci)" + UserDefaults.standard.string(forKey: "distanceUnitDefaultAb")!
                            self.generalFootnoteLabels[0].isHidden = true
                            self.subtitle2ButtonInfo.isHidden = false
                            break
                        case 2:
                            let res = MonthlyStatMethods.getPowerArrayAndDate(workouts!)
                            self.runningDates = res.dateInStr
                            
                            self.dataArray = res.power

                            // 保留两位小数
                            self.dataArray = self.dataArray.map{
                                return AssistantMethods.convert($0, maxDecimals: 2)
                            }
//                            print("配速")
//                            print(self.dataArray)
                            
                            self.setUpLineChartView(0)
                            
                            break
                        case 3:
                            let res = MonthlyStatMethods.getCadenceArrayAndDate(workouts!)
                            self.runningDates = res.dateInStr

                            self.dataArray = res.cadence
                            self.dataArray = self.dataArray.map{
                                return AssistantMethods.convert($0, maxDecimals: 0)
                            }
                            
                            self.setUpLineChartView(0)

                            
                        case 4:
                            let res = MonthlyStatMethods.getPaceArrayAndDate(workouts!)
                            self.runningDates = res.dateInStr
                            // 1. line
                            self.dataArray = res.pace
                            self.dataArray = self.dataArray.map{
                                return AssistantMethods.convert($0, maxDecimals: 2)
                            }
                            
                            self.setUpLineChartView(0)
                            
                            if self.dataArray.count >= AnomalyDetectionConfig().minLenOfCI + 1 {
                                self.subtitle1ButtonInfo.isHidden = false
                                let confidenceIntervalDetection = UIAction(title: "置信区间") { (action) in
                                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "PaceAnalysisTable") as! PaceAnalysisTable
                                    vc.inputDate = self.runningDates
                                    vc.inputData = self.dataArray
                                    let navigationController = UINavigationController(rootViewController: vc)
                                    self.present(navigationController, animated: true, completion: nil)
                                }
                                
                                let DBSCANDetection = UIAction(title: "DBSCAN") { (aciton) in
                                    // DBSCANVC
                                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "DBSCANVC") as! DBSCANVC
                                    vc.inputDate = self.runningDates
                                    vc.inputData = self.dataArray
                                    let navigationController = UINavigationController(rootViewController: vc)
                                    self.present(navigationController, animated: true, completion: nil)
                                    
                                    
                                }
                                
                                
                                let menuTitle = "异常检测算法"
                                let menu = UIMenu(title: menuTitle, options: .singleSelection, children: [confidenceIntervalDetection, DBSCANDetection])
                                self.subtitle1ButtonInfo.menu = menu
                                self.subtitle1ButtonInfo.showsMenuAsPrimaryAction = true
                                
                                
                            }
                            
                            
                            // 2. pie
                            
                            self.pieChartData = AssistantMethods.classifyRunningPace(res.pace)
                            
                            if self.pieChartData.count != 0{
                                self.setUpPieChartView(1)
                            }
                            self.subtitle2ButtonInfo.isHidden = false
                            
                            
                        case 5:
                            let res = MonthlyStatMethods.getHRAndDate(workouts!)
                            self.runningDates = res.dateInStr

                            
                            self.dataArray = res.HR.map{
                                return AssistantMethods.convert($0, maxDecimals: 0)
                            }
                            
                            self.setUpBandChartView(0)
                            self.HRZoneUIView.frame = self.allChartView[1].frame
                            self.HRZoneUIView.isHidden = false
                            self.showHRZone()
                            self.contentView[1].addSubview(self.HRZoneUIView)
                            self.subtitle2ButtonInfo.isHidden = true
                            
                        case 6:
                            let res = MonthlyStatMethods.getCalorieArrayAndDate(workouts!)
                            self.runningDates = res.dateInStr

                            self.dataArray = res.calories 

                            
                            
                            self.cumuActiveKCAL.gradientColors = [UIColor.init(red: 234/255.0, green: 188/255.0, blue: 137/255.0, alpha: 1).cgColor, UIColor.init(red: 241/255.0, green: 81/255.0, blue: 75/255.0, alpha: 1).cgColor]
                            let totalKCAL = String(format: "%.0f", MonthlyStatMethods.rouding(self.dataArray.reduce(0, +)))
                            self.cumuActiveKCAL.text = totalKCAL
                            self.cumuKCALUIView.frame = self.allChartView[1].frame
                            
                            self.contentView[1].addSubview(self.cumuKCALUIView)
                            
                            self.dataArray = self.dataArray.map{
                                return AssistantMethods.convert($0, maxDecimals: 0)
                            }
                            self.setUpLineChartView(0)
                            self.subtitle2ButtonInfo.isHidden = true
                        default:
                            break
                        }

                    }
                    else{
                    }
                }
            }
            
        }
        
    }
    
    
    /// 加载各个Type的收藏状态
    func loadFavoriteButton() {
        let favoriteStatus = self.typeIDToFavorite[self.typeID]
        self.adjustFavoriteButtonStatus(favoriteStatus!)
    }
    
    /// 改变收藏的状态
    @IBAction func favoriteBtnPressed(_ sender: UIButton) {
        
        let keyStrings: [String] = ["占位", "FavRunDistance", "FavRunPower",
                                    "FavRunCadence", "FavRunPace",
                                    "FavRunHR", "FavRunEnergy"
        ]
        
        if UserDefaults.standard.bool(forKey: keyStrings[self.typeID]) {
            UserDefaults.standard.set(false, forKey: keyStrings[self.typeID])
            self.adjustFavoriteButtonStatus(false)
            
        }
        else {
            UserDefaults.standard.set(true, forKey: keyStrings[self.typeID])
            self.adjustFavoriteButtonStatus(true)
        }
        
    }
    /// 根据布尔值调整按钮的显示状态
    func adjustFavoriteButtonStatus(_ favorite: Bool) {
        let heartEmptyImage = UIImage(systemName: "suit.heart")
        let heartFillImage = UIImage(systemName: "suit.heart.fill")
        if favorite {
            DispatchQueue.main.async {
                self.favoriteButton.setImage(heartFillImage, for: .normal)
            }
        }
        else {
            DispatchQueue.main.async {
                self.favoriteButton.setImage(heartEmptyImage, for: .normal)
            }
        }
    }
    
    
    /// Type0 - 根据最大心率计算
    func showHRZone() {

        switch UserDefaults.standard.integer(forKey: "PreferredHRZoneType") {
        case 0:
            
            // 字体大小
            let font = UIFont.boldSystemFont(ofSize: 12)
            
            // 设置字体
            for (idx, zoneTitleLabel) in self.zoneNameList.enumerated(){
                let str = "hrType0_zone" + "\(idx)"
                zoneTitleLabel.text = NSLocalizedString(str, comment: "")
                zoneTitleLabel.layer.cornerRadius = 10
                zoneTitleLabel.layer.backgroundColor = ColorUtil.getHRZoneColors()[idx].cgColor
                zoneTitleLabel.textColor = UIColor.label
                if !UserDefaults.standard.bool(forKey: "useSmiley") {
                    zoneTitleLabel.font = font
                }
                else {
                    zoneTitleLabel.font = SmileyFontSize.getInSize(14)
                }
                zoneTitleLabel.textAlignment = .center
            }
            
            let portionInStr = ["50% - 60%", "60% - 70%", "70% - 80%", "80% - 90%", "90% - 100%"]
            for (idx, portionLabel) in self.HRPortionList.enumerated() {
                portionLabel.text = portionInStr[idx]

                if !UserDefaults.standard.bool(forKey: "useSmiley") {
                    portionLabel.font = font
                }
                else {
                    portionLabel.font = SmileyFontSize.getInSize(14)
                }
            }
            
            let thresholdHR = AssistantMethods.getHRZone_MaxHR()
            if thresholdHR != [0, 0, 0, 0, 0, 0] {

                
                for (idx, HRLabel) in self.HRThresholdList.enumerated() {
                    if idx < thresholdHR.count - 1 {
                        HRLabel.text = "\(thresholdHR[idx]) - \(thresholdHR[idx+1]) BPM"
                    }
                    if !UserDefaults.standard.bool(forKey: "useSmiley") {
                        HRLabel.font = font
                    }
                    else {
                        HRLabel.font = SmileyFontSize.getInSize(14)
                    }
                }
            }
            else {
                // 无法载入用户的出生日期
                if self.typeID == 5 {
                    self.generalFootnoteLabels[0].isHidden = false
                    self.generalFootnoteLabels[0].text = NSLocalizedString("dateHint", comment: "")
                }
                
                
                for (idx, HRLabel) in self.HRThresholdList.enumerated() {
                    if idx < thresholdHR.count - 1 {
                        HRLabel.text = "---"
                    }
                    if !UserDefaults.standard.bool(forKey: "useSmiley") {
                        HRLabel.font = font
                    }
                    else {
                        HRLabel.font = SmileyFontSize.getInSize(14)
                    }
                }
            }

            

            
            break
        default:
            break
        }
    }
    
    func getHRZoneBandArr() -> [AAPlotBandsElement] {
        var aaPlotBandsArr: [AAPlotBandsElement] = []
        let thresholdHR = AssistantMethods.getHRZone_MaxHR().map{Double($0)}
        let col = ColorUtil.getHRZoneColorsInHex()
        for (idx, thresholdVal) in thresholdHR.enumerated() {
            if idx < thresholdHR.count - 1 {
                let tempElement = AAPlotBandsElement().from(thresholdHR[idx]).to(thresholdHR[idx+1]).color(col[idx])
                
                aaPlotBandsArr.append(tempElement)
            }
        }
        return aaPlotBandsArr
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.userInterfaceStyle == .dark {
            // 当前是深色模式
            self.bgColor = ChartColorHex.ChartBKColor.chartBgColorDark0.rawValue
            self.chartTextColor = ChartColorHex.ChartTextColor.chartTextColorDark1.rawValue
            
        } else {
            // 当前是浅色模式
            self.bgColor = ChartColorHex.ChartBKColor.chartBgColorLight0.rawValue
            self.chartTextColor = ChartColorHex.ChartTextColor.chartTextColorLight0.rawValue

            
        }
        // 刷新
        if self.typeID == 1 || self.typeID == 4{
            DispatchQueue.main.async {
//                self.allChartView[0].removeFromSuperview()
//                self.setUpLineChartView(0)

                if (self.pieView != nil) {
                    self.pieView.removeFromSuperview()
                    self.setUpPieChartView(1)
                }
                
                
                
            }
        }
        else if self.typeID == 2 || self.typeID == 3 || self.typeID == 4{
            DispatchQueue.main.async {
//                self.setUpLineChartView(0)
            }
        }
        else if typeID==5 {
            DispatchQueue.main.async {

                if (self.bandView != nil) {
                    self.bandView.removeFromSuperview()
                    self.setUpBandChartView(0)
                }
                
                
                
            }
        }
        else {
            
        }
        
    }
    
    // MARK: - 散点图
    func setUpScatterModel() -> AAChartModel {
        let curColor: Any = AAGradientColor.oceanBlue
        let chartType = AAChartType.scatter
        let curSuffix = " " + UserDefaults.standard.string(forKey: "distanceUnitDefaultAb")!
        
        let scatterModel = AAChartModel()
            .chartType(chartType)
            .dataLabelsEnabled(false)       //是否显示值
            .tooltipEnabled(true)
            .markerRadius(3)
            .xAxisVisible(true)
            .yAxisVisible(true)
            .tooltipValueSuffix(curSuffix)
            .categories(self.runningDates)
            .series([
                AASeriesElement()
                    .showInLegend(true)
                    .name("")
                    .data(self.dataArray)
                    .color(curColor)
                    
            ])
        
        return scatterModel
    }
    
    // MARK: - 线图
    func setUpLineChartModel() -> AAChartModel {
        let color: [Any] = [AAGradientColor.oceanBlue, AAColor.rgbaColor(50, 205, 50), AAGradientColor.reflexSilver, AAGradientColor.sweetDream, AAGradientColor.coastalBreeze, AAGradientColor.fizzyPeach]

        var curColor: Any = AAGradientColor.oceanBlue
        var curSuffix: String = ""
        var chartType = self.dataArray.count > 1 ? AAChartType.spline : AAChartType.bubble
        switch typeID {
        case 0:
            // wu
            curColor = color[0]
//            chartType = AAChartType.scatter
        case 1:
            curColor = color[0]
            curSuffix = " " + UserDefaults.standard.string(forKey: "distanceUnitDefaultAb")!
//            chartType = AAChartType.scatter
//            return setUpScatterModel()
        case 2:
            curColor = color[1]
//            curColor = self.getTypeIDToColor(2)
            curSuffix = " " + NSLocalizedString("powerUnit", comment: "")

        case 3:
            curColor = color[2]
            curSuffix = " " + NSLocalizedString("cadenceUnit", comment: "")

        case 4:
            curColor = color[3]
            curSuffix = ""
            // NSLocalizedString("paceMinUnit", comment: "") + " " +  NSLocalizedString("perper", comment: "") + " " +  UserDefaults.standard.string(forKey: "distanceUnitDefaultAb")!
        case 5:
            //
            curColor = color[4]
            curSuffix = " " + NSLocalizedString("HR_unit", comment: "")
        case 6:
            curColor = color[5]
            curSuffix = " " + NSLocalizedString("energyUnit", comment: "")
        default:
            curColor = color[0]
        }
        self.bgColor = ChartColorHex.ChartBKColor.chartBgColorDark0.rawValue
        self.chartTextColor = ChartColorHex.ChartTextColor.chartTextColorDark1.rawValue
        let bubbleModel = AAChartModel()
            .chartType(chartType)
            .dataLabelsEnabled(false)       //是否显示值
            .tooltipEnabled(true)
            .markerRadius(0)
            .xAxisVisible(true)
            .yAxisVisible(true)
            .tooltipValueSuffix(curSuffix)
            .categories(self.runningDates)
            .series([
                AASeriesElement()
                    .showInLegend(false)
                    .name("")
                    .lineWidth(AssistantMethods.getLineWidth(self.dataArray.count))
                    .data(self.dataArray)
                    .color(curColor)
                    
            ])
        
        
        let splineModelNoAxis = AAChartModel()
            .chartType(chartType)
            .dataLabelsEnabled(false)       //是否显示值
            .tooltipEnabled(true)
            .markerRadius(0)
            .xAxisVisible(false)
            .yAxisVisible(false)
            
            .tooltipValueSuffix(curSuffix)
            .categories(self.runningDates)
            .series([
                AASeriesElement()
                    .showInLegend(false)
                    .name("")
                    .lineWidth(AssistantMethods.getLineWidth(self.dataArray.count))
                    .data(self.dataArray)
                    .color(curColor)
                    
            ])
        
        let splineModelAxisDate = AAChartModel()
            .chartType(chartType)
            .dataLabelsEnabled(false)       //是否显示值
            .tooltipEnabled(true)
            .markerRadius(5)
            .xAxisGridLineWidth(0.5)
            .xAxisVisible(true)
            .yAxisVisible(true)
            .tooltipValueSuffix(curSuffix)
            .categories(self.runningDates)
            .series([
                AASeriesElement()
                    .showInLegend(false)
                    .name("")
                    .lineWidth(AssistantMethods.getLineWidth(self.dataArray.count))
                    .data(self.dataArray)
                    .color(curColor)
                    
            ])
        
        let splineModelAxisNoDate = AAChartModel()
            .chartType(chartType)
            .dataLabelsEnabled(false)       //是否显示值
            .tooltipEnabled(true)
            .markerRadius(0)
            .xAxisGridLineWidth(0.5)
            .xAxisVisible(false)
            .yAxisVisible(true)
            .tooltipValueSuffix(curSuffix)
            .categories(self.runningDates)
            .series([
                AASeriesElement()
                    .showInLegend(false)
                    .name("")
                    .lineWidth(AssistantMethods.getLineWidth(self.dataArray.count))
                    .data(self.dataArray)
                    .color(curColor)
                    
            ])
        let dataCount = self.dataArray.count
        if dataCount == 1 {
            return bubbleModel
        }
        else if dataCount > 1 && dataCount <= 4 {
            if self.typeID == 4 {
                return splineModelAxisDate.yAxisReversed(true)
            }
            else {
                return splineModelAxisDate
            }

            
        }
        else if dataCount > 4 && dataCount <= 100 {
   
            if self.typeID == 4 {
                return splineModelAxisNoDate.yAxisReversed(true)
            }
            else {
                return splineModelAxisNoDate
            }
        }
        else {
            if self.typeID == 4 {
                return splineModelNoAxis.yAxisReversed(true)
            }
            else {
                return splineModelNoAxis
            }
        }

    }
    
    
    
    /// 取消隐藏 标题 & 图表
    func showAllOutlets(){
        for ll in self.biggerTitleLabel {
            ll.isHidden = false
        }
        
        for vv in self.contentView {
            vv.isHidden = false
        }
    }
    
    func showFirstOutlets(){
        self.biggerTitleLabel.first?.isHidden = false
        self.contentView.first?.isHidden = false
    }
    
    /// 展示所有图表
    func showLineChart() {
        // 1. line
        if self.dataArray.count != 0 {
            self.setUpLineChartView(0)
        }

        
    }
    

    func setUpPieChartView(_ idx: Int){
        let rect = self.allChartView[idx].frame
        self.pieView = AAChartView()
        pieView.isHidden = false
        pieView.frame = rect
        pieView.isScrollEnabled = false
        pieView.isClearBackgroundColor = true
        pieView.isUserInteractionEnabled = UserDefaults.standard.bool(forKey: "allowChartInteraction")


        self.contentView[idx].addSubview(pieView)
        let pieChartModel = getPieChartModel()
        pieView.aa_drawChartWithChartModel(pieChartModel)
    }
     
    
    func setUpBandChartView(_ idx: Int){
        let rect = self.allChartView[idx].frame
        self.bandView = AAChartView()
        bandView.isHidden = false
        bandView.frame = rect
        bandView.isScrollEnabled = false
        bandView.isClearBackgroundColor = true
        bandView.isUserInteractionEnabled = UserDefaults.standard.bool(forKey: "allowChartInteraction")
        self.contentView[idx].addSubview(bandView)
        let bandChartModel = self.getBandChartModel()
        bandView.aa_drawChartWithChartOptions(bandChartModel)
//        bandView.aa_drawChartWithChartModel(bandChartModel)
    }
    
    
    /// 饼图模型配置
    func getPieChartModel() -> AAChartModel {
        if traitCollection.userInterfaceStyle == .dark {
            // 当前是深色模式
            self.bgColor = ChartColorHex.ChartBKColor.chartBgColorDark0.rawValue
            self.chartTextColor = ChartColorHex.ChartTextColor.chartTextColorDark0.rawValue
            
        } else {
            // 当前是浅色模式
            self.bgColor = ChartColorHex.ChartBKColor.chartBgColorLight0.rawValue
            self.chartTextColor = ChartColorHex.ChartTextColor.chartTextColorLight0.rawValue
        }
        // 颜色设置
        var pieColor = ColorUtil.getPieChartColor(0)
        if self.typeID == 4 {
            pieColor = ColorUtil.getPieChartColor(1)
        }

        
        let pModel = AAChartModel()
            .chartType(.pie)
            .backgroundColor(self.bgColor as Any)
            .dataLabelsEnabled(true) //是否直接显示扇形图数据
            .dataLabelsStyle(.init(color: self.chartTextColor))
            .yAxisTitle("")
            .xAxisLabelsStyle(.init(color: self.chartTextColor))
            .series([
                AASeriesElement()
                
                    .colors(pieColor)
                    .name(NSLocalizedString("pieNumRuns", comment: ""))
                    .innerSize("0%")//内部圆环半径大小占比(内部圆环半径/扇形图半径),
                    .allowPointSelect(true)
                    .states(AAStates()
                        .hover(AAHover()
                            .enabled(true)//禁用点击区块之后出现的半透明遮罩层
                    ))
                    .data(self.pieChartData)
            ])
        return pModel

    }
    /// Band Chart
    func getBandChartModel() -> AAOptions {
        let aaChartModel = AAChartModel()
            .chartType(.spline)  //图形类型
            .dataLabelsEnabled(false)
            .legendEnabled(false)
            .categories(self.runningDates)
            .xAxisVisible(false)
            .yAxisGridLineWidth(0)
            .markerRadius(0)
            .yAxisVisible(true)
            .tooltipValueSuffix(NSLocalizedString("hrUnit", comment: ""))
            .series([
                AASeriesElement()
                    .name(NSLocalizedString("HR_hr", comment: ""))
                    .data(self.dataArray)
                    .color(traitCollection.userInterfaceStyle == .dark ? AAColor.white : AAColor.black)
                    .lineWidth(AssistantMethods.getLineWidth(self.dataArray.count))
            ])
        let aaOptions = aaChartModel.aa_toAAOptions()
        let aaPlotBandsArr = self.getHRZoneBandArr()
        aaOptions.yAxis?.plotBands(aaPlotBandsArr)
        
        return aaOptions
    }
    
    func setUpUI() {
        self.setUpContentView()
        self.mediumTitle.text = theTitle
        self.inputData.text = self.inputOverviewData
        self.inputData.textColor = self.getTypeIDToColor(self.typeID)
        for (idx, subTitle) in self.subTitles.enumerated() {
            self.biggerTitleLabel[idx].text = subTitle
        }
        self.setUpFont()
        
        
        if dateLabelTxt != "" {
            self.dateLabel.text = self.dateLabelTxt
        }

        self.showAndSetFootnote()

    }
    
    
    /// 设置脚注的内容
    func showAndSetFootnote() {
//        if UserDefaults.standard.bool(forKey: <#T##String#>) {
//            self.generalFootnoteLabels[1].isHidden = true
//        }
        if self.typeID == 2 {
            self.generalFootnoteLabels[0].isHidden = false
        }

    }
    
    func setUpFont() {
        if UserDefaults.standard.bool(forKey: "useSmiley") {
            self.mediumTitle.font = SmileyFontSize.getMedium()
            for ll in self.biggerTitleLabel {
                ll.font = SmileyFontSize.getBigger()
            }
            self.dateLabel.font = SmileyFontSize.getNormal()
            
            for footnoteLabel in self.generalFootnoteLabels {
                footnoteLabel.font = SmileyFontSize.getFootnote()
            }
        }
    }
    
    
    /// 设置UIView的阴影效果
    func setUpContentView() {
        for vv in self.contentView {
            vv.backgroundColor = ColorUtil.getMonthlyStatViewBKColor()
            vv.layer.shadowColor = uniUISetting.shadowColor
            vv.layer.cornerRadius = uniUISetting.cornerRadius
            vv.layer.shadowOffset = uniUISetting.shadowOffset
            vv.layer.shadowRadius = uniUISetting.shadowRadius
            vv.layer.shadowOpacity = uniUISetting.shadowOpcacity
            vv.layer.shadowPath =  UIBezierPath(rect: vv.bounds).cgPath
            vv.layer.masksToBounds = false
        }
    }

    
    
    /// line图
    func plotLineChart_data() {
        let data = self.dataArray.enumerated().map{
            return (x: $0, y: $1)
        }
        
        
        let series = ChartSeries(data: data)
        
        series.area = true
        
        series.color = ColorUtil.getSeriesColor()
        
        chart.add(series)

        self.contentView[0].addSubview(chart)
        
    }
    
    /// line图
//    func plotLineChart_ui() {
//        chart = Chart(frame: self.lineChartUIView.frame)
//        chart.center = self.lineChartUIView.center
//        chart.showXLabelsAndGrid = false
//        chart.labelColor = ColorUtil.dynamicColor(dark: UIColor.white, light: UIColor.black)
//        chart.delegate = self
//
//    }
    
    
    
    
    /// 设置line图的UI——注，也可以不是line图，可以在getModel处设置！
    func setUpLineChartView(_ idx: Int) {
        let rect = self.allChartView[idx].frame
        let aaChartView = AAChartView()
        aaChartView.isClearBackgroundColor = true
//        aaChartView.backgroundColor = UIColor
        aaChartView.isHidden = false
        aaChartView.frame = rect
        aaChartView.isScrollEnabled = false
        // TODO: 取消注释
        if self.typeID == 4 || self.dataArray.count <= 1 {
//            aaChartView.isUserInteractionEnabled = false
        }
        else {
            aaChartView.isUserInteractionEnabled = UserDefaults.standard.bool(forKey: "allowChartInteraction")
        }
        self.contentView[idx].addSubview(aaChartView)
        let aaChartModel = self.setUpLineChartModel()
        aaChartView.aa_drawChartWithChartModel(aaChartModel)
        
    }
    


    /// 运动强度绘制 _ 不是Bubble
    func setUpEIChartView(_ idx: Int) {
        let rect = self.allChartView[idx].frame
        let aaChartView = AAChartView()
        aaChartView.isClearBackgroundColor = true
        aaChartView.isHidden = false
        aaChartView.frame = rect
        aaChartView.isScrollEnabled = false
        aaChartView.isUserInteractionEnabled = UserDefaults.standard.bool(forKey: "allowChartInteraction")
        self.contentView[idx].addSubview(aaChartView)
        let aaChartModel = self.setUpColModel()
        aaChartView.aa_drawChartWithChartModel(aaChartModel)
    }
    
    
    func setUpColModel() -> AAChartModel {
        let bModel = AAChartModel()
            .chartType(.column)
            .dataLabelsEnabled(false)       //是否显示值
            .markerRadius(0)
            .xAxisVisible(false)
            .yAxisVisible(false)
            .categories(self.runningDates)
            .series([
                AASeriesElement()
                    .showInLegend(false)
                    .name("")
                    .lineWidth(AssistantMethods.getLineWidth(self.dataArray.count))
                    .data(self.classificationArray)
                    .color(AAGradientColor.sweetDream)
            ])
        
        return bModel
    }
    
    
    
    func redrawTheLineView() {
        
    }
    

    
    @IBAction func doneBtnPressed(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    
    
    

    
    func didTouchChart(_ chart: Chart, indexes: [Int?], x: Double, left: CGFloat) {
        for (seriesIndex, dataIndex) in indexes.enumerated() {
              if dataIndex != nil {
                // The series at `seriesIndex` is that which has been touched
                let value = chart.valueForSeries(seriesIndex, atIndex: dataIndex)
              }
            }
    }
    
    func didFinishTouchingChart(_ chart: Chart) {
        
    }
    
    func didEndTouchingChart(_ chart: Chart) {
        
        
    }
    

    
}


extension UIView {
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = .zero
        layer.shadowRadius = 1

        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}


extension PlotStyle1{
    /*
     /// typeID对应的是否收藏
     lazy var typeIDToFavorite: [Int: Bool] = [1: UserDefaults.standard.bool(forKey: "FavRunDistance"),
                                               2: UserDefaults.standard.bool(forKey: "FavRunPower"),
                                               3: UserDefaults.standard.bool(forKey: "FavRunCadence"),
                                               4: UserDefaults.standard.bool(forKey: "FavRunPace"),
                                               5: UserDefaults.standard.bool(forKey: "FavRunHR"),
                                               6: UserDefaults.standard.bool(forKey: "FavRunEnergy")
     ]
     */
    /// TypeID对应的颜色
    func getTypeIDToColor(_ id: Int) -> UIColor {
        
        let colorsSet = ColorUtil.getTableLogoImageColor()
        let mapArr = [1: colorsSet[0],
                      2: colorsSet[8],
                      3: colorsSet[9],
                      4: colorsSet[2],
                      5: colorsSet[6],
                      6: colorsSet[7]
              ]
        return mapArr[id]!
    }
    
}


extension UIView {
    func setHeight(_ h:CGFloat, animateTime:TimeInterval?=nil) {

        if let c = self.constraints.first(where: { $0.firstAttribute == .height && $0.relation == .equal }) {
            c.constant = CGFloat(h)

            if let animateTime = animateTime {
                UIView.animate(withDuration: animateTime, animations:{
                    self.superview?.layoutIfNeeded()
                })
            }
            else {
                self.superview?.layoutIfNeeded()
            }
        }
    }
}
