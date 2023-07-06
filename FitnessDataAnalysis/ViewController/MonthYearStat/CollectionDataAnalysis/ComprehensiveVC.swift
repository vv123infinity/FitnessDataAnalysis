//
//  ComprehensiveVC.swift
//  FitnessDataAnalysis
//
//  Created by Infinity vv123 on 2023/6/4.
//

import UIKit
import AAInfographics
import HealthKit


class ComprehensiveVC: UIViewController {

    @IBOutlet weak var dateRangeLabel: UILabel!
    @IBOutlet var contentView: [UIView]!
    @IBOutlet var chartView: [UIView]!
    @IBOutlet weak var hintTextLabel: UILabel!
    @IBOutlet weak var progress: UIProgressView!
    
    
    // MARK: - Properties
    /// 起始日期
    var startDate: Date!
    /// 结束日期
    var endDate: Date!
    /// 输入日期范围
    var dateLabelTxt: String = ""
    /// 展示的日期
    var dateToShow: [String] = []
    
    /// 获取的数据，三个指标
    var seriesData: [[Double]] = []
    /// 三个序列对应的时间
    var seriesDate: [[String]] = []
    
    /// 体能训练
    var workouts: [HKWorkout]!
    
    /// 展示的日期——最长的
    var dateCategory: [String] = []
    /// 序列的名字
    var seriesNames: [String] = ["", "", ""]
    /// 序列1数据
    var series1Data: [Double] = []
    /// 序列1数据
    var series2Data: [Double] = []
    /// 序列1数据
    var series3Data: [Double] = []
    /// 所有序列的数据
    lazy var allSeriesData: [[Double]] = [self.series1Data, self.series2Data, self.series3Data]
    
    /// 颜色
    var colorSet: [String] = ["", "", ""]
    /// 栈
    lazy var stack: [Int] = (UserDefaults.standard.array(forKey: "ComprehensiveAnalysisIndicatorArray") as? [Int])!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setBasic()

