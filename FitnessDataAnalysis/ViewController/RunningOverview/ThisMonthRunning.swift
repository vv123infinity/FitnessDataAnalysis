//
//  ThisMonthRunning.swift
//  FitnessDataAnalysis
//
//  Created by 十口V🌼 on 2023/3/2.
//

import UIKit
import HealthKit
import AAInfographics

class ThisMonthRunning: UIViewController {
    // MARK: - 接口
    @IBOutlet weak var runningAnimationUIView: UIView!  // 跑步小人🏃🏻‍♀️
    @IBOutlet weak var backUIView: UIView!      // 滚动视图上的View
    @IBOutlet var chartContentUIView: [UIView]!    // 图表所在的UIView
    
    @IBOutlet weak var thisMonthTotalDistance: GradientLabel!
    // 月初~今天的日期label
    @IBOutlet weak var thisMonthDateRangeLabel: UILabel!
    // 总跑量band图表的vIew
    @IBOutlet weak var bandChartUIView: UIView!
    
    
    // MARK: - 属性
    /// 上个月的起始日期
    var startDate: Date!
    /// 上个月的结束日期
    var endDate: Date!
    var thisMonthWorkouts: [HKWorkout]!
    /// 上个月的跑步距离数组（km）
    var thisMonthDistanceArray: [Double] = []
    /// 上个月的跑步日期数组
    var thisMonthRunningDates: [String] = []
    var bgColor: String!
    var chartTextColor: String!    // Chart中文字的颜色
    
    
    // MARK: 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()

        // 设置标题 如 2023-03
        self.setTitle()
        
        self.setUpUIP1()
        
