//
//  SettingRootTable.swift
//  FitnessDataAnalysis
//
//  Created by 十口V🌼 on 2023/2/28.
//

import UIKit
import HealthKit
class SettingRootTable: UITableViewController {

    // MARK: - Outlets
//    @IBOutlet weak var doneBarBtn: UIBarButtonItem!
    
    // MARK: - Properties
    /// 个人主页设置ID
    private let profileCellID = "AboutMeCellID"
    /// 通用设置Cell ID
    private let generalCellID = "GeneralCellID"
    /// 数据设置ID
    private let dataCellID = "dataCellID"
    /// 其他设置Cell ID
    private let otherCellID = "otherCellID"
    /// 个人信息列表
    var personalInfoList: [String] = []
    /// 通用设置列表
    var generalInfoList: [String] = []
    /// 通用列表的具体选项
    lazy var generalChoicesList: [[String]] = [[]]
    /// 数据列表
    lazy var dataInfoList: [String] = []
    /// 其他列表
    lazy var otherInfoList: [String] = []
    /// 展示在Table 中的list
    lazy var totalInfoListToShow: [[String]] = [self.personalInfoList, self.generalInfoList, self.dataInfoList, otherInfoList]
    
    /// section的标题
    var sectionTitle: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backItem = UIBarButtonItem()
        backItem.title = ""
        self.navigationItem.backBarButtonItem = backItem // This will
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // 1. 从plist获取各个项的字符串
        self.getTitleOfTableCell()
        
