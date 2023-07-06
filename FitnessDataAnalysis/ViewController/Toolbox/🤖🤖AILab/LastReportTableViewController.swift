//
//  LastReportTableViewController.swift
//  FitnessWithML
//
//  Created by Infinity vv123 on 2022/10/28.
//

import UIKit
import CoreData

class LastReportTableViewController: UITableViewController {
    
    @IBOutlet var imgView: [UIImageView]!
    @IBOutlet var imgUIView: [UIView]!
    @IBOutlet weak var finalScoreLabel: UILabel!
    @IBOutlet weak var standingPosLabel: UILabel!
    
    
    // MARK: - 传递的参数
    var personTowardDir: String!
    var finalScorePercentage: String!
    
    var hunchbackCell: Bool = false
    var anteriorPelvicTiltCell: Bool = false
    var forwardTiltoftheNeckCell: Bool = false
    
    var vcPassesTitle:String!
    var vcTipsTitle: [String?]!
    var vcInfoText: [String?]!
    var vcSubTitle: String!
    

    
    
    
    // MARK: - Core Data related properties
    var poseManagedContext: NSManagedObjectContext!
    
    
    
    // MARK: - Properties
    var normalItemArrNum = 0
    var slightItemArrNum = 0
    var moderateItemArrNum = 0
    var severeItemArrNum = 0
    var capturedDate: String!
    var standingPos: String!
    var allLevelTitle: [[String]] = []
    var allPoseMistakesTitleToInfo: [[String: String]] = []
    lazy var poseMisInfo: [String: String] = ["Forward Tilt of the Neck": "A abnormal posture where the head is positioned with ears in front of your body's vertical midline.",
                                              "Anterior Pelvic Tilt": "An anterior pelvic tilt is when your pelvis is rotated forward, which forces your spine to curve.",
                                              "Hunchback": "A back deformed by a sharp forward angle, forming a hump, typically caused by collapse of a vertebra.",
                                              "High and Low Shoulders": "High and Low Shoulders",
                                              "Bow-leggedness": "Bow-leggedness",
                                              "Knock Knees": "Knock Knees"
    ]
    var n = 0
    var validLevel: [Int] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        theUISettings()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        poseManagedContext = appDelegate!.persistentContainer.viewContext
        
        self.navigationController?.navigationBar.tintColor = ColorUtil.getBarBtnColor()
        
