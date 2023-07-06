//
//  FavoriteCollection.swift
//  FitnessDataAnalysis
//
//  Created by 十口V🌼 on 2023/5/9.
//

import UIKit
import HealthKit
import AAInfographics
import Fastis


private let reuseIdentifier = "Cell"
class StatCollection: UICollectionViewController {

    // MARK: - Outlets

    
    
    // MARK: - Properties
    /// collection的ID
    let myIdentifier = "FavoriteCellID"
    /// 每行的item
    private let itemsPerRow: CGFloat = 2
    /// 集合项目之间的空隙
    private let sectionInsets = UIEdgeInsets(
      top: 50,
      left: 10,
      bottom: 50,
      right: 10)

    /// 各个section的行名称
    var myRowTextInSection: [[String]] = []
    
    
    var myFavoriteTitles: [String] = ["1", "2", "3", "2", "3", "2", "3", "2", "3", "2", "3", "2", "3"]
    
    var myFavoriteData: [String] = ["11", "22", "33", "2", "3", "2", "3", "2", "3", "2", "3", "2", "3"]
    /// 各个CollectionItem的标题
    var collItemTitles: [String] = []
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        
        
        self.setUpBasicUI()
        
        self.loadPlist()
        

        // 2. 尝试读取用户的健康数据
        WorkoutDataStore.loadLastWorkouts() { (res, error) in
            // 可以成功访问Workout类型的数据
            if res != nil && res!.count != 0 && error == nil{
                self.loadWorkoutsAndGetDistance()
            }
            
        }
        
        
        
        
        // Do any additional setup after loading the view.
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
            
            self.collectionView.reloadData()
            
            // TODO: 显示数据来源
//            var dataSourceStr = "数据来源\n"
//            for deviceName in self.result.dataSource {
//                dataSourceStr += "\(deviceName)\n"
//            }
            
            
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.collItemTitles.count > 0 ? 2 : 0
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if section == 1 {
            return self.collItemTitles.count > 0 ? self.collItemTitles.count : 0
        }
        else {
            return 1
        }

    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // MARK: - 整合分析Cell
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AnalysisCellID", for: indexPath) as? myCollectionViewCell
            cell?.bkView.backgroundColor = ColorUtil.getCellBackgroundColorStyle()


            let colors = ColorUtil.getTableLogoImageColor()
            let images = self.getTableLogoImageColor()
            cell?.cellTitle.text = "分析报告"
            cell?.cellData.text = "运动表现"
            cell?.cellLogo.image = UIImage(systemName: "list.bullet.clipboard")
            cell?.cellLogo.tintColor = UIColor(red: 0.180, green: 0.773, blue: 0.710, alpha: 1)
            cell?.cellTitle.textColor = UIColor(red: 0.180, green: 0.773, blue: 0.710, alpha: 1)
            cell?.cellSupplementary[0].text = "---"
            cell?.cellSupplementary[1].text = "---"
            cell?.cellSupplementary[0].isHidden = true
            cell?.cellSupplementary[1].isHidden = true
            // 背景框的边角、阴影
            
            cell?.bkView.layer.cornerRadius = 10
            cell?.bkView.layer.masksToBounds = false
            cell?.bkView.layer.shadowColor = UIColor(red: 0.796, green: 0.957, blue: 0.941, alpha: 1).cgColor
            cell?.bkView.layer.shadowOffset = .zero
            cell?.bkView.layer.shadowRadius = 3
            cell?.bkView.layer.shadowOpacity = 1

