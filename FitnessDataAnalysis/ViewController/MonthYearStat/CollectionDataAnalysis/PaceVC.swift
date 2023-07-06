//
//  PaceVC.swift
//  FitnessDataAnalysis
//
//  Created by Infinity vv123 on 2023/6/3.
//

import UIKit
import AAInfographics
import HealthKit
import SigmaSwiftStatistics

class PaceVC: UIViewController {
    
    
    @IBOutlet weak var dateRangeLabel: UILabel!
    @IBOutlet var contentView: [UIView]!
    @IBOutlet weak var chartView: UIView!
    @IBOutlet weak var hintTextLabel: UILabel!
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var paceHintLabel: UILabel!
    
    // MARK: - Properties
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
    /// 配速的数据（单位：分钟/公里或英里）
    var paceDataArray: [Double] = []
    
    var splitIndex: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setBasic()
        self.loadWKAndProcess()

    }
    


    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.progress.fadeIn()
            self.progress.setProgress(0.4, animated: true)
        }

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        DispatchQueue.main.async {
            self.progress.fadeOut()
            self.progress.setProgress(0, animated: true)
        }
    }
    
    /// 设置line图的UI——注，也可以不是line图，可以在getModel处设置！
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
    func setUpPaceModel() -> AAChartModel{
        let bModel = AAChartModel()
            .chartType(.scatter)
            .dataLabelsEnabled(false)       //是否显示值
            .markerRadius(3)
            .xAxisGridLineWidth(0.8)
            .yAxisGridLineWidth(0.8)
            .yAxisReversed(true)
            .xAxisVisible(true)
            .xAxisLabelsEnabled(false)
            .yAxisVisible(true)
            .dataLabelsEnabled(false)
            .categories(self.dateArray)
            .series([
                AASeriesElement()
                    .showInLegend(true)
                    .name("配速")
                    .data(self.paceDataArray)
                    .color(AAGradientColor.eveningDelight)
            ])
        
        return bModel
    }



    // MARK: - 加载体能训练-需要的指标
    func loadWKAndProcess() {
        WorkoutDataStore.loadLastWorkouts() { (res, error) in
            // 可以成功访问Workout类型的数据
            if res != nil && res!.count != 0 && error == nil{
                WorkoutDataStore.loadThisMonthWorkouts(self.startDate, self.endDate, true) { [self] (workouts, error) in
//                    self.workouts = workouts!
                    let result = MonthlyStatMethods.getPaceArrayAndDate(workouts!)
                    self.paceDataArray = result.pace
                    self.dateArray = result.dateInStr
                    
                    // 获取配速数据
                    let points = self.genPaceDataPoints()
                    // 定义三个Labels
                    let kmm = KMeans<Character>(labels: ["A", "B", "C"])
                    // 通过KMeans聚类
                    kmm.trainCenters(points, convergeDistance: 0.01)
                    // 打印输出3个centroids
//                    for (label, centroid) in zip(kmm.labels, kmm.centroids) {
//                      print("\(label): \(centroid)")
//                    }
//                    print("\nClassifications")
                    /// 异常的日期数组
                    var anomalyDate: [String] = []
                    /// 上一个数据点的Label
                    var lastLabel: String = ""
                    for (label, point) in zip(kmm.fit(points), points) {
                        if lastLabel != "" {
                            // 检测到异常点（异常日期）
                            if "\(label)" != lastLabel {
                                anomalyDate.append("\(self.dateArray[Int(point.data[0]-1)])")
                                self.splitIndex.append(Int(point.data[0]-1))
                            }
                            lastLabel = "\(label)"
                        }
                        else {
                            lastLabel = "\(label)"
                        }
//                      print("\(label): \(point)")
                    }
                    
                    self.setUpLineChartView()

                    let c1 = Array(self.paceDataArray[0..<self.splitIndex[0]])
                    let c2 = Array(self.paceDataArray[self.splitIndex[0]..<self.splitIndex[1]])
                    let c3 = Array(self.paceDataArray[self.splitIndex[1]..<self.paceDataArray.count])
                    let t1 = self.dateArray[0] + "至" + self.dateArray[self.splitIndex[0]-1]
                    let t2 = self.dateArray[self.splitIndex[0]] + "至" + self.dateArray[self.splitIndex[1]-1]
                    let t3 = self.dateArray[self.splitIndex[1]] + "至" + self.dateArray.last!
                    
                    let mu1InStr = MonthlyStatMethods.convertPaceSecToMinSec(Sigma.average(c1)!*60)
                    let mu2InStr = MonthlyStatMethods.convertPaceSecToMinSec(Sigma.average(c2)!*60)
                    let mu3InStr = MonthlyStatMethods.convertPaceSecToMinSec(Sigma.average(c3)!*60)
                    
                    if anomalyDate.count == 2 {
                        var hintDataStr = t1 + "，平均配速为" + mu1InStr + "。" + t2 + "，平均配速为" + mu2InStr + "。" + t3 + "，平均配速为" + mu3InStr + "。"
                        self.hintTextLabel.text = "您的配速在" + anomalyDate[0] + "和" + anomalyDate[1] + "前后有较大差异。"
                        self.paceHintLabel.text = hintDataStr
                    }
                    

                    
                }
                
            }
        }
        
    }
    
    
    func genPaceDataPoints() -> [Vector] {
        var points = [Vector]()
        for i in 0..<self.paceDataArray.count {
            var data = [Double]()
            data.append(Double(i+1))
            data.append(self.paceDataArray[i])
            points.append(Vector(data))
        }
        return points
    }


    func setBasic() {
        self.title = "???"
        for vv in self.contentView {
            vv.layer.cornerRadius = 15
            vv.backgroundColor = ColorUtil.dynamicColor(dark: UIColor.systemGray6, light: UIColor.white)
        }
        self.dateRangeLabel.text = self.dateLabelTxt
        self.progress.tintColor = ColorUtil.getBarBtnColor()

        self.hintTextLabel.text = "\t"
    }
    
    
    @IBAction func infoBtnPressed(_ sender: UIButton) {
        //InfomationHintVC
        let sb = UIStoryboard(name: "Assistant", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "InfomationHintVC") as? InfomationHintVC
        vc?.showText = "为了更好地了解您在各次训练中的运动强度，我们需要在查看您每次的跑步量时的配速和距离，以计算您在一段时期内的运动强度。我们将单次跑步的强度定义为距离（公里/英里）加权平均配速（每公里/英里几分钟）。"
        vc?.title = "跑步配速分析说明"
        let nav = UINavigationController(rootViewController: vc!)
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium()]
            //, .large()
            sheet.prefersGrabberVisible = true
        }
        self.present(nav, animated: true, completion: nil)
        
    }
    
    
    
    
}
