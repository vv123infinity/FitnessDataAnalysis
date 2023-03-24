//
//  MonthlyStatMethods.swift
//  FitnessDataAnalysis
//
//  Created by 十口V🌼 on 2023/3/21.
//

import Foundation
import UIKit
import HealthKit

class MonthlyStatMethods {
    
    class func reserveSec(_ secs: Double) -> (secInInt: Int, carryMin: Int) {
        // Double -> Int
        var secInInt = Int(secs)
        let decimalPart = secs - Double(secInInt)
        if decimalPart >= 0.5 {
            secInInt += 1
        }
        if secInInt == 60{
            return (0, 1)
        }
        else{
            return (secInInt, 0)
        }
    }
    /// 配速 如 369s/KM -> X'Y''/KM
    class func convertPaceSecToMinSec(_ secs: Double) -> String {
        // 如359.678 s / KM
        // 5'
        var minPartInt = Int(secs/60)
        // 59.678
        let secPartDouble = secs - Double(minPartInt) * Double(60)
        // 60 -> 进位
        let res = reserveSec(secPartDouble)
        let secPartInt = res.secInInt
        minPartInt += res.carryMin
        // 将平均配速转换成用户可读的形式 如 5'58''/KM
        if UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit") == 0{
            return "\(minPartInt)\'\(secPartInt)\'\'/ " + NSLocalizedString("distanceUnitKM", comment: "")
        }
        else {
            return "\(minPartInt)'\(secPartInt)''/ " + NSLocalizedString("distanceUnitMile", comment: "")
        }
        
    }
    
    
    /// 计算累计跑步时间，输入workout
    /// 返回：
    /// ① 总里程
    /// ② 总时间
    /// ③ 平均配速
    /// ④ 跑步次数
    /// ⑤ 单次距离数组，用于制图
    class func calcIndicatorInUserUnit(_ workouts: [HKWorkout]) -> (accDistance: String, accTime: String, avgPace: String, numOfRuns: String, distanceArray: [Double], maxDistance: String, maxPace: String) {
        // 总时间
        var totalTimeInSec = 0.0
        // 配速数组
        var totalPaceInsec: [Double] = []
        // 总距离
        var totalDistanceInMeter: [Double] = []
        // 打卡日期数组
        var dateArray: [String] = []
        
        
        let runningType = HKQuantityType(.distanceWalkingRunning)
        let runningPower = HKQuantityType(.runningPower)
        
        
        for wk in workouts {
            // 总时间
            totalTimeInSec += wk.duration as Double
            // 当前距离——单位米
            guard let runningDistanceNewVersion = wk.statistics(for: runningType)?.sumQuantity()?.doubleValue(for: .meter()) else {
                return ("", "", "", "", [], "", "")
            }
            totalDistanceInMeter.append(runningDistanceNewVersion)
            
            // 打卡日期
            dateArray.append(AssistantMethods.getDateInFormatString(wk.startDate, "yyyy-MM-dd"))
            
            
            // 配速
            if UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit") == 0 {
                // 2 zhi
                let r = PaceCalculatorMethods.paceCalcMinSecAccurate(runningDistanceNewVersion, 2, wk.duration as Double, .toKM)
                totalPaceInsec.append(r)
            }
            else if UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit") == 1 {
                let r = PaceCalculatorMethods.paceCalcMinSecAccurate(runningDistanceNewVersion, 2, wk.duration as Double, .toMile)
                totalPaceInsec.append(r)

            }
            else{
                
            }
            
            // 步频
//            wk.statistics(for: <#T##HKQuantityType#>)
            
        }
        
        // 总距离返回
        // 用户偏好的距离单位
        let defaultUnit = UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit")
        
        // 转换单位 & 保留两位小数
        let distArray = totalDistanceInMeter.map{
            return AssistantMethods.convertMeterToUnit(defaultUnit, $0)
        }
        
        // 计算总距离 M
        let totalDistanceAccInMeter: Double = totalDistanceInMeter.reduce(0) { (r, n) in
            r + n
        }
        
        // 计算总距离 用户的单位
        let distanceInUserUnit = AssistantMethods.convertMeterToUnit(defaultUnit, totalDistanceAccInMeter)
        
        // MARK: 展示的总里程
        var totalDistanceToShow = ""
        if UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit") == 0{
            totalDistanceToShow = "\(distanceInUserUnit) " + NSLocalizedString("distanceUnitKM", comment: "")
        }
        else {
            totalDistanceToShow = "\(distanceInUserUnit) " + NSLocalizedString("distanceUnitMile", comment: "")
            
        }
        

        
        
        // MARK: 展示的总耗时
        let hours: Int = Int(totalTimeInSec/3600)
        let mins: Int = Int((totalTimeInSec - Double(hours) * 3600) / 60)
        let secs: Int = Int((totalTimeInSec - Double(hours) * 3600 - Double(mins) * 60))
        let totalTimeToShow = "\(hours):\(mins):\(secs)"
        
        // MARK: 展示的平均配速
        // 平均配速 = 1/m (时间/距离)
        /// 平均配速（单位秒）
        let avgPaceInSec = totalPaceInsec.reduce(0, +) / Double(totalPaceInsec.count)
        let avgPaceToShow = convertPaceSecToMinSec(avgPaceInSec)
        
        // MARK: 展示的跑步次数
        //
        let numOfRunsToShow = "\(dateArray.count)"
        
        
        // MARK: 展示的跑步最远距离
        let maxDistance: Double = distArray.max()!
        var maxDistanceToShow = String(format: "%.2f", maxDistance) + " "
        if UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit") == 0{
            maxDistanceToShow += NSLocalizedString("distanceUnitKM", comment: "")
        }
        else {
            maxDistanceToShow += NSLocalizedString("distanceUnitMile", comment: "")
            
        }
        
        
        // MARK: 展示的跑步最快跑步配速
        let maxPace: Double = totalPaceInsec.min()!
        let maxPaceToShow: String = convertPaceSecToMinSec(maxPace)
        
        return (totalDistanceToShow, totalTimeToShow, avgPaceToShow, numOfRunsToShow, distArray, maxDistanceToShow, maxPaceToShow)
        
                            
    }
    
    
    
    
}
