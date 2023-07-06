//
//  AbnormDetecion.swift
//  FitnessDataAnalysis
//
//  Created by Infinity vv123 on 2023/5/31.
//

import UIKit
import SigmaSwiftStatistics
import HealthKit

class AbnormDetecion: UIViewController {

    var aDetector: AnomalyDetector!
    /// 当前加载到的workouts
    var workouts: [HKWorkout] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let runningType = HKQuantityType(.distanceWalkingRunning)
        let runningPower = HKQuantityType(.runningPower)
        let runningSpeedType = HKQuantityType(.runningSpeed)
        let runningStrideLengthType = HKQuantityType(.runningStrideLength)
        // 速度＝步频×步幅
        let runStepCountType = HKQuantityType(.stepCount)
        let runHRType = HKQuantityType(.heartRate)
        let activeEnergyBurnedType = HKQuantityType(.activeEnergyBurned)
        let energyType = HKQuantityType(.dietaryEnergyConsumed)
        
        WorkoutDataStore.loadWorkouts() { [self] (res, error) in
            // 可以成功访问Workout类型的数据
            if res != nil && res!.count != 0 && error == nil{
                self.workouts = res!

                for wk in self.workouts {
                    // 0. 运动类型——跑步 略
                    
                    // 1. 日期
                    let date = AssistantMethods.getDateInFormatString(wk.startDate, "yyyy-MM-dd")
//                    print("\"\(date)\"", terminator: ", ")
                    
                    
                    // 2. 距离
                    let runningDistanceNewVersion = wk.statistics(for: runningType)?.sumQuantity()?.doubleValue(for: .meter())
                    
                    if let runningDistanceNewVersion = runningDistanceNewVersion {
//                        print("\(runningDistanceNewVersion)", terminator: ", ")
                    }
                    else {
//                        print("0", terminator: ", ")
                    }
                    
                    
                    // 3. 总时间
                    let duration = wk.duration as Double
//                    print("\(duration)", terminator: ", ")
                    // 4. 卡路里
                    if let activeEnergy = wk.totalEnergyBurned?.doubleValue(for: .kilocalorie()) {
//                        print("\(activeEnergy)", terminator: ", ")
                    }
                    else {
//                        print("0", terminator: ", ")
                    }
                    // 5. 平均心率
                    if let runAvgHR = wk.statistics(for: runHRType)?.averageQuantity()?.doubleValue(for: .count().unitDivided(by: .minute())) {
//                        print("\(runAvgHR)", terminator: ", ")
                    }
                    else {
//                        print("0", terminator: ", ")
                    }
                    // 6. 最大心率
                    if let runMaxHR = wk.statistics(for: runHRType)?.maximumQuantity()?.doubleValue(for: .count().unitDivided(by: .minute())) {
//                        print("\(runMaxHR)", terminator: ", ")
                    }                    else {
//                        print("0", terminator: ", ")
                    }
                    
                    // 7. 平均速度
                    if let runAvgSpeed = wk.statistics(for: runningSpeedType)?.averageQuantity()?.doubleValue(for: .meter().unitDivided(by: .minute())) {
//                        print("\(runAvgSpeed)", terminator: ", ")
                    }else{
//                        print("0", terminator: ", ")
                    }
                    
                    // 8. 最大速度
                    if let runMaxSpeed = wk.statistics(for: runningSpeedType)?.maximumQuantity()?.doubleValue(for: .meter().unitDivided(by: .minute())) {
//                        print("\(runMaxSpeed)", terminator: ", ")
                    }else{
//                        print("0", terminator: ", ")
                    }
                    
                    // 9. 平均步幅
                    if let runAvgStrideLength = wk.statistics(for: runningStrideLengthType)?.averageQuantity()?.doubleValue(for: .meter()) {
//                        print("\(runAvgStrideLength)", terminator: ", ")
                    }else{
//                        print("0", terminator: ", ")
                    }
                    // 10. 最大步幅
                    if let runMaxStrideLength = wk.statistics(for: runningStrideLengthType)?.maximumQuantity()?.doubleValue(for: .meter()) {
//                        print("\(runMaxStrideLength)", terminator: ", ")
                    }else{
//                        print("0", terminator: ", ")
                    }
                    
                    // 11. 跑步功率
                    if let runAvgPower = wk.statistics(for: runningPower)?.averageQuantity()?.doubleValue(for: .watt()) {
//                        print("\(runAvgPower)", terminator: ", ")
                    }else {
//                        print("0", terminator: ", ")
                    }
                     

                    
                    // 12. 跑步功率
                    if let runMaxPower = wk.statistics(for: runningPower)?.maximumQuantity()?.doubleValue(for: .watt()) {
                        print("\(runMaxPower)", terminator: ", ")
                    }else {
                        print("0", terminator: ", ")
                    }
                     
                    
//                    print("\n\n")
                }
            }
            
        }
        
//        let titles = ["日期", "距离", "时间", "卡路里", "平均心率", "最大心率", "平均配速"]
//        for tt in titles {
//            print("\(tt)", terminator: "|\t")
//        }
        
        
    }
    
    
    
    /*
     //        let x = getSeriesData1()
     //        let x: [Double] = [4.92, 5.14, 5.32, 5.25, 5.31, 5.44, 5.41, 5.29, 5.59, 5.42, 5.3, 5.31, 5.23, 5.69, 5.57, 5.55]
     //        let res = getDateAndData()
     //        self.aDetector = AnomalyDetector(inputDate: res.date, inputData: res.data, anomalyDetectionConfig: AnomalyDetectionConfig())
     //        let _ = self.aDetector.splitSeriesData()
             
             
     //        let x_future = getSeriesData2()
     //        self.test(x, x_future)
     */
    
    func test(_ input: [Double], _ test_x: [Double]){
        let mu = Sigma.average(input)
        let sigma = Sigma.standardDeviationSample(input)
        // 计算置信区间
        let leftVal = mu! - 3*sigma!
        let rightVal = mu! + 3*sigma!
        print("置信区间：[\(leftVal), \(rightVal)]")
        for x in test_x {
            if x>=leftVal && x<=rightVal {

            }
            else {
                print("\(x) 不在置信区间内！")
            }
        }
        
        
    }
    
    

}
