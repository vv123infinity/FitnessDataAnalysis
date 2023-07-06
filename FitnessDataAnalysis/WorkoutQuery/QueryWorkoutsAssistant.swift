//
//  QueryWorkoutsAssistant.swift
//  FitnessDataAnalysis
//
//  Created by 十口V🌼 on 2023/2/25.
//

import HealthKit
import UIKit

class QueryWorkoutsAssistant {
    

    
    /// 返回跑步距离
    /// - Parameters:
    ///   - workoutsArray: workouts数组
    /// - Returns: 上跑步距离，单位米
    class func getWorkoutsDistance(_ workoutsArray: [HKWorkout]) -> [Double] {
        
        var totalDistance: [Double] = []
        
        let runningType = HKQuantityType(.distanceWalkingRunning)

        for ii in workoutsArray {
            guard let runningDistanceNewVersion = ii.statistics(for: runningType)?.sumQuantity()?.doubleValue(for: .meter()) else {
                continue
            }
            totalDistance.append(runningDistanceNewVersion)
        }
        
        return totalDistance
        
    }
    
    // MARK: 跑步距离&日期
    /// 返回跑步距离和相应的日期
    /// - Parameters:
    ///   - workoutsArray: workouts数组
    ///   - dateFormat: 日期字符串的格式
    /// - Returns: 上跑步距离，单位米
    class func getWorkoutsDistanceAndDate(_ workoutsArray: [HKWorkout], _ dateFormat: String) -> (dist: [Double], workoutDate: [String]) {
        
        var totalDistance: [Double] = []
        var dateArray: [String] = []
        
        let runningType = HKQuantityType(.distanceWalkingRunning)

        for ii in workoutsArray {
            guard let runningDistanceNewVersion = ii.statistics(for: runningType)?.sumQuantity()?.doubleValue(for: .meter()) else {
                return ([0.0], [" "])
            }
            totalDistance.append(runningDistanceNewVersion)
            dateArray.append(AssistantMethods.getDateInFormatString(ii.startDate, dateFormat))
        }
        
        return (totalDistance, dateArray)
        
    }
    
    
    // MARK: - 近x个月
    ///查询前x个月的跑步距离（累计）
    /// - Parameters:
    ///   - workoutsArray: running 类型的Workout数组
    ///   - x: x=0表示本月，x=1表示上个月 (x>=0)
    /// - Returns: 当前月的跑步距离，单位米
    class func queryRecentMonthDistance(_ workoutsArray: [HKWorkout], _ x: Int) -> Double {
        
        // 获取上x个月的年份和月份
        let calendar = Calendar.current
        let lastMonth = calendar.date(byAdding: .month, value: -x, to: Date())!
        let year = calendar.component(.year, from: lastMonth)
        let month = calendar.component(.month, from: lastMonth)

        // 获取上x个月的日期范围
        let dateComponents = DateComponents(year: year, month: month)
        let startDate = calendar.date(from: dateComponents)!
        let endDate = calendar.date(byAdding: .month, value: 1, to: startDate)!
        

        
        // 使用 filter 函数筛选出日期范围内的记录
        let filteredWorkouts = workoutsArray.filter{ wk in
            return wk.startDate >= startDate && wk.startDate < endDate
        }

        
        var totalDistance: Double = 0.0
        let runningType = HKQuantityType(.distanceWalkingRunning)

        for ii in filteredWorkouts {
            guard let runningDistanceNewVersion = ii.statistics(for: runningType)?.sumQuantity()?.doubleValue(for: .meter()) else {
                return 0.0
            }
            totalDistance += runningDistanceNewVersion
        }
        return totalDistance
    }
    
    // MARK: - 近x个月跑步距离不累计
    ///查询前x个月的跑步距离（不累计）
    /// - Parameters:
    ///   - workoutsArray: running 类型的Workout数组
    ///   - x: x=0表示本月，x=1表示上个月 (x>=0)
    /// - Returns: 当前月的跑步距离，单位米
    class func queryRecentMonthDistanceDetail(_ workoutsArray: [HKWorkout], _ x: Int) -> (distance: [Double], date: [String]) {
        
        // 获取上x个月的年份和月份
        let calendar = Calendar.current
        let lastMonth = calendar.date(byAdding: .month, value: -x, to: Date())!
        let year = calendar.component(.year, from: lastMonth)
        let month = calendar.component(.month, from: lastMonth)

