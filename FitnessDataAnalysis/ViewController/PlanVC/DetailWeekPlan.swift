
import UIKit
import CoreData
import HealthKit
import CoreML


class DetailWeekPlan: UIViewController, ChartDelegate {
    /// 日期选择
    @IBOutlet weak var datePicker: UIDatePicker!
    /// 按钮数组，0-距离第一次跑步 1-距离上一次跑步
    @IBOutlet var myButtonArray: [UIButton]!
    
    @IBOutlet var generalLabel: [UILabel]!
    
    @IBOutlet var chartUIView: UIView!
    @IBOutlet var actChartView: UIView!
    
    /// Hint Label UIView
    @IBOutlet var hintLabelUIView: [UIView]!
    @IBOutlet var hintLabels: [UILabel]!
    /// Text UIView
    @IBOutlet var textUIView: UIView!

    /// Date hint Label
    @IBOutlet var dateHintLabel: UILabel!
    
    lazy var chart: Chart = Chart()
    
    var planColor: UIColor = UIColor.init(red: 255/255.0, green: 165/255.0, blue: 0/255.0, alpha: 1)
    
    var managedObjectContext: NSManagedObjectContext!
    var curDate: Date = Date()
    /// 第一次跑步的日期
    var firstDate: String!
    /// 最近一次跑步的日期
    var lastDate: String!
    var dateToSelect: [Date] = []
    /// emoji数组
    lazy var emojiArray = ["🏃‍♀️", "🏃", "🏃‍♂️"]
    /// "dd" : XX km
    var dateToDistance: [String: Double] = [:]
    /// Fetch from Core Data
    var planedDistanceArrayToPlot: [Double] = []
    /// yyyy-MM-dd 数组
    var fullDateArray: [String] = []
    /// dd 数组
    var ddDateArray: [String] = []
    /// 用于预测距离的LSTM模型
    var lstm_dist_model: MLModel!
    /// 用于预测的数组
    var distArrayToPredict: [Float] = []
    
    // MARK: - 生命周期viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUI()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedObjectContext = appDelegate!.persistentContainer.viewContext
        self.setUpBackItem()
        
        self.setUpDays()

