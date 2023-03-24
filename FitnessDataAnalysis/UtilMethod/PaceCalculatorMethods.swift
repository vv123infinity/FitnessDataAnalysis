//
//  PaceCalculatorMethods.swift
//  FitnessDataAnalysis
//
//  Created by 十口V🌼 on 2023/2/27.
//

import Foundation
import UIKit
// 1 Mile = 1,609.344 Meters
// 1 Meter = 0.00062137119 Miles

class PaceCalculatorMethods {
    
    /// 将 1 米转换成用户要求的配速单位的常数
    enum ConvertMeterToPaceunit: Double {
        
        case toMile = 0.00062137119
        case toKM = 0.001
        case toMeter = 1
        case to1500M = 0.0006666667
        case to800M = 0.00125
        case to400M = 0.0025
        case to200M = 0.005
    }
    
    /// 配速阈值设置，单位分
    enum PaceThresholdSetting: Double {
        case fastInKM = 5.0
        case fastInMile = 8.0333334
        case middleInKM = 6.0
        case middleInMile = 9.65
    }
    
    
    class func secondsToMinutesSeconds(seconds: Int) -> (minutes: Int, seconds: Int) {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return (minutes, remainingSeconds)
    }

    
    /// 配速转换器。配速=时间/距离
    /// - Parameters:
    ///   - distance: 跑步距离
    ///   - distancUnit: 跑步距离的单位。0-km，1-mile，2-meter
    ///   - hrs: 跑步经过的小时
    ///   - mins: 经过的分钟数
    ///   - secs: 经过的秒
    ///   - paceUnit: 跑速的单位，如 X分Y秒每 英里/公里/1500M/800M/400M/200M
    class func paceCalc(_ distance: Double, _ distanceUnit: Int, _ hrs: Int, _ mins: Int, _ secs: Int, _ paceUnit: ConvertMeterToPaceunit) -> String {
        let convertConstantMileToMeter: Double = 1609.344
        // 1. 将距离转换为米
        var totalDistanceInMeter: Double = 0.0
        switch distanceUnit{
        case 0:
            totalDistanceInMeter = distance * 1000
        case 1:
            totalDistanceInMeter = convertConstantMileToMeter * distance
        case 2:
            totalDistanceInMeter = distance
        default:
            totalDistanceInMeter = 0
        }
        
        // 2. 将时间转换为秒
        let totalTimeInSec: Double = Double(60*60*hrs + 60*mins + secs)
        
        // 3. 时间 / (距离*转换常数) = X secs / paceUnit
        let paceInSecs = totalTimeInSec / (totalDistanceInMeter * paceUnit.rawValue)
        let res = secondsToMinutesSeconds(seconds: Int(paceInSecs))
        print(res)
        let resMin = res.minutes
        let resSec = res.seconds
        
        return "\(resMin) " + NSLocalizedString("paceMinUnit", comment: "") + " \(resSec) " + NSLocalizedString("paceSecUnit", comment: "")
        
    }
    
    
    /// 配速转换器。配速=时间/距离
    /// - Parameters:
    ///   - distance: 跑步距离
    ///   - distancUnit: 跑步距离的单位。0-km，1-mile，2-meter
    ///   - hrs: 跑步经过的小时
    ///   - mins: 经过的分钟数
    ///   - secs: 经过的秒
    ///   - paceUnit: 跑速的单位，如 X分Y秒每 英里/公里/1500M/800M/400M/200M
    class func paceCalcMinSec(_ distance: Double, _ distanceUnit: Int, _ hrs: Int, _ mins: Int, _ secs: Int, _ paceUnit: ConvertMeterToPaceunit) -> (minutes: Int, seconds: Int) {
        let convertConstantMileToMeter: Double = 1609.344
        // 1. 将距离转换为米
        var totalDistanceInMeter: Double = 0.0
        switch distanceUnit{
        case 0:
            totalDistanceInMeter = distance * 1000
        case 1:
            totalDistanceInMeter = convertConstantMileToMeter * distance
        case 2:
            totalDistanceInMeter = distance
        default:
            totalDistanceInMeter = 0
        }
        
        // 2. 将时间转换为秒
        let totalTimeInSec: Double = Double(60*60*hrs + 60*mins + secs)
        
        // 3. 时间 / (距离*转换常数) = X secs / paceUnit
        let paceInSecs = totalTimeInSec / (totalDistanceInMeter * paceUnit.rawValue)
        let res = secondsToMinutesSeconds(seconds: Int(paceInSecs))
        return res
    }
    
    
    class func paceCalcMinSecAccurate(_ distance: Double, _ distanceUnit: Int, _ secs: Double, _ paceUnit: ConvertMeterToPaceunit) -> Double {
        let convertConstantMileToMeter: Double = 1609.344
        // 1. 将距离转换为米
        var totalDistanceInMeter: Double = 0.0
        switch distanceUnit{
        case 0:
            totalDistanceInMeter = distance * 1000
        case 1:
            totalDistanceInMeter = convertConstantMileToMeter * distance
        case 2:
            totalDistanceInMeter = distance
        default:
            totalDistanceInMeter = 0
        }
        
        // 2. 将时间转换为秒
        let totalTimeInSec: Double = Double(secs)
        
        // 3. 时间 / (距离*转换常数) = X secs / paceUnit
        let paceInSecs = totalTimeInSec / (totalDistanceInMeter * paceUnit.rawValue)
        let min: Int = Int(paceInSecs / 60)
        let leftPart = paceInSecs - 60*Double(min)
        
        let res = secondsToMinutesSeconds(seconds: Int(paceInSecs))

        return paceInSecs
    }
    
}

