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
    /// 跑步设置ID
    private let runCellID = "runCellID"
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
    /// 跑步偏好列表
    lazy var runPreferenceList: [String] = []
    /// 其他列表
    lazy var otherInfoList: [String] = []
    /// 展示在Table 中的list
    lazy var totalInfoListToShow: [[String]] = [self.personalInfoList, self.generalInfoList,  self.runPreferenceList, self.dataInfoList, self.otherInfoList]
    
    /// section的标题
    var sectionTitle: [String] = []
    /// 跑步类型
    lazy var runTypeList: [String] = []

    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if UserDefaults.standard.bool(forKey: "tintColorDidChange") {
     
      
        }
        
        

        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
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
        
        // 加载RunType.plist
        self.loadRunTypeFromPlist()
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
                                 dataDictionary["sec2Run"]! as! String,
                                 dataDictionary["sec3Data"]! as! String,
                                 dataDictionary["sec4Other"]! as! String,
            ]
            // 个人信息列表
            self.personalInfoList = dataDictionary["sec0PersonalInfoArray"]! as! [String]
            
            self.generalInfoList = dataDictionary["sec1GeneralArray"]! as! [String]
            
            self.runPreferenceList = dataDictionary["sec2RunArray"]! as! [String]
            
            self.dataInfoList = dataDictionary["sec3DataArray"]! as! [String]
            
            
            self.otherInfoList = dataDictionary["sec4OtherArray"]! as! [String]
            
            // 通用具体
            self.generalChoicesList = [dataDictionary["generalChoicesList"]! as! [String]]
            
        }
        catch{
            
        }
        
    }
    
    
    func loadRunTypeFromPlist() {
        let plistURL = Bundle.main.url(forResource: "RunType", withExtension: "plist")
        // 设置各个var的值
        do {
            let data = try Data(contentsOf: plistURL!)
            let plistData = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
            let dataDictionary = plistData as! [String: Any]
            self.runTypeList = (dataDictionary["RunningTypeArray"]! as? [String])!
            
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
//        self.tableView.backgroundColor = ColorUtil.getBackgroundColorStyle1()
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
            var content = cell.defaultContentConfiguration()
            content.text = self.totalInfoListToShow[0][indexPath.row]
//            if UserDefaults.standard.bool(forKey: "useSmiley") {
//                content.textProperties.font = SmileyFontSize.getNormal()
//            }
//            content.textProperties.font = SmileyFontSize.getCellFont()
            content.image = UIImage(systemName: "person.crop.circle")
            content.imageProperties.tintColor = ColorUtil.getBarBtnColor()
            cell.contentConfiguration = content

            return cell
        }
        
        else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: generalCellID, for: indexPath)
            if indexPath.row == 1 {
                // 是否打开记录开关
                var content = cell.defaultContentConfiguration()
                content.text = self.totalInfoListToShow[1][indexPath.row]
                content.image = UIImage(systemName: "magnifyingglass")
                content.imageProperties.tintColor = ColorUtil.getBarBtnColor()
//                if UserDefaults.standard.bool(forKey: "useSmiley") {
//                    content.textProperties.font = SmileyFontSize.getNormal()
//                }
//                content.textProperties.font = SmileyFontSize.getCellFont()
                let switchView = UISwitch(frame: .zero)
                switchView.setOn(UserDefaults.standard.bool(forKey: "lastQueryDateRange"), animated: true)
                switchView.tag = indexPath.row // for detect which row switch Changed
                switchView.onTintColor = ColorUtil.getBarBtnColor()
                switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
                cell.accessoryView = switchView
                cell.contentConfiguration = content
                
            }
            else if indexPath.row == 2 {
                // 是否打开记录开关
                var content = cell.defaultContentConfiguration()
                content.text = self.totalInfoListToShow[1][indexPath.row]
                content.image = UIImage(systemName: "chart.pie")
                content.imageProperties.tintColor = ColorUtil.getBarBtnColor()
//                if UserDefaults.standard.bool(forKey: "useSmiley") {
//                    content.textProperties.font = SmileyFontSize.getNormal()
//                }
//                content.textProperties.font = SmileyFontSize.getCellFont()
                let switchView = UISwitch(frame: .zero)
                switchView.setOn(UserDefaults.standard.bool(forKey: "allowChartInteraction"), animated: true)
                switchView.tag = indexPath.row // for detect which row switch Changed
                switchView.onTintColor = ColorUtil.getBarBtnColor()
                switchView.addTarget(self, action: #selector(self.chartInteractionSwitchChanged(_:)), for: .valueChanged)
                cell.accessoryView = switchView
                cell.contentConfiguration = content
            }
            else {
                var content = cell.defaultContentConfiguration()
                content.text = self.totalInfoListToShow[1][indexPath.row]
//                if UserDefaults.standard.bool(forKey: "useSmiley") {
//                    content.textProperties.font = SmileyFontSize.getNormal()
//                }
//                content.textProperties.font = SmileyFontSize.getCellFont()
                switch indexPath.row {
                case 0:
                    content.image = UIImage(systemName: "ruler")
                case 3:
                    content.image = UIImage(systemName: "calendar")
                case 4:
                    content.image = UIImage(systemName: "camera.filters")
//                case 4:
//                    content.image = UIImage(systemName: "moonphase.first.quarter")
                default:
                    break
                }
//                content.image = UIImage(systemName: "link.circle")
                content.imageProperties.tintColor = ColorUtil.getBarBtnColor()
                cell.contentConfiguration = content
//                content.image
            }
            return cell
        }
        
        else if indexPath.section == 2{
            let cell = tableView.dequeueReusableCell(withIdentifier: runCellID, for: indexPath)
            // cell.backgroundColor = ColorUtil.getCellBackgroundColorStyle()
            var content = cell.defaultContentConfiguration()
            content.text = self.totalInfoListToShow[2][indexPath.row]
//            if UserDefaults.standard.bool(forKey: "useSmiley") {
//                content.textProperties.font = SmileyFontSize.getNormal()
//            }
//            content.textProperties.font = SmileyFontSize.getCellFont()
            
            switch indexPath.row {
            case 0:
                content.image = UIImage(systemName: "figure.run.circle")
            case 1:
                content.image = UIImage(systemName: "heart")
            case 2:
                content.image = UIImage(systemName: "checklist")
                break
            default:
                content.image = UIImage(systemName: "lock.shield")

            }
            content.imageProperties.tintColor = ColorUtil.getBarBtnColor()
            cell.contentConfiguration = content
            return cell
        }
        
        else if indexPath.section == 3{
            let cell = tableView.dequeueReusableCell(withIdentifier: dataCellID, for: indexPath)
            // cell.backgroundColor = ColorUtil.getCellBackgroundColorStyle()
            var content = cell.defaultContentConfiguration()
            content.text = self.totalInfoListToShow[3][indexPath.row]
//            if UserDefaults.standard.bool(forKey: "useSmiley") {
//                content.textProperties.font = SmileyFontSize.getNormal()
//            }
//            content.textProperties.font = SmileyFontSize.getCellFont()
            
            switch indexPath.row {
            case 0:
//                content.image = UIImage(named: "data-protection")
                content.image = UIImage(systemName: "figure.walk.circle")
                content.imageProperties.tintColor = ColorUtil.getBarBtnColor()
            case 1:
//                content.image = UIImage(named: "privacy")
                content.image = UIImage(systemName: "chart.bar")
                content.imageProperties.tintColor = ColorUtil.getBarBtnColor()
            default:
//                content.image = UIImage(named: "theRuler")
                content.image = UIImage(systemName: "lock.shield")
                content.imageProperties.tintColor = ColorUtil.getBarBtnColor()
            }
            

            
            cell.contentConfiguration = content
            return cell
        }
        else if indexPath.section == 4{
            let cell = tableView.dequeueReusableCell(withIdentifier: otherCellID, for: indexPath)
            // cell.backgroundColor = ColorUtil.getCellBackgroundColorStyle()
            var content = cell.defaultContentConfiguration()
            content.text = self.totalInfoListToShow[4][indexPath.row]
//            content.textProperties.font = SmileyFontSize.getCellFont()

            switch indexPath.row {
            case 0:
//                content.image = UIImage(named: "aboutUs")
                content.image = UIImage(systemName: "person.2")
                content.imageProperties.tintColor = ColorUtil.getBarBtnColor()
            default:
//                content.image = UIImage(named: "aboutUs")
                content.image = UIImage(systemName: "person.2")
                content.imageProperties.tintColor = ColorUtil.getBarBtnColor()
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
    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 55
//    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.totalInfoListToShow[section].count
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }


    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // MARK: - Section 0 个人信息
        
        if indexPath.section == 0 {
            let storyboard = UIStoryboard(name: "Assistant", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "AboutYouVC") as! AboutYouVC
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
        
        else if indexPath.section == 1 {
            
            switch indexPath.row {
            case 0:
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "GeneralDetailTable") as! GeneralDetailTable
                
                vc.typeID = 1
                vc.viewTitle = self.generalInfoList[indexPath.row]
                vc.viewChoices = self.generalChoicesList[indexPath.row]
//                self.present(vc, animated: true)
                self.navigationController?.pushViewController(vc, animated: true)
                
            case 3:
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "GeneralDetailTable") as! GeneralDetailTable
                vc.typeID = 3
                vc.viewTitle = self.generalInfoList[indexPath.row]
                
                // 加载需要展示的内容(选项)
                let plistURL = Bundle.main.url(forResource: "SettingItems", withExtension: "plist")
                
                do {
                    let data = try Data(contentsOf: plistURL!)
                    let plistData = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
                    let dataDictionary = plistData as! [String: Any]
                    vc.viewChoices = dataDictionary["generalWeekList"]! as! [String]
                }catch{}
                
//                self.present(vc, animated: true)
                self.navigationController?.pushViewController(vc, animated: true)
            case 4:

                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "GeneralDetailTable") as! GeneralDetailTable
                vc.typeID = 4
                vc.viewTitle = self.generalInfoList[indexPath.row]

                // 加载需要展示的内容(选项)
                let plistURL = Bundle.main.url(forResource: "SettingItems", withExtension: "plist")

                do {
                    let data = try Data(contentsOf: plistURL!)
                    let plistData = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
                    let dataDictionary = plistData as! [String: Any]
                    vc.viewChoices = dataDictionary["TintColorSet"]! as! [String]
//                    self.present(vc, animated: true)
                    self.navigationController?.pushViewController(vc, animated: true)
//                    let nav = UINavigationController(rootViewController: vc)
//                    if let sheet = nav.sheetPresentationController {
//                        sheet.detents = [.medium()]
//                    }
//                    self.present(nav, animated: true)
//
                }catch{}
                
                
                
               
                
                
//                let sb = UIStoryboard(name: "Main", bundle: nil)
//                let vc = sb.instantiateViewController(withIdentifier: desStr)
//                let nav = UINavigationController(rootViewController: vc)
//                if let sheet = nav.sheetPresentationController {
//                    sheet.detents = [.medium()]
//                    //, .large()
//                }
//                present(nav, animated: true, completion: nil)
                

                
                
//                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                let vc = storyboard.instantiateViewController(withIdentifier: "GeneralDetailTable") as! GeneralDetailTable
//                vc.typeID = 4
//                vc.viewTitle = self.generalInfoList[indexPath.row]
//
//                // 加载需要展示的内容(选项)
//                let plistURL = Bundle.main.url(forResource: "SettingItems", withExtension: "plist")
//
//                do {
//                    let data = try Data(contentsOf: plistURL!)
//                    let plistData = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
//                    let dataDictionary = plistData as! [String: Any]
//                    vc.viewChoices = dataDictionary["AppAppearance"]! as! [String]
//                }catch{}
//
//                self.present(vc, animated: true)
            default:
                print()
            }
            

            
        }
        

        else if indexPath.section == 2 {
            switch indexPath.row {
            case 0:
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "GeneralDetailTable") as! GeneralDetailTable
                vc.typeID = 5
                vc.viewTitle = self.runPreferenceList[indexPath.row]
                do {
                    vc.viewChoices = self.runTypeList
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            case 1:
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "GeneralDetailTable") as! GeneralDetailTable
                vc.typeID = 6
                vc.viewTitle = self.runPreferenceList[indexPath.row]
                // 加载需要展示的内容(选项)
                let plistURL = Bundle.main.url(forResource: "SettingItems", withExtension: "plist")
                
                do {
                    let data = try Data(contentsOf: plistURL!)
                    let plistData = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
                    let dataDictionary = plistData as! [String: Any]
                    vc.viewChoices = dataDictionary["HRZoneArray"]! as! [String]
                    self.navigationController?.pushViewController(vc, animated: true)
                }catch{}
            case 2:
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "GeneralDetailTable") as! GeneralDetailTable
                vc.typeID = 7
                vc.viewTitle = self.runPreferenceList[indexPath.row]
                // 加载需要展示的内容(选项)
                let plistURL = Bundle.main.url(forResource: "SettingItems", withExtension: "plist")
                
                do {
                    let data = try Data(contentsOf: plistURL!)
                    let plistData = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
                    let dataDictionary = plistData as! [String: Any]
                    vc.viewChoices = dataDictionary["ComprehensiveArray"]! as! [String]
                    self.navigationController?.pushViewController(vc, animated: true)
                }catch{}
                
            default:
                break
            }
        }
            
        else if indexPath.section == 3 {
            // TODO: 提示同步健康数据
            var desStr = ""
            
            switch indexPath.row{
            case 0:
                desStr = "WorkouData"
                break
            case 1:
                // PersonalInfoTable
                desStr = "PersonalInfoTable"
                break
            case 2:
                desStr = "PrivacyPolicy"
                break
            default:
                break
            }
            
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: desStr)
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
        
        else if indexPath.section == 4{
            var desStr = ""
            
            switch indexPath.row{
            case 0:
                desStr = "ContactUS"
                break
            default:
                break
            }
            
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: desStr)
            let nav = UINavigationController(rootViewController: vc)
            if let sheet = nav.sheetPresentationController {
                sheet.detents = [.medium()]
                //, .large()
                sheet.prefersGrabberVisible = true
            }
            present(nav, animated: true, completion: nil)
            
//            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        else{
            
        }
        
        
    }
    
//    private func presentModal() {
//        let detailViewController = DetailViewController()
//        let nav = UINavigationController(rootViewController: detailViewController)
//        // 1
//        nav.modalPresentationStyle = .pageSheet
//
//
//        // 2
//        if let sheet = nav.sheetPresentationController {
//
//            // 3
//            sheet.detents = [.medium(), .large()]
//
//        }
//        // 4
//        present(nav, animated: true, completion: nil)
//
//    }
//
    


}