        // 获取上x个月的日期范围
        let dateComponents = DateComponents(year: year, month: month)
        let startDate = calendar.date(from: dateComponents)!
        let endDate = calendar.date(byAdding: .month, value: 1, to: startDate)!
        

        
        // 使用 filter 函数筛选出日期范围内的记录
        let filteredWorkouts = workoutsArray.filter{ wk in
            return wk.startDate >= startDate && wk.startDate < endDate
        }

        
        var totalDistance: [Double] = []
        var allDate: [String] = []
        let runningType = HKQuantityType(.distanceWalkingRunning)

        for ii in filteredWorkouts {
            guard let runningDistanceNewVersion = ii.statistics(for: runningType)?.sumQuantity()?.doubleValue(for: .meter()) else {
                return ([0.0], [""])
            }
            totalDistance.append(runningDistanceNewVersion)
            allDate.append(AssistantMethods.getDateInFormatString(ii.startDate, "yyyy-MM-dd"))
        }
        return (totalDistance, allDate)
    }
    
    // MARK: - recent 12M
    ///查询最近十二个月的跑步距离（不累计）
    /// - Parameters:
    ///   - workoutsArray: running 类型的Workout数组
    /// - Returns: 时间从远到近各月的跑步距离，单位米
    class func queryRecent12MonRunningDistance(_ workoutsArray: [HKWorkout]) -> [Double] {
        var totalDistanceArr: [Double] = []
        
        for i in stride(from: 11, through: 0, by: -1) {
            totalDistanceArr.append(queryRecentMonthDistance(workoutsArray, i))
        }
        return totalDistanceArr
    }
    // MARK: - 最近5个月
    ///查询最近6个月的跑步距离（累计）
    /// - Parameters:
    ///   - workoutsArray: running 类型的Workout数组
    /// - Returns: 时间从远到近各月的跑步距离，单位米
    class func queryRecent5MonRunningDistance(_ workoutsArray: [HKWorkout], _ local: String) -> [Double] {
        var totalDistanceArr: [Double] = []
        
        for i in stride(from: 4, through: 0, by: -1) {
            totalDistanceArr.append(queryRecentMonthDistance(workoutsArray, i))
        }
        return totalDistanceArr
    }
    
    // MARK: - 最近5个月
    ///查询最近6个月的跑步距离（不累计）
    /// - Parameters:
    ///   - workoutsArray: running 类型的Workout数组
    /// - Returns: 时间从远到近各月的跑步距离，单位米
    class func queryRecent5MonRunningDistanceDetail(_ workoutsArray: [HKWorkout], _ local: String) -> (distance: [[Double]], dateInString: [[String]]) {
        var totalDistanceArr: [[Double]] = []
        var dateInStr: [[String]] = []
        
        for i in stride(from: 4, through: 0, by: -1) {
            let res = queryRecentMonthDistanceDetail(workoutsArray, i)
            totalDistanceArr.append(res.distance.reversed())
            dateInStr.append(res.date.reversed())
        }

//        var dateIn1DimInString: [String] = []
//        for ele in dateInStr {
//            for dd in ele {
//                dateIn1DimInString.append(dd)
//            }
//        }

        return (totalDistanceArr, dateInStr)
    }
    
    
    
    
    // MARK: - 查询最近X个月
    ///查询最近x月的跑步距离（不累计）
    /// - Parameters:
    ///   - workoutsArray: running 类型的Workout数组
    ///   - x: 月份数
    /// - Returns: 时间从远到近各月的跑步距离，单位米
    class func queryRecentXMonRunningDistance(_ workoutsArray: [HKWorkout], _ x: Int) -> [Double] {
        var totalDistanceArr: [Double] = []
        
        for i in stride(from: x-1, through: 0, by: -1) {
            totalDistanceArr.append(queryRecentMonthDistance(workoutsArray, i))
        }

        return totalDistanceArr
    }
    
    // MARK: - 7D Distance
    ///查询最近7天的跑步总距离距离（累计）
    /// - Parameters:
    ///   - workoutsArray: running 类型的Workout数组
    /// - Returns: 跑步距离，单位米，不累计
    /// 两种类型的日期数组
    class func getRecentSevenDaysDistance(_ workoutsArray: [HKWorkout]) -> (dis: [Double], dateArray: [String], dateInDate: [Date]) {
        var disArray: [Double] = []
        var dateArray: [String] = []
        var dateInDate: [Date] = []
//        var _: Double = 0.0
        // 1. 获取今天的日期并存储
        let currentDate = Date()
        
