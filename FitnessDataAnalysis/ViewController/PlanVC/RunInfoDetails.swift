//
//  RunInfoDetails.swift
//  FitnessDataAnalysis
//
//  Created by 十口V🌼 on 2023/4/4.
//

import UIKit
import CoreData

class RunInfoDetails: UITableViewController {

    /// 输入进来的那个实例
    var inputInstance: OneDayPlan!
    /// 上下文
    var managedObjectContext: NSManagedObjectContext!
    // 第一部分
    /// 0.0 日期 - 在setUpUI中设置
    var part_0_0_recordDate: Date!
    
    // MARK: - PART 1 -
    /// 1.0 距离 prepareData
    var part_1_0_distanceToShow: String =  " "
    /// 1.1 跑步类型
    var part_1_1_type: String = " "
    /// 1.2 跑步感受
    var part_1_2_feeling: String = ""
    
    
    // MARK: - PART 2 -
    /// 2.0 跑前拉伸
    var part_2_0_before_run: Bool = false
    /// 2.1 跑后拉伸
    var part_2_1_after_run: Bool = false
    
    // MARK: - PART 3 -
    /// 3.0 日志
    var part_3_0_notes: String = " "
    
    lazy var allSectionsTitle: [[String]] = [
        [NSLocalizedString("part_1_0_title", comment: ""),
         NSLocalizedString("part_1_1_title", comment: ""),
         NSLocalizedString("part_1_2_title", comment: "")],
        
        [NSLocalizedString("part_2_0_title", comment: ""),
         NSLocalizedString("part_2_1_title", comment: "")],
        
        [NSLocalizedString("part_3_0_title", comment: "")],
        
        [NSLocalizedString("deleteRecord", comment: "")],
    ]
    
    var allSectionsVal: [[Any]]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()


        // UI设置
        self.setUpUI()
        // 上下文
        self.setUpCoreData()
        // 准备数据
        self.prepareData()
    }
    
    
    /// UI设置
    func setUpUI() {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        self.navigationItem.backBarButtonItem = backItem // This will
        if inputInstance.runningDate != nil {
            self.part_0_0_recordDate = inputInstance.runningDate!
            self.title = AssistantMethods.getDateInFormatString(part_0_0_recordDate, "yyyy-MM-dd")
        }
        else {
            self.title = ""
        }
        
    }
    
    /// 设置管理上下文
    func setUpCoreData() {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedObjectContext = appDelegate!.persistentContainer.viewContext
        
    }
    
    
    
    /// 准备数据
    func prepareData() {
        if let inputInstance = inputInstance {

            let distanceInUnit: Bool = self.inputInstance.unitIsKM
            var distanceInStringWithUnit = ""
            if distanceInUnit {
                switch UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit") {
                case 0:
                    let distance = AssistantMethods.convert(self.inputInstance.runningDistance, maxDecimals: 2)
                    distanceInStringWithUnit += "\(distance)" + " " + NSLocalizedString("distanceUnitKM", comment: "")
                case 1:
                    let distanceInMI = AssistantMethods.convert(AssistantMethods.distanceKMtoMile(self.inputInstance.runningDistance), maxDecimals: 2)
                    
                    distanceInStringWithUnit += "\(distanceInMI)" + " " + NSLocalizedString("distanceUnitMile", comment: "")
                default:
                    break
                }

            }
            else {
                
                switch UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit") {
                case 0:
                    let distanceInKM = AssistantMethods.convert(AssistantMethods.distanceMileToKM(self.inputInstance.runningDistance), maxDecimals: 2)
                    distanceInStringWithUnit += "\(distanceInKM)" + " " + NSLocalizedString("distanceUnitKM", comment: "")
                case 1:
                    let distanceInMI = AssistantMethods.convert(self.inputInstance.runningDistance, maxDecimals: 2)
                    distanceInStringWithUnit += "\(distanceInMI)" + " " + NSLocalizedString("distanceUnitMile", comment: "")
                default:
                    break
                }
                
                
            }
            self.part_1_0_distanceToShow = distanceInStringWithUnit
            
            
            
            // 跑步类型
            var runTypeID = 0
            runTypeID = Int(self.inputInstance.runType)
            self.prepareRunType(runTypeID)
            
            self.part_1_2_feeling = GeneralMethods.getRunningFeelingEmoji(Int(self.inputInstance.feeling))
            
            // sec 2
            self.part_2_0_before_run = self.inputInstance.beforeRun
            self.part_2_1_after_run = self.inputInstance.afterRun
            
            // sec3
            if self.inputInstance.note != nil && !self.inputInstance.note!.isEmpty && self.inputInstance.note! != "" {
                self.part_3_0_notes = self.inputInstance.note!
                
            }
            else {
                self.part_3_0_notes = "暂无记录"
            }
    
            self.allSectionsVal = [
            [part_1_0_distanceToShow, part_1_1_type, part_1_2_feeling],
            [part_2_0_before_run, part_2_1_after_run],
            [part_3_0_notes]
        ]
            
            
        }
    }
    
    /// 根据plist获取设置列表的sec标题和内容
    func prepareRunType(_ idx: Int) {
        let plistURL = Bundle.main.url(forResource: "RunType", withExtension: "plist")
        // 设置各个var的值
        do {
            let data = try Data(contentsOf: plistURL!)
            let plistData = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
            let dataDictionary = plistData as! [String: Any]
            // 各个跑步类型
            let runTypeList = dataDictionary["RunningTypeArray"]! as! [String]
            self.part_1_1_type = runTypeList[idx]
        }
        catch{
            
        }
        
    }
    
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.allSectionsTitle.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.allSectionsTitle[section].count
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "sec0ID", for: indexPath)
            var content = cell.defaultContentConfiguration()
            if UserDefaults.standard.bool(forKey: "useSmiley") {
                content.textProperties.font = SmileyFontSize.getNormal()
                content.secondaryTextProperties.font = SmileyFontSize.getFootnote()
            }
            content.text = self.allSectionsTitle[0][indexPath.row]
            content.secondaryText = (self.allSectionsVal[0][indexPath.row] as! String)
            cell.contentConfiguration = content
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "sec1ID", for: indexPath)
            var content = cell.defaultContentConfiguration()
            if UserDefaults.standard.bool(forKey: "useSmiley") {
                content.textProperties.font = SmileyFontSize.getNormal()
                content.secondaryTextProperties.font = SmileyFontSize.getFootnote()
            }
            content.text = self.allSectionsTitle[1][indexPath.row]
            let curVal: Bool = (self.allSectionsVal[1][indexPath.row] as? Bool)!
            content.secondaryText = curVal ? "✅" : "❎"
            
            cell.contentConfiguration = content
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "sec2ID", for: indexPath)
            var content = cell.defaultContentConfiguration()
            if UserDefaults.standard.bool(forKey: "useSmiley") {
                content.textProperties.font = SmileyFontSize.getNormal()
            }
            content.textProperties.color = UIColor.gray
