//
//  IntensityVC.swift
//  FitnessDataAnalysis
//
//  Created by Infinity vv123 on 2023/6/3.
//

import UIKit
import HealthKit
import AAInfographics


class IntensityVC: UIViewController {
    
    @IBOutlet weak var dateRangeLabel: UILabel!
    @IBOutlet var contentView: [UIView]!
    @IBOutlet weak var chartView: UIView!
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
    /// 展示的运动强度
    var intensityToShow: [Double] = []
    
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
            self.progress.setProgress(0.2, animated: true)
        }

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        DispatchQueue.main.async {
            self.progress.fadeOut()
            self.progress.setProgress(0, animated: true)
        }
    }
    
    
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
        vc?.showText = "为了更好地了解您在各次训练中的运动强度，我们需要在查看您每次的跑步量时的配速和距离，以计算您在一段时期内的运动强度。我们将单次跑步的强度定义为距离（公里/英里）加权平均配速（每公里/英里几分钟）。"
        vc?.title = "运动强度说明"
        let nav = UINavigationController(rootViewController: vc!)
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium()]
            //, .large()
            sheet.prefersGrabberVisible = true
        }
        self.present(nav, animated: true, completion: nil)
        
    }
    

    
    // MARK: - 加载体能训练-需要的指标
    func loadWKAndProcess() {
        WorkoutDataStore.loadLastWorkouts() { (res, error) in
            // 可以成功访问Workout类型的数据
            if res != nil && res!.count != 0 && error == nil{
                
                WorkoutDataStore.loadThisMonthWorkouts(self.startDate, self.endDate, true) { [self] (workouts, error) in
                    // 加载分析运动强度所需的 ① 配速(KM/min or Miles/min) ② 距离(KM/Miles)
                    let result = MonthlyStatMethods.getIntensityData(workouts!)
                    let date = result.date
                    let pace = result.pace
                    let dist = result.distance
                    
                    let weightedPaceArray = self.weightedPaceArray(pace)
                    let intensityArray = self.getIntensityArray(weightedPaceArray, dist)
                    self.intensityToShow = intensityArray
                    self.dateToShow = date
                    
                    
                    self.setUpLineChartView()

                    if let maxIntensityIndex = self.intensityToShow.firstIndex(of: self.intensityToShow.max()!) {
                        let maxIntensityDate: String = date[maxIntensityIndex]
                        let maxIntensityPace: Double = pace[maxIntensityIndex]
                        let maxIntensityDistance: Double = dist[maxIntensityIndex]
                        var maxIntensityPaceString: String = ""
                        var maxIntensityDistString: String = ""
                        if UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit") == 0 {
                            maxIntensityDistString += "\(maxIntensityDistance)公里"
                        }
                        else {
                            maxIntensityDistString += "\(maxIntensityDistance)英里"
                        }
                        maxIntensityPaceString = MonthlyStatMethods.convertPaceSecToMinSec(maxIntensityPace*60)
    
                        self.hintTextLabel.text = "您的运动强度在\(maxIntensityDate)达到最高，以平均配速\(maxIntensityPaceString)跑了\(maxIntensityDistString)，再接再厉！"
                        
                    }
                    
                    
  
                    
                    
                    
                }
 
                
                
                
                
                
                
                
            }
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
        let aaChartModel = self.setUpIntensityModel()
        aaChartView.aa_drawChartWithChartModel(aaChartModel)
        
    }
    func setUpIntensityModel() -> AAChartModel{
        let bModel = AAChartModel()
            .chartType(.column)
            .dataLabelsEnabled(false)       //是否显示值
            .markerRadius(1)
            .xAxisGridLineWidth(0.8)
            .yAxisGridLineWidth(0.8)
            .xAxisVisible(true)
            .xAxisLabelsEnabled(false)
            .yAxisVisible(true)
            .dataLabelsEnabled(false)
            .categories(self.dateToShow)
            .series([
                AASeriesElement()
                    .showInLegend(false)
                    .name("")
                    .data(self.intensityToShow)
                    .color(AAGradientColor.fizzyPeach)
            ])
        
        return bModel
    }
    
    
    
    /*
     def scale_minmax(colname):
       """Returns column values scaled to 0-1 range"""
       scaled = (colname - colname.min()) / (colname.max() - colname.min())
       scaled.loc[scaled.idxmin()] = 0.05  # setting the minimum value to be 0.05 instead of 0
       return scaled
     */
    /// 正则化 返回
    func scale_minmax(_ inputArray: [Double]) -> [Double] {
        let minVal = inputArray.min()!
        let maxVal = inputArray.max()!
        let range = maxVal - minVal
        let scaledArray = inputArray.map{($0-minVal)/range}
        let scaledArray2 = scaledArray.map{$0==Double(0) ? Double(0.05) : $0}
        return scaledArray2
    }
    
    /// 对配速数组加权
    func weightedPaceArray(_ paceArray: [Double]) -> [Double] {
        let scaledPaceArray = scale_minmax(paceArray)
        let weightedPaceArray = scaledPaceArray.map{ $0*(-1) + 1}
        return weightedPaceArray
    }
    
    /// 生成强度数据
    func getIntensityArray(_ weightedPaceArray: [Double], _ distanceArray: [Double]) -> [Double] {
        if weightedPaceArray.count == distanceArray.count {
            var intensityArr: [Double] = []
            
            for i in 0..<weightedPaceArray.count {
                let temp = weightedPaceArray[i] * distanceArray[i]
                intensityArr.append(temp)
            
            }
            return intensityArr
        }
        else {
            return []
        }
    }
    
    
    
}
