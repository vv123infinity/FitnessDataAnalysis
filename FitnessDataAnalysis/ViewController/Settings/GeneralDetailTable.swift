//
//  GeneralDetailTable.swift
//  FitnessDataAnalysis
//
//  Created by Infinity vv123 on 2023/3/5.
//

import UIKit

class GeneralDetailTable: UITableViewController {

//    @IBOutlet weak var doneBarBtn: UIBarButtonItem!
    
    @IBOutlet var doneBtn: UIButton!
    @IBOutlet var hintLabel: UILabel!
    
    
    // MARK: - 属性
    // 定义好根据Table的选择展现的信息
    
    /// 0表示语言设置，1测量单位，2外观，3日期开始
    var typeID: Int = 0
    /// Nav标题
    var viewTitle: String = ""
    /// 要展现的属性的选项
    var viewChoices: [String] = []
    
    // 此 Table 的Cell ID
    private var cellIdentifier = "userSelect"
    
    var inputUnit: Int = -1
    var finalUnit: Int = -1
    
    var inputDate: Bool = false
    var outputDate: Bool = true
    var detailsArray: [String] = []
    
    // 判断是否修改了高亮颜色
    var inputTintColorIndex: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        self.navigationItem.backBarButtonItem = backItem // This will
        self.title = self.viewTitle
        self.setUpUI()
        self.inputTintColorIndex = UserDefaults.standard.integer(forKey: "tintColorIndex")
        
