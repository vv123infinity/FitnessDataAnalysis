//
//  ToolBoxTable.swift
//  FitnessDataAnalysis
//
//  Created by 十口V🌼 on 2023/4/5.
//

import UIKit

class ToolBoxTable: UITableViewController {

    // MARK: - Properties
    var toolboxTitle: [String] = []
    var toolboxDetail: [String] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.setUpBackItem()
        self.getTitleOfTableCell()
    }
    
    /// 返回按钮无标题
    func setUpBackItem() {
        let bkItem = UIBarButtonItem()
        bkItem.title = ""
        self.navigationItem.backBarButtonItem = bkItem
    }

     /// 根据plist获取设置列表的sec标题和内容
     func getTitleOfTableCell() {
         let plistURL = Bundle.main.url(forResource: "ToolboxPlist", withExtension: "plist")
         // 设置各个var的值
         do {
             let data = try Data(contentsOf: plistURL!)
             let plistData = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
             let dataDictionary = plistData as! [String: Any]
             self.toolboxTitle = (dataDictionary["ToolListItemTitle"] as? [String])!
             self.toolboxDetail = (dataDictionary["ToolListItemDetail"] as? [String])!
         }
         catch{
             
         }
         
     }
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "toolboxID", for: indexPath)

        var content = cell.defaultContentConfiguration()
        // 字体
        content.textProperties.font = SmileyFontSize.getCellFont()
        content.secondaryTextProperties.font = SmileyFontSize.getCellFontSecond()
        // 文本
        content.text = self.toolboxTitle[indexPath.row]
        content.secondaryText = self.toolboxDetail[indexPath.row]
        
        // 图像
        switch indexPath.row{
        case 0:
            content.image = UIImage(systemName: "note.text")
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
        return 100
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        var vc: UIViewController!
        switch indexPath.row{
        case 0:
            vc = sb.instantiateViewController(withIdentifier: "PaceCalculator") as? PaceCalculator
            
        case 1:
            vc = sb.instantiateViewController(withIdentifier: "AIFunctionsTable") as? AIFunctionsTable

        default:
            break
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
