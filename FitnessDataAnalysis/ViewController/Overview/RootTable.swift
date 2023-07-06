//
//  RootTable.swift
//  FitnessDataAnalysis
//
//  Created by Infinity vv123 on 2023/6/28.
//

import UIKit

class RootTable: UITableViewController {

    // MARK: - Outlets
    /// 右上角的编辑按钮
    @IBOutlet weak var editBtn: UIBarButtonItem!
    /// 页面最底部的提示信息
    @IBOutlet weak var footLabel: UILabel!
    
    
    // MARK: - properties
    /// 各个Table的ID
    var cellSecID = ["sec1", "sec2", "sec3"]
    /// 是否可以访问用户健康数据且数据数量不为0
    var dataAuth: Bool = false
    /// 第二个section的列表内容
    var sec2Content: [String] = []
    /// 第二个section项目的logo
    var sec2LogoName: [String] = []
    
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        // 数据权限
        self.testDataAuth()
        // 加载plist内容
        self.getPlistContent()
        // 配置
        self.setBasicInfo()
    }
    
    
    /// 设置基础的UI和配置信息
    func setBasicInfo() {
        // 高亮颜色
        self.editBtn.tintColor = ColorUtil.getBarBtnColor()

    }
    
    /// 尝试是否可以访问用户健康数据
    func testDataAuth() {
        WorkoutDataStore.loadLastWorkouts() { (res, error) in
            // 可以成功访问Workout类型的数据
            if res != nil && res!.count != 0 && error == nil{
                self.dataAuth = true
            }
            else {
                self.dataAuth = false
            }
            
            if self.dataAuth {
                self.tableView.reloadData()
            }
            
        }
        
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        // TODO: 取消注释
//        return dataAuth ? 3 : 1
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return [1, self.sec2Content.count, 2][section]
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section{
        case 0:
            return 150
        case 1:
            return 50
        case 2:
            return 100
        default:
            return 50
        }

    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        

        
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellSecID[indexPath.section], for: indexPath)
        var content = cell.defaultContentConfiguration()
        
        // 未获取数据/数据量为0
        // TODO: - 取消注释这个if !self.dataAuth 和else的注释
//        if !self.dataAuth {
            if indexPath.row == 0 && indexPath.section == 0 {
                content.text = NSLocalizedString("noDataHintText", comment: "")
                content.secondaryText = "🙁"
                content.secondaryTextProperties.alignment = .center
                content.secondaryTextProperties.font = UIFont.systemFont(ofSize: 40)
                self.footLabel.isHidden = false
                self.footLabel.text = NSLocalizedString("noDataHintFootLabel", comment: "")
                self.editBtn.isHidden = true
            }

//        }
        // 可以成功访问数据
//        else {
            if indexPath.section == 1 {
                // 显示文本
                content.text = self.sec2Content[indexPath.row]
                content.image = UIImage(systemName: self.sec2LogoName[indexPath.row])
                content.imageProperties.tintColor = UIColor.blue
            }
            
//        }
        
        
        cell.contentConfiguration = content
        return cell
    }

    /// 获取overviewItem.plist的内容
    func getPlistContent() {
        let plistURL = Bundle.main.url(forResource: "overviewItem", withExtension: "plist")
        // 设置各个var的值
        do {
            let data = try Data(contentsOf: plistURL!)
            let plistData = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
            let dataDictionary = plistData as! [String: Any]
            // sec2的各个列表名称
            let sec2List = dataDictionary["sec2Array"]! as! [String]
            self.sec2Content = sec2List
            self.sec2LogoName = dataDictionary["sec2LogoName"]! as! [String]
        }
        catch{
            
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