        let calendar = Calendar.current
        let today = Date()
        
        // 2. 创建Calendar对象，获取本周的开始日期
        let weekday = calendar.component(.weekday, from: today)
        var minusVal: Int = 0
        if UserDefaults.standard.bool(forKey: "weekStartFromMon") {
            minusVal = 2
        }
        else{
            minusVal = 1
        }
        let daysToSubtract = weekday - minusVal
        var startDate = calendar.date(byAdding: .day, value: -daysToSubtract, to: today)!
        
        let comparisonResult = startDate.compare(today)
        
        if comparisonResult == .orderedDescending {
            // 开始日期在今天之后（下个星期一）
            startDate = calendar.date(byAdding: .day, value: -7, to: startDate)!
        }
        
        
        let lastWeekWorkouts = workoutsArray.filter { wk in
            return wk.startDate >= startDate && wk.startDate <= currentDate
        }
        
        let runningType = HKQuantityType(.distanceWalkingRunning)

        
        for (index, element) in lastWeekWorkouts.enumerated() {
            // 1. 添加日期
            dateInDate.append(element.startDate)
            guard let runningDistanceNewVersion = element.statistics(for: runningType)?.sumQuantity()?.doubleValue(for: .meter()) else {
                return ([0.0], [""], [])
            }
            
            
            let df = DateFormatter()
            df.dateFormat = "dd"
            // "22", "22"
            // 1.0 , 0.8
            
            if dateArray.count > 0 && dateArray.last! == df.string(from: element.startDate){
                // 抛弃最后的元素
                disArray[disArray.count - 1] += runningDistanceNewVersion
            }
            else {
                dateArray.append(df.string(from: element.startDate))
                disArray.append(runningDistanceNewVersion)
            }
            
        }

        return (disArray, dateArray, dateInDate)
    }
    
    
    class func getTodayDistance(_ workoutsArray: [HKWorkout]) -> Double {
        // 1. 获取今天的日期并存储
        let currentDate = Date()
        
        // 2. 创建Calendar对象，获取一周前的日期
        let calendar = Calendar.current
        let oneWeekAgo = calendar.date(byAdding: .day, value: -1, to: currentDate)
        
        // 3. 循环遍历日期数组，并将日期与一周前的日期进行比较。如果日期在一周内，则将其添加到一个新的数组中。
        let lastWeekWorkouts = workoutsArray.filter { wk in
            return wk.startDate >= oneWeekAgo! && wk.startDate <= currentDate
        }
        
        var totalDistance: Double = 0.0
        let runningType = HKQuantityType(.distanceWalkingRunning)

        
        
        for (index, element) in lastWeekWorkouts.enumerated() {
            guard let runningDistanceNewVersion = element.statistics(for: runningType)?.sumQuantity()?.doubleValue(for: .meter()) else {
                return 0.0
            }
            totalDistance += runningDistanceNewVersion
            
        }
        return totalDistance
    }
    
    
    
    // MARK: - Start & End
    /// 自定义时间区段的函数，注意输入的各个参数都是Int类型。注意判断起始和结束时间是否合法，不合法返回-1.
    /// - Parameters:
    ///   - workoutsArray: running 类型的Workout数组
    ///   - startYear: 起始日期的年份
    ///   - startMonth: 起始日期的月份
    ///   - startDay: 起始日期的Day
    ///   - endYear: 结束日期的年份
    ///   - endMonth:结束日期的月份
    ///   - endDay:结束日期的Day
    /// - Returns: 此区间内的跑步总距离，单位km。如果返回-1，表示该起始&结束日期不合法。
    class func getTargetDistanceWithStartEndDate(_ workoutsArray: [HKWorkout], _ startYear: Int, _ startMonth: Int, _ startDay: Int, _ endYear: Int, _ endMonth: Int, _ endDay: Int) -> Double {
        let calendar = Calendar.current
        
        // 1. initilize start date
        var startDateComponents = DateComponents()
        startDateComponents.year = startYear
        startDateComponents.month = startMonth
        startDateComponents.day = startDay
        let startDate = calendar.date(from: startDateComponents)!
        
