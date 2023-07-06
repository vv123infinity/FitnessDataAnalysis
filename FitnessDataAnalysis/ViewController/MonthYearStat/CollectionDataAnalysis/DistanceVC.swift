//
//  DistanceVC.swift
//  FitnessDataAnalysis
//
//  Created by Infinity vv123 on 2023/6/4.
//

import UIKit
import AAInfographics
import HealthKit
import SigmaSwiftStatistics

class DistanceVC: UIViewController {

    // MARK: - 一系列接口（与用户交互相关的）
    /// 界面的日期范围Label
    @IBOutlet weak var dateRangeLabel: UILabel!
    /// 内容视图
    @IBOutlet var contentView: [UIView]!
    /// 图表视图——绘制chart
    @IBOutlet weak var chartView: UIView!
    /// 可以理解为展现给用户的数据分析的结果
    @IBOutlet weak var hintTextLabel: UILabel!
    /// 进度条
    @IBOutlet weak var progress: UIProgressView!
    /// 暂时未用到
    @IBOutlet weak var distanceHintLabel: UILabel!
    
    // MARK: - Properties（也就是本地变量）
    /// 起始日期
    var startDate: Date!
    /// 结束日期
    var endDate: Date!
    /// 输入日期范围
    var dateLabelTxt: String = ""
    /// 展示的日期
    var dateToShow: [String] = []
    /// 配速的时间序列
    var dateArray: [String] = []
    /// 跑步的数据（单位 公里或英里）
    var distanceDataArray: [Double] = []
    /// 异常检测器
    var aDetector: AnomalyDetector!
    /// 异常检测配置
    var aDetectorConfig: AnomalyDetectionConfig = AnomalyDetectionConfig()
    /// 分析结果
    
    
    
    // MARK: - 应用生命周期（加载到内存）
    override func viewDidLoad() {
        super.viewDidLoad()
        // 1. 设置基础的UI
        self.setBasic()
        // 2. 加载Workout及进行数据分析
        self.loadWKAndProcess()
    }
    
    ///  加载异常检测器，执行分析
    func anomalyDetection(){
        // 加载异常检测器
        self.aDetectorConfig = AnomalyDetectionConfig()
        // 初始化异常检测器的输入时间、输入数据、和异常检测器的配置
        self.aDetector = AnomalyDetector(inputDate: self.dateArray, inputData: self.distanceDataArray, anomalyDetectionConfig: self.aDetectorConfig)
        // 调用DBSCAN
        let anomalyIndex = self.aDetector.analyzeDataDBSCAN()
        // 计算跑步距离的平均值
        let mu = Sigma.average(self.distanceDataArray)!
        var txtStr: String = "您"
        // 将DBSCAN检测到异常点与均值对比，得到异常点是高还是低（这个判断方法很朴素，有时间可以再优化）
        // TODO: 优化判断方法
        if anomalyIndex.count != 0 {
            for iidx in anomalyIndex {
                print(dateArray[iidx])
                var ch = ""
                if distanceDataArray[iidx] > mu {
                    ch = "高。"
                }else{
                    ch = "低。"
                }
                txtStr += "在\(dateArray[iidx])的跑步距离较平时" + ch

            }
            self.hintTextLabel.text = txtStr
        }
        else{
            self.hintTextLabel.text = "您的跑步距离表现较平稳。"
        }
    }
    
    // MARK: - 即将加入视图层级 (view hierarchy) 时调用
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 展示进度条的出现动画
        DispatchQueue.main.async {
            self.progress.fadeIn()
            self.progress.setProgress(0.6, animated: true)
        }

    }
    
    // MARK: - 视图即将消失、被覆盖或是隐藏时调用
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 进度条即将消失的动画
        DispatchQueue.main.async {
            self.progress.fadeOut()
            self.progress.setProgress(0, animated: true)
        }
    }
    
    // MARK: - 加载体能训练-需要的指标
    func loadWKAndProcess() {
        WorkoutDataStore.loadLastWorkouts() { (res, error) in
            // 可以成功访问Workout类型的数据
            if res != nil && res!.count != 0 && error == nil{
                WorkoutDataStore.loadThisMonthWorkouts(self.startDate, self.endDate, true) { [self] (workouts, error) in
                    let result = MonthlyStatMethods.getDistAndDate(workouts!)
                    self.dateArray = result.dateInStr
                    self.distanceDataArray = result.dist
                    self.setUpLineChartView()
                    // 加载异常检测
                    self.anomalyDetection()
                    
                }
            }
            else{
                
            }
        }
    }
    
    /// 设置基础的UI和其他东西
    func setBasic() {
        self.title = "跑步距离分析"
        // 设置内容视图的UI
        for vv in self.contentView {
            // 依旧是圆角矩形
            vv.layer.cornerRadius = 15
            // 内容视图的颜色
            vv.backgroundColor = ColorUtil.dynamicColor(dark: UIColor.systemGray6, light: UIColor.white)
        }
        // 日期范围Label的文本设置
        self.dateRangeLabel.text = self.dateLabelTxt
        // 进度条的颜色设置
        self.progress.tintColor = ColorUtil.getBarBtnColor()
        // 输出提示的Label
        self.hintTextLabel.text = "\t"
    }
    
    /// 点击“跑步距离分析”右边的i按钮出现一个关于本视图的说明
    @IBAction func infoBtnPressed(_ sender: UIButton) {
        //InfomationHintVC
        let sb = UIStoryboard(name: "Assistant", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "InfomationHintVC") as? InfomationHintVC
        vc?.showText = "为了更好地了解您在各次训练中的运动强度，我们需要在查看您每次的跑步量时的配速和距离，以计算您在一段时期内的运动强度。我们将单次跑步的强度定义为距离（公里/英里）加权平均配速（每公里/英里几分钟）。"
        vc?.title = "跑步距离分析说明"
        let nav = UINavigationController(rootViewController: vc!)
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium()]
            //, .large()
            sheet.prefersGrabberVisible = true
        }
        self.present(nav, animated: true, completion: nil)
        
    }
    
    /// 调包——设置line图的UI——注，也可以不是line图，可以在getModel处设置！
    func setUpLineChartView() {
        let rect = self.chartView.frame
        let aaChartView = AAChartView()
        aaChartView.isClearBackgroundColor = true
        aaChartView.isHidden = false
        aaChartView.frame = rect
        aaChartView.isScrollEnabled = false
        aaChartView.isUserInteractionEnabled = UserDefaults.standard.bool(forKey: "allowChartInteraction")

        self.contentView[0].addSubview(aaChartView)
        let aaChartModel = self.setUpPaceModel()
        aaChartView.aa_drawChartWithChartModel(aaChartModel)
        
    }
    /// 设置chart模型
    func setUpPaceModel() -> AAChartModel{
        let bModel = AAChartModel()
            .chartType(.spline)
            .dataLabelsEnabled(false)       //是否显示值
            .markerRadius(0)
            .xAxisGridLineWidth(0.8)
            .yAxisGridLineWidth(0.8)
            .xAxisVisible(true)
            .xAxisLabelsEnabled(false)
            .yAxisVisible(true)
            .dataLabelsEnabled(false)
            .categories(self.dateArray)
            .series([
                AASeriesElement()
                    .showInLegend(false)
                    .name("距离")
                    .data(self.distanceDataArray)
                    .color(AAGradientColor.freshPapaya)
            ])
        
        return bModel
    }

    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
