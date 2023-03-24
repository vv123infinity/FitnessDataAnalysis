//
//  ShowMore.swift
//  FitnessDataAnalysis
//
//  Created by Infinity vv123 on 2023/3/16.
//

import UIKit
import HealthKit


class ShowMore: UIViewController, ChartDelegate{

    // MARK: 接口
    @IBOutlet weak var monthChartUIView: UIView!
    @IBOutlet var displayLabel: [UILabel]!
    
    lazy var chart = Chart(frame: self.monthChartUIView.bounds)
    var workouts: [HKWorkout]!
    
    // 展示数据的日期
    var displayedDate: [[String]]!
    lazy var dateIdx: Int = -1
    
    // MARK: 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. 加载体能训练，显示图表
        self.loadWorkoutsAndGetDistance()
        
        
    }
    
    
    func setUpMonthChart(_ monthSeries: [[Double]]) {
        chart.showXLabelsAndGrid = false
        self.chart.delegate = self
        chart.isUserInteractionEnabled = UserDefaults.standard.bool(forKey: "allowChartInteraction")
        // 处理各个月跑量数据
        var allMonthSeries: [ChartSeries] = []
        // 各月颜色
        let colors = ColorUtil.getMonthSeriesColor()

        // date 的索引
        
        for (i, ser) in monthSeries.enumerated() {
            // 准备data
            let data = ser.map {
                dateIdx += 1
                return (x: dateIdx, y: $0)
            }
            
            let series = ChartSeries(data: data)
            series.color = colors[i]
            series.area = true
            
            allMonthSeries.append(series)
        }
        self.chart.add(allMonthSeries)
        
        // TODO: 用户开启了预测模式
        if 1 == 1{
            let predictedDistance = [(x: Int(self.dateIdx + 1), y: Double(8)), (x: Int(self.dateIdx + 2), y: Double(8)), (x: Int(self.dateIdx + 3), y: Double(8))]
            let predictedSer = ChartSeries(data: predictedDistance)
            predictedSer.color = ChartColors.purpleColor()
            predictedSer.area = false
            self.chart.add(predictedSer)
        }
        

        
        self.monthChartUIView.addSubview(chart)
        
    }

    
    // MARK: 加载体能训练
    func loadWorkoutsAndGetDistance() {
        WorkoutDataStore.loadWorkouts() { (workouts, error) in
            self.workouts = workouts
            // 得到距离，单位米
            let res = QueryWorkoutsAssistant.queryRecent5MonRunningDistanceDetail(workouts!, "zh_CN")
            // 用户偏好的距离单位
            let defaultUnit = UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit")
            var monDistInUnit: [[Double]] = []
            // 转换单位 & 保留两位小数
            let allDistanceArr = res.distance
            self.displayedDate = res.dateInString

            for element in allDistanceArr {
                let newRes = element.map{
                    return AssistantMethods.convertMeterToUnit(defaultUnit, $0)
                }
                monDistInUnit.append(newRes)
            }
            
            self.setUpMonthChart(monDistInUnit)
            
//            self.recent5MonRunningDistance = d
//            print(d)
//            // 计算总距离
//            let totalRes = d.reduce(0) { (r, n) in
//                r + n
//            }
//            print(totalRes)
//            self.setUpFirstPurpleBarChart_Data()
//            self.setUpWeekAndTodayLabel()
        }
    }
    
    func didTouchChart(_ chart: Chart, indexes: Array<Int?>, x: Double, left: CGFloat) {

        var selectedIndex = indexes.firstIndex(where: { (e) -> Bool in
            return e != nil
        })
        
        for (seriesIndex, dataIndex) in indexes.enumerated() {
            if selectedIndex != displayedDate.count {
                if dataIndex != nil {
                  // The series at `seriesIndex` is that which has been touched
                  let value = chart.valueForSeries(seriesIndex, atIndex: dataIndex)
                    if displayLabel.first != nil {
                        displayLabel.first!.text = "\(value!)" + "\(displayedDate[seriesIndex][dataIndex!])"
                    }
                }
            }
            else {
                if displayLabel.first != nil {
                    displayLabel.first!.text = "预测值"
                }
            }

       }
     }

    func didFinishTouchingChart(_ chart: Chart) {
      // Do something when finished
    }

    func didEndTouchingChart(_ chart: Chart) {
      // Do something when ending touching chart
    }

}