        // 2. initilize end date
        var endDateComponents = DateComponents()
        endDateComponents.year = endYear
        endDateComponents.month = endMonth
        endDateComponents.day = endDay
        let endDateInit = calendar.date(from: endDateComponents)!
        let endDate = calendar.date(byAdding: .day, value: 1, to: endDateInit)!
        
        // 3. 判断输入日期是否合法
        if endDate < startDate {
            return -1
        }
        
        // 4. use filter closure to pick the target workouts
        let filterWorkouts = workoutsArray.filter { wk in
            return wk.startDate >= startDate && wk.startDate < endDate
        }
        
        
        var totalDistance: Double = 0.0
        let runningType = HKQuantityType(.distanceWalkingRunning)
        for ii in filterWorkouts {
            print("\(ii.startDate)")
            guard let runningDistanceNewVersion = ii.statistics(for: runningType)?.sumQuantity()?.doubleValue(for: .meter()) else {
                return 0.0
            }
            totalDistance += AssistantMethods.convert(runningDistanceNewVersion/1000, maxDecimals: 2)
        }
        
        print("The running distance between \(startYear)/\(startMonth)/\(startDay) and \(endYear)/\(endMonth)/\(endDay) is \(totalDistance) km.🌟")
        
        return totalDistance
    }
    
    // MARK: - 查询最早跑步记录的日期并存入UserDefault
    class func queryEarliestRunningRecord(){
        WorkoutDataStore.loadEarliestWorkout{ (record, error) in
            let earliestDate = (record?.first?.startDate)!
            UserDefaults.standard.set(earliestDate as AnyObject, forKey: "earliestRunningRecordDate")
        }
        
    }
    

    /// 获取workout数组中的距离和配速
    /// - Parameters:
    ///   - workoutsArray: running 类型的Workout数组
    /// - Returns:
    ///   wDist - 距离，根据用户的输入
    ///   wPace - 配速
    class func getAllDistAndPaceInDouble(_ workoutsArray: [HKWorkout], _ inputDistanceUnit: Int) -> (wDist: [Double], wPace: [Double]) {
        
        var distInUserUnit: [Double] = []
//        let userPaceUnit = UserDefaults.standard.integer(forKey: "UserRunningDistanceUnit")
//        let
        
//        let cycleType = HKQuantityType(.distanceCycling)
        
        let runningType: HKQuantityType = HKQuantityType(.distanceWalkingRunning)
        
//        if UserDefaults.standard.integer(forKey: "analyzeSportType") == 0{
//            runningType = cycleType
//        }
//        else {
//            runningType = HKQuantityType(.distanceWalkingRunning)
//        }

        
        let paceInDouble: [Double] = workoutsArray.map{ workout in
            
            guard let runningDistanceNewVersion = workout.statistics(for: runningType)?.sumQuantity()?.doubleValue(for: .meter()) else {
                return 0.0
            }
            switch inputDistanceUnit {
            case 0:
                distInUserUnit.append(AssistantMethods.convertMeterToUnit(0, runningDistanceNewVersion))
                let paceRes = PaceCalculatorMethods.paceCalcMinSec(runningDistanceNewVersion, 2, 0, 0, Int(workout.duration), .toKM)
                return Double(paceRes.minutes) + Double(Double(paceRes.seconds) / 60.0)
            case 1:
                distInUserUnit.append(AssistantMethods.convertMeterToUnit(1, runningDistanceNewVersion))
                let paceRes = PaceCalculatorMethods.paceCalcMinSec(runningDistanceNewVersion, 2, 0, 0, Int(workout.duration), .toMile)
                return Double(paceRes.minutes) + Double(Double(paceRes.seconds) / 60.0)
            case 2:
                distInUserUnit.append(AssistantMethods.convertMeterToUnit(2, runningDistanceNewVersion))
                let paceRes = PaceCalculatorMethods.paceCalcMinSec(runningDistanceNewVersion, 2, 0, 0, Int(workout.duration), .toMeter)
                return Double(paceRes.minutes) + Double(Double(paceRes.seconds) / 60.0)
            default:
                print("应该不会执行到这里")
                return 0.0
            }
        }
        return (distInUserUnit, paceInDouble)
    }
    
    
    
}

