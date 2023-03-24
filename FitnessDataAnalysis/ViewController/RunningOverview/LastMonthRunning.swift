//
//  LastMonthRunning.swift
//  FitnessDataAnalysis
//
//  Created by 十口V🌼 on 2023/3/2.
//
import HealthKit
import AAInfographics
import UIKit

import Fastis

//import 
class LastMonthRunning: UIViewController {

    // MARK: - 接口
    @IBOutlet weak var backUIView: UIView!      // 滚动视图上的View
    @IBOutlet var chartContentUIView: [UIView]!    // 图表所在的UIView
    /// 月初~今天的日期label
    @IBOutlet weak var lastMonthDateRangeLabel: UILabel!    // 上个月的日期区间
    /// 总跑量line图表的vIew
    @IBOutlet weak var lineChartUIView: UIView!
    /// 上个月总跑量的grad label
    @IBOutlet weak var lastMonthTotalDistance: GradientLabel!
//    @IBOutlet weak var testBtn: UIButton!
    /// 日期选择器按钮
    @IBOutlet weak var datePickerBtn: UIBarButtonItem!
    
    
    // MARK: - 属性
    /// 起始日期（默认上个月）
    var startDate: Date!
    /// 结束日期（默认上个月）
    var endDate: Date!
    var lastMonthWorkouts: [HKWorkout]!
    /// 上个月的跑步距离数组（km）
    var lastMonthDistanceArray: [Double] = []
    /// 上个月的跑步日期数组
    var lastMonthRunningDates: [String] = []
    var bgColor: String!
    var chartTextColor: String!    // Chart中文字的颜色
    /// 用户是否自定义日期
    var userDefineDateFlag: Bool = false
    
    // MARK: 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()

        // 设置标题 如 2023-02
        self.getAndSetDateTitle()
        
