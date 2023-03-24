//
//  TestUnit.swift
//  FitnessDataAnalysis
//
//  Created by 十口V🌼 on 2023/3/3.
//

import UIKit

class TestUnit: UIViewController {

    
    @IBOutlet var unitButtons: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // 最近24个月的记录
        /*
        WorkoutDataStore.loadWorkouts() { (workouts, error) in
            // 得到距离，单位米
            let dInMeter = QueryWorkoutsAssistant.queryRecentXMonRunningDistance(workouts!, 24)
            // 用户偏好的距离单位
            let defaultUnit = UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit")
            // 转换单位 & 保留两位小数
            let res = dInMeter.map{
                return AssistantMethods.convertMeterToUnit(defaultUnit, $0)
            }
            print(res)
        }
        */
        
        WorkoutDataStore.loadWorkoutsPastToNow() { (workouts, error) in
            // 得到距离，单位米
            let res = QueryWorkoutsAssistant.getWorkoutsDistanceAndDate(workouts!, "yyyy-MM-dd")
            IOHelperMethods.writeToCSV(res.workoutDate, res.dist)
            
            print(res.workoutDate[0])
            print(res.dist[0])
            
            print(res.workoutDate.last!)
            print(res.dist.last!)
            
        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    @IBAction func unitBtnPressed(_ sender: UIButton) {
        if sender == self.unitButtons[0] {
            print("千米")
            UserDefaults.standard.set(UserPreferenceSetting.RunningDistanceUnit.km.rawValue, forKey: "UserRunningDistanceUnit")
            UserDefaults.standard.set("KM", forKey: "distanceUnitDefaultAb")
        }
        else if sender == self.unitButtons[1] {
            print("Mile")
            UserDefaults.standard.set(UserPreferenceSetting.RunningDistanceUnit.mile.rawValue, forKey: "UserRunningDistanceUnit")
            UserDefaults.standard.set("Mile", forKey: "distanceUnitDefaultAb")
        }
        else if sender == self.unitButtons[2] {
            print("米")
            UserDefaults.standard.set(UserPreferenceSetting.RunningDistanceUnit.meter.rawValue, forKey: "UserRunningDistanceUnit")
            UserDefaults.standard.set("M", forKey: "distanceUnitDefaultAb")
        }
        else {
            
        }
        
    }
    

}
