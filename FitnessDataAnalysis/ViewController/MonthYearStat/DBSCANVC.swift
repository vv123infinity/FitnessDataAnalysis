//
//  DBSCANVC.swift
//  FitnessDataAnalysis
//
//  Created by Infinity vv123 on 2023/6/1.
//

import UIKit

class DBSCANVC: UIViewController {
    /// 时间序列数据的日期
    var inputDate: [String] = []
    /// 时间序列的数据
    var inputData: [Double] = []
    
    /// 异常检测器
    var aDetector: AnomalyDetector!
    /// 异常检测配置
    var aDetectorConfig: AnomalyDetectionConfig = AnomalyDetectionConfig()
    /// 分析结果
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "跑步配速分析"
        self.inputDate = ["", "", "",
                          "", "", "",
                          "", "", "",
                          "", "", "", ""]
        self.inputData = [10, 5.02, 5.6,
                          5.7, 6, 6,
                          6, 7, 7,
                          8, 4, 5
        ]
        self.anomalyDetection()
    }
    
    ///  加载异常检测器，执行分析
    func anomalyDetection(){
        // 加载异常检测器
        self.aDetectorConfig = AnomalyDetectionConfig()
        self.aDetector = AnomalyDetector(inputDate: self.inputDate, inputData: self.inputData, anomalyDetectionConfig: self.aDetectorConfig)
        let _ = self.aDetector.analyzeDataDBSCAN()

//        self.tableView.reloadData()
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
