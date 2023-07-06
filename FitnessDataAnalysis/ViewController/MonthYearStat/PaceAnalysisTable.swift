//
//  PaceAnalysisTable.swift
//  FitnessDataAnalysis
//
//  Created by Infinity vv123 on 2023/6/1.
//

import UIKit
import AAInfographics


class PaceAnalysisTable: UITableViewController {

    // MARK: - outlets
    @IBOutlet weak var doneBtn: UIButton!
    
    // MARK: - 属性
    /// 时间序列数据的日期
    var inputDate: [String] = []
    /// 时间序列的数据
    var inputData: [Double] = []
    
    /// 异常检测器
    var aDetector: AnomalyDetector!
    /// 异常检测配置
    var aDetectorConfig: AnomalyDetectionConfig = AnomalyDetectionConfig()
    /// 分析结果
    var result: (data: [[Double]], trend: [Bool], startDate: [String], endDate: [String])!

//    var aaChartView: AAChartView!
    /// Chart
//    lazy var chart: Chart = Chart()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "跑步配速分析"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark.circle.fill"), style: .plain, target: self, action: #selector(self.doneBarBtn(_:)))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.label
        
        
        self.setUpUI()
        print("Pace Table \n\n\n")
        print(inputDate)
        print(inputData)
        // 对输入数据进行异常检测分析
        self.anomalyDetection()

    }

                                                                                                                                                        
    @objc func doneBarBtn(_ sender: UIBarButtonItem) {
            self.dismiss(animated: true)
                                                                 
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if self.result.data != [[]] {
            return self.result.trend.count
        }
        else {
            return 0
        }

    }

    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {


        let cell = tableView.dequeueReusableCell(withIdentifier: "PaceAnalysisCellID", for: indexPath) as? PaceTableCell
 
//        let chart = Chart()
//        chart.center = (cell?.chartView.center)!
//        chart.frame = (cell?.chartView.frame)!
//        chart.xLabelsFormatter = { (labelIndex: Int, labelValue: Double) -> String in
//            return self.result[labelIndex]
//        }
        
        let colors = [
            // 绿
            UIColor(red: 0.522, green: 0.647, blue: 0.616, alpha: 1),
            // 红
            UIColor(red: 0.953, green: 0.522, blue: 0.514, alpha: 1)
            ]
        let colorsHex = ["#85A59D", "#F38583"]
        
        cell?.imgView.image = self.result.trend[indexPath.row] ? UIImage(systemName: "arrow.up") : UIImage(systemName: "arrow.down")
    
        cell?.imgView.tintColor = self.result.trend[indexPath.row] ? colors[0] : colors[1]

        cell?.dateRange.text = self.result.startDate[indexPath.row] + "至" + self.result.endDate[indexPath.row]

        let change = self.result.trend[indexPath.row] ? "上升趋势。" : "下降趋势。"
        cell?.hintTextLabel.text = self.result.startDate[indexPath.row] + "至" + self.result.endDate[indexPath.row] + "您的跑步配速呈" + change
        
        let aaChartView = AAChartView()
        aaChartView.frame = (cell?.chartView.frame)!
        
        aaChartView.isClearBackgroundColor = true
        aaChartView.isUserInteractionEnabled = false
        aaChartView.isScrollEnabled = false
        
        cell?.chartContentView.addSubview(aaChartView)
        

        let colorH = self.result.trend[indexPath.row] ? colorsHex[0] : colorsHex[1]
        aaChartView.aa_drawChartWithChartModel(getLineModel(self.result.data[indexPath.row], colorH))

        return cell!

    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    func setUpUI() {
//        self.doneBtn.tintColor = ColorUtil.getBarBtnColor()
        
    }
    
    ///  加载异常检测器，执行分析
    func anomalyDetection(){
        // 加载异常检测器
        self.aDetectorConfig = AnomalyDetectionConfig()
        self.aDetector = AnomalyDetector(inputDate: self.inputDate, inputData: self.inputData, anomalyDetectionConfig: self.aDetectorConfig)
        let res = self.aDetector.analyzeDataCI()
        self.result = res
//        self.tableView.reloadData()
    }
    
    @IBAction func doneBtnPressed(_ sender: UIButton){
//        self.navigationController?.popToRootViewController(animated: true)
        self.dismiss(animated: true)
        
    }
    

    func getLineModel(_ data: [Double], _ color: String) -> AAChartModel {
        let aaChartModel = AAChartModel()
            .chartType(.line)
            .animationType(.easeFromTo)
            .dataLabelsEnabled(false) //Enable or disable the data labels. Defaults to false
            .yAxisReversed(true)
            .markerRadius(2)
            .series([
                AASeriesElement()
                    .showInLegend(false)
                    .name("")
                    .lineWidth(1)
                    .data(data)
                    .color(color)
                    
            ])

        return aaChartModel
    }

    
}