        // 配速图像
        self.configChart()
        

    }
    /// ① 初始化计划跑量和实际跑量的图像 ② 准备获取用户的跑步数据，CoreData数据，并给Chart赋值
    func configChart() {
        // 在每次配置前都清空一下chart
        self.clearChart()
        
        self.chart = Chart()
        self.chart.delegate = self
        self.prepareRunningDistanceData()
    }
    
    /// 清除Chart的相关数据
    func clearChart() {
        self.chart.removeFromSuperview()
        self.dateToDistance = [:]
        self.planedDistanceArrayToPlot = []
        self.chart = Chart()
    }
    
    /// 返回按钮无标题
    func setUpBackItem() {
        let bkItem = UIBarButtonItem()
        bkItem.title = ""
        self.navigationItem.backBarButtonItem = bkItem
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.clearChart()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configChart()
        
    }
    
    /// 本周的实际跑量和计划跑量
    func prepareRunningDistanceData() {
        WorkoutDataStore.loadLastWorkouts() { (res, error) in
            // 可以成功访问Workout类型的数据
            if res != nil && res!.count != 0 && error == nil{
                WorkoutDataStore.loadRecent15DaysWorkouts() { (workouts, error) in
                    
                    // 得到距离，单位米
                    let res = QueryWorkoutsAssistant.queryRecent5MonRunningDistance(workouts!, "zh_CN")
                    
                    // 用户偏好的距离单位
                    let defaultUnit = UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit")
                    // 转换单位 & 保留两位小数
                    // 距离数组
                    let d = res.map{
                        return AssistantMethods.convertMeterToUnit(defaultUnit, $0)
                    }
                    
                    
                    var keyString = ""
                    if UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit") == 0
                    {
                        keyString = "thisMonthTargetVolInKM"
                    }
                    else if UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit") == 1{
                        keyString = "thisMonthTargetVolInMile"
                    }
                    
                    guard let wk = workouts else {return}
                    
                    if wk != [] && !wk.isEmpty && wk != nil {
                        let res = QueryWorkoutsAssistant.getRecentSevenDaysDistance(wk)
                        let defaultUnit = UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit")
                        // 转换单位 & 保留两位小数
                        let disInUnit = res.dis.map {
                            return AssistantMethods.convertMeterToUnit(defaultUnit, $0)
                        }
                        
                        var dateToDis: [String: Double] = [:]
                        let resDate = AssistantMethods.getThisWeekDate()
                        // 初始化
                        for dd in resDate.dd {
                            dateToDis[dd] = 0.0
                        }
                        
                        for i in 0..<res.dateArray.count {
                            dateToDis[res.dateArray[i]] = disInUnit[i]
                        }
                        self.dateToDistance = dateToDis
                        print(self.dateToDistance)
                        self.loadWeekPlanCoreData()
                        
                    }
                    
                }
                
                // 1. 加载最近7天的跑步距离
                WorkoutDataStore.loadWorkouts7Days() {(workouts, error) in
                    let res = MonthlyStatMethods.getDistAndDate(workouts!)
                    let distDouble: [Double] = res.dist
                    let distFloat32: [Float32] = distDouble.map{Float32($0)}
                    // 2. 加载LSTM模型
                    self.lstm_dist_model = try! lstm_dist(configuration: .init()).model
                    // 3. 输入数据格式转换
                    let testInputArray: [Float32] = distFloat32
                    let array1 = try? MLMultiArray(shape: [1, 7, 1], dataType: .float32)
                    let inputMLarray = LSTM_Util.assignInput(array1!, testInputArray)
                    let input = lstm_distInput(lstm_input: inputMLarray!)
                    do {
                        // 4. 执行预测
                        let pred = try! self.lstm_dist_model.prediction(from: input)
                        let lstmOutput = lstm_distOutput(features: pred)
                        let res = lstmOutput.Identity[[0, 0]]
                        // 5. 查看预测结果
                        print(res)
                        // 6. 更新UI ...
                        
                        // ...
                        self.hintLabels[2].isHidden = false
                        var unitStr = "公里。"
                        if UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit") == 1
                        {
                            unitStr = "英里。"
                        }
                        self.hintLabels[2].text = "根据您的历史跑量记录，预测您下次跑步距离为" + "\(res)" + unitStr
                    }
                    
                }
            }
            else {
                // 不能访问用户的数据
                self.loadWeekPlanCoreData()
            }
            
        }
        
    }
    
    func loadWeekPlanCoreData(){
        // 1. 加载数据
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedObjectContext = appDelegate!.persistentContainer.viewContext
        
        
        // 2. 显示数据
        
        let res = queryPlanInCoreData()
        var planedDistanceArray: [Double] = []
        var planedDistance: Double = 0.0
        self.fullDateArray = AssistantMethods.getThisWeekDate().yyyyMMdd
        
        for selected_dd in AssistantMethods.getThisWeekDate().dd {
            if res.resInStr.contains(selected_dd) {
                switch UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit") {
                case 0:
                    if res.resInStrInt[selected_dd] == 0 {
                        planedDistance = res.resInStrDouble[selected_dd]!
                    }
                    else{
                        planedDistance = AssistantMethods.distanceMileToKM(res.resInStrDouble[selected_dd]!)
                    }
                    break
                case 1:
                    if res.resInStrInt[selected_dd] == 0 {
                        planedDistance = AssistantMethods.distanceKMtoMile(res.resInStrDouble[selected_dd]!)
                    }
                    else{
                        planedDistance = res.resInStrDouble[selected_dd]!
                    }
                    
                    
                    break
                default: break
                    
                }

                
            }
            else{
                planedDistance = 0.0
            }
            
            planedDistanceArray.append(planedDistance)
        }
        
        self.planedDistanceArrayToPlot = planedDistanceArray
        self.setUpChart()
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
        print("Core Data查询数量\(result.count)")
        if result.count != 0 {
            for plan in result {
                let df = DateFormatter()
                df.dateFormat = "dd"
                let ddStr = df.string(from: plan.targetDate!)
                resInStr.append(ddStr)
                resInStrDouble[ddStr] = plan.targetDistance
                resInStrInt[ddStr] = Int(plan.distanceUnit)
            }
            self.ddDateArray = resInStr
            print(resInStr)
            print(resInStrDouble)
            return (resInStr, resInStrDouble, resInStrInt)
        }
        else{
            return (resInStr, resInStrDouble, resInStrInt)
        }
        
    }
    
    
    
    /// 计划和实际跑量的图像
    func setUpChart() {
        self.chart.frame = self.actChartView.frame
        self.chart.center = self.actChartView.center
        
        let name = AssistantMethods.getThisWeekDate().dd

        
        chart.xLabelsFormatter = { (labelIndex: Int, labelValue: Double) -> String in
            return name[labelIndex]
        }
        
        
        
        // MARK: - 计划跑量
        var series1 = ChartSeries([0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
        if self.planedDistanceArrayToPlot != [] {
//            let planedDistanceIn2Decimal = self.planedDistanceArrayToPlot.map {AssistantMethods.convert($0, maxDecimals: 2)}
            series1 = ChartSeries(self.planedDistanceArrayToPlot)
        }
        series1.color = self.planColor
        series1.area = true
        
        // MARK: - 实际跑量
        var series2 = ChartSeries([0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
        if self.dateToDistance != [:] {

            var dist: [Double] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
            for (idx, dd) in name.enumerated() {
                dist[idx] = self.dateToDistance[dd]!
            }
            let distIn2Decimal = dist.map {AssistantMethods.convert($0, maxDecimals: 2)}
            series2 = ChartSeries(distIn2Decimal)

        }
        series2.color = ColorUtil.getBarBtnColor()
        series2.area = true


        self.chart.add([series1, series2])
        self.chart.labelColor = ColorUtil.dynamicColor(dark: UIColor.white, light: UIColor.black)
        self.chartUIView.addSubview(self.chart)

        
    }
    
    
    func didTouchChart(_ chart: Chart, indexes: Array<Int?>, x: Double, left: CGFloat) {
        for vv in self.hintLabelUIView {
            vv.fadeIn()
        }
        for l in self.hintLabels {
            l.fadeIn()
        }
        for (seriesIndex, dataIndex) in indexes.enumerated() {
         if dataIndex != nil {
             self.dateHintLabel.text = self.fullDateArray[dataIndex!]
           // The series at `seriesIndex` is that which has been touched
             let value = chart.valueForSeries(seriesIndex, atIndex: dataIndex)

             if seriesIndex == 0{
                 // 计划
                 self.hintLabels[1].text = "\(value!)"
             }
             
             else if seriesIndex == 1 {
                 self.hintLabels[0].text = "\(value!)"

             }
         }
       }
     }
    
    
    func setUpDays() {
        // 距离上一次跑步
        WorkoutDataStore.loadLastWorkouts() { (res, error) in
            // 可以成功访问Workout类型的数据
            if res != nil && res!.count != 0 && error == nil{
                // 79N-Qx-blI
                let fromDate = (res?.first?.startDate)!
                let calendar = Calendar.current
                
                let recentDays = calendar.numberOfDaysBetween(fromDate, and: Date())

                self.lastDate = AssistantMethods.getDateInFormatString(fromDate, "yyyy-MM-dd")
                if UserDefaults.standard.bool(forKey: "useSmiley") {
                    
                    let font = SmileyFontSize.getNormal()
                    let att = [NSAttributedString.Key.font: font]
                    let btn = self.myButtonArray[1]
                    
                    let str = NSAttributedString(string: "\(recentDays)" + NSLocalizedString("dayUnit", comment: ""), attributes: att)
                    
                    btn.setAttributedTitle(str, for: .normal)
                    btn.setAttributedTitle(str, for: .highlighted)
                    
                }
                else {
                    self.myButtonArray[1].configuration?.title = "\(recentDays)" + NSLocalizedString("dayUnit", comment: "")
                }
            }
            else {
            }
            
        }
        
        
        // 距离第一次跑步
        WorkoutDataStore.loadFirstWorkouts() { (res, error) in
            // 可以成功访问Workout类型的数据
            if res != nil && res!.count != 0 && error == nil{
                // 79N-Qx-blI
                let fromDate = (res?.first?.startDate)!
                let calendar = Calendar.current
                let recentDays = calendar.numberOfDaysBetween(fromDate, and: Date())
                

                self.firstDate = AssistantMethods.getDateInFormatString(fromDate, "yyyy-MM-dd")
                
                if UserDefaults.standard.bool(forKey: "useSmiley") {
                    
                    let font = SmileyFontSize.getNormal()
                    let att = [NSAttributedString.Key.font: font]
                    let btn = self.myButtonArray[0]
                    
                    let str = NSAttributedString(string: "\(recentDays)" + NSLocalizedString("dayUnit", comment: ""), attributes: att)
                    
                    btn.setAttributedTitle(str, for: .normal)
                    btn.setAttributedTitle(str, for: .highlighted)
                    
                }
                else {
                    self.myButtonArray[0].configuration?.title = "\(recentDays)" + NSLocalizedString("dayUnit", comment: "")
                }
                
                
            }
            else {
            }
            
        }
        
        

        
        
    }

    
    
    func setUpUI()
    {
        self.datePicker.tintColor = ColorUtil.getBarBtnColor()
        // 标题设置
        self.title = NSLocalizedString("DailyPlanTitle", comment: "")
        
        self.view.backgroundColor = ColorUtil.getBackgroundColorStyle1()
        
        self.setUpFont()

        for vv in self.hintLabelUIView {
            vv.layer.cornerRadius = 10
            vv.backgroundColor = UIColor.systemGray6
            vv.isHidden = true
        }
        
        self.hintLabels[0].textColor = ColorUtil.getBarBtnColor()
        self.hintLabels[1].textColor = self.planColor
        for l in self.hintLabels {
            l.isHidden = true
        }
        if UIScreen.main.bounds.size.height > 680 {
            self.textUIView.backgroundColor = UIColor.systemGray6
//            self.textUIView.layer.shadowColor = ColorUtil.getTextFieldHighlightColor().cgColor
//            self.textUIView.layer.shadowOffset = .zero
//            self.textUIView.layer.shadowOpacity = 1
//            self.textUIView.layer.shadowRadius = 3
            self.textUIView.layer.cornerRadius = 10
            self.textUIView.isHidden = false
            self.hintLabels[2].isHidden = false
        }
        else{
            self.textUIView.isHidden = true
        }
    
    }
    
    func setUpFont() {

        
        
        if UserDefaults.standard.bool(forKey: "useSmiley") {
            
            let font = SmileyFontSize.getFootnote()
            let att = [NSAttributedString.Key.font: font]
           
            for btn in self.myButtonArray {
                let str = (btn.configuration?.subtitle)!
                let attStr = NSAttributedString(string: str, attributes: att)
                btn.configuration?.attributedSubtitle = AttributedString(attStr)
            }
            
            for ll in self.hintLabels {
                ll.font = SmileyFontSize.getInSize(14)
            }
            self.dateHintLabel.font = SmileyFontSize.getInSize(14)
        }
    }
    
    
    
    func setUpAppleDatePicker() {
        for userDate in self.dateToSelect {
            self.datePicker.setDate(userDate, animated: true)
        }
    }

    
    @IBAction func datePickerValChanged(_ sender: Any) {
        let datePicked = self.datePicker.date
        // 判断日期 —— 今天及以后才设立目标
        let comparisonResult = datePicked.compare(Date())
        
        if comparisonResult == .orderedDescending || comparisonResult == .orderedSame{
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let dayPlanVC = sb.instantiateViewController(identifier: "MakeDayPlan") as MakeDayPlan
            dayPlanVC.inputDateInDate = datePicked
//            self.present(dayPlanVC, animated: true)
            self.navigationController?.pushViewController(dayPlanVC, animated: true)
            
        }
        else{
        }
        // 返回今天
        self.datePicker.date = Date()
    }
    
    
    
    
    func queryAllGoalsAndSelect() {
        let request: NSFetchRequest<RunningPlan> = RunningPlan.fetchRequest()
        let result = try! managedObjectContext.fetch(request)
        print(result.count)
        if result.count > 0 {
           // 打钩
//            let allDates: [Date] = result.map{$0.targetDate!}
            for res in result {

                self.dateToSelect.append(res.targetDate!)
                
            }
        }
        else{

        }
        
        
    }
    
    
    
    @IBAction func firstBtn(_ sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "DaysDetails") as! DaysDetails
        vc.dateInStr = self.firstDate
        vc.infoStr = (self.myButtonArray[0].configuration?.subtitle)!
        vc.emoji = self.emojiArray.randomElement()
        let nav = UINavigationController(rootViewController: vc)
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }

        self.present(nav, animated: true)
        
    }
    
    
    @IBAction func lastBtn(_ sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "DaysDetails") as! DaysDetails
        vc.dateInStr = self.lastDate
        
        vc.emoji = self.emojiArray.randomElement()
        vc.infoStr = (self.myButtonArray[1].configuration?.subtitle)!
        let nav = UINavigationController(rootViewController: vc)
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        
        self.present(nav, animated: true)
        
    }
    
    


    func didFinishTouchingChart(_ chart: Chart) {
        // Do something when finished
      }

    func didEndTouchingChart(_ chart: Chart) {
        // Do something when ending touching chart
      }
}