        self.tableView.sectionHeaderTopPadding = 20
        self.tableView.sectionFooterHeight = 30
        allLevelTitle = fetchLastPoseData()
        self.title = capturedDate
        normalItemArrNum = allLevelTitle[0].count
        slightItemArrNum = allLevelTitle[1].count
        moderateItemArrNum = allLevelTitle[2].count
        severeItemArrNum = allLevelTitle[3].count
        if severeItemArrNum != 0{
            n+=1
            validLevel.append(3)
        }
        if moderateItemArrNum != 0{
            n+=1
            validLevel.append(2)
        }
        if slightItemArrNum != 0 {
            n+=1
            validLevel.append(1)
        }
        if normalItemArrNum != 0 {
            n+=1
            validLevel.append(0)
        }



        
    }
    
    func theUISettings() {
        for img in imgView{
            img.layer.cornerRadius = 10
        }
        
        for item in imgUIView {
            item.layer.cornerRadius = 10
        }
        
        self.standingPosLabel.text = self.personTowardDir
        self.finalScoreLabel.text = self.finalScorePercentage
    }
    

    
    func fetchLastPoseData() -> [[String]] {
        var allLevelItemTitle:[[String]] = [[], [], [], []]  // level 0, 1, 2, 3
        
        let fetchRequest3: NSFetchRequest<PoseCapture> = PoseCapture.fetchRequest()
        do {
            fetchRequest3.sortDescriptors = [NSSortDescriptor(key: "captureDate", ascending: false)]
            fetchRequest3.fetchLimit = 1
            let result = try poseManagedContext.fetch(fetchRequest3)
            if result.count > 0 {
                for res in result {
                    capturedDate = res.captureDate!.getFormattedDate(format: "yyyy-MM-dd")
                    standingPos = res.standingPosition!
                    let ch = standingPosLabel.text
                    if ch == "S" {
                        let currSideEval = res.genSideEvaluation
                        let nLevel = (currSideEval?.neckForwardTiltLevel)!
                        allLevelItemTitle[Int(nLevel)].append("Forward Tilt of the Neck")
                        let anteriorTiltLevel = (currSideEval?.anteriorPelvicTiltLevel)!
                        allLevelItemTitle[Int(anteriorTiltLevel)].append("Anterior Pelvic Tilt")
                        let hunchLevel = (currSideEval?.hunchbackLevel)!
                        allLevelItemTitle[Int(hunchLevel)].append("Hunchback")
                    }
                    else {
                        let currFrontEval = res.genFrontEvaluation
                        let shoudersLevel = (currFrontEval?.highLowShouldersLevel)!
                        // Bow-leggedness
                        let bowLeggednessLevel = (currFrontEval?.bowLeggedness)!
                        let knockKneesLevel = (currFrontEval?.knockKnees)!
                        allLevelItemTitle[Int(shoudersLevel)].append("High and Low Shoulders")
                        allLevelItemTitle[Int(bowLeggednessLevel)].append("Bow-leggedness")
                        allLevelItemTitle[Int(knockKneesLevel)].append("Knock Knees")
                        
                    }
                

                }
            }

        }catch{
            
        }
        return allLevelItemTitle
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is AdviceViewController{
            let vc = segue.destination as? AdviceViewController
            
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return n
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if n == 0{
            return 0
        }
        else {
            for i in 0..<n{
                if section == i {
                    let ll = validLevel[i]
                    switch ll {
                    case 3:
                        return allLevelTitle[3].count
                    case 2:
                        return allLevelTitle[2].count
                    case 1:
                        return allLevelTitle[1].count
                    case 0:
                        return allLevelTitle[0].count
                    default:
                        return 0
                    }
                }
            }
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? ReportTableViewCell
        if cell!.titleLabel.text == "Hunchback" {
            print("???")
            hunchbackCell = true
            self.vcPassesTitle = "Hunchback"
            self.vcSubTitle = "???"
            self.vcTipsTitle = ["✔︎ Squats", "✔︎ Kneeling Leg Lift with Back Stretch",
                                "✔︎ Plank", "✔︎ Hip Flexor Stretch"]
            self.vcInfoText = ["✔︎ Squats", "✔︎ Kneeling Leg Lift with Back Stretch",
                               "✔︎ Plank", "✔︎ Hip Flexor Stretch"]
//            prepare(for: UIStoryboardSegue, sender: Any?)
        }
        else if cell?.titleLabel.text == "Forward Tilt of the Neck" {
            forwardTiltoftheNeckCell = true
            self.vcPassesTitle = "Forward Tilt of the Neck"
            self.vcSubTitle = "???"
            self.vcTipsTitle = ["✔︎ Squats", "✔︎ Kneeling Leg Lift with Back Stretch",
                                "✔︎ Plank", "✔︎ Hip Flexor Stretch"]
            self.vcInfoText = ["✔︎ Squats", "✔︎ Kneeling Leg Lift with Back Stretch",
                               "✔︎ Plank", "✔︎ Hip Flexor Stretch"]
        }
        else if cell?.titleLabel.text == "Anterior Pelvic Tilt" {
            anteriorPelvicTiltCell = true
            self.vcPassesTitle = "Anterior Pelvic Tilt"
            self.vcSubTitle = "🌟🌟🌟"
            self.vcTipsTitle = ["✔︎ Squats", "✔︎ Kneeling Leg Lift with Back Stretch",
                                "✔︎ Plank", "✔︎ Hip Flexor Stretch"]
            self.vcInfoText = ["✔︎ Squats", "✔︎ Kneeling Leg Lift with Back Stretch",
                               "✔︎ Plank", "✔︎ Hip Flexor Stretch"]
        }
        else {
            
        }
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        
        if n == 0{
            return ""
        }
        else {
            for i in 0..<n{
                if section == i {
                    let ll = validLevel[i]
                    switch ll {
                    case 3:
                        return "Severe"
                    case 2:
                        return "Moderate"
                    case 1:
                        return "Sight"
                    case 0:
                        return "Normal"
                    default:
                        return ""
                    }
                }
            }
        }
        return ""
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
        
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        for i in 0..<n{
            if indexPath.section == i{
                let psMisLevel = validLevel[i]
                switch psMisLevel {
                case 3:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "SevereCellID", for: indexPath) as! ReportTableViewCell
                    cell.backgroundColor = ColorUtil.dynamicColor(dark: UIColor.init(red: 123/255.0, green: 67/255.0, blue: 41/255.0, alpha: 0.35), light:UIColor.init(red: 245/255.0, green: 134/255.0, blue: 83/255.0, alpha: 0.2))
                    if allLevelTitle[3].count > 0 {
                        cell.titleLabel.text = allLevelTitle[3][indexPath.row]
                        cell.textViewInfo.text = poseMisInfo[allLevelTitle[3][indexPath.row]]
                    }
                    
                    let neckEvalSeg = cell.poseMistakesSeg!
                    
                    neckEvalSeg.selectedSegmentIndex = 3
                    neckEvalSeg.selectedSegmentTintColor = ColorUtil.dynamicColor(dark: UIColor.init(red: 123/255.0, green: 67/255.0, blue: 41/255.0, alpha: 1), light:UIColor.init(red: 245/255.0, green: 134/255.0, blue: 83/255.0, alpha: 1))
                    return cell
                case 2:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ModerateCellID", for: indexPath) as! ReportTableViewCell
                    cell.backgroundColor = ColorUtil.dynamicColor(dark: UIColor.init(red: 85/255.0, green: 80/255.0, blue: 64/255.0, alpha: 0.4), light:UIColor.init(red: 245/255.0, green: 222/255.0, blue: 179/255.0, alpha: 0.35))
                    // 对应allTitle的2
                    if allLevelTitle[2].count > 0 {
                        cell.titleLabel.text = allLevelTitle[2][indexPath.row]
                        cell.textViewInfo.text = poseMisInfo[allLevelTitle[2][indexPath.row]]
//                        cell.infoLabel.text = allPoseMistakesTitleToInfo[2][cell.titleLabel.text!]
                    }

                    let neckEvalSeg = cell.poseMistakesSeg!
        
                    neckEvalSeg.selectedSegmentIndex = 2
                    neckEvalSeg.selectedSegmentTintColor = ColorUtil.dynamicColor(dark: UIColor.init(red: 85/255.0, green: 80/255.0, blue: 64/255.0, alpha: 1), light:UIColor.init(red: 255/255.0, green: 225/255.0, blue: 132/255.0, alpha: 1))
                    
                    return cell
                case 1:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "SlightCellID", for: indexPath) as! ReportTableViewCell
                    if allLevelTitle[1].count > 0 {
                        cell.titleLabel.text = allLevelTitle[1][indexPath.row]
                        cell.textViewInfo.text = poseMisInfo[allLevelTitle[1][indexPath.row]]
//                        cell.infoLabel.text = allPoseMistakesTitleToInfo[2][cell.titleLabel.text!]
                    }
                    
                    cell.backgroundColor = ColorUtil.dynamicColor(dark: UIColor.init(red: 128/255.0, green: 113/255.0, blue: 66/255.0, alpha: 0.2), light:UIColor.init(red: 245/255.0, green: 233/255.0, blue: 190/255.0, alpha: 0.2))
                    let neckEvalSeg = cell.poseMistakesSeg!
        
                    neckEvalSeg.selectedSegmentIndex = 1
                    neckEvalSeg.selectedSegmentTintColor = ColorUtil.dynamicColor(dark: UIColor.init(red: 128/255.0, green: 113/255.0, blue: 66/255.0, alpha: 1), light:UIColor.init(red: 245/255.0, green: 233/255.0, blue: 190/255.0, alpha: 1))
                
                    
                    return cell
                case 0:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "NormalCellID", for: indexPath) as! ReportTableViewCell
                    cell.backgroundColor = ColorUtil.dynamicColor(dark: UIColor.init(red: 123/255.0, green: 177/255.0, blue: 95/255.0, alpha: 0.2), light:UIColor.init(red: 201/255.0, green: 255/255.0, blue: 213/255.0, alpha: 0.2))
                    if allLevelTitle[0].count > 0 {
                        cell.titleLabel.text = allLevelTitle[0][indexPath.row]
                        cell.textViewInfo.text = poseMisInfo[allLevelTitle[0][indexPath.row]]
//                        cell.infoLabel.text = allPoseMistakesTitleToInfo[2][cell.titleLabel.text!]
                    }
                    
                    let neckEvalSeg = cell.poseMistakesSeg!
        
                    neckEvalSeg.selectedSegmentIndex = 0
                    neckEvalSeg.selectedSegmentTintColor = ColorUtil.dynamicColor(dark: UIColor.init(red: 123/255.0, green: 177/255.0, blue: 95/255.0, alpha: 1), light:UIColor.init(red: 201/255.0, green: 255/255.0, blue: 213/255.0, alpha: 1))
                    
                    return cell
                default:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "NormalCellID", for: indexPath) as! ReportTableViewCell
                    return cell
                }
            }
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "NormalCellID", for: indexPath) as! ReportTableViewCell
        return cell
    }
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SevereCellID", for: indexPath) as! ReportTableViewCell
            cell.backgroundColor = ColorUtil.dynamicColor(dark: UIColor.init(red: 123/255.0, green: 67/255.0, blue: 41/255.0, alpha: 0.2), light:UIColor.init(red: 245/255.0, green: 134/255.0, blue: 83/255.0, alpha: 0.2))
            let neckEvalSeg = cell.poseMistakesSeg!
            
            neckEvalSeg.selectedSegmentIndex = 3
            neckEvalSeg.selectedSegmentTintColor = ColorUtil.dynamicColor(dark: UIColor.init(red: 123/255.0, green: 67/255.0, blue: 41/255.0, alpha: 1), light:UIColor.init(red: 245/255.0, green: 134/255.0, blue: 83/255.0, alpha: 1))
            return cell
            
        }
        else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ModerateCellID", for: indexPath) as! ReportTableViewCell
            cell.backgroundColor = ColorUtil.dynamicColor(dark: UIColor.init(red: 85/255.0, green: 80/255.0, blue: 64/255.0, alpha: 0.2), light:UIColor.init(red: 255/255.0, green: 225/255.0, blue: 132/255.0, alpha: 0.2))
