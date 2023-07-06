//
//  AboutYouVC.swift
//  FitnessDataAnalysis
//
//  Created by Infinity vv123 on 2023/5/31.
//

import UIKit
import HealthKit
class AboutYouVC: UITableViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var sysnButton: UIButton!
    
    
    // MARK: - 属性
    /// 获取的用户信息的标题
    var userInfoArrayTitles: [String] = ["--","--","--"]
    /// 各个信息对应的LOGO
    var systemImgName: [String] = ["person.circle.fill", "figure.arms.open", "figure.arms.open"]
    /// 各个信息对应的LOGO的高亮色
    var systemImgColor: [UIColor] = [UIColor.gray, UIColor.systemPurple, UIColor.systemPurple]
    /// 具体数据
    lazy var userInfo: [String] = ["", "", ""]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "关于你"
        
        self.sysnUserInfo()
        self.getTitleOfTableCell()
        
        self.setUpUI()
    }

    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        // TODO: 修改信息
        return 3
    }

    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserInfoCellID", for: indexPath)

        var content = cell.defaultContentConfiguration()
        content.text = self.userInfoArrayTitles[indexPath.row]
        content.secondaryText = self.userInfo[indexPath.row]
        content.image = UIImage(systemName: self.systemImgName[indexPath.row])
        content.imageProperties.tintColor = self.systemImgColor[indexPath.row]
        cell.contentConfiguration = content
        
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2 {
            self.loadAllWeightData()
        }
    }
    

    @IBAction func sysnBtnPressed(_ sender: UIButton) {
        self.sysnUserInfo()
    }
    
    func sysnUserInfo(){
        self.loadAge()
        self.loadAndDisplayMostRecentHeight()
        self.tableView.reloadData()
    }
    
    func setUpUI(){
        self.sysnButton.tintColor = ColorUtil.getBarBtnColor()
    }
    
    // MARK: - 获取Plist
    /// 根据plist获取设置列表的sec标题和内容
    func getTitleOfTableCell() {
        let plistURL = Bundle.main.url(forResource: "SettingItems", withExtension: "plist")
        // 设置各个var的值
        do {
            let data = try Data(contentsOf: plistURL!)
            let plistData = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
            let dataDictionary = plistData as! [String: Any]
            //
            self.userInfoArrayTitles = dataDictionary["AboutYouArray"] as! [String]
        }
        catch{
            
        }
        
    }
    
    
    // MARK: - 获取最新的数据
    func loadAge() {
        let healthKitStore = HKHealthStore()
        do {
            
            //1. This method throws an error if these data are not available.
            do {
                let birthdayComponents = try healthKitStore.dateOfBirthComponents()
                //2. Use Calendar to calculate age.
                let today = Date()
                let calendar = Calendar.current
                let todayDateComponents = calendar.dateComponents([.year],
                                                                    from: today)
                let thisYear = todayDateComponents.year!
                let age = thisYear - birthdayComponents.year!
                self.userInfo[0] = "\(age)"
                self.tableView.reloadData()
            }catch {
                
            }
            

        }
    }
    
    func loadAndDisplayMostRecentHeight(){
        let healthKitStore = HKHealthStore()
        do {
            //1. Use HealthKit to create the Height Sample Type
            guard let heightSampleType = HKSampleType.quantityType(forIdentifier: .height) else {
              print("Height Sample Type is no longer available in HealthKit")
              return
            }
                
            GetBodyData.getMostRecentSample(for: heightSampleType) { (sample, error) in
                  
              guard let sample = sample else {
                  
                if let error = error {
                    
                }
                    
                return
              }
                  
              //2. Convert the height sample to meters, save to the profile model,
              //   and update the user interface.
                let heightInMeters = sample.quantity.doubleValue(for: HKUnit.meter())
                
                self.userInfo[1] = "\(heightInMeters*100)厘米"
                self.tableView.reloadData()
            }
            
            guard let weightSampleType = HKSampleType.quantityType(forIdentifier: .bodyMass) else {
              print("Body Mass Sample Type is no longer available in HealthKit")
              return
            }
                
            GetBodyData.getMostRecentSample(for: weightSampleType) { (sample, error) in
                  
              guard let sample = sample else {
                    
                if let error = error {
                }
                return
              }
                  
              let weightInKilograms = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
//                self.weight = "\(weightInKilograms)"
                self.userInfo[2] = "\(weightInKilograms)千克"
                self.tableView.reloadData()
            }
        }


    }
    
    
    func loadAllWeightData() {
        let healthKitStore = HKHealthStore()
        do {
            guard let weightSampleType = HKSampleType.quantityType(forIdentifier: .bodyMass) else {
              print("Body Mass Sample Type is no longer available in HealthKit")
              return
            }
                
            GetBodyData.getAllSample(for: weightSampleType) { (sample, error) in
                if let error = error {
                    return
                }
 
                
                if sample.count > 0 {
                    for s in sample{
//                        print("StartDate, ")
//                        print("\(s?.startDate)")
                        let weightInKilograms = s!.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
                        
                    }
                    
                }
                  

                  
                

                
                
            }
            
            
        }
    }
    
    
}