        if typeID == 6{
            self.hintLabel.isHidden = false
            let plistURL = Bundle.main.url(forResource: "SettingItems", withExtension: "plist")
            
            do {
                let data = try Data(contentsOf: plistURL!)
                let plistData = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
                let dataDictionary = plistData as! [String: Any]
                self.detailsArray = dataDictionary["HRZoneArrayDetails"]! as! [String]

            }catch{}
            
            self.hintLabel.text = self.detailsArray[UserDefaults.standard.integer(forKey: "PreferredHRZoneType")]
        }
        else if typeID == 7 {
            self.hintLabel.isHidden = false
            self.hintLabel.text = "选择您在跑步数据统计与分析-分析报告-综合分析中关注的指标吗，最多选择3个指标。"
        }
        else {
            
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.inputUnit = UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit")
        self.inputDate = UserDefaults.standard.bool(forKey: "weekStartFromMon")
        
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.finalUnit = UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit")
        self.outputDate = UserDefaults.standard.bool(forKey: "weekStartFromMon")
        
        if inputUnit != finalUnit {
            UserDefaults.standard.setValue(true, forKey: "UnitHasChanged")
        }
        
        if inputDate != outputDate {
            UserDefaults.standard.setValue(true, forKey: "WeekStartDateHasChanged")
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.inputTintColorIndex != UserDefaults.standard.integer(forKey: "tintColorIndex") {
            UserDefaults.standard.set(true, forKey: "tintColorDidChange")
        }
        
    }
    
    
    func setUpUI(){

        self.navigationController?.navigationItem.rightBarButtonItem?.isHidden = true
        self.navigationItem.rightBarButtonItem?.title = ""
  
        if UserDefaults.standard.bool(forKey: "useSmiley"){
            self.setUpFontSmiley()
        }
        
        self.tableViewUI()

    }
    
    
    func setUpFontSmiley() {
        self.hintLabel.font = SmileyFontSize.getFootnote()
        
//        let att = [NSAttributedString.Key.font: font]
//        let str = NSAttributedString(string: (self.doneBtn.titleLabel?.text)!, attributes: att)
//        self.doneBtn.setAttributedTitle(str, for: .normal)
//        self.doneBtn.setAttributedTitle(str, for: .highlighted)
    }
    
    @IBAction func doneBtnPressed() {
        
        if typeID == 4 {
            self.navigationController?.popToRootViewController(animated: true)
        }
        else {
            self.dismiss(animated: true)
        }
        
    }
    
    func setUpNav(){
        self.navigationController?.navigationBar.tintColor = ColorUtil.getGeneralTintColorStyle1()
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [.foregroundColor: ColorUtil.getGeneralTintColorStyle1()]
        appearance.largeTitleTextAttributes = [.foregroundColor: ColorUtil.getGeneralTintColorStyle1()]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
    }
    
    func tableViewUI() {
//        self.tableView.backgroundColor = ColorUtil.getBackgroundColorStyle1()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.viewChoices.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)

        
        switch self.typeID{
        case 0:
            UserDefaults.standard.set(indexPath.row, forKey: "theAppLanguage")
            //

            if indexPath.row == UserDefaults.standard.integer(forKey: "theAppLanguage") {
                cell.accessoryType = .checkmark
            }
            else{
                cell.accessoryType = .none
            }
            
            tableView.reloadData()
        case 1:
            if indexPath.row == 0{
                UserDefaults.standard.set(UserPreferenceSetting.RunningDistanceUnit.km.rawValue, forKey: "UserRunningDistanceUnit")
                UserDefaults.standard.set("KM", forKey: "distanceUnitDefaultAb")
            }
            else if indexPath.row == 1 {
                UserDefaults.standard.set(UserPreferenceSetting.RunningDistanceUnit.mile.rawValue, forKey: "UserRunningDistanceUnit")
                UserDefaults.standard.set("MI", forKey: "distanceUnitDefaultAb")
            }
            else{
                UserDefaults.standard.set(UserPreferenceSetting.RunningDistanceUnit.meter.rawValue, forKey: "UserRunningDistanceUnit")
                UserDefaults.standard.set("M", forKey: "distanceUnitDefaultAb")
            }
            // 打钩✅
            if indexPath.row == UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit") {
                cell.accessoryType = .checkmark
            }
            else{
                cell.accessoryType = .none
            }
            
            tableView.reloadData()
            
        case 2:
            break
        case 3:
            
            if indexPath.row == 0 {
                UserDefaults.standard.set(true, forKey: "weekStartFromMon")
                cell.accessoryType = .checkmark
            }
            else{
                UserDefaults.standard.set(false, forKey: "weekStartFromMon")
                cell.accessoryType = .checkmark
            }
            
            tableView.reloadData()
        case 4:
            UserDefaults.standard.set(indexPath.row, forKey: "tintColorIndex")
            //"appAppearance"
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "RootViewController") as? RootViewController
            if !UserDefaults.isFirstLaunch() {
                
                self.navigationController?.pushViewController(vc!, animated: true)
            }
            else {
            }
            tableView.reloadData()
        case 5:
            UserDefaults.standard.set(indexPath.row, forKey: "PreferredRunType")
            tableView.reloadData()
        case 6:
            UserDefaults.standard.set(indexPath.row, forKey: "PreferredHRZoneType")
            tableView.reloadData()
            break
        case 7:
            cell.selectionStyle = .none
            
            let indicatorArray = UserDefaults.standard.array(forKey: "ComprehensiveAnalysisIndicatorArray") as? [Int]
            var myStack: [Int] = []
            if indicatorArray == nil {
                myStack.insert(indexPath.row, at: 0)
            }
            else {
                myStack = indicatorArray!
                print("初始栈：\(myStack)")
                if !myStack.contains(indexPath.row) {
                    if indicatorArray?.count == 3 {
                        let _ = myStack.popLast()
                        myStack.insert(indexPath.row, at: 0)
                    }
                    else {
                        myStack.insert(indexPath.row, at: 0)
                    }
                }

            }
            print("结束栈：\(myStack)")
            UserDefaults.standard.set(myStack, forKey: "ComprehensiveAnalysisIndicatorArray")
            tableView.reloadData()
            
        default:
            print("")
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.tintColor = ColorUtil.dynamicColor(dark: UIColor.white, light: UIColor.black)
        // Configure the cell...
        var content = cell.defaultContentConfiguration()
        content.text = self.viewChoices[indexPath.row]
        content.textProperties.font = SmileyFontSize.getCellFont()
        
        
        switch self.typeID{
        case 0:
            if indexPath.row == UserDefaults.standard.integer(forKey: "theAppLanguage") {
                cell.accessoryType = .checkmark
            }
            else{
                cell.accessoryType = .none
            }
            
        case 1:
            if indexPath.row == UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit") {
                cell.accessoryType = .checkmark
            }
            else{
                cell.accessoryType = .none
            }
        case 2:
            break
        case 3:
            if indexPath.row == 0 {
                if UserDefaults.standard.bool(forKey: "weekStartFromMon") {
                    cell.accessoryType = .checkmark
                }
                else{
                    cell.accessoryType = .none
                }
            }
            else{
                if UserDefaults.standard.bool(forKey: "weekStartFromMon") {
                    cell.accessoryType = .none
                }
                else{
                    cell.accessoryType = .checkmark
                }
                
            }
        case 4:
            cell.accessoryType = .none
            if indexPath.row == UserDefaults.standard.integer(forKey: "tintColorIndex") {
                cell.accessoryType = .checkmark
            }
            else {
                cell.accessoryType = .none
            }
        case 5:
            cell.accessoryType = .none
            if indexPath.row == UserDefaults.standard.integer(forKey: "PreferredRunType") {
                cell.accessoryType = .checkmark
            }
            else {
                cell.accessoryType = .none
            }
        case 6:
            cell.accessoryType = .none
            if indexPath.row == UserDefaults.standard.integer(forKey: "PreferredHRZoneType") {
                cell.accessoryType = .checkmark
            }
            else {
                cell.accessoryType = .none
            }
            self.hintLabel.text = self.detailsArray[UserDefaults.standard.integer(forKey: "PreferredHRZoneType")]

        case 7:
            let indicatorArray = UserDefaults.standard.array(forKey: "ComprehensiveAnalysisIndicatorArray") as? [Int]
            if indicatorArray == nil {
                cell.accessoryType = .none
            }
            else {
                if (indicatorArray?.contains(indexPath.row))!{
                    cell.accessoryType = .checkmark
                }
                else{
                    cell.accessoryType = .none
                }
            }
            break
            
            
        default:
            print("")
        }
        
        cell.contentConfiguration = content

        return cell
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