            return cell!
        }
        else if indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.myIdentifier, for: indexPath) as? myCollectionViewCell
            cell?.bkView.backgroundColor = ColorUtil.getCellBackgroundColorStyle()
            
            let colors = ColorUtil.getTableLogoImageColor()
            let images = self.getTableLogoImageColor()
            if self.indicatorValueList.count > 0 && self.collItemTitles.count > 0{
                
                cell?.cellTitle.text = self.collItemTitles[indexPath.row]
                cell?.cellData.text = self.indicatorValueList[indexPath.row]
                cell?.cellLogo.image = images[indexPath.row]
                cell?.cellLogo.tintColor = colors[indexPath.row]
                cell?.cellTitle.textColor = colors[indexPath.row]
                cell?.cellSupplementary[0].text = "---"
                cell?.cellSupplementary[1].text = "---"
                // 背景框的边角、阴影
                cell?.bkView.layer.cornerRadius = 10
                cell?.bkView.layer.masksToBounds = false
                cell?.bkView.layer.shadowColor = UIColor.systemGray6.cgColor
                cell?.bkView.layer.shadowOffset = .zero
                cell?.bkView.layer.shadowRadius = 3
                cell?.bkView.layer.shadowOpacity = 1
                // 补充信息 -
                // ① 平均每次X公里
                if indexPath.row == 0 {
                    cell?.cellSupplementary[0].isHidden = false
                    cell?.cellSupplementary[1].isHidden = false
                    let avgDisEachTime = self.result.distanceArray.reduce(0, +) / Double(self.result.distanceArray.count)
                    let avgDisEachTime2Deci = AssistantMethods.convert(avgDisEachTime, maxDecimals: 2)
                    cell?.cellSupplementary[0].text = NSLocalizedString("avgDisPerRun", comment: "")
                    var avgDistanceToShow = "\(avgDisEachTime2Deci)"
                    
                    if UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit") == 0{
                       avgDistanceToShow +=  NSLocalizedString("distanceUnitKM", comment: "")
                    }
                    else {
                        avgDistanceToShow +=  NSLocalizedString("distanceUnitMile", comment: "")
                    }
                    cell?.cellSupplementary[1].text = avgDistanceToShow
                }
                else if indexPath.row == 3 {
                    // 平均每次跑步耗时
                    cell?.cellSupplementary[0].isHidden = false
                    cell?.cellSupplementary[1].isHidden = false
                    cell?.cellSupplementary[0].text = NSLocalizedString("avgTimePerRun", comment: "")
                    let avgTimeToShow = self.result.avgTime
                    
                    cell?.cellSupplementary[1].text = avgTimeToShow
                }
                else if indexPath.row == 4 {
                    cell?.cellSupplementary[0].isHidden = true
                    cell?.cellSupplementary[1].isHidden = false
                    cell?.cellSupplementary[1].text = self.result.maxDistanceDate
                }
                else if indexPath.row == 5 {
                    cell?.cellSupplementary[0].isHidden = true
                    cell?.cellSupplementary[1].isHidden = false
                    cell?.cellSupplementary[1].text = self.result.maxPaceDate
                }
                else {
                    cell?.cellSupplementary[0].isHidden = true
                    cell?.cellSupplementary[1].isHidden = true
                }
                
            }
            else {
                cell?.cellTitle.text = self.collItemTitles[indexPath.row]
                cell?.cellData.text = "---"
                cell?.cellLogo.image = images[indexPath.row]
                cell?.cellLogo.tintColor = colors[indexPath.row]
                cell?.cellSupplementary[0].text = "\t"
                cell?.bkView.layer.cornerRadius = 10
                cell?.bkView.layer.masksToBounds = false
            }
            return cell!
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.myIdentifier, for: indexPath) as? myCollectionViewCell
            return cell!
        }
        

    }
    
    // MARK: 浅深色模式
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        
        
    }
    // MARK:  - 点击触发转场-
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? myCollectionViewCell
        if self.workouts.count > 0 && indexPath.section == 0 {
            let sb = UIStoryboard(name: "Assistant", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "AnalysisPageVC") as? AnalysisPageVC
            vc?.startDate = self.startDate
            vc?.endDate = self.endDate
            vc?.dateLabelTxt = self.title!
            self.navigationController?.pushViewController(vc!, animated: true)
            
        }
        else if self.workouts.count > 0 && indexPath.section == 1 {
            cell?.bkView.layer.shadowOffset = .zero
            cell?.bkView.layer.shadowOpacity = 0.88
            // ColorUtil.getTextFieldHighlightColor().cgColor
            cell?.bkView.layer.shadowColor = UIColor.systemGray3.cgColor
            cell?.bkView.layer.shadowRadius = 3
            
            
            // PART 2 触发转场
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
                    plotStyle1VC?.dateLabelTxt = self.title!
                    plotStyle1VC?.subTitles = [NSLocalizedString("detailInfo", comment: ""),
                                               NSLocalizedString("classificationDistance", comment: "")
                    ]
                    
                    
                    
                }
                // 展示plotStyle1VC
                self.present(plotStyle1VC!, animated: true)
                
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
            
            DispatchQueue.main.asyncAfter(deadline: .now()+0.8) {
                cell?.bkView.layer.shadowColor = UIColor.systemGray6.cgColor
                cell?.bkView.layer.shadowOffset = .zero
                cell?.bkView.layer.shadowRadius = 3
                cell?.bkView.layer.shadowOpacity = 1
            }
            
        }
        else{
            
        }

    }
    

    // MARK: UICollectionViewDelegate


    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }


    
    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

    func setUpBasicUI() {
        self.getAndSetDateTitle()
        self.setUpBackItem()
        self.setDateRangeLabel()
        self.setBackground()
    }
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
    
    /// 设置Collection的背景
    func setBackground(){
//        self.collectionView.backgroundColor = UIColor.black
//        self.collectionView.backgroundView =
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
            self.title = dateToShow
        }
        else {
            self.title = "---"
//            self.thisMonthDateLabel.text = NSLocalizedString("noRunRecordsP0", comment: "") + dateToShow + NSLocalizedString("noRunRecordsP1", comment: "") + "🥹"
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
    /// 根据plist获取设置列表的sec标题和内容
    func loadPlist() {
        let plistURL = Bundle.main.url(forResource: "RunDataAnalysisIndicator", withExtension: "plist")
        // 设置各个var的值
        do {
            let data = try Data(contentsOf: plistURL!)
            let plistData = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
            let dataDictionary = plistData as! [String: Any]
            self.collItemTitles = (dataDictionary["IndicatorArrayVersion0"] as? [String])!
            print(collItemTitles)
            // 各个标题
//            self.mySectionTitle = (dataDictionary["sectionTitle"] as? [String])!
            // 各个标题的行
//            self.myRowTextInSection = [["个人收藏项"], (dataDictionary["IndicatorArrayVersion0"] as? [String])!]
            
        }
        catch{
            
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
            self.collectionView.reloadData()
        }
        
        fastisController.present(above: self)
//        self.navigationController?.pushViewController(fastisController, animated: true)
        
    }
    
}


// MARK: - Collection View Flow Layout Delegate
extension StatCollection: UICollectionViewDelegateFlowLayout {
  // 1
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath
  ) -> CGSize {
    // 2
    let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
    let availableWidth = view.frame.width - paddingSpace
    let widthPerItem = availableWidth / itemsPerRow
    
    return CGSize(width: widthPerItem, height: widthPerItem)
  }
  
  // 3
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    insetForSectionAt section: Int
  ) -> UIEdgeInsets {
    return sectionInsets
  }
  
  // 4
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    minimumLineSpacingForSectionAt section: Int
  ) -> CGFloat {
    return sectionInsets.left
  }
}



