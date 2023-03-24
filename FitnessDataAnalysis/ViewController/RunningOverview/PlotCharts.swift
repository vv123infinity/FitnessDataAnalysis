//
//  PlotCharts.swift
//  FitnessDataAnalysis
//
//  Created by 十口V🌼 on 2023/2/24.
//


import UIKit
import HealthKit
import AAInfographics


class PlotCharts: UIViewController {

    // MARK: - 接口
    @IBOutlet var aaChartUIView: UIView!
    @IBOutlet weak var totalDistanceLabel: GradientLabel!
    @IBOutlet weak var backUIView: UIView!      // 滚动视图上的View
    @IBOutlet var chartContentUIView: [UIView]!
    @IBOutlet weak var runningFreq: UILabel!
    @IBOutlet var scatterUIView: UIView!
    @IBOutlet weak var pieChartView: UIView!
    @IBOutlet weak var interactionBtn: UIBarButtonItem!
//    @IBOutlet weak var interactionHintUIView: UIView!
    
    // MARK: - Properties
    lazy var allowInteraction: Bool = UserDefaults.standard.bool(forKey: "allowChartInteraction")
    var bgColor: String!
    var chartTextColor: String!    // Chart中文字的颜色
    var workouts: [HKWorkout]!   // 加载的workout
    /// 散点图数据
    var data: [[Double]] = []
    /// 近十二个月的跑量 unit: km
    var runningDistanceRecent12: [Double] = []
    var pieChartData: [[Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUIP1()
        
        WorkoutDataStore.loadLastWorkouts() { (res, error) in
            // 可以成功访问Workout类型的数据
            if res != nil && res!.count != 0 && error == nil{
                // 1 set up UI
                self.setUpUIP2()
                self.loadWorkouts()
            }
            else {
                // 隐藏内容视图
                for chartUIView in self.chartContentUIView {
                    chartUIView.isHidden = true
                }
//                self.authorizeHK()
                
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
    
    
    
    // MARK: - IBAction
    @IBAction func changeInteractionBtnPressed(_ sender: UIBarButtonItem) {
        if UserDefaults.standard.bool(forKey: "allowChartInteraction") {
            UserDefaults.standard.set(false, forKey: "allowChartInteraction")
        }
        else{
            UserDefaults.standard.set(true, forKey: "allowChartInteraction")
        }
        
        DispatchQueue.main.async {
            self.setUpInteractionBtn()
            self.firstTry(UserDefaults.standard.bool(forKey: "allowChartInteraction"))
            self.setUpScatterChart(UserDefaults.standard.bool(forKey: "allowChartInteraction"))
            self.setUpPieChartView(UserDefaults.standard.bool(forKey: "allowChartInteraction"))
            
            if !UserDefaults.standard.bool(forKey: "interactionHintController") {
                var acTitle = ""
                if UserDefaults.standard.bool(forKey: "allowChartInteraction") {
                    acTitle = NSLocalizedString("interactionVC_TitleOn", comment: "")
                }
                else{
                    acTitle = NSLocalizedString("interactionVC_TitleOff", comment: "")
                }
                let OKAction = UIAlertAction(title: NSLocalizedString("interactionVC_buttonTitle", comment: ""), style: .default)
                
                let ac = UIAlertController(title: acTitle, message: NSLocalizedString("interactionVC_Message", comment: ""), preferredStyle: .alert)

                let noMoreTips = UIAlertAction(title: NSLocalizedString("interactionVC_noTips", comment: ""), style: .destructive){_ in
                    UserDefaults.standard.set(true, forKey: "interactionHintController")
                }
                ac.addAction(noMoreTips)
                ac.addAction(OKAction)

                self.present(ac, animated: true)
            }
            
            // TODO: 提示用户现在是否可以交互 Size如何选择。。。
            
            /*
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.frame = CGRect(x: 20, y: 20, width: 80, height: 80)
            blurView.center = CGPoint(x: 50, y: 50)
            blurView.layer.cornerRadius = 20
            blurView.clipsToBounds = true
            let vibrancyView = UIVisualEffectView(effect:
                                                    UIVibrancyEffect(blurEffect: blurEffect))
            vibrancyView.frame.size = blurView.frame.size
            vibrancyView.layer.cornerRadius = 20
            vibrancyView.layer.masksToBounds = true
            blurView.contentView.addSubview(vibrancyView)
             
            //将文本标签添加到vibrancy视图中
            let label=UILabel(frame:CGRectMake(0, 0, 30, 30))
            label.text = "Hello World"
            label.font = UIFont(name: "HelveticaNeue-Bold", size: 10)
            label.textAlignment = .center
            label.textColor = UIColor.white
            vibrancyView.contentView.addSubview(label)
            self.chartContentUIView.addSubview(blurView)
            
            blurView.isHidden = true
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                blurView.alpha = 1
                
            }) { _ in
                blurView.isHidden = false
                
            }
            UIView.animate(withDuration: 0.5, delay: 1.5, options: .curveEaseOut, animations: {
                blurView.alpha = 0
            }) { _ in
                blurView.removeFromSuperview()
            }
             */

        }

        

        
    }
    
    

    
    // MARK: - HK认证
    func authorizeHK() {
        HKSetupAssistant.authorizeHealthKit() { (s, error) in
            guard s else {
                let baseMessage = "HealthKit Authorization Failed"
                if let error = error {
                  print("\(baseMessage). Reason: \(error.localizedDescription)")
                } else {
                  print(baseMessage)
                }
                return
              }
        }
    }
    
    // MARK: - Basic UI
    func setUpUIP1(){
        // 2. View bk color
        self.view.backgroundColor = ColorUtil.getBackgroundColorStyle1()
        // 3. back
        self.backUIView.backgroundColor = ColorUtil.getBackgroundColorStyle1()
        // 5. 菜单颜色
        self.navigationController?.navigationBar.tintColor = ColorUtil.getBarBtnColor()
        
//        self.setUpNavigation()
    }
    func setUpUIP2() {
        // 1. Gradient Label
        self.totalDistanceLabel.gradientColors = ColorUtil.getGradTextStyle2().map{$0.cgColor}
        
        // 4. 设置最外侧UIView
        self.setUpChartUIView()

        // 6. 交互按钮
        self.setUpInteractionBtn()
    }
    func hideElements(){
        self.totalDistanceLabel.isHidden = true
        self.aaChartUIView.isHidden = true
        self.scatterUIView.isHidden = true
        self.runningFreq.isHidden = true
    }
    func hideAAChart() {
        self.aaChartUIView.isHidden = true
        self.scatterUIView.isHidden = true
    }
    func showNormalElements() {
        self.totalDistanceLabel.isHidden = false
        self.aaChartUIView.isHidden = false
        self.scatterUIView.isHidden = false
        self.runningFreq.isHidden = false
    }
    func setUpNavigation(){
        self.navigationController?.navigationBar.tintColor = ColorUtil.getGeneralTintColorStyle1()
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [.foregroundColor: ColorUtil.getGeneralTintColorStyle1()]
        appearance.largeTitleTextAttributes = [.foregroundColor: ColorUtil.getGeneralTintColorStyle1()]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
    }
    func setUpChartUIView() {
        for chartUIView in self.chartContentUIView {
            chartUIView.layer.cornerRadius = 20
//            chartUIView.backgroundColor = ColorUtil.runningOverviewBKColor()
            chartUIView.backgroundColor = ColorUtil.dynamicColor(dark: UIColor.black, light: UIColor.white)
            chartUIView.layer.shadowOpacity = 0.48
            chartUIView.layer.shadowColor = ColorUtil.runningOverviewLayerShadowColor()
            chartUIView.layer.shadowOffset = .zero
            chartUIView.layer.shadowRadius = 1
        }
    }
    func setUpInteractionBtn() {
        if UserDefaults.standard.bool(forKey: "allowChartInteraction") {
            self.interactionBtn.image = UIImage(named: "allowInteraction")
        }else{
            self.interactionBtn.image = UIImage(named: "forbidInteraction")
        }
    }
    
    // MARK: - 加载Workout
    /// 从HKHealthStore获取最新的最近十二个月的Workout记录
    func loadWorkouts() {
        WorkoutDataStore.loadWorkouts() { (workouts, error) in
            self.workouts = workouts
            // 得到距离，单位米
            let res = QueryWorkoutsAssistant.queryRecent12MonRunningDistance(workouts!)
            // 用户偏好的距离单位
            let defaultUnit = UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit")
            // 转换单位 & 保留两位小数
            self.runningDistanceRecent12 = res.map{
                return AssistantMethods.convertMeterToUnit(defaultUnit, $0)
            }
            // 计算总距离
            let totalRes = self.runningDistanceRecent12.reduce(0) { (r, n) in
                r + n
            }
            // TODO: 将来需要修改
            // 将计算得到的值存入UserDefaults中
            UserDefaults.standard.set(String(format: "%.2f", totalRes), forKey: "IndicatorRecent12MonDistance")
            // 展示总距离
            self.totalDistanceLabel.text = String(format: "%.2f", totalRes) + " " + UserDefaults.standard.string(forKey: "distanceUnitDefaultAb")!
            
            
            //  MARK: 条形图12个月的距离
            self.firstTry(self.allowInteraction)
            
            
            // MARK: 散点图——训练日期分布图
            if defaultUnit != 2 {
                let r = QueryWorkoutsAssistant.getAllDistAndPaceInDouble(workouts!, defaultUnit)
                var distPaceArray: [[Double]] = []
                let freq = r.wDist.count
                
                for i in 0..<freq {
                    distPaceArray.append([r.wDist[i], r.wPace[i]])
                }
                
                self.data = distPaceArray
                self.setUpScatterChart(self.allowInteraction)
            }
            else {
                self.chartContentUIView[2].isHidden = true
            }
            
            // MARK:  Pie Chart
            // 单位2 - 米
            let pieData = QueryWorkoutsAssistant.getAllDistAndPaceInDouble(workouts!, 2)
            self.pieChartData = AssistantMethods.classifyRunningDistance(pieData.wDist)
            self.setUpPieChartView(self.allowInteraction)
            
            // 跑步频率提示信息
            let freq = pieData.wDist.count
            var frequencyMessage = NSLocalizedString("runningFrequencyMessageP1", comment: "") + "\(freq)" + NSLocalizedString("runningFrequencyMessageP2", comment: "")
            if freq > 200 {
                frequencyMessage += "🥳"
            }
            else{
                frequencyMessage += "😅"
            }
            self.runningFreq.text = frequencyMessage
            
            

            
    }
        
    }
    
    
    

    
    // MARK: - 条形图
    /// 绘制最近12个月跑量的条形图
    func firstTry(_ interaction: Bool) {
        
        let rect = self.aaChartUIView.frame
        let aaChartView = AAChartView()
        aaChartView.isHidden = false
        aaChartView.frame = rect
        aaChartView.isScrollEnabled = false
        aaChartView.isUserInteractionEnabled = interaction
        self.chartContentUIView[0].addSubview(aaChartView)
        
        let aaChartModel = self.getAAChartModel()
        aaChartView.aa_drawChartWithChartModel(aaChartModel)
        
    }
    /// 条形图模型配置
    func getAAChartModel() -> AAChartModel {
        if traitCollection.userInterfaceStyle == .dark {
            // 当前是深色模式
            self.bgColor = ChartColorHex.ChartBKColor.chartBgColorDark0.rawValue
            self.chartTextColor = ChartColorHex.ChartTextColor.chartTextColorDark0.rawValue
            
        } else {
            // 当前是浅色模式
            self.bgColor = ChartColorHex.ChartBKColor.chartBgColorLight0.rawValue
            self.chartTextColor = ChartColorHex.ChartTextColor.chartTextColorLight0.rawValue
            
        }
        
        let model0 = AAChartModel().chartType(.bar)
            .animationType(.easeFromTo)
            .yAxisVisible(false)
            .colorsTheme([ChartColorHex.BarColorSet.recent12VisColor0.rawValue])
            .categories(AssistantMethods.getRecent12MonName())
            .tooltipValueSuffix(" "+NSLocalizedString("distanceUnitKM", comment: ""))

            .series([AASeriesElement().name(NSLocalizedString("distance", comment: "")).data(self.runningDistanceRecent12).dataLabels(.init().color(self.chartTextColor).softConnector(true)).showInLegend(true)
                    ])
            .xAxisLabelsStyle(.init(color: self.chartTextColor))
            .backgroundColor(self.bgColor as Any)
            .borderRadius(1)

//        let model1= AAChartModel().chartType(.)
        return model0
        
    }
    

    // MARK: - 饼图
    /// 绘制圆饼图
    func setUpPieChartView(_ interaction: Bool){
        let rect = self.pieChartView.frame
        let pieView = AAChartView()
        pieView.isHidden = false
        pieView.frame = rect
        pieView.isScrollEnabled = false
        pieView.isUserInteractionEnabled = interaction
        self.chartContentUIView[1].addSubview(pieView)
        let pieChartModel = getPieChartModel()
        pieView.aa_drawChartWithChartModel(pieChartModel)
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
        let pModel = AAChartModel()
            .chartType(.pie)
            .backgroundColor(self.bgColor as Any)
//            .title("LANGUAGE MARKET SHARES JANUARY,2020 TO MAY")
//            .subtitle("virtual data")
            .dataLabelsEnabled(true) //是否直接显示扇形图数据
            .dataLabelsStyle(.init(color: self.chartTextColor))
            .yAxisTitle("")
            .xAxisLabelsStyle(.init(color: self.chartTextColor))
            .series([
                AASeriesElement()
                    .colors(["#F6BD60", "#F8EDE3", "#F6CAC4", "#85A59D", "#F38583"])
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
    
    // MARK: - 散点图
    /// 将跑者配速分成几类。
    func splitSomePace() -> [AASeriesElement] {
        let colorSet = ["#F08080", "#F8AD9D", "#FFDABA"]   // 快 -> 慢
        var th1 = 0.0
        var th2 = 0.0
        // 用户偏好的距离单位
        let defaultUnit = UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit")
        switch defaultUnit {
        case 0:
            th1 = PaceCalculatorMethods.PaceThresholdSetting.fastInKM.rawValue
            th2 = PaceCalculatorMethods.PaceThresholdSetting.middleInKM.rawValue
        case 1:
            th1 = PaceCalculatorMethods.PaceThresholdSetting.fastInMile.rawValue
            th2 = PaceCalculatorMethods.PaceThresholdSetting.middleInMile.rawValue
        default:
            print("hello")
        }
        
        // 1. 快 配速 < 5.0
        let fastData = data.filter {
            return $0[1] < th1
        }
        // 2. 中  5.0<= <=6.0
        let middleData = data.filter {
            return $0[1] >= th1 && $0[1] <= th2
        }
        // 3. 慢   > 6
        let slowData = data.filter {
            return $0[1] > th2
        }
        if defaultUnit == 2 {
            let resSE = AASeriesElement().name("s/m").color(colorSet[1]).data(self.data)
            return [resSE]
        }
        else {
            let fastSE = AASeriesElement().name("Fast").color(colorSet[0]).data(fastData)
            let middleSE = AASeriesElement().name("Middle").color(colorSet[1]).data(middleData)
            let slowSE = AASeriesElement().name("Slow").color(colorSet[2]).data(slowData)
            return [fastSE, middleSE, slowSE]
        }

    }
    /// 绘制距离——配速散点图
    func setUpScatterChart(_ interaction: Bool) {
        let rect = self.scatterUIView.frame
        let scatterView = AAChartView()
        scatterView.isHidden = false
        scatterView.frame = rect
        scatterView.isScrollEnabled = false
        scatterView.isUserInteractionEnabled = interaction
        self.chartContentUIView[2].addSubview(scatterView)
        let scatterChartModel = getScatterChartModel(data)
        scatterView.aa_drawChartWithChartModel(scatterChartModel)
    }
    
    /// 散点图模型配置
    func getScatterChartModel(_ data: [[Double]]) -> AAChartModel{
        if traitCollection.userInterfaceStyle == .dark {
            // 当前是深色模式
            self.bgColor = ChartColorHex.ChartBKColor.chartBgColorDark0.rawValue
            self.chartTextColor = ChartColorHex.ChartTextColor.chartTextColorDark0.rawValue
            
        } else {
            // 当前是浅色模式
            self.bgColor = ChartColorHex.ChartBKColor.chartBgColorLight0.rawValue
            self.chartTextColor = ChartColorHex.ChartTextColor.chartTextColorLight0.rawValue
        }
        
        let sModel = AAChartModel()
            .chartType(.scatter)
            .animationType(.easeFromTo)
            .markerSymbol(.circle)
//            .markerSymbolStyle(.borderBlank)
            .markerRadius(3.5)
            .xAxisLabelsEnabled(true)
//            .xAxisTitle(NSLocalizedString("distanceUnitDefault", comment: ""))
            .xAxisTitle(UserDefaults.standard.string(forKey: "distanceUnitDefaultAb")!)
            .yAxisTitle(NSLocalizedString("pace", comment: ""))
            .yAxisReversed(true)
            .series(self.splitSomePace())
            .backgroundColor(self.bgColor as Any)
            .xAxisLabelsStyle(.init(color: self.chartTextColor))
            .yAxisLabelsStyle(.init(color: self.chartTextColor))
            .yAxisLabelsEnabled(true)
            .yAxisGridLineWidth(0)
        return sModel
    }
    

    
    
    // MARK: - Dark/Light
    /// 设备外观设置
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.userInterfaceStyle == .dark {
            // 当前是深色模式
            self.bgColor = ChartColorHex.ChartBKColor.chartBgColorDark0.rawValue
            self.chartTextColor = ChartColorHex.ChartTextColor.chartTextColorDark0.rawValue
            
        } else {
            // 当前是浅色模式
            self.bgColor = ChartColorHex.ChartBKColor.chartBgColorLight0.rawValue
            self.chartTextColor = ChartColorHex.ChartTextColor.chartTextColorLight0.rawValue
            
        }
        
        // 刷新UI
        self.setUpUIP2()
        // 重新AA绘制图表
        self.firstTry(UserDefaults.standard.bool(forKey: "allowChartInteraction"))
        self.setUpScatterChart(UserDefaults.standard.bool(forKey: "allowChartInteraction"))
        self.setUpPieChartView(UserDefaults.standard.bool(forKey: "allowChartInteraction"))
        
    }

    


}
