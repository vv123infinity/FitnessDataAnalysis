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
    
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        // 数据权限
        self.testDataAuth()
        // 配置
        self.setBasicInfo()
    }
    
    
    /// 设置基础的UI和配置信息
    func setBasicInfo() {
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
        return dataAuth ? 3 : 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return [1, 6, 2][section]
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
        if !self.dataAuth {
            if indexPath.row == 0 {
                content.text = NSLocalizedString("noDataHintText", comment: "")
                content.secondaryText = "🙁"
                content.secondaryTextProperties.alignment = .center
                content.secondaryTextProperties.font = UIFont.systemFont(ofSize: 40)
                self.footLabel.isHidden = false
                self.footLabel.text = NSLocalizedString("noDataHintFootLabel", comment: "")
                self.editBtn.isHidden = true
            }

        }
        // 可以成功访问数据
        else {
            if indexPath.section == 1 {
                content.text = "Test"
            }
            
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
