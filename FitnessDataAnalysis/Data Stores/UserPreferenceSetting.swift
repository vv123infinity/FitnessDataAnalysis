//
//  UserPreferenceSetting.swift
//  FitnessDataAnalysis
//
//  Created by 十口V🌼 on 2023/2/28.
//

import Foundation
import UIKit

class UserPreferenceSetting {
    
    
    enum RunningDistanceUnit: Int{
        case km = 0
        case mile = 1
        case meter = 2
    }
    
    
    
    /// 用户偏好设置默认值设置，也可以看成各项指标初始化。例如距离单位，跑步配速单位。
    /// （持久化存储）
    class func setUpUserPreference() {
        UserDefaults.standard.set(UserPreferenceSetting.RunningDistanceUnit.km.rawValue, forKey: "UserRunningDistanceUnit")
        UserDefaults.standard.set("KM", forKey: "distanceUnitDefaultAb")
        UserDefaults.standard.set(true, forKey: "allowChartInteraction")
        // 是否已经提示了交互
        UserDefaults.standard.set(false, forKey: "interactionHintController")
        
        UserDefaults.standard.set(" ", forKey: "lastMonthRunningDistanceInKM")
        UserDefaults.standard.set(" ", forKey: "lastMonthRunningDistanceInMile")
        UserDefaults.standard.set(" ", forKey: "lastMonthRunningDistanceInMeter")
        
        UserDefaults.standard.set(" ", forKey: "thisMonthRunningDistanceInKM")
        UserDefaults.standard.set(" ", forKey: "thisMonthRunningDistanceInMile")
        UserDefaults.standard.set(" ", forKey: "thisMonthRunningDistanceInMeter")
        
        
        UserDefaults.standard.set(" ", forKey: "recent12MonthRunningDistance")
        
        UserDefaults.standard.set(false, forKey: "ShowRunningOverviewChart")
        // App语言
        UserDefaults.standard.set(0, forKey: "theAppLanguage")
        // App外观 - 0——跟随系统 1——永远浅色 2——永远深色
        UserDefaults.standard.set(0, forKey: "appAppearance")
        
        UserDefaults.standard.set(false, forKey: "loginApple")
        
        // 是否保留上一次查询起始日期
        
        UserDefaults.standard.set(true, forKey: "lastQueryDateRange")
        // 上一次查询的起始日期
        UserDefaults.standard.set(-1, forKey: "lastQueryDateStart")
        // 上一次查询的结束日期
        UserDefaults.standard.set(-1, forKey: "lastQueryDateEnd")
        
        UserDefaults.standard.set(NSLocalizedString("indicator_1_pace", comment: ""), forKey: "indicator_1_selection")
        
        // 指标1类型初始化
        UserDefaults.standard.set(0, forKey: "IndicatorOneType")
        
        // 当前圆环进度
        UserDefaults.standard.set(0.5, forKey: "circleProgess")
        
        // 用户本月目标跑量
        UserDefaults.standard.set(100 as Double, forKey: "thisMonthTargetVolInKM")
        UserDefaults.standard.set(80 as Double, forKey: "thisMonthTargetVolInMile")
        
        UserDefaults.standard.set(false, forKey: "useSmiley")
        
        // 是否关注卡路里
        UserDefaults.standard.set(false, forKey: "careActiveEnergy")
        
        // 日期从星期一开始
        UserDefaults.standard.set(true, forKey: "weekStartFromMon")
        
        // Preferred 首选跑步类型
        UserDefaults.standard.set(0, forKey: "PreferredRunType")
        
        UserDefaults.standard.set(0, forKey: "tintColorIndex")
        
        UserDefaults.standard.set(false, forKey: "UnitHasChanged")
        UserDefaults.standard.set(false, forKey: "tintColorDidChange")
        UserDefaults.standard.set(false, forKey: "WeekStartDateHasChanged")
        
        UserDefaults.standard.set(0, forKey: "PreferredHRZoneType")
        UserDefaults.standard.set([0, 1, 2] as? [Int], forKey: "ComprehensiveAnalysisIndicatorArray")
        
        
    }
    
    
    
}
