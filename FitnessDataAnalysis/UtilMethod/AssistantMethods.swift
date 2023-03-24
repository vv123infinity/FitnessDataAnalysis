//
//  AssistantMethods.swift
//  FitnessDataAnalysis
//
//  Created by 十口V🌼 on 2023/2/25.
//

import UIKit

class AssistantMethods {
    
    
    // MARK: 保留小数
    /// 保留_位小数
    /// 来自：https://developer.apple.com/forums/thread/110402
    class func convert(_ a: Double, maxDecimals max: Int) -> Double {
        let stringArr = String(a).split(separator: ".")
        let decimals = Array(stringArr[1])
        var string = "\(stringArr[0])."

        var count = 0;
        for n in decimals {
            if count == max { break }
            string += "\(n)"
            count += 1
        }


        let double = Double(string)!
        return double
    }
    
    //MARK: 日期字符串
    /// 获取 "yyyy-MM-dd" / "yyyy-MM" 格式的日期字符串
    class func getDateInFormatString(_ date: Date, _ format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en")
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
    
    class func getDateFromString(_ s: String, _ format: String) -> Date {
        let dateString = s
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        if let date = dateFormatter.date(from: dateString) {
            print(date)
            return date
        } else {
            print("Invalid date format")
            return Date.init()
        }
        

    }
    
    
    // MARK: 12个月名称
    /// 返回最近12个月的年月份，时间从远到近。
    /// - Returns:例子，["2022-03", "2022-04", "2022-05", "2022-06", "2022-07", "2022-08", "2022-09", "2022-10", "2022-11", "2022-12", "2023-01", "2023-02"]
    class func getRecent12MonName() -> [String] {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en")
        dateFormatter.dateFormat = "yyyy-MM"

        var yearMonths = [String]()
        let calendar = Calendar.current
        let now = Date()

        for i in stride(from: 11, through: 0, by: -1) {
            if let date = calendar.date(byAdding: .month, value: -i, to: now) {
                let yearMonth = dateFormatter.string(from: date)
                yearMonths.append(yearMonth)
            }
        }
        return yearMonths
}
    
    
    class func getRecent5MonName() -> [String] {
        let dateFormatter = DateFormatter()
//        dateFormatter.locale = Locale(identifier: "zh_CN")
        dateFormatter.dateFormat = "MM"
        let calendar = Calendar.current
        let now = Date()
        var yearMonths = [String]()
        
        for i in stride(from: 4, through: 0, by: -1) {
            if let date = calendar.date(byAdding: .month, value: -i, to: now) {
                let m = Int(dateFormatter.string(from: date))!
                
//                let monthAsString:String = dateFormatter.monthSymbols[m - 1]
                let monthAsString2 = dateFormatter.shortMonthSymbols[m-1]
                yearMonths.append(monthAsString2)
            }
        }
//        print(yearMonths)
        return yearMonths
    }
    
    
    
    // MARK: 单位转换
    /// 将距离（米）转换为其他单位 保留两位小数（不进位）
    /// - Parameters:
    ///   - idx: 0 - 转换成KM 1 - Mile 2 - M
    ///   - d: 输入的数
    /// - Returns: 结果
    class func convertMeterToUnit(_ idx: Int, _ d: Double) -> Double{
        switch idx {
        case 0:
            // convert to km
            return convert((d*PaceCalculatorMethods.ConvertMeterToPaceunit.toKM.rawValue), maxDecimals: 2)
        case 1:
            // convert to mile
            return convert((d*PaceCalculatorMethods.ConvertMeterToPaceunit.toMile.rawValue), maxDecimals: 2)
        case 2:
            // 需要保留小数
            return convert(d, maxDecimals: 2)
        default:
            return convert(d, maxDecimals: 2)
        }
    }
    
    // MARK: 跑步距离分类
    /// 将单次跑步距离分成几个类
    /// 1) (0, 5) - <200m, [200,400), [400, 800), [800, 1500] (1500, 5000)
    /// 2) [5, 10)
    /// 3) [10, 20)
    /// 4) [20, 40)
    /// 5) > 40
    class func classifyRunningDistance(_ distanceData: [Double]) -> [[Any]]{
        print(distanceData[0])
        // 1. 首先计算最远跑步距离
        guard let maxDistance: Double = distanceData.max() else {
            return [[0]]
        }
    
        
        if maxDistance > 0 && maxDistance < 5000 {
            let less200Count = distanceData.filter{$0 < 200.0}.count
            let between200And400 = distanceData.filter{return $0>=200 && $0<400}.count
            let between400And800 = distanceData.filter{return $0>=400 && $0<800}.count
            let between800And1500 = distanceData.filter{return $0>=800 && $0<1500}.count
            let between1500And5000 = distanceData.filter{return $0>=1500 && $0<5000}.count
            return [["<200M", less200Count], ["200~400M", between200And400], ["400~800M", between400And800], ["800~1500M", between800And1500], ["1500~5000M", between1500And5000]]
        }
        else if maxDistance >= 5000 && maxDistance < 10000 {
            // class 1 - <5km
            // class 2 - [5, 6)
            // class 3 - [6, 7)
            // class 4 - [7, 8)
            // class 5 - [8, 10)
            let less5 = distanceData.filter{return $0<5000}.count
            let between5And6 = distanceData.filter{return $0>=5000 && $0<6000}.count
            let between6And7 = distanceData.filter{return $0>=6000 && $0<7000}.count
            let between7And8 = distanceData.filter{return $0>=7000 && $0<8000}.count
            let between8And10 = distanceData.filter{return $0>=8000 && $0<10000}.count
            return [["<5KM", less5], ["5~6KM", between5And6], ["6~7KM", between6And7], ["7~8KM", between7And8], ["8~10KM", between8And10]]
        }
        else if maxDistance >= 10000 && maxDistance < 15000 {
            // class 1 - <5km
            // class 2 - [5, 7)
            // class 3 - [7, 10)
            // class 4 - [10, 12)
            // class 5 - [12, 15)
            let less5 = distanceData.filter{return $0<5000}.count
            let between5And7 = distanceData.filter{return $0>=5000 && $0<7000}.count
            let between7And10 = distanceData.filter{return $0>=7000 && $0<10000}.count
            let between10And12 = distanceData.filter{return $0>=10000 && $0<12000}.count
            let between12And15 = distanceData.filter{return $0>=12000 && $0<15000}.count
            return [["<5KM", less5], ["5~7KM", between5And7], ["7~10KM", between7And10], ["10~12KM", between10And12], ["12~15KM", between12And15]]
        }
        else {
            return [[0]]
        }
        
        
        
    }
    
    // MARK: 上个月的起始和结束
    /// 默认获取上个月的起始和结束或 用户自定义起始日期
    class func getLastMonthStartEndDate(_ fromDate: Date, _ toDate: Date, _ userRangeFlag: Bool) -> (startDate: Date, endDate: Date) {
        if userRangeFlag {
            return (fromDate, toDate)
        }
        else {
            let calendar = Calendar.current
            let lastMonth = calendar.date(byAdding: .month, value: -1, to: Date())!
            let year = calendar.component(.year, from: lastMonth)
            let month = calendar.component(.month, from: lastMonth)

            // 获取上个月的日期范围
            let dateComponents = DateComponents(year: year, month: month)
            let startDate = calendar.date(from: dateComponents)!
            let endDate = calendar.date(byAdding: .month, value: 1, to: startDate)!
//            return (startDate, endDate)
            
            if UserDefaults.standard.bool(forKey: "lastQueryDateRange"){
                // 获取上一次的起始日期
                if UserDefaults.standard.integer(forKey: "lastQueryDateStart") == -1 && UserDefaults.standard.integer(forKey: "lastQueryDateEnd") == -1{
                    // 第一次下载
                    return (startDate, endDate)
                }
                else{
                    let lastStartDate = UserDefaults.standard.object(forKey: "lastQueryDateStart") as! Date
                    let lastEndDate = UserDefaults.standard.object(forKey: "lastQueryDateEnd") as! Date
                    return (lastStartDate, lastEndDate)
                }
            }
            else {
                return (startDate, endDate)
            }
        }

    }
    
    class func getThisMonthStartEndDate(_ fromDate: Date, _ toDate: Date, _ userRangeFlag: Bool) -> (startDate: Date, endDate: Date) {
        if userRangeFlag {
            return (fromDate, toDate)
        }
        else {

            let calendar = Calendar.current
            let today = Date()
            let components = calendar.dateComponents([.year, .month], from: today)
            let startDate = calendar.date(from: components)!
            let endDate = Date.init()

            if UserDefaults.standard.bool(forKey: "lastQueryDateRange"){
                // 获取上一次的起始日期
                if UserDefaults.standard.integer(forKey: "lastQueryDateStart") == -1 && UserDefaults.standard.integer(forKey: "lastQueryDateEnd") == -1{
                    // 第一次下载
                    return (startDate, endDate)
                }
                else{
                    let lastStartDate = UserDefaults.standard.object(forKey: "lastQueryDateStart") as! Date
                    let lastEndDate = UserDefaults.standard.object(forKey: "lastQueryDateEnd") as! Date
                    return (lastStartDate, lastEndDate)
                }
            }
            else {
                return (startDate, endDate)
            }
        }

    }
    
    
    
    
    
    // MARK: app外观
    /// 返回用户设定的app外观
    class func returnUserAppearanceMode() -> UIUserInterfaceStyle {
        
        let x = UserDefaults.standard.integer(forKey: "appAppearance")
        switch x {
        case 0:
            return UIUserInterfaceStyle.unspecified
        case 1:
            return UIUserInterfaceStyle.light
        case 2:
            return UIUserInterfaceStyle.dark
        default:
            return UIUserInterfaceStyle.unspecified
        }
        
    }
    
    
    
}