        self.setUpUIP1()
        
        
        self.loadWorkoutsBasedOnDate()
        
        
        
    }
    
    /// 加载workouts
    func loadWorkoutsBasedOnDate(){
        WorkoutDataStore.loadLastWorkouts() { (res, error) in
            // 可以成功访问Workout类型的数据
            if res != nil && res!.count != 0 && error == nil{
                // 1 set up UI
                self.setUpUIP2()
                // 开始load上个月的跑步workouts
                WorkoutDataStore.loadLastMonthWorkouts(self.startDate, self.endDate, self.userDefineDateFlag) { (workouts, error) in
                    self.lastMonthWorkouts = workouts
                    // 获取上个月跑步的距离和日期
                    let res = QueryWorkoutsAssistant.getWorkoutsDistanceAndDate(self.lastMonthWorkouts, "yyyy-MM-dd")
                    
                    let resDistance = res.dist
                    self.lastMonthRunningDates = res.workoutDate.reversed()
                    // 转换距离的单位
                    let userUnit = UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit")
                    self.lastMonthDistanceArray = resDistance.map {
                        return AssistantMethods.convertMeterToUnit(userUnit, $0)
                    }
                    self.lastMonthDistanceArray = self.lastMonthDistanceArray.reversed()
                    // 计算总距离 & 配置渐变label
                    let totalDistanceInMeter: Double = resDistance.reduce(0) {(res, num) in
                        return res + num
                    }
                    
                    // 更新上个月跑量的值
                    for i in 0..<3{
                        /// total distance
                        let td = AssistantMethods.convertMeterToUnit(i, totalDistanceInMeter)
                        if i == 0 {
                            let tdInString = String(format: "%.2f", td) + " KM"
                            UserDefaults.standard.set(tdInString, forKey: "lastMonthRunningDistanceInKM")
                        }
                        else if i == 1 {
                            let tdInString = String(format: "%.2f", td) + " Mile"
                            UserDefaults.standard.set(tdInString, forKey: "lastMonthRunningDistanceInMile")
                        }
                        else if i == 2 {
                            let tdInString = String(format: "%.2f", td) + " M"
                            UserDefaults.standard.set(tdInString, forKey: "lastMonthRunningDistanceInMeter")
                        }
                        else {
                            
                        }
                    }
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
                    
                    self.lastMonthTotalDistance.text = totalDistanceToShow
                    self.lastMonthTotalDistance.gradientColors = ColorUtil.getGradTextStyle3()
                    
                    // 配置图表
                    self.setUpLineChartView()
                }
            }
            else {
                // 隐藏内容视图
                for chartUIView in self.chartContentUIView {
                    chartUIView.isHidden = true
                }
                
                // 提醒用户开启权限
                let ac = UIAlertController(title: NSLocalizedString("openWorkoutTitle", comment: ""), message: NSLocalizedString("openWorkoutMessage", comment: ""), preferredStyle: .alert)
                let action = UIAlertAction(title: NSLocalizedString("openWorkoutAction", comment: ""), style: .default) {_ in
                    self.navigationController?.popToRootViewController(animated: true)
                }
                ac.addAction(action)
                self.present(ac, animated: true)
                
            }
            
        }
        
    }
    
    @IBAction func choosePickerBtnPressed(_ sender: UIBarButtonItem) {
        chooseDate()
    }
    
    func chooseDate() {
        let fastisController = FastisController(mode: .range)
        fastisController.title = NSLocalizedString("datePickerChooseDateRange", comment: "")
        fastisController.maximumDate = Date()
        fastisController.allowToChooseNilDate = true
        fastisController.shortcuts = [.lastWeek, .lastMonth]
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
            self.loadWorkoutsBasedOnDate()
            self.setDateRangeLabel()
        }
        
        fastisController.present(above: self)
        
    }
    // MARK: 上月日期
    /// 展示「上月」的起始日期——结束
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
        let dateToShow = startDateInString + NSLocalizedString("dateTo", comment: "") + endDateInString
        // 赋值给Label
        self.lastMonthDateRangeLabel.text = dateToShow
        
    }
    
    /// 标题栏的年份、月份
    func getAndSetDateTitle() {
        let dateFormatter4 = DateFormatter()
        dateFormatter4.locale = Locale(identifier: "en")
        dateFormatter4.dateFormat = "yyyy-MM"
        let res = AssistantMethods.getLastMonthStartEndDate(Date.init(), Date.init(), self.userDefineDateFlag)
        self.startDate = res.startDate
        self.endDate = res.endDate
        
    }
    
    // MARK: - Basic UI
    /// 基础UI
    func setUpUIP1(){
        self.title = "查询"
        
        // 2. View bk color
        self.view.backgroundColor = ColorUtil.getBackgroundColorStyle1()
        // 3. back
        self.backUIView.backgroundColor = ColorUtil.getBackgroundColorStyle1()
        
        self.navigationController?.navigationBar.tintColor = ColorUtil.getBarBtnColor()
        // 5. 菜单颜色
//        self.setUpNavigation()
        if traitCollection.userInterfaceStyle == .dark {
            self.datePickerBtn.image = UIImage(named: "darkCalendar")
        }
        else{
            self.datePickerBtn.image = UIImage(named: "lightCalendar")
        }
    }
    
    // MARK: 第二部分UI
    /// 与图表相关的UI，可以获取训练记录再展示
    func setUpUIP2() {
        self.setUpChartUIView()
        // 展示日期区间
        self.setDateRangeLabel()
        
        
    }
    
    // MARK: 总跑量图
    /// 配置图表模型
    func setUpLineChartModel() -> AAChartModel {
        if traitCollection.userInterfaceStyle == .dark {
            // 当前是深色模式
            self.bgColor = ChartColorHex.ChartBKColor.chartBgColorDark0.rawValue
            self.chartTextColor = ChartColorHex.ChartTextColor.chartTextColorDark1.rawValue
            
        } else {
            // 当前是浅色模式
            self.bgColor = ChartColorHex.ChartBKColor.chartBgColorLight0.rawValue
            self.chartTextColor = ChartColorHex.ChartTextColor.chartTextColorLight0.rawValue
            
        }
        /*
        let aaDataLabels = AADataLabels()
            .enabled(true)
            .format("{y} KM")
            .shape("callout")
            .style(AAStyle(color: AAColor.red, fontSize: 13, weight: .bold))
            .backgroundColor(AAColor.white)// white color
//            .borderColor(AAColor.red)// red color
            .borderRadius(1.5)
            .borderWidth(1.3)
        
        let minData = AADataElement()
            .dataLabels(aaDataLabels)
            .y(Float(self.lastMonthDistanceArray.min()!))
            .toDic()!
        
        let maxData = AADataElement()
            .dataLabels(aaDataLabels)
            .y(Float(self.lastMonthDistanceArray.max()!))
            .toDic()!
*/
        var lineWid: Float = 5
        let cc = self.lastMonthDistanceArray.count
        print(cc)
        
        if cc <= 10 {
            lineWid = 5
        }
        else if cc > 10 && cc <= 30 {
            lineWid = 4
        }
        else if cc > 30 && cc <= 50 {
            lineWid = 3
        }
        else if cc > 50 && cc <= 70 {
            lineWid = 2
        }
        else{
            lineWid = 1
        }
        
        
        
        return AAChartModel()
            .chartType(.spline)
            .dataLabelsEnabled(false)       //是否显示值
            .tooltipEnabled(true)
            .markerRadius(0)
            .xAxisVisible(false)
            .tooltipValueSuffix(" " + UserDefaults.standard.string(forKey: "distanceUnitDefaultAb")!)
            .categories(self.lastMonthRunningDates)
            .yAxisVisible(true)
            .series([
                AASeriesElement()
                    .name("")
                    
                    .lineWidth(lineWid)
                    .data(self.lastMonthDistanceArray)
                    .color(AAGradientColor.oceanBlue)
            ])
            .backgroundColor(self.bgColor as Any)
            .xAxisLabelsStyle(.init(color: self.chartTextColor))
            .yAxisLabelsStyle(.init(color: self.chartTextColor))
        
        
    }
    /// 设置band图的UI
    func setUpLineChartView() {
        let rect = self.lineChartUIView.frame
        let aaChartView = AAChartView()
        aaChartView.isHidden = false
        aaChartView.frame = rect
        aaChartView.isScrollEnabled = false
//        aaChartView.isUserInteractionEnabled = UserDefaults.standard.bool(forKey: "allowChartInteraction")
        aaChartView.isUserInteractionEnabled = true
        self.chartContentUIView[0].addSubview(aaChartView)
        let aaChartModel = self.setUpLineChartModel()
        aaChartView.aa_drawChartWithChartModel(aaChartModel)
        
    }
    
    

    
    
    
    
    /// 图表所在的UIView的配置
    func setUpChartUIView() {
        for chartUIView in self.chartContentUIView {
            chartUIView.layer.cornerRadius = 20
            chartUIView.backgroundColor = ColorUtil.dynamicColor(dark: UIColor.black, light: UIColor.white)
            chartUIView.layer.shadowOpacity = 0.48
            chartUIView.layer.shadowColor = ColorUtil.runningOverviewLayerShadowColor()
            chartUIView.layer.shadowOffset = .zero
            chartUIView.layer.shadowRadius = 1
        }
    }
    
    func setUpNavigation(){
        self.navigationController?.navigationBar.tintColor = ColorUtil.getGeneralTintColorStyle1()
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [.foregroundColor: ColorUtil.getGeneralTintColorStyle1()]
        appearance.largeTitleTextAttributes = [.foregroundColor: ColorUtil.getGeneralTintColorStyle1()]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
    }

    
    // MARK: - Dark/Light
    /// 设备外观设置
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.userInterfaceStyle == .dark {
            // 当前是深色模式
            self.bgColor = ChartColorHex.ChartBKColor.chartBgColorDark0.rawValue
            self.chartTextColor = ChartColorHex.ChartTextColor.chartTextColorDark1.rawValue
            self.datePickerBtn.image = UIImage(named: "darkCalendar")
        } else {
            // 当前是浅色模式
            self.bgColor = ChartColorHex.ChartBKColor.chartBgColorLight0.rawValue
            self.chartTextColor = ChartColorHex.ChartTextColor.chartTextColorLight0.rawValue
            self.datePickerBtn.image = UIImage(named: "lightCalendar")
        }
        
        // 刷新
        self.setUpLineChartView()
        
    }
    
    
}
