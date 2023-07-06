//
//  FetchRunningNotes.swift
//  FitnessDataAnalysis
//
//  Created by Infinity vv123 on 2023/3/25.
//

import UIKit
import CoreData


class FetchRunningNotes: UITableViewController {
    
    @IBOutlet weak var footnoteLabel: UILabel!
    
    
    var currentRunFeelingInstance: OneDayPlan!
    
    var managedObjectContext: NSManagedObjectContext!
    
    
    lazy var refreshControl_: UIRefreshControl? = {
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action:
                         #selector(FetchRunningNotes.handleRefresh(_:)),
                                     for: UIControl.Event.valueChanged)
            refreshControl.tintColor = UIColor.red
            
            return refreshControl
        }()
    
    
    /// 所有的instance
    var allInstanceFetched: [OneDayPlan]!
    /// fetch的所有跑步日期
    var allRunningDate: [Date] = []
    /// fetch的所有跑步notes
    var allRunningNotes: [String] = []
    /// fetch的所有跑步感受
    var allRunningFeeling: [Int] = []
    /// fetch的所有跑步距离
    var allRunningDistance: [Double] = []
    /// fetch的所有跑步距离单位
    var allRunningDistanceUnit: [Int] = []
    
    private let cellID = "Notes"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.addSubview(self.refreshControl_!)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        self.navigationItem.backBarButtonItem = backItem // This will
        self.setUpUI()
        
        self.loadData()


        
        
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
            
        self.loadData()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        refreshControl.endRefreshing()
        
    }
    
    
    func loadData() {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedObjectContext = appDelegate!.persistentContainer.viewContext

        let req: NSFetchRequest<OneDayPlan> = OneDayPlan.fetchRequest()
        
        self.allInstanceFetched = []
        let res = try! managedObjectContext.fetch(req)
        self.allInstanceFetched = res
        
        if res.count > 0 {
            self.allRunningDate = []
            self.allRunningFeeling = []
            self.allRunningDistance = []
            for rr in res {
                self.allRunningFeeling.append(Int(rr.feeling))
                if rr.runningDate == nil {
                    self.allRunningDate.append(Date())
                }
                else {
                    self.allRunningDate.append(rr.runningDate!)
                }
                self.allRunningDistance.append(rr.runningDistance)
                let unitInInt = rr.unitIsKM ? Int(0) : Int(1)
                self.allRunningDistanceUnit.append(unitInInt)
                
                
//                if rr.note == nil {
//                    self.allRunningNotes.append("\t")
//                }
//                else {
//                    self.allRunningNotes.append(rr.note!)
//                }
                
                
            }
            
            
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loadData()
        self.tableView.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.loadData()
//        self.tableView.reloadData()
    }
    
    
    func setUpUI() {
        self.setUpFont()
        
        self.footnoteLabel.text = "不管全世界所有人怎么说，我都认为自己的感受才是正确的。无论别人怎么看，我绝不打乱自己的节奏。喜欢的事自然可以坚持，不喜欢的怎么也长久不了。—— 村上春树 《当我谈跑步时，我在谈什么》"
        
        
    }
    func setUpFont() {
        if UserDefaults.standard.bool(forKey: "useSmiley") {
            self.footnoteLabel.font = SmileyFontSize.getFootnote()
        }
    }
    
    func getCurrentTimeStampWOMiliseconds(dateToConvert: NSDate) -> String {
        let objDateformat: DateFormatter = DateFormatter()
            objDateformat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let strTime: String = objDateformat.string(from: dateToConvert as Date)
        let objUTCDate: NSDate = objDateformat.date(from: strTime)! as NSDate
        let milliseconds: Int64 = Int64(objUTCDate.timeIntervalSince1970)
        let strTimeStamp: String = "\(milliseconds)"
        return strTimeStamp
        }
    
    
    
    @IBAction func addNoteBtnPressed(_ sender: UIBarButtonItem) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let noteVC = sb.instantiateViewController(withIdentifier: "RunFeeling") as! RunFeeling
        noteVC.typeID = 1
        noteVC.curDate = Date() // 默认今天
        self.present(noteVC, animated: true)
        
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
////        return ["🌟", "✅", "🚌"][section]
//        return "🏃🏃‍♀️"
//    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.allRunningDate.count
    }

//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 85
//    }
    
    
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.allInstanceFetched.count > 0 {
            let curInstance = self.allInstanceFetched[indexPath.row]
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let dstVC = sb.instantiateViewController(withIdentifier: "RunInfoDetails") as! RunInfoDetails
            
            dstVC.inputInstance = curInstance
            
            self.navigationController?.pushViewController(dstVC, animated: true)
        }
        
    }
    
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Notes", for: indexPath)
        var content = cell.defaultContentConfiguration()
        if UserDefaults.standard.bool(forKey: "useSmiley") {
            content.textProperties.font = SmileyFontSize.getNormal()
            content.secondaryTextProperties.font = SmileyFontSize.getFootnote()
        }
        
        content.secondaryTextProperties.color = UIColor.gray
        // 时间
        let timeDate = allRunningDate[indexPath.row]
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let timeInStr = df.string(from: timeDate)
        // 距离
        let distanceInUnit = self.allRunningDistanceUnit[indexPath.row]
        var distanceInStringWithUnit = ""
        if distanceInUnit == 0 {
            switch UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit") {
            case 0:
                let distance = AssistantMethods.convert(self.allRunningDistance[indexPath.row], maxDecimals: 2)
                distanceInStringWithUnit += "\(distance)" + " " + NSLocalizedString("distanceUnitKM", comment: "")
            case 1:
                let distanceInMI = AssistantMethods.distanceKMtoMile(self.allRunningDistance[indexPath.row])
                
                distanceInStringWithUnit += "\(distanceInMI)" + " " + NSLocalizedString("distanceUnitMile", comment: "")
            default:
                break
            }

        }
        else {
            
            switch UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit") {
            case 0:
                let distanceInKM = AssistantMethods.convert(AssistantMethods.distanceMileToKM(self.allRunningDistance[indexPath.row]), maxDecimals: 2)
                distanceInStringWithUnit += "\(distanceInKM)" + " " + NSLocalizedString("distanceUnitKM", comment: "")
            case 1:
                let distanceInMI = AssistantMethods.convert(self.allRunningDistance[indexPath.row], maxDecimals: 2)
                distanceInStringWithUnit += "\(distanceInMI)" + " " + NSLocalizedString("distanceUnitMile", comment: "")
            default:
                break
            }
            
            
        }
        
        
        content.text = distanceInStringWithUnit + GeneralMethods.getRunningFeelingEmoji(allRunningFeeling[indexPath.row])
        
        content.secondaryText = timeInStr
        //+ "\n" + self.allRunningNotes[indexPath.row]
        
        content.image = UIImage(systemName: "shoeprints.fill")
        content.imageProperties.tintColor = UIColor.label
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
