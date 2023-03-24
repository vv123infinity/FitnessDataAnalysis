//
//  ChartColorHex.swift
//  FitnessDataAnalysis
//
//  Created by 十口V🌼 on 2023/2/28.
//

import Foundation
import UIKit

class ChartColorHex {
    
    enum BarColorSet: String {
        // 1. 近十二个月跑量条形图可视化颜色  
//        case recent12VisColor0 = "#708090"
        case recent12VisColor0 = "#e74c3c"
    }
    
    enum ChartBKColor: String {
        // 1. 浅色模式下Chart的背景颜色
        case chartBgColorLight0 = "#FFFFFF"
        // 2. 深色模式下Chart的背景颜色
        case chartBgColorDark0 = "#1B1B1B"
    }
    
    
    enum ChartTextColor: String {
        // 1. Chart中文字的颜色——浅色
        case chartTextColorLight0 = "#000000"
        // 2. Chart中文字的颜色——深色
        case chartTextColorDark0 = "#FFFFFF"
        case chartTextColorDark1 = "#696E73"
    }

    
}
