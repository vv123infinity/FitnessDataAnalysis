//
//  GeneralDetailTable.swift
//  FitnessDataAnalysis
//
//  Created by Infinity vv123 on 2023/3/5.
//

import UIKit

class GeneralDetailTable: UITableViewController {

//    @IBOutlet weak var doneBarBtn: UIBarButtonItem!
    
    
    // MARK: - 属性
    // 定义好根据Table的选择展现的信息
    
    /// 0表示语言设置，1测量单位，2外观
    var typeID: Int = 0
    /// Nav标题
    var viewTitle: String = ""
    /// 要展现的属性的选项
    var viewChoices: [String] = []
    
    // 此 Table 的Cell ID
    private var cellIdentifier = "userSelect"
    
    var inputUnit: Int = -1
    var finalUnit: Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backItem = UIBarButtonItem()
        backItem.title = ""
        self.navigationItem.backBarButtonItem = backItem // This will
        self.title = self.viewTitle
        self.setUpUI()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        

        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.inputUnit = UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit")
        tableView.reloadData()

        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.finalUnit = UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit")
        if inputUnit != finalUnit {
            UserDefaults.standard.setValue(true, forKey: "UnitHasChanged")
        }
    }
    
    
    func setUpUI(){
//        self.setUpNav()
        if UserDefaults.standard.bool(forKey: "useSmiley"){
            self.setUpFontSmiley()
        }
        
        self.tableViewUI()
//        self.doneBarBtn.tintColor = ColorUtil.getBarBtnColor()
    }
    
    
    func setUpFontSmiley() {
        
        
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
                UserDefaults.standard.set("Mile", forKey: "distanceUnitDefaultAb")
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
            UserDefaults.standard.set(indexPath.row, forKey: "appAppearance")
            if indexPath.row == UserDefaults.standard.integer(forKey: "appAppearance") {
                cell.accessoryType = .checkmark
            }
            else{
                cell.accessoryType = .none
            }
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
            if indexPath.row == UserDefaults.standard.integer(forKey: "appAppearance") {
                cell.accessoryType = .checkmark
            }
            else{
                cell.accessoryType = .none
            }
            //         UserDefaults.standard.set(0, forKey: "appAppearance")
            
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