//            content.secondaryTextProperties.font = SmileyFontSize.getCellFont()
            content.text = (self.allSectionsVal[2][indexPath.row] as! String)
//            content.secondaryText =
            cell.contentConfiguration = content
            return cell
//        case 3:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "sec3ID", for: indexPath)
//            var content = cell.defaultContentConfiguration()
//            content.textProperties.font = SmileyFontSize.getCellFont()
//            content.secondaryTextProperties.font = SmileyFontSize.getCellFont()
//            content.text = "第4部分"
//            content.secondaryText = "详细情况"
//            cell.contentConfiguration = content
//            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "secFinalID", for: indexPath)
            var content = cell.defaultContentConfiguration()
            
            if UserDefaults.standard.bool(forKey: "useSmiley") {
                content.textProperties.font = SmileyFontSize.getNormal()
//                content.secondaryTextProperties.font = SmileyFontSize.getFootnote()
            }
            content.text = NSLocalizedString("deleteRecord", comment: "")
            content.textProperties.color = UIColor.init(red: 207/255.0, green: 38/255.0, blue: 29/255.0, alpha: 1)
            cell.contentConfiguration = content
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "secXID", for: indexPath)
            return cell
            
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 3:
            // 准备alert VC
            let alertVC = UIAlertController(title: NSLocalizedString("confirmDelete", comment: ""), message: "", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: NSLocalizedString("yesAction", comment: ""), style: .destructive){ (action) in
                // 删除记录
                do {
                    try! self.managedObjectContext.delete(self.inputInstance)
                    self.navigationController?.popViewController(animated: true)
                    
                }
                
            }
            
            let noAction = UIAlertAction(title: NSLocalizedString("noAction" , comment: ""), style: .cancel) { (action) in
                print("取消删除")
            }
            
            alertVC.addAction(yesAction)
            alertVC.addAction(noAction)
            self.present(alertVC, animated: true)
            
            break
            
        default:
            break
        }
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

}
