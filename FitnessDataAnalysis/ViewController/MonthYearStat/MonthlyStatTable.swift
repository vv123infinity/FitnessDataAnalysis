//
//  MonthlyStatTable.swift
//  FitnessDataAnalysis
//
//  Created by Infinity vv123 on 2023/4/16.
//

import UIKit
import HealthKit
import AAInfographics
import Fastis


class MonthlyStatTable: UITableViewController {

    // MARK: - Outlet
    /// ① 默认本月月初-今天 ② 用户自定义
    @IBOutlet weak var thisMonthDateLabel: UILabel!
    /// collectionView
//    @IBOutlet weak var myCollectionView: UICollectionView!
    
    
    // MARK: - Properties
    /// section的标题
    var mySectionTitle: [String] = []
    /// 各个section的行名称
    var myRowTextInSection: [[String]] = []
    /// section的cell ID Array
    private var secCellID: [String] = ["FavoriteCellID", "OverviewCellID"]
    
//    private var reuseIdentifier = "myFavoriteCellID"
//    private let itemsPerRow: CGFloat = 2
//    private let sectionInsets = UIEdgeInsets(
//      top: 50.0,
//      left: 20.0,
//      bottom: 50.0,
//      right: 20.0)
//    var myFavoriteTitles: [String] = ["1", "2", "3", "2", "3"]
//    var myFavoriteData: [String] = ["11", "22", "33", "2", "3"]
    
    
    
    /// 通用的各项设置
    lazy var uniUISetting = UniversalUISettings()
    /// 当前加载到的workouts
    var workouts: [HKWorkout] = []
    
    var userDefineDateFlag: Bool = false
    /// 起始日期（默认本月初）
    var startDate: Date!
    /// 结束日期（默认现在）
    var endDate: Date!
    
    /// 获取到的并需要展现的各项结果
    var result: (workoutDate: [String], accDistance: String, accTime: String, avgPace: String, numOfRuns: String, distanceArray: [Double], maxDistance: String, maxPace: String, avgPower: String, avgCadence: String, avgHR: String, avgCalorie: String, dataSource: Set<String>, maxDistanceDate: String, maxPaceDate: String, avgTime: String)!
    /// 各个指标的具体数值
    var indicatorValueList: [String] = []
    /// 辅助Type要取消右箭头的 项目ID
    var cancelRightArrowID: [Int] = [1, 3, 4, 5]
    
    // MARK: - 应用生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        // 0. 配置基础UI
        self.setUpUIAndBasicProg()
//        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        // 1. 加载plist
        self.loadPlist()
        
        // 2. 尝试读取用户的健康数据
        WorkoutDataStore.loadLastWorkouts() { (res, error) in
            // 可以成功访问Workout类型的数据
            if res != nil && res!.count != 0 && error == nil{
                self.loadWorkoutsAndGetDistance()
            }
            
        }
        
    }
    

    
    // MARK: -各个IBAction的关联方法-
    @IBAction func choosePickerBtnPressed(_ sender: UIBarButtonItem) {
        chooseDate()
    }
    
    func chooseDate() {
        let fastisController = FastisController(mode: .range)
        fastisController.title = NSLocalizedString("datePickerChooseDateRange", comment: "")
        if UserDefaults.standard.bool(forKey: "useSmiley"){
            DispatchQueue.main.async {
                fastisController.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedString.Key.font: SmileyFontSize.getNormal()]
                
            }
        }
        
        fastisController.maximumDate = Date()
        fastisController.allowToChooseNilDate = true
        fastisController.shortcuts = [.lastWeek, .lastMonth, .thisYear]
        fastisController.dismissHandler = {
            fastisController.navigationController?.popViewController(animated: true)
        }
        fastisController.doneHandler = { resultRange in
            guard let fDate = resultRange?.fromDate,
                  let tDate = resultRange?.toDate else{
                return
            }
            
            self.startDate = resultRange?.fromDate
            self.endDate = resultRange?.toDate
            UserDefaults.standard.set(self.startDate!, forKey: "lastQueryDateStart")
            UserDefaults.standard.set(self.endDate!, forKey: "lastQueryDateEnd")
            self.userDefineDateFlag = true
            self.loadWorkoutsAndGetDistance()
//            fastisController.navigationController?.popViewController(animated: true)
            fastisController.dismiss(animated: true)
            self.tableView.reloadData()
        }
        
        fastisController.present(above: self)