//            let neckEvalSeg = cell.poseMistakesSeg!
//
//            neckEvalSeg.selectedSegmentIndex = 2
//            neckEvalSeg.selectedSegmentTintColor = ColorUtil.dynamicColor(dark: UIColor.init(red: 85/255.0, green: 80/255.0, blue: 64/255.0, alpha: 1), light:UIColor.init(red: 255/255.0, green: 225/255.0, blue: 132/255.0, alpha: 1))
            
            return cell
        }
        else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SlightCellID", for: indexPath) as! ReportTableViewCell
            cell.backgroundColor = ColorUtil.dynamicColor(dark: UIColor.init(red: 128/255.0, green: 113/255.0, blue: 66/255.0, alpha: 0.2), light:UIColor.init(red: 245/255.0, green: 233/255.0, blue: 190/255.0, alpha: 0.2))
//            let neckEvalSeg = cell.poseMistakesSeg!
//
//            neckEvalSeg.selectedSegmentIndex = 1
//            neckEvalSeg.selectedSegmentTintColor = ColorUtil.dynamicColor(dark: UIColor.init(red: 128/255.0, green: 113/255.0, blue: 66/255.0, alpha: 1), light:UIColor.init(red: 245/255.0, green: 233/255.0, blue: 190/255.0, alpha: 1))
        
            
            return cell
        }
        else if indexPath.section == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NormalCellID", for: indexPath) as! ReportTableViewCell
            cell.backgroundColor = ColorUtil.dynamicColor(dark: UIColor.init(red: 123/255.0, green: 177/255.0, blue: 95/255.0, alpha: 0.2), light:UIColor.init(red: 201/255.0, green: 255/255.0, blue: 213/255.0, alpha: 0.2))
//            let neckEvalSeg = cell.poseMistakesSeg!
//
//            neckEvalSeg.selectedSegmentIndex = 0
//            neckEvalSeg.selectedSegmentTintColor = ColorUtil.dynamicColor(dark: UIColor.init(red: 123/255.0, green: 177/255.0, blue: 95/255.0, alpha: 1), light:UIColor.init(red: 201/255.0, green: 255/255.0, blue: 213/255.0, alpha: 1))
            
            return cell
        }
        
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! ReportTableViewCell

            return cell
        }
    }
*/
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
