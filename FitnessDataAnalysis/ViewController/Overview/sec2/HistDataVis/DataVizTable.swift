//
//  DataVizTable.swift
//  FitnessDataAnalysis
//
//  Created by Infinity vv123 on 2023/7/8.
//

import UIKit
import HealthKit


class DataVizTable: UITableViewController {

    @IBOutlet var datePickerBtn: UIBarButtonItem!
    
    
    /// 各个section的ID
    let mySecID: [String] = ["PerfomanceID", "RunningID"]
    /// 各个section的标题
    var sectionTitle: [String] = []
    /// 各个section的具体项
    var sectionItem: [[String]] = [[], []]
    /// 第二个section的logo
    var runningLogo: [UIImage] = []
    /// 自定义日期
    var userDefineDateFlag: Bool = false
    /// 起始日期（默认本月初）
    var startDate: Date!
    /// 结束日期（默认现在）
    var endDate: Date!
    /// 获取到的并需要展现的各项结果
    var result: (workoutDate: [String], accDistance: String, accTime: String, avgPace: String, numOfRuns: String, distanceArray: [Double], maxDistance: String, maxPace: String, avgPower: String, avgCadence: String, avgHR: String, avgCalorie: String, dataSource: Set<String>, maxDistanceDate: String, maxPaceDate: String, avgTime: String)!
    /// 当前加载到的workouts
    var workouts: [HKWorkout] = []
    /// 各个指标的具体数值
    var indicatorValueList: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.getPlistContent()
        self.setBasic()
        self.loadWorkoutsAndGetDistance()
    }
    
    func loadWorkoutsAndGetDistance() {
        WorkoutDataStore.loadThisMonthWorkouts(self.startDate, self.endDate, self.userDefineDateFlag) { (workouts, error) in
            
            // 判断所选日期区间是否进行了体能训练，也就是workouts的长度
            if workouts!.count > 0 {
                // 得到距离，单位米
                self.workouts = workouts!
                let result = MonthlyStatMethods.calcIndicatorInUserUnit(self.workouts)
                
                self.result = result
                self.indicatorValueList = []
                // 按照plist里面的顺序添加的元素
                self.indicatorValueList.append(result.accDistance)
                self.indicatorValueList.append(result.numOfRuns)
                self.indicatorValueList.append(result.avgPace)
                self.indicatorValueList.append(result.accTime)
                self.indicatorValueList.append(result.maxDistance)
                self.indicatorValueList.append(result.maxPace)
                self.indicatorValueList.append(result.avgHR)
                self.indicatorValueList.append(result.avgCalorie)
                self.indicatorValueList.append(result.avgPower)
                self.indicatorValueList.append(result.avgCadence)


            }
            
            else{
                // 用户选择的日期范围内没有符合的记录
                self.workouts = []

            }

            // TODO: 显示数据来源
//            var dataSourceStr = "数据来源\n"
//            for deviceName in self.result.dataSource {
//                dataSourceStr += "\(deviceName)\n"
//            }
            
            
        }
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.mySecID.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.sectionItem[section].count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sectionTitle[section]
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.mySecID[indexPath.section], for: indexPath) as? DataVisTableCell
        cell?.titleLabel.text = self.sectionItem[indexPath.section][indexPath.row]
        let colors = ColorUtil.getTableLogoImageColor()
        
        if indexPath.section == 1 {
            // TODO: - quxiaozhushi
//            cell?.dataLabel.text = self.indicatorValueList[indexPath.row]
            cell?.imgView.image = runningLogo[indexPath.row]
            cell?.imgView.tintColor = colors[indexPath.row]
            cell?.titleLabel.textColor = colors[indexPath.row]
        }
        
        return cell!
    }



    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            // PART 2 触发转场
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let plotStyle1VC = sb.instantiateViewController(withIdentifier: "PlotStyle1") as? PlotStyle1
            let dataPlotVC = sb.instantiateViewController(withIdentifier: "DataPlotVC") as? DataPlotVC
            
            switch indexPath.row {
            case 0:
                // MARK: - 距离
//                if self.result.distanceArray != [0.0] && self.result.distanceArray.count != 0 {
                    
//                    plotStyle1VC?.typeID = 1
//                    plotStyle1VC?.startDate = self.startDate
//                    plotStyle1VC?.endDate = self.endDate
//                    plotStyle1VC?.dataArray = self.result.distanceArray
//                    plotStyle1VC?.runningDates = self.result.workoutDate
//                    plotStyle1VC?.theTitle = NSLocalizedString("totalDistance_v0001", comment: "")
//
//                    plotStyle1VC?.inputOverviewData = self.indicatorValueList[0]
//                    plotStyle1VC?.dateLabelTxt = self.title!
//                    plotStyle1VC?.subTitles = [NSLocalizedString("detailInfo", comment: ""),
//                                               NSLocalizedString("classificationDistance", comment: "")
//                    ]
                    
                    dataPlotVC?.title = self.sectionItem[1][indexPath.row]
                    
//                }
                self.navigationController?.pushViewController(dataPlotVC!, animated: true)
                
                break
                
            case 2:
                // MARK: - 配速
                plotStyle1VC?.typeID = 4
                plotStyle1VC?.startDate = self.startDate
                plotStyle1VC?.endDate = self.endDate
                
                plotStyle1VC?.dateLabelTxt = self.title!
                
                plotStyle1VC?.theTitle = NSLocalizedString("avgPaceTitle", comment: "")
                plotStyle1VC?.inputOverviewData = self.indicatorValueList[2]
                //            plotStyle1VC?.subTitles = [NSLocalizedString("paceDetailInfo", comment: "")]
                
                plotStyle1VC?.subTitles = [NSLocalizedString("paceDetailInfo", comment: ""), NSLocalizedString("learnPaceCalcSubTitle2", comment: "")]
                // 展示plotStyle1VC
                //                self.navigationController?.pushViewController(plotStyle1VC!, animated: true)
                self.present(plotStyle1VC!, animated: true)
            case 6:
                // MARK: - 心率
                plotStyle1VC?.typeID = 5
                plotStyle1VC?.startDate = self.startDate
                plotStyle1VC?.endDate = self.endDate
                
                plotStyle1VC?.dateLabelTxt = self.title!
                
                plotStyle1VC?.theTitle = NSLocalizedString("avgHRTitle", comment: "")
                plotStyle1VC?.inputOverviewData = self.indicatorValueList[6]
                
                
                plotStyle1VC?.subTitles = [NSLocalizedString("HR_DetailInfo", comment: ""), NSLocalizedString("yourHRZone", comment: "")]
                // 展示plotStyle1VC
                //                self.navigationController?.pushViewController(plotStyle1VC!, animated: true)
                self.present(plotStyle1VC!, animated: true)
            case 7:
                // MARK: - 动态千卡
                plotStyle1VC?.typeID = 6
                plotStyle1VC?.startDate = self.startDate
                plotStyle1VC?.endDate = self.endDate
                plotStyle1VC?.dateLabelTxt = self.title!
                plotStyle1VC?.theTitle = NSLocalizedString("avgEnergyTitle", comment: "")
                plotStyle1VC?.inputOverviewData = self.indicatorValueList[7]
                plotStyle1VC?.subTitles = [NSLocalizedString("avgEnergyDetail", comment: ""),
                                           NSLocalizedString("cumuKCAL" ,         comment: "")]
                self.present(plotStyle1VC!, animated: true)
                
                break
            case 8:
                plotStyle1VC?.typeID = 2
                plotStyle1VC?.startDate = self.startDate
                plotStyle1VC?.endDate = self.endDate
                plotStyle1VC?.dateLabelTxt = self.title!
                plotStyle1VC?.theTitle = NSLocalizedString("avgPowerTitle", comment: "")
                plotStyle1VC?.inputOverviewData = self.indicatorValueList[8]
                plotStyle1VC?.subTitles = [NSLocalizedString("powerDetailInfo", comment: "")]
                
                if self.indicatorValueList[8] != "---" {
                    self.present(plotStyle1VC!, animated: true)
                }
                
            case 9:
                // MARK: - 步频的typeID是3
                plotStyle1VC?.typeID = 3
                plotStyle1VC?.startDate = self.startDate
                plotStyle1VC?.endDate = self.endDate
                plotStyle1VC?.dateLabelTxt = self.title!
                plotStyle1VC?.theTitle = NSLocalizedString("avgCadenceTitle", comment: "")
                plotStyle1VC?.inputOverviewData = self.indicatorValueList[9]
                plotStyle1VC?.subTitles = [NSLocalizedString("cadenceDetailInfo", comment: "")]
                if self.indicatorValueList[9] != "---" {
                    self.present(plotStyle1VC!, animated: true)
                }
                
            default:
                break
                
            }
            
        }
    }
    
    @IBAction func datePickerBtnPressed(_ sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "DatePickerVC") as? DatePickerVC
        let nav = UINavigationController(rootViewController: vc!)
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        
        self.present(nav, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 59
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func setBasic() {
        self.datePickerBtn.tintColor = ColorUtil.getBarBtnColor()
        self.navigationItem.backBarButtonItem?.tintColor = ColorUtil.getBarBtnColor()
        self.navigationItem.leftBarButtonItem?.tintColor = ColorUtil.getBarBtnColor()
        self.navigationController?.navigationBar.tintColor = ColorUtil.getBarBtnColor()
        self.title = "数据统计与分析"
        self.getAndSetDateTitle()
        self.runningLogo = self.getTableLogoImageColor()
    }

    /// 获取并配置日期
    func getAndSetDateTitle() {
        let dateFormatter4 = DateFormatter()
        dateFormatter4.dateFormat = "yyyy-MM"
        let res = AssistantMethods.getThisMonthStartEndDate(Date.init(), Date.init(), self.userDefineDateFlag)
//        self.startDate = res.startDate
        self.startDate = AssistantMethods.getDateFromString("2023-05-01", "yyyy-MM-dd")
        self.endDate = res.endDate
        
        let calendar = Calendar.current
        // 设置要展现的日期形式
        dateFormatter4.dateFormat = "yyyy-MM-dd"
        // 获取字符串
        let startDateInString = dateFormatter4.string(from: res.startDate)
        let actualEndDate = res.endDate
        let endDateInString = dateFormatter4.string(from: actualEndDate)
        var dateToShow = ""
        if startDateInString == endDateInString {
            dateToShow = startDateInString
        }
        else {
            dateToShow = startDateInString + NSLocalizedString("dateTo", comment: "") + endDateInString
        }
        

    }
    
    /// 获取overviewItem.plist的内容
    func getPlistContent() {
        let plistURL = Bundle.main.url(forResource: "sec2Table", withExtension: "plist")
        // 设置各个var的值
        do {
            let data = try Data(contentsOf: plistURL!)
            let plistData = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
            let dataDictionary = plistData as! [String: Any]
            // sec2的各个列表名称
            self.sectionTitle = dataDictionary["allSecTitle"]! as! [String]
//            self.sectionItem[0] = []
            self.sectionItem[0] = dataDictionary["basicBodyArray"]! as! [String]
            self.sectionItem[1] = dataDictionary["runningArray"] as! [String]
        }
        catch{
            
        }
        
    }
    
    /// 獲取表格的logo图像
    func getTableLogoImageColor() -> [UIImage] {
        let logoImg: [String] = [
            // 跑步距离
            "figure.run",
            // 跑步次数
            "number.circle",
            // 平均配速
            "timer",
            // 时长
            "timelapse",
            // 最远距离 
            "shoeprints.fill",
            // 最快配速
            "hourglass",
            // 平均心率
            "heart.circle",

            // 卡路里
            "flame",

            // 功率
            "arrow.left.arrow.right",

            // 步频
            "arrow.left.arrow.right",
            "arrow.left.arrow.right"
            ]
        
        return logoImg.map{UIImage(systemName: $0)!}
    }
    
    //    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
    //
    //        if indexPath.section == 1 {
    //            return true
    //        }
    //        else {
    //            return false
    //        }
    //    }
    //
    //    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    //
    //
    //        }

        
        
    //    @IBAction func toggleEditMove(_ sender: UIBarButtonItem) {
    ////        self.tableView.isEditing = !self.tableView.isEditing
    //        self.tableView.isEditing.toggle()
    //        if self.tableView.isEditing {
    //            self.editBtn.title = "完成"
    //        }
    //        else{
    //            self.editBtn.title = "编辑"
    //        }
    //    }
        
    
}