//        self.navigationController?.pushViewController(fastisController, animated: true)
        
    }
    
    /// 设置用户选择的日期范围
    func setDateRangeLabel(){
        let calendar = Calendar.current
        // 设置要展现的日期形式
        let dateFormatter4 = DateFormatter()
        dateFormatter4.locale = Locale(identifier: "en")
        dateFormatter4.dateFormat = "yyyy-MM-dd"
        // 获取字符串
        let startDateInString = dateFormatter4.string(from: self.startDate)
//        let actualEndDate = calendar.date(byAdding: .day, value: -1, to: self.endDate)!
        let actualEndDate = self.endDate
        let endDateInString = dateFormatter4.string(from: actualEndDate!)
        var dateToShow = ""
        if startDateInString == endDateInString {
            dateToShow = startDateInString
        }
        else {
            dateToShow = startDateInString + NSLocalizedString("dateTo", comment: "") + endDateInString
        }
        
        // 赋值给Label
        
        if self.workouts.count > 0 {
            self.thisMonthDateLabel.text = dateToShow
        }
        else {
            self.thisMonthDateLabel.text = NSLocalizedString("noRunRecordsP0", comment: "") + dateToShow + NSLocalizedString("noRunRecordsP1", comment: "") + "🥹"
        }
        
    }
    
    
    /// 加载体能训练记录
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

            self.setDateRangeLabel()
            
            self.tableView.reloadData()
        }
    }
    
    // MARK: 表格表格
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.mySectionTitle.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.myRowTextInSection[section].count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.mySectionTitle[section]
        
    }

    // MARK:
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: secCellID[indexPath.section], for: indexPath) as? DataStatTableCell
        
//        let cell = tableView.cellForRow(at: indexPath) as? ReportTableViewCell
        
        
//        var content = cell.defaultContentConfiguration()
        // 指标说明
//        content.text = self.myRowTextInSection[indexPath.section][indexPath.row]
        cell?.cellTitle.text = self.myRowTextInSection[indexPath.section][indexPath.row]



        
        let colors = ColorUtil.getTableLogoImageColor()

        let images = self.getTableLogoImageColor()
        
        
        // 指标数值
        if indexPath.section == 1 && self.indicatorValueList.count > 0 {
//            content.secondaryText = self.indicatorValueList[indexPath.row]
            cell?.cellData.text = self.indicatorValueList[indexPath.row]
            cell?.cellLogo.tintColor = colors[indexPath.row]
            cell?.cellTitle.textColor = colors[indexPath.row]
            cell?.cellLogo.image = images[indexPath.row]
            // 右边箭头的设置
            if self.cancelRightArrowID.contains(indexPath.row) {
                cell?.accessoryType = .none
            }
            else {
                cell?.accessoryType = .disclosureIndicator
            }
            
            // 辅助信息的显示 最快配速 最远距离日期
            if indexPath.row == 4 || indexPath.row == 5 {
                cell?.detailDate.isHidden = false
                if indexPath.row == 4 {
                    cell?.detailDate.text = self.result.maxDistanceDate
                }
                else if indexPath.row == 5 {
                    cell?.detailDate.text = self.result.maxPaceDate
                }
                else {
                    
                }
            }
        }
        else {
            cell?.cellData.text = "收藏"
        }
        // 各项数字的颜色
