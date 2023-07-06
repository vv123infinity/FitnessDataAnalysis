//
//  PoseAnaTableViewController.swift
//  FitnessWithML
//
//  Created by Infinity vv123 on 2022/10/23.
//

import UIKit
import CoreData
class PoseAnaTableViewController: UITableViewController {
    @IBOutlet weak var hintLabel: UILabel!
    
    var poseManagedContext: NSManagedObjectContext!
    var totalCount: Int = 0
//    var lastPoseReportTitle: String!
    var lastPoseReportDate: String!
    var lastPosePosition: String!
    var lastLevelArr: [Int] = []
//    var historyRecordTitleArray: [String] = []
    var historyRecordDateArray: [String] = []
    var historyRecordPosePositionArray: [String] = []
    
    
    
    // MARK: - Properties
    lazy var historyRecordTitle: [String] = ["Hist Record 0", "Hist Record 1", "Hist Record 2",
                                        "Hist Record 3", "Hist Record 4", "Hist Record 5"]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = ColorUtil.getBarBtnColor()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        poseManagedContext = appDelegate!.persistentContainer.viewContext
        
        refreshControl = UIRefreshControl()
        fetchCount()
        refreshControl!.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl!.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl!) // not required when
        tableView.reloadData()
        
        self.tableView.sectionHeaderTopPadding = 20
        UserDefaults.standard.set(50, forKey: "weight")
        UserDefaults.standard.set(168, forKey: "height")
//        let defaults = UserDefaults.standard
//        if (defaults.integer(forKey: "height") == 0) {
//            let alert = UIAlertController(title: "Please enter your height in the settings", message: "We need your height data to improve the quality of sampling", preferredStyle: .alert)
//            let action = UIAlertAction(title: "OK", style: .default)
//            alert.addAction(action)
//            present(alert, animated: true)
//        }
    }
    
    func fetchLastResults() {
        let fetchRequest3: NSFetchRequest<PoseCapture> = PoseCapture.fetchRequest()
        fetchRequest3.sortDescriptors = [NSSortDescriptor(key: "captureDate", ascending: false)]
        do{
            let result = try poseManagedContext.fetch(fetchRequest3)
            if result.count > 0 {
                let lastRes = result.first
                self.lastPoseReportDate = lastRes?.captureDate!.getFormattedDate(format: "yyyy-MM-dd")
                self.lastPosePosition = lastRes?.standingPosition
                if self.lastPosePosition == "side" {
                    var tempArr: [Int] = []
                    tempArr.append(Int((lastRes?.genSideEvaluation?.neckForwardTiltLevel)!))
                    tempArr.append(Int((lastRes?.genSideEvaluation?.anteriorPelvicTiltLevel)!))
                    tempArr.append(Int((lastRes?.genSideEvaluation?.hunchbackLevel)!))
                    lastLevelArr = tempArr
                    if result.count > 1 {
                        for i in 0..<result.count {
                            if i >= 1 {
                                self.historyRecordDateArray.append((result[i].captureDate!.getFormattedDate(format: "yyyy-MM-dd")))
                                self.historyRecordPosePositionArray.append((result[i].standingPosition)!)
                            }
                        }
                        
                    }
                }
                


            }
            totalCount = result.count
            
        }catch{}
    }

    
    func fetchCount(){
        let fetchRequest3: NSFetchRequest<PoseCapture> = PoseCapture.fetchRequest()
        do{
            let result = try poseManagedContext.fetch(fetchRequest3)
            totalCount = result.count
            refreshControl!.endRefreshing()
//            DispatchQueue.main.async {
//                self.tableView.refreshControl?.endRefreshing()
//                self.tableView.reloadData()
//            }
            
        }catch{}

    }
    @objc func refresh(_ sender: AnyObject) {
       // Code to refresh table view
        fetchCount()
    }
    
    
    @objc func callPullToRefresh(){
        fetchCount()
        
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        fetchCount()
        if totalCount > 1 {
            return 2
        }
        if totalCount == 0 {
            return 0
        }
        if totalCount == 1 {
            return 1
        }
        return 0
    }
    
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Latest Poseture Analysis Report"
        }
        else if section == 1 {
            return "History Record"
        }
        else {
            return ""
        }
    }
    
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        fetchCount()
        if section == 0 {
            if totalCount > 0{
                return 1
            }
            else{
                return 0
            }

        }
        else if section == 1 {
            return totalCount -  1
        }
        else {
            return 0
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is LastReportTableViewController {
            let vc = segue.destination as? LastReportTableViewController
            // "label" and "friends" are part of destinationVC
            vc?.finalScorePercentage = getTotalScore(lastLevelArr)
            vc?.personTowardDir = lastPosePosition == "side" ? "S" : "F"
        }}
    
        
    func getTotalScore(_ levelArr: [Int]) -> String {
        var sum = 100
        for l in levelArr {
            sum -= l
        }
        return "\(sum)%"
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        fetchLastResults()
        
        
        if indexPath.section == 0{
            // 最新的报告板块
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "PoseAnalysisReportIdentifier", for: indexPath)
            
            var content = cell.defaultContentConfiguration()
            content.text = "Latest Pose Report"
            content.secondaryText = lastPoseReportDate
            
            content.textProperties.font = UIFont.boldSystemFont(ofSize: 14)
            content.textProperties.color = ColorUtil.getBarBtnColor()
            
            //ColorUtil.dynamicColor(dark: UIColor.init(red: 255/255.0, green: 255/255.0, blue: 204/255.0, alpha: 1), light: UIColor.init(red: 218/255.0, green: 165/255.0, blue: 32/255.0, alpha: 1))
            
            
            cell.contentConfiguration = content
            
            cell.backgroundColor = ColorUtil.dynamicColor(
                dark: UIColor.init(red: 184/255.0, green: 134/255.0, blue: 11/255.0, alpha: 1),
                light:UIColor.init(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1)
//                    UIColor.init(red: 240/255.0, green: 230/255.0, blue: 140/255.0, alpha: 0.3)
                                                          )
            return cell
        }
        else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PoseAnalysisHistReportIdentifier", for: indexPath)
            var content = cell.defaultContentConfiguration()
            // Lateral posture analysis

                // self.historyRecordDateArray[indexPath.row]
//                content.secondaryText = "???"
            if self.historyRecordPosePositionArray[indexPath.row] == "side" {
                content.text = "Lateral posture analysis"
            }
            else {
                content.text = "Forward posture analysis"
            }
            
            content.secondaryText = self.historyRecordPosePositionArray[indexPath.row]
            cell.contentConfiguration = content

            return cell
            
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
            return cell
        }

    }

}
