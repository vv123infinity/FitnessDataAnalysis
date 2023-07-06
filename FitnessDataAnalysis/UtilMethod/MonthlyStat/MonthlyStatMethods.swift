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
    
    /// 四舍五入
    class func rouding(_ input: Double) -> Double{
        let integarPart = Int(input)
        if input - Double(integarPart) >= 0.5 {
            return Double(integarPart) + Double(1.0)
        }
        else{
            return Double(integarPart)
        }
    }
    
    class func getDistAndDate(_ workouts: [HKWorkout]) -> (dist: [Double], dateInStr: [String]) {
        /// 总距离
        var totalDistanceInMeter: [Double] = []
        /// 打卡日期数组
        var dateArray: [String] = []
        let runningType = HKQuantityType(.distanceWalkingRunning)
        for wk in workouts {
            // 2. 当前距离——单位米
            let runningDistanceNewVersion = wk.statistics(for: runningType)?.sumQuantity()?.doubleValue(for: .meter())
            if let runningDistanceNewVersion = runningDistanceNewVersion {
                totalDistanceInMeter.append(runningDistanceNewVersion)
            }else{
                totalDistanceInMeter.append(0.0)
            }
            // 3. 打卡日期
            dateArray.append(AssistantMethods.getDateInFormatString(wk.startDate, "yyyy-MM-dd"))
            
        }
        // 用户偏好的距离单位
        let defaultUnit = UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit")
        
        // 转换单位 & 保留两位小数
        let distArray = totalDistanceInMeter.map{
            return AssistantMethods.convertMeterToUnit(defaultUnit, $0)
        }
        
        return (distArray, dateArray)
    }
    
    
    class func getHRAndDate(_ workouts: [HKWorkout]) -> (HR: [Double], dateInStr: [String]) {
        /// 心率
        var runningHRArray: [Double] = []
        var dateInStr: [String] = []
        let runHRType = HKQuantityType(.heartRate)
        
        for wk in workouts {
            guard let runAvgHR = wk.statistics(for: runHRType)?.averageQuantity()?.doubleValue(for: .count().unitDivided(by: .minute())) else {
                continue
            }
            
            if !runAvgHR.isNaN && !runAvgHR.isZero {
                runningHRArray.append(runAvgHR)
                dateInStr.append(AssistantMethods.getDateInFormatString(wk.startDate, "yyyy-MM-dd"))
            }
        }
        
        return (runningHRArray, dateInStr)
    }
    
    
    class func getPowerArrayAndDate(_ workouts: [HKWorkout]) -> (power: [Double], dateInStr: [String]) {
        /// 跑步功率
        var runningPowerArray: [Double] = []
        var dateInStr: [String] = []
        let runningPower = HKQuantityType(.runningPower)
        for wk in workouts {
            // 跑步功率 - 只需要平均的
            guard let runningPower = wk.statistics(for: runningPower)?.averageQuantity()?.doubleValue(for: .watt()) else {
                continue
            }
            if !runningPower.isNaN && !runningPower.isZero {
                runningPowerArray.append(runningPower)
                dateInStr.append(AssistantMethods.getDateInFormatString(wk.startDate, "yyyy-MM-dd"))
            }
        }
        
        return (runningPowerArray, dateInStr)
    }
    
    
    class func getCalorieArrayAndDate(_ workouts: [HKWorkout]) -> (calories: [Double], dateInStr: [String]) {
        /// 跑步能量
        var runningCalorieArray: [Double] = []
        var dateInStr: [String] = []
//        let activeEnergyBurnedType = HKQuantityType(.activeEnergyBurned)
        for wk in workouts {
            // 跑步能量 - 只需要平均的
            // Energy
            if let activeEnergy = wk.totalEnergyBurned?.doubleValue(for: .kilocalorie()) {
                runningCalorieArray.append(activeEnergy)
                dateInStr.append(AssistantMethods.getDateInFormatString(wk.startDate, "yyyy-MM-dd"))
            }


        }
        
        return (runningCalorieArray, dateInStr)
    }
    
    
    class func getCadenceArrayAndDate(_ workouts: [HKWorkout]) -> (cadence: [Double], dateInStr: [String]) {
        /// 跑步步频
        var runningCadenceArray: [Double] = []
        var dateInStr: [String] = []
        let runStepCountType = HKQuantityType(.stepCount)
        for wk in workouts {
           
            guard let runStepCount = wk.statistics(for: runStepCountType)?.sumQuantity()?.doubleValue(for: .count())else {
                continue
            }
            
            if !runStepCount.isNaN && !runStepCount.isZero {
                let cadence = (runStepCount / Double(wk.duration)) * Double(60)
                runningCadenceArray.append(rouding(cadence))
                dateInStr.append(AssistantMethods.getDateInFormatString(wk.startDate, "yyyy-MM-dd"))
            }

        }
        
        return (runningCadenceArray, dateInStr)
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
        let space = UserDefaults.standard.bool(forKey: "useSmiley") ? " " : " "
        if UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit") == 0{
            
            let resStr = "\(minPartInt)" + NSLocalizedString("paceMinUnit", comment: "") + space + "\(secPartInt)" + NSLocalizedString("paceSecUnit", comment: "") + "/" + NSLocalizedString("distanceUnitKM", comment: "")
            return resStr
        }
        else {
            let resStr = "\(minPartInt)" + NSLocalizedString("paceMinUnit", comment: "") + space + "\(secPartInt)" + NSLocalizedString("paceSecUnit", comment: "") + "/" + NSLocalizedString("distanceUnitMile", comment: "")
            return resStr
        }
        
    }
    
    /// 获取workout中的配速
    class func getPaceArrayAndDate(_ workouts: [HKWorkout]) -> (pace: [Double], dateInStr: [String], paceArrToShow: [String]) {
        /// 配速数组，单位分钟
        var totalPaceInsec: [Double] = []
        /// 配速——展示给用户的，单位，分秒
        var paceToShow: [String] = []
        /// 日期
        var dateInStr: [String] = []
        let runningType = HKQuantityType(.distanceWalkingRunning)
        
        for wk in workouts {
            // 当前距离——单位米
            guard let runningDistanceNewVersion = wk.statistics(for: runningType)?.sumQuantity()?.doubleValue(for: .meter()) else {continue}
            
            // 配速
            if UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit") == 0 {
                // 2 zhi
                let r = PaceCalculatorMethods.paceCalcMinSecAccurate(runningDistanceNewVersion, 2, wk.duration as Double, .toKM)
                
                let paceInSec = Double( r / Double(60) )
                totalPaceInsec.append(paceInSec)
                paceToShow.append(convertPaceSecToMinSec(r))
                
                // 日期
                dateInStr.append(AssistantMethods.getDateInFormatString(wk.startDate, "yyyy-MM-dd"))
            }
            else if UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit") == 1 {
                let r = PaceCalculatorMethods.paceCalcMinSecAccurate(runningDistanceNewVersion, 2, wk.duration as Double, .toMile)
                let paceInSec = Double( r / Double(60) )
                totalPaceInsec.append(paceInSec)
                paceToShow.append(convertPaceSecToMinSec(r))
                // 日期
                dateInStr.append(AssistantMethods.getDateInFormatString(wk.startDate, "yyyy-MM-dd"))
            }
            else{
                
            }
            
        }
        
        return (totalPaceInsec, dateInStr, paceToShow)
        
    }
    
    
    /// 获取分析运动强度所需的数据（单位是用户选择的）
    /// - Parameters:
    ///    - workouts: 根据起始和结束日期Fetch的体能训练
    /// - Returns: ① 日期 ② 配速 ③ 距离
    ///
    class func getIntensityData(_ workouts: [HKWorkout]) -> (date: [String], pace: [Double], distance: [Double]) {
        var dateArray: [String] = []
        var paceArray: [Double] = []
        var disatanceArray: [Double] = []
        var distArray: [Double] = []
        let runningType = HKQuantityType(.distanceWalkingRunning)
        for wk in workouts {
            // 当前距离——单位米
            guard let runningDistanceNewVersion = wk.statistics(for: runningType)?.sumQuantity()?.doubleValue(for: .meter()) else {continue}
            if !runningDistanceNewVersion.isZero {
                disatanceArray.append(runningDistanceNewVersion)
                // 配速
                if UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit") == 0 {
                    // 2 zhi
                    let r = PaceCalculatorMethods.paceCalcMinSecAccurate(runningDistanceNewVersion, 2, wk.duration as Double, .toKM)
                    
                    let paceInSec = Double( r / Double(60) )
                    paceArray.append(paceInSec)
                    // 日期
                    dateArray.append(AssistantMethods.getDateInFormatString(wk.startDate, "yyyy-MM-dd"))
                }
                else if UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit") == 1 {
                    let r = PaceCalculatorMethods.paceCalcMinSecAccurate(runningDistanceNewVersion, 2, wk.duration as Double, .toMile)
                    let paceInSec = Double( r / Double(60) )
                    paceArray.append(paceInSec)

                    // 日期
                    dateArray.append(AssistantMethods.getDateInFormatString(wk.startDate, "yyyy-MM-dd"))
                }
                else{
                    
                }
            }
            

            // 用户偏好的距离单位
            let defaultUnit = UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit")
            
            // 转换单位 & 保留两位小数
            distArray = disatanceArray.map{
                return AssistantMethods.convertMeterToUnit(defaultUnit, $0)
            }
        
            
        }
        
        return (dateArray, paceArray, distArray)
    }
    
    
    
    /// 计算累计跑步时间，输入workout
    /// 返回：
    /// 0️⃣ 日期数组
    /// ① 总里程
    /// ② 总时间
    /// ③ 平均配速
    /// ④ 跑步次数
    /// ⑤ 单次距离数组，用于制图
    /// ⑥ maxDistance：单次跑步距离最大
    /// ⑦ maxPace：单次跑步配速最快
    /// ⑧ avgPower：平均功率
    /// ⑨ avgCadence：平均步频
    /// ⑩ avgHR: 平均心率
    /// 11. Avg Energy Burned
    /// avgTime: 平均耗时
    class func calcIndicatorInUserUnit(_ workouts: [HKWorkout]) -> (workoutDate: [String], accDistance: String, accTime: String, avgPace: String, numOfRuns: String, distanceArray: [Double], maxDistance: String, maxPace: String, avgPower: String, avgCadence: String, avgHR: String, avgCalorie: String, dataSource: Set<String>, maxDistanceDate: String, maxPaceDate: String, avgTime: String) {
        // MARK: 需要存在数组中的值
        /// 总时间
        var totalTimeInSec = 0.0
        /// 配速数组
        var totalPaceInsec: [Double] = []
        /// 总距离
        var totalDistanceInMeter: [Double] = []
        /// 打卡日期数组
        var dateArray: [String] = []
        /// 跑步功率
        var runningPowerArray: [Double] = []
        /// 跑步步频数组
        var runningCadenceArray: [Double] = []
        /// 运动平均心率
        var avgHRArray: [Double] = []
        /// 活动能量
        var activeEnergyArray: [Double] = []
        
        
        /// 数据来源
        var dataSourceArray: Set<String> = []
        
        
        // MARK: - 类型
        let runningType = HKQuantityType(.distanceWalkingRunning)
//        let cycleType = HKQuantityType(.distanceCycling)
        let runningPower = HKQuantityType(.runningPower)
        // 速度＝步频×步幅
        let runStepCountType = HKQuantityType(.stepCount)
        let runHRType = HKQuantityType(.heartRate)
        let activeEnergyBurnedType = HKQuantityType(.activeEnergyBurned)
        let energyType = HKQuantityType(.dietaryEnergyConsumed)
        
        // MARK: 遍历
        for wk in workouts {
            // TODO: 判断室内/室外
            /// 数据来源设备名称
            let sourceDevName = wk.sourceRevision.source.name
            dataSourceArray.insert(sourceDevName)
            
            // MARK: - 室内 & 室外
            // 1. 总时间
            totalTimeInSec += wk.duration as Double
            // 2. 当前距离——单位米
            let runningDistanceNewVersion = wk.statistics(for: runningType)?.sumQuantity()?.doubleValue(for: .meter())
            if let runningDistanceNewVersion = runningDistanceNewVersion {
                totalDistanceInMeter.append(runningDistanceNewVersion)
            }
            // 4. 配速
            if UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit") == 0 {
                // 2 zhi
                let r = PaceCalculatorMethods.paceCalcMinSecAccurate(runningDistanceNewVersion!, 2, wk.duration as Double, .toKM)
                totalPaceInsec.append(r)
            }
            else if UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit") == 1 {
                let r = PaceCalculatorMethods.paceCalcMinSecAccurate(runningDistanceNewVersion!, 2, wk.duration as Double, .toMile)
                totalPaceInsec.append(r)

            }
            else{
                
            }
            
            // 3. 打卡日期
            dateArray.append(AssistantMethods.getDateInFormatString(wk.startDate, "yyyy-MM-dd"))
            
            
            
            // 跑步速度 & 跑步步幅
            if let runStepCount = wk.statistics(for: runStepCountType)?.sumQuantity()?.doubleValue(for: .count()) {
                if !runStepCount.isNaN && !runStepCount.isZero {
                    let cadence = (runStepCount / Double(wk.duration)) * Double(60)
                    runningCadenceArray.append(cadence)
                }
            }
            

            
            
            // 心率
            if let runAvgHR = wk.statistics(for: runHRType)?.averageQuantity()?.doubleValue(for: .count().unitDivided(by: .minute())) {
                avgHRArray.append(runAvgHR)
            }
   
            


            
            // Energy
            if let activeEnergy = wk.totalEnergyBurned?.doubleValue(for: .kilocalorie()) {
                activeEnergyArray.append(activeEnergy)
            }

            




            // MARK: - 只室外
            guard let runningPower = wk.statistics(for: runningPower)?.averageQuantity()?.doubleValue(for: .watt())
            else {
                continue
            }
            
            if !runningPower.isNaN {
                runningPowerArray.append(runningPower)
            }
                    
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
        var totalTimeToShow: String = ""
        var avgTimeToShow: String = ""
        totalTimeToShow = getCumTime(totalTimeInSec)
        avgTimeToShow = getCumTime(totalTimeInSec / Double(workouts.count))
        
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
        let maxDistanceIndex: Int = distArray.firstIndex(of: maxDistance)!
        
        var maxDistanceToShow = String(format: "%.2f", maxDistance) + " "
        if UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit") == 0{
            maxDistanceToShow += NSLocalizedString("distanceUnitKM", comment: "")
        }
        else {
            maxDistanceToShow += NSLocalizedString("distanceUnitMile", comment: "")
            
        }
        // MARK: 展示的跑步最远距离 的日期
        var maxDistanceDateToShow = "---"
        maxDistanceDateToShow = dateArray[maxDistanceIndex]
        
        
        
        // MARK: 展示的跑步最快跑步配速
        let maxPace: Double = totalPaceInsec.min()!
        let maxPaceIndex: Int = totalPaceInsec.firstIndex(of: maxPace)!
        
        let maxPaceToShow: String = convertPaceSecToMinSec(maxPace)
        // MARK: 展示的跑步最快跑步配速 日期
        var maxPaceDateToShow = "---"
        maxPaceDateToShow = dateArray[maxPaceIndex]
        
        // MARK: 展示的平均跑步功率
        var avgPowerToShow = "---"
        if runningPowerArray.count > 0 {
            let avgPower: Double = (runningPowerArray.reduce(0.0, +)) / Double(runningPowerArray.count)
            avgPowerToShow = String(format: "%.0f", avgPower) + " " + NSLocalizedString("powerUnit", comment: "")
        }

        
        // MARK: - 展示的平均步频
        var avgCadenceToShow = "---"
        if runningCadenceArray.count > 0 {
            let avgCadence: Double = (runningCadenceArray.reduce(0.0, +)) / Double(runningCadenceArray.count)
            let avgCadenceRounding = rouding(avgCadence)
            avgCadenceToShow = String(format: "%.0f", avgCadenceRounding) + " " + NSLocalizedString("cadenceUnit", comment: "")
        }
        
        
        // MARK: - 展示的平均心率
        var avgHRToShow = "---"
        if avgHRArray.count > 0 {
            let avgHR: Double = (avgHRArray.reduce(0, +)) / Double(avgHRArray.count)
            let avgHRRounding = rouding(avgHR)
            avgHRToShow = String(format: "%.0f", avgHRRounding) + " " + NSLocalizedString("HR_unit", comment: "")
        }
        
        // MARK: - 展示的Active Energy
        var energyToShow = "---"
        if activeEnergyArray.count > 0 {
            let avgEnergy = (activeEnergyArray.reduce(0, +) / Double(activeEnergyArray.count))
            let avgEnergyRounding = rouding(avgEnergy)
            energyToShow = String(format: "%.0f", avgEnergyRounding) + " " + NSLocalizedString("energyUnit", comment: "")
        }
        
        
        // MARK: -返回-
        return (dateArray, totalDistanceToShow, totalTimeToShow, avgPaceToShow, numOfRunsToShow, distArray, maxDistanceToShow, maxPaceToShow, avgPowerToShow, avgCadenceToShow, avgHRToShow, energyToShow, dataSourceArray, maxDistanceDateToShow, maxPaceDateToShow, avgTimeToShow)
                            
    }
    
    
    class func getCumTime(_ totalTimeInSec: Double) -> String{
        let hours: Int = Int(totalTimeInSec/3600)
        let mins: Int = Int((totalTimeInSec - Double(hours) * 3600) / 60)
        let secs: Int = Int((totalTimeInSec - Double(hours) * 3600 - Double(mins) * 60))
        
        var totalTimeToShow: String = ""
        
        if hours < 10 {
            totalTimeToShow += "0\(hours):"
        }
        else {
            totalTimeToShow += "\(hours):"
        }
        if mins < 10 {
            totalTimeToShow += "0\(mins):"
        }
        else{
            totalTimeToShow += "\(mins):"
        }
        if secs < 10 {
            totalTimeToShow += "0\(secs)"
        }
        else{
            totalTimeToShow += "\(secs)"
        }
        return totalTimeToShow
    }
    
    
}