        WorkoutDataStore.loadLastWorkouts() { (res, error) in
            // 可以成功访问Workout类型的数据
            if res!.count != 0 && error == nil{
                // 1 set up UI
                self.setUpUIP2()
                // 开始load这个月的跑步workouts
                WorkoutDataStore.loadThisMonthWorkouts() {(workouts, error) in
                    self.thisMonthWorkouts = workouts
                    // 获取本月跑步的距离和日期
                    let res = QueryWorkoutsAssistant.getWorkoutsDistanceAndDate(self.thisMonthWorkouts, "yyyy-MM-dd")
                    
                    let resDistance = res.dist
                    self.thisMonthRunningDates = res.workoutDate.reversed()
                    // 转换距离的单位
                    let userUnit = UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit")
                    self.thisMonthDistanceArray = resDistance.map {
                        return AssistantMethods.convertMeterToUnit(userUnit, $0)
                    }
                    self.thisMonthDistanceArray = self.thisMonthDistanceArray.reversed()
                    // 计算总距离 & 配置渐变label
                    let totalDistanceInMeter: Double = resDistance.reduce(0) {(res, num) in
                        return res + num
                    }
                    
                    // 更新跑量的值
                    for i in 0..<3{
                        /// total distance
                        let td = AssistantMethods.convertMeterToUnit(i, totalDistanceInMeter)
                        if i == 0 {
                            let tdInString = String(format: "%.2f", td) + " KM"
                            UserDefaults.standard.set(tdInString, forKey: "thisMonthRunningDistanceInKM")
                        }
                        else if i == 1 {
                            let tdInString = String(format: "%.2f", td) + " Mile"
                            UserDefaults.standard.set(tdInString, forKey: "thisMonthRunningDistanceInMile")
                        }
                        else if i == 2 {
                            let tdInString = String(format: "%.2f", td) + " M"
                            UserDefaults.standard.set(tdInString, forKey: "thisMonthRunningDistanceInMeter")
                        }
                        else {
                            
                        }
                    }
                    var totalDistanceToShow: String = " "
                    switch userUnit {
                    case 0:
                        totalDistanceToShow = UserDefaults.standard.string(forKey: "thisMonthRunningDistanceInKM")!
                    case 1:
                        totalDistanceToShow = UserDefaults.standard.string(forKey: "thisMonthRunningDistanceInMile")!
                    case 2:
                        totalDistanceToShow = UserDefaults.standard.string(forKey: "thisMonthRunningDistanceInMeter")!
                    default:
                        totalDistanceToShow = UserDefaults.standard.string(forKey: "thisMonthRunningDistanceInKM")!
                    }
                    self.thisMonthTotalDistance.text = totalDistanceToShow
                    self.thisMonthTotalDistance.gradientColors = ColorUtil.getGradTextStyle3()
                    
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
    
    /// 标题栏的年份、月份
    func setTitle() {
        let dateFormatter4 = DateFormatter()
        dateFormatter4.locale = Locale(identifier: "en")
        dateFormatter4.dateFormat = "yyyy-MM"
        let nn = Date()
        self.title = dateFormatter4.string(from: nn)
    }
    
    // MARK: - Basic UI
    /// 基础UI
    func setUpUIP1(){
        // 2. View bk color
        self.view.backgroundColor = ColorUtil.getBackgroundColorStyle1()
        // 3. back
        self.backUIView.backgroundColor = ColorUtil.getBackgroundColorStyle1()
        
        self.navigationController?.navigationBar.tintColor = ColorUtil.getBarBtnColor()
        
        // 5. 菜单颜色
//        self.setUpNavigation()
    }
    
    // MARK: 第二部分UI
    /// 与图表相关的UI，可以获取训练记录再展示
    func setUpUIP2() {
        self.setUpChartUIView()
        // 展示日期区间
        self.getAndSetDateRangeLabel()
        self.setUpLineChartView()
        
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
        return AAChartModel()
            .chartType(.spline)
            .dataLabelsEnabled(false)       //是否显示值
            .tooltipEnabled(true)
            .markerRadius(0)
            .xAxisVisible(false)
            .tooltipValueSuffix(" " + UserDefaults.standard.string(forKey: "distanceUnitDefaultAb")!)
            .categories(self.thisMonthRunningDates)
            .yAxisVisible(true)
            .series([
                AASeriesElement()
                    .name("")
                    
                    .lineWidth(7)
                    .data(self.thisMonthDistanceArray)
                    .color(AAGradientColor.oceanBlue)
            ])
            .backgroundColor(self.bgColor as Any)
            .xAxisLabelsStyle(.init(color: self.chartTextColor))
            .yAxisLabelsStyle(.init(color: self.chartTextColor))
        
        
    }
    
    
    /// 设置band图的UI
    func setUpLineChartView() {
        let rect = self.bandChartUIView.frame
        let aaChartView = AAChartView()
        aaChartView.isHidden = false
        aaChartView.frame = rect
        aaChartView.isScrollEnabled = false
        aaChartView.isUserInteractionEnabled = UserDefaults.standard.bool(forKey: "allowChartInteraction")
        self.chartContentUIView[0].addSubview(aaChartView)
        let aaChartModel = self.setUpLineChartModel()
        aaChartView.aa_drawChartWithChartModel(aaChartModel)
        
    }
    
    
    // MARK: 本月日期
    /// 获取本月的起始日期——今天并赋值
    func getAndSetDateRangeLabel(){
        // 设置要展现的日期形式
        let dateFormatter4 = DateFormatter()
        dateFormatter4.locale = Locale(identifier: "en")
        dateFormatter4.dateFormat = "yyyy-MM-dd"
        
        
        // 获取本月的起始日期
        let calendar = Calendar.current
        let today = Date()
        let components = calendar.dateComponents([.year, .month], from: today)
        let startOfMonth = calendar.date(from: components)!
        
        let nn = Date()   // 今天的日期
        // 获取字符串
        let startDateInString = dateFormatter4.string(from: startOfMonth)
        let todayDateInString = dateFormatter4.string(from: nn)
        let dateToShow = startDateInString + NSLocalizedString("dateTo", comment: "") + todayDateInString
        // 赋值给Label
        self.thisMonthDateRangeLabel.text = dateToShow
        
    }
    
    func loadRunningAnimation() {
        let jeremyGif = UIImage.gifImageWithName("pikachu-running")
        let imageView = UIImageView(image: jeremyGif)
        imageView.frame = self.runningAnimationUIView.frame
        self.runningAnimationUIView.addSubview(imageView)
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
    
    
    // MARK: - Dark/Light
    /// 设备外观设置
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
        self.setUpLineChartView()
        
    }
    




    func setUpNavigation(){
        self.navigationController?.navigationBar.tintColor = ColorUtil.getGeneralTintColorStyle1()
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [.foregroundColor: ColorUtil.getGeneralTintColorStyle1()]
        appearance.largeTitleTextAttributes = [.foregroundColor: ColorUtil.getGeneralTintColorStyle1()]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
    }

}