//        content.secondaryTextProperties.color = UIColor.red
        if UserDefaults.standard.bool(forKey: "useSmiley"){
//            content.secondaryTextProperties.font = SmileyFontSize.getInSize(15.5)
//            content.textProperties.font = SmileyFontSize.getInSize(15.5)
        }
        else {
//            content.secondaryTextProperties.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
//            content.textProperties.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        }

        
//        cell.contentConfiguration = content
        return cell!
        
    }
    
    // MARK: - segue
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let plotStyle1VC = sb.instantiateViewController(withIdentifier: "PlotStyle1") as? PlotStyle1
            
            switch indexPath.row {
            case 0:
                // MARK: - 距离
                if self.result.distanceArray != [0.0] && self.result.distanceArray.count != 0 {
                    
                    plotStyle1VC?.typeID = 1
                    plotStyle1VC?.startDate = self.startDate
                    plotStyle1VC?.endDate = self.endDate
                    plotStyle1VC?.dataArray = self.result.distanceArray
                    plotStyle1VC?.runningDates = self.result.workoutDate
                    plotStyle1VC?.theTitle = NSLocalizedString("totalDistance_v0001", comment: "")
                    
                    plotStyle1VC?.inputOverviewData = self.indicatorValueList[0]
                    plotStyle1VC?.dateLabelTxt = self.thisMonthDateLabel.text!
                    plotStyle1VC?.subTitles = [NSLocalizedString("detailInfo", comment: ""),
                                               NSLocalizedString("classificationDistance", comment: "")
                    ]
                    
                    
                    
                }
                // 展示plotStyle1VC
                //                self.navigationController?.pushViewController(plotStyle1VC!, animated: true)
                self.present(plotStyle1VC!, animated: true)
                
                break
                
            case 2:
                // MARK: - 配速
                plotStyle1VC?.typeID = 4
                plotStyle1VC?.startDate = self.startDate
                plotStyle1VC?.endDate = self.endDate
                
                plotStyle1VC?.dateLabelTxt = self.thisMonthDateLabel.text!
                
                plotStyle1VC?.theTitle = NSLocalizedString("avgPaceTitle", comment: "")
                plotStyle1VC?.inputOverviewData = self.indicatorValueList[2]
                plotStyle1VC?.subTitles = [NSLocalizedString("paceDetailInfo", comment: ""), NSLocalizedString("learnPaceCalcSubTitle2", comment: "")]
                // 展示plotStyle1VC
                //                self.navigationController?.pushViewController(plotStyle1VC!, animated: true)
                self.present(plotStyle1VC!, animated: true)
                
                //            case 4:
                //                // MARK: - 最远距离~sheet
                //                let sb = UIStoryboard(name: "Main", bundle: nil)
                //                let vc = sb.instantiateViewController(withIdentifier: "DaysDetails") as! DaysDetails
                //                vc.dateInStr = self.result.maxDistanceDate
                //                vc.emoji = " "
                //                vc.infoStr = " "
                //                let nav = UINavigationController(rootViewController: vc)
                //                if let sheet = nav.sheetPresentationController {
                //                    sheet.detents = [.medium()]
                //                    sheet.prefersGrabberVisible = true
                //                }
                //
                //                self.present(nav, animated: true)
                //
                //            case 5:
                //                // max Pace
                //                let sb = UIStoryboard(name: "Main", bundle: nil)
                //                let vc = sb.instantiateViewController(withIdentifier: "DaysDetails") as! DaysDetails
                //                vc.dateInStr = self.result.maxPaceDate
                //                vc.emoji = " "
                //                vc.infoStr = " "
                //                let nav = UINavigationController(rootViewController: vc)
                //                if let sheet = nav.sheetPresentationController {
                //                    sheet.detents = [.medium()]
                //                    sheet.prefersGrabberVisible = true
                //                }
                //
                //                self.present(nav, animated: true)
                
            case 6:
                // MARK: - 心率
                plotStyle1VC?.typeID = 5
                plotStyle1VC?.startDate = self.startDate
                plotStyle1VC?.endDate = self.endDate
                
                plotStyle1VC?.dateLabelTxt = self.thisMonthDateLabel.text!
                
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
                plotStyle1VC?.dateLabelTxt = self.thisMonthDateLabel.text!
                plotStyle1VC?.theTitle = NSLocalizedString("avgEnergyTitle", comment: "")
                plotStyle1VC?.inputOverviewData = self.indicatorValueList[7]
                plotStyle1VC?.subTitles = [NSLocalizedString("avgEnergyDetail", comment: ""),
                                           NSLocalizedString("cumuKCAL" , comment: "")]
                self.present(plotStyle1VC!, animated: true)
                
                break
            case 8:
                plotStyle1VC?.typeID = 2
                plotStyle1VC?.startDate = self.startDate
                plotStyle1VC?.endDate = self.endDate
                plotStyle1VC?.dateLabelTxt = self.thisMonthDateLabel.text!
                plotStyle1VC?.theTitle = NSLocalizedString("avgPowerTitle", comment: "")
                plotStyle1VC?.inputOverviewData = self.indicatorValueList[8] + NSLocalizedString("powerUnit" , comment: "")
                plotStyle1VC?.subTitles = [NSLocalizedString("powerDetailInfo", comment: "")]
                
                self.present(plotStyle1VC!, animated: true)
                
            case 9:
                // MARK: - 步频的typeID是3
                plotStyle1VC?.typeID = 3
                plotStyle1VC?.startDate = self.startDate
                plotStyle1VC?.endDate = self.endDate
                plotStyle1VC?.dateLabelTxt = self.thisMonthDateLabel.text!
                plotStyle1VC?.theTitle = NSLocalizedString("avgCadenceTitle", comment: "")
                plotStyle1VC?.inputOverviewData = self.indicatorValueList[9] +  NSLocalizedString("cadenceUnit" , comment: "")
                plotStyle1VC?.subTitles = [NSLocalizedString("cadenceDetailInfo", comment: "")]
                
                self.present(plotStyle1VC!, animated: true)
            default:
                break
                
            }
        }
    }
    

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }

    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
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

    /// 根据plist获取设置列表的sec标题和内容
    func loadPlist() {
        let plistURL = Bundle.main.url(forResource: "RunDataAnalysisIndicator", withExtension: "plist")
        // 设置各个var的值
        do {
            let data = try Data(contentsOf: plistURL!)
            let plistData = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
            let dataDictionary = plistData as! [String: Any]
            // 各个标题
            self.mySectionTitle = (dataDictionary["sectionTitle"] as? [String])!
            // 各个标题的行
            self.myRowTextInSection = [["个人收藏项"], (dataDictionary["IndicatorArrayVersion0"] as? [String])!]
            
        }
        catch{
            
        }
        
    }
    
    

    
    
    // MARK: - UI设置和基础程序
    func setUpUIAndBasicProg() {
        self.getAndSetDateTitle()
        self.setUpBackItem()
        self.setDateRangeLabel()
//        self.datePickerBtn.configuration?.titleAlignment = .trailing

        
    }
    
    
    // 255, 43, 96, 170
    /// 返回按钮无标题
    func setUpBackItem() {
        let bkItem = UIBarButtonItem()
        bkItem.title = ""
        self.navigationItem.backBarButtonItem = bkItem
    }
    
    /// 获取并配置日期
    func getAndSetDateTitle() {
        let dateFormatter4 = DateFormatter()
        dateFormatter4.locale = Locale(identifier: "en")
        dateFormatter4.dateFormat = "yyyy-MM"
        let res = AssistantMethods.getThisMonthStartEndDate(Date.init(), Date.init(), self.userDefineDateFlag)
        self.startDate = res.startDate
        self.endDate = res.endDate
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
}