        self.loadWKAndProcess()

    }
    
    // TODO: 修改进度条
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.progress.fadeIn()
            self.progress.setProgress(0.8, animated: true)
        }

    }
    

    
    // MARK: - 加载体能训练-需要的指标
    func loadWKAndProcess() {
        WorkoutDataStore.loadLastWorkouts() { (res, error) in
            // 可以成功访问Workout类型的数据
            if res != nil && res!.count != 0 && error == nil{
                WorkoutDataStore.loadThisMonthWorkouts(self.startDate, self.endDate, true) { [self] (workouts, error) in
                    self.workouts = workouts!
                    self.analyzeIndicator()
                    print(seriesData)
                    print(seriesDate)
                    self.processData()
                    self.setUpLineChartView()
                }
                
            }
        }
        
    }
    
    /// 分析用户选择了哪些指标
    /// 0 距离，1 配速，2动态千卡，3体重，4体脂率，5平均心率，6跑步步频，7跑步功率
    func analyzeIndicator() {
        // MARK: 1. 获取用户选择的指标
        let indicatorArray = UserDefaults.standard.array(forKey: "ComprehensiveAnalysisIndicatorArray") as? [Int]
        var myStack: [Int] = []
        if indicatorArray == nil {
            myStack = [0, 1, 2]
        }
        else {
            myStack = indicatorArray!
        }
        
        for i in 0..<myStack.count {
            self.seriesNames[i] = self.mapIndicatorName(myStack[i])
            self.colorSet[i] = ColorUtil.getCompColors(myStack[i])
        }
        
        while myStack.count > 0 {
            let curIndex = myStack.popLast()!
            self.getIndicatorData(curIndex)
        }
    }
    
    // MARK: - 获取数据
    func getIndicatorData(_ idx: Int) {
        switch idx {
        case 0:
            let result = MonthlyStatMethods.getDistAndDate(self.workouts)
            self.seriesData.insert(result.dist, at: 0)
            self.seriesDate.insert(result.dateInStr, at: 0)
        case 1:
            let result = MonthlyStatMethods.getPaceArrayAndDate(self.workouts)
            self.seriesData.insert(result.pace, at: 0)
            self.seriesDate.insert(result.dateInStr, at: 0)
        case 2:
            let result = MonthlyStatMethods.getCalorieArrayAndDate(self.workouts)
            self.seriesData.insert(result.calories, at: 0)
            self.seriesDate.insert(result.dateInStr, at: 0)
        default:
            break
        }
    }
    
    func processData(){
        let dateCount = self.seriesDate.map{$0.count}
        let maxIndex = dateCount.firstIndex(of: dateCount.max()!)!
        let maxDateArray = self.seriesDate[maxIndex]
        self.dateCategory = maxDateArray
        var dateToData: [String: [Double]] = [:]
        for i in 0..<maxDateArray.count{
            dateToData[maxDateArray[i]] = [Double(0.0), Double(0.0), Double(0.0)]
        }
        for i in 0..<3 {
            for j in 0..<self.seriesData[i].count {
                if maxDateArray.contains(self.seriesDate[i][j]) {
                    dateToData[self.seriesDate[i][j]]![i] = seriesData[i][j]
                }
            }
        }
        let ascDict = dateToData.sorted(by: {$0.0 < $1.0})
        for (_, v) in ascDict {
            self.series1Data.append(v[0])
            self.series2Data.append(v[1])
            self.series3Data.append(v[2])
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func setBasic() {
        self.title = "???"
        for vv in self.contentView {
            vv.layer.cornerRadius = 15
            vv.backgroundColor = ColorUtil.dynamicColor(dark: UIColor.systemGray6, light: UIColor.white)
        }
        self.dateRangeLabel.text = self.dateLabelTxt
        self.progress.tintColor = ColorUtil.getBarBtnColor()

    }
    
    
    @IBAction func infoBtnPressed(_ sender: UIButton) {
        //InfomationHintVC
        let sb = UIStoryboard(name: "Assistant", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "InfomationHintVC") as? InfomationHintVC
        vc?.showText = "---------------"
        vc?.title = "综合分析"
        let nav = UINavigationController(rootViewController: vc!)
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium()]
            //, .large()
            sheet.prefersGrabberVisible = true
        }
        self.present(nav, animated: true, completion: nil)
        
    }
    
    /// 设置line图的UI——注，也可以不是line图，可以在getModel处设置！
    func setUpLineChartView() {
        for i in 0..<self.chartView.count {
            let rect = self.chartView[i].frame
            let aaChartView = AAChartView()
            aaChartView.isClearBackgroundColor = true
            aaChartView.isHidden = false
            aaChartView.frame = rect
            aaChartView.isScrollEnabled = false
            aaChartView.isUserInteractionEnabled = UserDefaults.standard.bool(forKey: "allowChartInteraction")

            self.contentView[0].addSubview(aaChartView)
            let aaChartModel = self.setUpCompModel(i)
            aaChartView.aa_drawChartWithChartModel(aaChartModel)
        }
        
    }
    
    
    
    func setUpCompModel(_ idx: Int) -> AAChartModel {
        var columnModel = AAChartModel()
            .chartType(.spline)
            .dataLabelsEnabled(false)       //是否显示值
            .markerRadius(0)
            .xAxisGridLineWidth(0.8)
            .yAxisGridLineWidth(0.8)
            .xAxisVisible(true)
            .xAxisLabelsEnabled(false)
            .yAxisLabelsEnabled(false)
            .yAxisVisible(true)
            .dataLabelsEnabled(false)
            .categories(self.dateCategory)
            .series([
                AASeriesElement()
                    .showInLegend(true)
//                    .dashStyle(.solid)
                    .name(self.seriesNames[idx])
                    .data(self.allSeriesData[idx])
                    .color(self.colorSet[idx]),
            ])
        if self.stack[idx] == 1 {
            columnModel.yAxisReversed(true)
        }
        
        return columnModel
    }
    

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        DispatchQueue.main.async {
            self.progress.fadeOut()
            self.progress.setProgress(0, animated: true)
        }
    }
    
    
    func mapIndicatorName(_ idx: Int) -> String {
        // 加载需要展示的内容(选项)
        let plistURL = Bundle.main.url(forResource: "SettingItems", withExtension: "plist")
        
        do {
            let data = try Data(contentsOf: plistURL!)
            let plistData = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
            let dataDictionary = plistData as! [String: Any]
            let names = dataDictionary["ComprehensiveArray"]! as! [String]

            return names[idx]
        }catch{}
        
        return "🤣"
    }
    
    /// 正则化 返回
    func scale_minmax(_ inputArray: [Double]) -> [Double] {
        let minVal = inputArray.min()!
        let maxVal = inputArray.max()!
        let range = maxVal - minVal
        let scaledArray = inputArray.map{($0-minVal)/range}
        return scaledArray
    }
    
    
}