        // 2. 设置基础UI
        self.setUpUI()
    }
    
    
    
    /// 根据plist获取设置列表的sec标题和内容
    func getTitleOfTableCell() {
        let plistURL = Bundle.main.url(forResource: "SettingItems", withExtension: "plist")
        // 设置各个var的值
        do {
            let data = try Data(contentsOf: plistURL!)
            let plistData = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
            let dataDictionary = plistData as! [String: Any]
            // 各个标题
            self.sectionTitle = [dataDictionary["sec0PersonalInfo"]! as! String,
                                 dataDictionary["sec1General"]! as! String,
                                 dataDictionary["sec2Data"]! as! String,
                                 dataDictionary["sec3Other"]! as! String,
            ]
            // 个人信息列表
            self.personalInfoList = dataDictionary["sec0PersonalInfoArray"]! as! [String]
            
            self.generalInfoList = dataDictionary["sec1GeneralArray"]! as! [String]
            
            self.dataInfoList = dataDictionary["sec2DataArray"]! as! [String]
            
            self.otherInfoList = dataDictionary["sec3OtherArray"]! as! [String]
            
            // 通用具体
            self.generalChoicesList = [dataDictionary["generalChoicesList"]! as! [String]]
            
        }
        catch{
            
        }
        
    }
    
    

    func setUpUI(){

        
        self.tableViewUI()
        self.navigationController?.navigationBar.tintColor = ColorUtil.getBarBtnColor()
        if UserDefaults.standard.bool(forKey: "useSmiley"){
            self.setUpFontSmiley()
        }
    }
    
    func setUpFontSmiley(){
        self.navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.label,
            .font: SmileyFontSize.getNormal()
        ]
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedString.Key.font: SmileyFontSize.getNormal()]

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
        self.tableView.backgroundColor = ColorUtil.getBackgroundColorStyle1()
    }
    
    
    // MARK: - Table view data source


    @objc func switchChanged(_ sender : UISwitch!){
        if sender.isOn {
            UserDefaults.standard.set(true, forKey: "lastQueryDateRange")
        }
        else{
            UserDefaults.standard.set(false, forKey: "lastQueryDateRange")
        }
    }
    @objc func chartInteractionSwitchChanged(_ sender : UISwitch!){
        if sender.isOn {
            UserDefaults.standard.set(true, forKey: "allowChartInteraction")
        }
        else{
            UserDefaults.standard.set(false, forKey: "allowChartInteraction")
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: profileCellID, for: indexPath)
            cell.backgroundColor = ColorUtil.getCellBackgroundColorStyle()
            var content = cell.defaultContentConfiguration()
            content.text = self.totalInfoListToShow[0][indexPath.row]
            
            content.textProperties.font = SmileyFontSize.getCellFont()
            
            content.image = UIImage(named: "test-account")
//            cell.backgroundColor = ColorUtil.dynamicColor(dark: UIColor.black, light: UIColor.white) UIFont(name: "Smiley Sans", size: 28)
            cell.contentConfiguration = content
            
            return cell
        }
        
        else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: generalCellID, for: indexPath)
            cell.backgroundColor = ColorUtil.getCellBackgroundColorStyle()
            if indexPath.row == 1 {
                // 是否打开记录开关
                var content = cell.defaultContentConfiguration()
                content.text = self.totalInfoListToShow[1][indexPath.row]
                content.image = UIImage(named: "save")
                content.textProperties.font = SmileyFontSize.getCellFont()
                let switchView = UISwitch(frame: .zero)
                switchView.setOn(UserDefaults.standard.bool(forKey: "lastQueryDateRange"), animated: true)
                switchView.tag = indexPath.row // for detect which row switch Changed
                switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
                cell.accessoryView = switchView
                cell.contentConfiguration = content
                
            }
            else if indexPath.row == 2 {
                // 是否打开记录开关
                var content = cell.defaultContentConfiguration()
                content.text = self.totalInfoListToShow[1][indexPath.row]
                content.image = UIImage(named: "combo-chart")
                content.textProperties.font = SmileyFontSize.getCellFont()
                let switchView = UISwitch(frame: .zero)
                switchView.setOn(UserDefaults.standard.bool(forKey: "allowChartInteraction"), animated: true)
                switchView.tag = indexPath.row // for detect which row switch Changed
                switchView.addTarget(self, action: #selector(self.chartInteractionSwitchChanged(_:)), for: .valueChanged)
                cell.accessoryView = switchView
                cell.contentConfiguration = content
            }
            
            else {
                var content = cell.defaultContentConfiguration()
                content.text = self.totalInfoListToShow[1][indexPath.row]
                content.textProperties.font = SmileyFontSize.getCellFont()
                content.image = UIImage(named: "theRuler")
                cell.contentConfiguration = content
                
            }
            return cell
        }
        else if indexPath.section == 2{
            let cell = tableView.dequeueReusableCell(withIdentifier: dataCellID, for: indexPath)
            cell.backgroundColor = ColorUtil.getCellBackgroundColorStyle()
            var content = cell.defaultContentConfiguration()
            content.text = self.totalInfoListToShow[2][indexPath.row]
            content.textProperties.font = SmileyFontSize.getCellFont()
            switch indexPath.row {
            case 0:
                content.image = UIImage(named: "data-protection")
            case 1:
                content.image = UIImage(named: "privacy")
            default:
                content.image = UIImage(named: "theRuler")
            }
            

            
            cell.contentConfiguration = content
            return cell
        }
        else if indexPath.section == 3{
            let cell = tableView.dequeueReusableCell(withIdentifier: otherCellID, for: indexPath)
            cell.backgroundColor = ColorUtil.getCellBackgroundColorStyle()
            var content = cell.defaultContentConfiguration()
            content.text = self.totalInfoListToShow[3][indexPath.row]
            content.textProperties.font = SmileyFontSize.getCellFont()

            switch indexPath.row {
            case 0:
                content.image = UIImage(named: "aboutUs")
            default:
                content.image = UIImage(named: "aboutUs")
            }
            cell.contentConfiguration = content
            return cell
        }
        else{
            return tableView.dequeueReusableCell(withIdentifier: generalCellID, for: indexPath)
        }
        
    }
    


    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.sectionTitle.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sectionTitle[section]
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.totalInfoListToShow[section].count
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }


    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            //GeneralDetailTable
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "GeneralDetailTable") as! GeneralDetailTable
            
            vc.typeID = 1
            vc.viewTitle = self.generalInfoList[indexPath.row]
            vc.viewChoices = self.generalChoicesList[indexPath.row]
//            self.present(vc, animated: true)
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
//        if indexPath.section == 2 && indexPath.row == 0 {
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let vc = storyboard.instantiateViewController(withIdentifier: "TestWeb") as! TestWeb
//
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
        if indexPath.section == 2 && indexPath.row == 0 {
            // TODO: 提示同步健康数据
            
        }
        
    }
    
    


}
