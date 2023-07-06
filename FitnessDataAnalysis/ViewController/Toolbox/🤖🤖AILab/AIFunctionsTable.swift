//
//  AIFunctionsTable.swift
//  FitnessDataAnalysis
//
//  Created by 十口V🌼 on 2023/3/31.
//

import UIKit

class AIFunctionsTable: UITableViewController {

    // MARK: - AI Function Table Cell
    
var cellName: [String] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getTitleOfTableCell()
        
        self.title = NSLocalizedString("AIFunctionTitle", comment: "")
        
        
        self.setUpUI()
        self.setBackItem()
        
    }

    
    /// 根据plist获取设置列表的sec标题和内容
    func getTitleOfTableCell() {
        let plistURL = Bundle.main.url(forResource: "ToolboxPlist", withExtension: "plist")
        // 设置各个var的值
        do {
            let data = try Data(contentsOf: plistURL!)
            let plistData = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
            let dataDictionary = plistData as! [String: Any]
            self.cellName = (dataDictionary["AIMotionLabArray"] as? [String])!
            
        }
        catch{
            
        }
        
    }
   
    
    
    func setUpUI(){
//        self.view.backgroundColor = ColorUtil.getBackgroundColorStyle1()
    }
    
    func setBackItem() {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        self.navigationItem.backBarButtonItem = backItem
        
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.cellName.count
    }
    
    


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "poseEstimationCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        
        content.textProperties.font = SmileyFontSize.getCellFont()
        content.text = self.cellName[indexPath.row]
        switch indexPath.row {
        case 0:
            content.image = UIImage(systemName: "figure.cross.training")
        case 1:
            content.image = UIImage(systemName: "figure.mixed.cardio")
            
        default:
            content.image = UIImage(systemName: "figure.mixed.cardio")
        }
        content.imageProperties.tintColor = ColorUtil.getBarBtnColor()
        cell.contentConfiguration = content
        return cell
    }

    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0{
            switch indexPath.row {
            case 0:
                let sb = UIStoryboard(name: "Main", bundle: nil)
                let vc = sb.instantiateViewController(withIdentifier: "SquatCounter")
                self.navigationController?.pushViewController(vc, animated: true)
            case 1:
                let sb = UIStoryboard(name: "Main", bundle: nil)
                let vc = sb.instantiateViewController(withIdentifier: "PoseMatching")
                self.navigationController?.pushViewController(vc, animated: true)
            default:
                let sb = UIStoryboard(name: "Main", bundle: nil)
                let vc = sb.instantiateViewController(withIdentifier: "PoseAnaTableViewController")
                self.navigationController?.pushViewController(vc, animated: true)
                break
            }
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
