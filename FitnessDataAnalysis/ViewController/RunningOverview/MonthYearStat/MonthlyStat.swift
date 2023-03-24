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
    @IBOutlet var contentView: [UIView]!
    /// 本月日期
    @IBOutlet weak var thisMonthDateLabel: UILabel!
    
    // 总跑量band图表的vIew
    @IBOutlet weak var lineChartUIView: UIView!
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
    
    // MARK: properties
    lazy var uniUISetting = UniversalUISettings()
    var workouts: [HKWorkout] = []
    /// 这个月的跑步距离数组（km）
    var thisMonthDistanceArray: [Double] = []
    /// 这个月的跑步日期数组
    var thisMonthRunningDates: [String] = []
    var bgColor: String!
    var chartTextColor: String!    // Chart中文字的颜色
    var userDefineDateFlag: Bool = false
    /// 起始日期（默认本月初）
    var startDate: Date!
    /// 结束日期（默认现在）
    var endDate: Date!
    
    var result: (accDistance: String, accTime: String, avgPace: String, numOfRuns: String, distanceArray: [Double], maxDistance: String, maxPace: String)!
    
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
        fastisController.shortcuts = [.lastWeek, .lastMonth]
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
        
        self.setUpContentView()
        self.setImageView()
        self.addBlurEffect()
        self.setUpIndicatorUIView()
        
        // 设置本月的日期

        self.setUpDatePickerButton()
        self.thisMonthDateLabel.layer.cornerRadius = 10
        self.setDateRangeLabel()
        self.setUpFootnoteColor()
    }

    func setUpIndicatorUIView(){
        for vv in self.indicatorUIView {
            vv.layer.cornerRadius = 10
            vv.backgroundColor = ColorUtil.dynamicColor(dark: UIColor.init(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1), light: UIColor.white)
        }
    }
    func setUpFootnoteColor(){
        for ll in self.footnoteSmileyLabel{
            ll.textColor = UIColor.gray
        }
    }
    
    
    
    func setUpDatePickerButton(){
        if traitCollection.userInterfaceStyle == .dark {
            self.datePickerBtn.setImage(UIImage(named: "darkCalendar"), for: .normal)
        }
        else{
            self.datePickerBtn.setImage(UIImage(named: "lightCalendar"), for: .normal)
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
        
        for vv in self.contentView {
            vv.backgroundColor = ColorUtil.getMonthlyStatViewBKColor()
            
            vv.layer.shadowColor = uniUISetting.shadowColor
            vv.layer.cornerRadius = uniUISetting.cornerRadius
            vv.layer.shadowOffset = uniUISetting.shadowOffset
            vv.layer.shadowRadius = uniUISetting.shadowRadius
            vv.layer.shadowOpacity = uniUISetting.shadowOpcacity
        }
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
                
                
                // MARK: 展示Overview的指标
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
        }
    }
    
    /// 设置line图的UI
    func setUpLineChartView() {
        let rect = self.lineChartUIView.frame
        let aaChartView = AAChartView()
        aaChartView.isHidden = false
        aaChartView.frame = rect
        aaChartView.isScrollEnabled = false
        aaChartView.isUserInteractionEnabled = UserDefaults.standard.bool(forKey: "allowChartInteraction")
        self.contentView[0].addSubview(aaChartView)
        let aaChartModel = self.setUpLineChartModel()
        aaChartView.aa_drawChartWithChartModel(aaChartModel)
        
    }
    
    
    func setUpLineChartModel() -> AAChartModel {
        if traitCollection.userInterfaceStyle == .dark {
            // 当前是深色模式
            self.bgColor = ChartColorHex.ChartBKColor.chartBgColorDark0.rawValue
            self.chartTextColor = ChartColorHex.ChartTextColor.chartTextColorDark1.rawValue
            return AAChartModel()
                .chartType(.spline)
                .dataLabelsEnabled(false)       //是否显示值
                .tooltipEnabled(true)
                .markerRadius(0)
                .xAxisVisible(false)
                .yAxisVisible(false)
                .tooltipValueSuffix(" " + UserDefaults.standard.string(forKey: "distanceUnitDefaultAb")!)
                .categories(self.thisMonthRunningDates)
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
            
        } else {
            // 当前是浅色模式
            self.bgColor = ChartColorHex.ChartBKColor.chartBgColorLight0.rawValue
            self.chartTextColor = ChartColorHex.ChartTextColor.chartTextColorLight0.rawValue
            return AAChartModel()
                .chartType(.spline)
                .dataLabelsEnabled(false)       //是否显示值
                .tooltipEnabled(true)
                .markerRadius(0)
                .xAxisVisible(false)
                .yAxisVisible(true)
                .tooltipValueSuffix(" " + UserDefaults.standard.string(forKey: "distanceUnitDefaultAb")!)
                .categories(self.thisMonthRunningDates)
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

            
        
        
    }
    
    
    // MARK: - Dark/Light
    /// 设备外观设置
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.userInterfaceStyle == .dark {
            // 当前是深色模式
            self.bgColor = ChartColorHex.ChartBKColor.chartBgColorDark0.rawValue
            self.chartTextColor = ChartColorHex.ChartTextColor.chartTextColorDark1.rawValue
//            self.datePickerBtn.image = UIImage(named: "darkCalendar")
            
        } else {
            // 当前是浅色模式
            self.bgColor = ChartColorHex.ChartBKColor.chartBgColorLight0.rawValue
            self.chartTextColor = ChartColorHex.ChartTextColor.chartTextColorLight0.rawValue
//            self.datePickerBtn.image = UIImage(named: "lightCalendar")
            
        }
        // 刷新
        self.setUpLineChartView()
        setUpDatePickerButton()
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
