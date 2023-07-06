//
//  ColorUtil.swift
//  FitnessDataAnalysis
//
//  Created by Infinity vv123 on 2023/2/24.
//

import UIKit
import AAInfographics
class ColorUtil {
    /// 获取圆饼图的颜色，index=0，蓝色，1-紫色
    class func getPieChartColor(_ idx: Int) -> [String] {
        switch idx {
        case 0:
            return ["#CAF0F8", "#90E0F0", "#00B5DA", "#0077B7", "#050660"]
        case 1:
            return ["#221A44", "#5F558F", "#A088C0", "#BF95C5", "#E0B0CC"]
        default:
            return ["#CAF0F8", "#90E0F0", "#00B5DA", "#0077B7", "#050660"]
        }
        
    }
    // #221A44, #5F558F, #A088C0, #BF95C5, #E0B0CC
    /*
     34, 26, 68,
     ,
     160, 136, 192,
     ,
     224, 176, 204,

     */
    /// 获取综合分析指标选择的高亮色（图表颜色）
    class func getCompColors(_ idx: Int) -> String {
        switch idx {
        case 0:
            return AAColor.rgbaColor(36, 151, 199)
        case 1:
            return AAColor.rgbaColor(120, 117, 212)
        case 2:
            return AAColor.rgbaColor(239, 86, 76)
        case 3:
            return AAColor.rgbaColor(95, 85, 143)
        case 4:
            return AAColor.rgbaColor(191, 149, 197)
        case 5:
            return AAColor.rgbaColor(255, 182, 193)
        case 6:
            return AAColor.rgbaColor(105, 105, 105)
        case 7:
            return AAColor.rgbaColor(50, 205, 50)

        default:
            return AAColor.rgbaColor(36, 151, 199)
        }
    }
    
    /// 獲取表格的logo高亮色
    class func getTableLogoImageColor() -> [UIColor] {
        // 255, 2, 181, 217
//255, 49, 130, 187
        // 255, 40, 175, 213
        let colors = [
            // 跑步距离
            UIColor.init(red: 36/255.0, green: 151/255.0, blue: 199/255.0, alpha: 1),
            // 跑步次数
            UIColor(red: 0.996, green: 0.675, blue: 0.369, alpha: 1),
            // 平均配速
            UIColor.init(red: 120/255.0, green: 117/255.0, blue: 212/255.0, alpha: 1),
            // 时长
            UIColor(red: 2/255, green: 181/255, blue: 217/155, alpha: 1),
            // 最远距离 
            UIColor(red: 0.996, green: 0.675, blue: 0.369, alpha: 1),
            // 最快配速
            UIColor(red: 0.780, green: 0.475, blue: 0.816, alpha: 1),
            // 平均心率
            UIColor.init(red: 255/255.0, green: 182/255.0, blue: 193/255.0, alpha: 1),
            // 卡路里
            UIColor.init(red: 239/255.0, green: 86/255.0, blue: 76/255.0, alpha: 1),
            // 功率
            UIColor.init(red: 50/255.0, green: 205/255.0, blue: 50/255.0, alpha: 1),
//            UIColor(red: 0.780, green: 0.475, blue: 0.816, alpha: 1),
            // 步频
//            UIColor(red: 2/255, green: 181/255, blue: 217/155, alpha: 1),
            UIColor.init(red: 105/255.0, green: 105/255.0, blue: 105/255.0, alpha: 1),
            UIColor(red: 0.996, green: 0.675, blue: 0.369, alpha: 1),
            UIColor(red: 0.780, green: 0.475, blue: 0.816, alpha: 1),
            ]
        
        return colors
    }
    
    
    public class func dynamicColor(dark:UIColor, light:UIColor) -> UIColor {
        if #available(iOS 13, *) {  // 版本号大于等于13
            return UIColor { (traitCollection: UITraitCollection) -> UIColor in
                return traitCollection.userInterfaceStyle == UIUserInterfaceStyle.dark ?
                dark : light
            }
        }
    }
    
    
    class func getTextFieldHighlightColor() -> UIColor {
        switch UserDefaults.standard.integer(forKey: "tintColorIndex"){
        case 0:
            return ColorUtil.dynamicColor(dark: UIColor(red: 0.439, green: 0.176, blue: 0.741, alpha: 1), light: UIColor(red: 40.0/255.0, green: 26.0/255.0, blue: 200.0/255.0, alpha: 1))
        case 1:
            let colors = [
                UIColor(red: 0.008, green: 0.667, blue: 0.690, alpha: 0.55),
                UIColor(red: 0.000, green: 0.804, blue: 0.675, alpha: 1)
                ]

            return ColorUtil.dynamicColor(dark: colors[1], light: colors[0])
        case 2:
            return UIColor.init(red: 70/255.0, green: 130/255.0, blue: 180/255.0, alpha: 0.75)
            
        default:
            return ColorUtil.dynamicColor(dark: UIColor(red: 0.439, green: 0.176, blue: 0.741, alpha: 1), light: UIColor(red: 40.0/255.0, green: 26.0/255.0, blue: 200.0/255.0, alpha: 1))
            
        }
    }
    
    
    
    /// 了解更多的渐变颜色，根据用户设置可变
    class func getGradTextStyle1() -> [UIColor] {

        
        switch UserDefaults.standard.integer(forKey: "tintColorIndex"){
        case 0:
            let color1 = UIColor(red: 255.0/255.0, green: 140.0/255.0, blue: 171.0/255.0, alpha: 1)
            let color2 = UIColor(red: 40.0/255.0, green: 26.0/255.0, blue: 200.0/255.0, alpha: 1)
            return [color1, color2]
            
        case 1:
            let colors = [
                UIColor(red: 0.067, green: 0.600, blue: 0.557, alpha: 1),
                getBarBtnColor()
                ]

            return colors

        case 2:
//            let colors = [
//                UIColor(red: 0.000, green: 0.824, blue: 1.000, alpha: 1),
//                getBarBtnColor()
//                ]
//
//            return colors
            let colors = [
                UIColor.init(red: 73/255.0, green: 148/255.0, blue: 167/255.0, alpha: 1),
                getBarBtnColor()
                ]

            return colors
        default:
            let color1 = UIColor(red: 255.0/255.0, green: 140.0/255.0, blue: 171.0/255.0, alpha: 1)
            let color2 = UIColor(red: 40.0/255.0, green: 26.0/255.0, blue: 200.0/255.0, alpha: 1)
            return [color1, color2]
        }
        
        
        
    }
    
    class func getGradBluePink() -> [UIColor] {
        switch UserDefaults.standard.integer(forKey: "tintColorIndex"){
        case 0:
            return [
                UIColor(red: 0.290, green: 0.302, blue: 0.639, alpha: 1),
                UIColor(red: 0.502, green: 0.522, blue: 0.835, alpha: 1)]
        case 1:
            let colors = [
                UIColor(red: 0.067, green: 0.600, blue: 0.557, alpha: 1),
                getBarBtnColor()
                ]

            return colors
        case 2:
            let colors = [
                UIColor.init(red: 73/255.0, green: 148/255.0, blue: 167/255.0, alpha: 1),
                getBarBtnColor()
                ]

            return colors
        default:
            return [
                UIColor(red: 0.290, green: 0.302, blue: 0.639, alpha: 1),
                UIColor(red: 0.502, green: 0.522, blue: 0.835, alpha: 1)]
        }
        


        
    }
    
    /// bar button 的颜色 深色模式——白色 浅色模式——紫色
    class func getBarBtnColor() -> UIColor{
        let colors = [
            /// 紫色
            UIColor.init(red: 127/255.0, green: 121/255.0, blue: 203/255.0, alpha: 1),
            /// 绿色
            UIColor(red: 0.522, green: 0.667, blue: 0.549, alpha: 1),

            /// 蓝色
            UIColor.init(red: 70/255.0, green: 130/255.0, blue: 180/255.0, alpha: 1),
            /// 金色
            UIColor.init(red: 255/255.0, green: 215/255.0, blue: 0/255.0, alpha: 1),
            /// 不知道
            UIColor(red: 0.416, green: 0.635, blue: 0.596, alpha: 1),
            ]

        let tintIndex = UserDefaults.standard.integer(forKey: "tintColorIndex")
        return colors[tintIndex]
    }
    
    
    class func getBarBtnColor_lowAlpha() -> UIColor{
        let colors = [
            /// 紫色
            UIColor.init(red: 127/255.0, green: 121/255.0, blue: 203/255.0, alpha: 0.2),
            /// 绿色
            UIColor(red: 0.522, green: 0.667, blue: 0.549, alpha: 0.2),

            /// 蓝色
            UIColor.init(red: 70/255.0, green: 130/255.0, blue: 180/255.0, alpha: 0.2),
            /// 金色
            UIColor.init(red: 255/255.0, green: 215/255.0, blue: 0/255.0, alpha: 0.2),
            /// 不知道
            UIColor(red: 0.416, green: 0.635, blue: 0.596, alpha: 0.12),
            ]

        let tintIndex = UserDefaults.standard.integer(forKey: "tintColorIndex")
        return colors[tintIndex]
    }
    
    
    
    class func getNavigationTitleColor() -> UIColor {
        switch UserDefaults.standard.integer(forKey: "appAppearance") {
        case 0:
            return dynamicColor(dark: UIColor.white, light: UIColor.black)
        case 1:
            return UIColor.black
        case 2:
            return UIColor.white
        default:
            return UIColor.white
            
        }
    }

    
    
    /// 主页方框的背景颜色
    class func runningOverviewBKColor() -> UIColor {
        //        return ColorUtil.dynamicColor(dark: UIColor.init(red: 42/255.0, green: 31/255.0, blue: 62/255.0, alpha: 1), light: UIColor.init(red: 242/255.0, green: 244/255.0, blue: 255/255.0, alpha: 1))
        //        let darkPurple = UIColor.init(red: 31/255.0, green: 1/255.0, blue: 54/255.0, alpha: 1)
        let darkPurple = UIColor.init(red: 18/255.0, green: 1/255.0, blue: 31/255.0, alpha: 1)
        
        return ColorUtil.dynamicColor(dark: darkPurple, light: UIColor.white)
    }
    
    
    /// 主页指标layer的阴影颜色
    class func runningOverviewLayerShadowColor() -> CGColor {
        return UIColor.init(red: 221/255.0, green: 217/255.0, blue: 224/255.0, alpha: 1).cgColor
    }
    
    class func getGeneralTintColorStyle1() -> UIColor{
        // 原来的浅色高亮紫 UIColor(red: 0.400, green: 0.200, blue: 0.600, alpha: 1.000)
        // UIColor(red: 0.698, green: 0.600, blue: 0.867, alpha: 1)
        // UIColor.init(red: 83/255.0, green: 80/255.0, blue: 176/255.0, alpha: 1)
        
        return ColorUtil.dynamicColor(dark:UIColor(red: 0.698, green: 0.600, blue: 0.867, alpha: 1), light: UIColor.init(red: 83/255.0, green: 80/255.0, blue: 176/255.0, alpha: 1))
//        return ColorUtil.dynamicColor(dark: UIColor.white, light: UIColor.black)
        
    }
    /// 浅色模式——浅黄   深色模式——深紫
    class func getBackgroundColorStyle1() -> UIColor{
        let colors = [
            UIColor(red: 0.988, green: 0.988, blue: 0.988, alpha: 1),
            UIColor(red: 0.973, green: 0.333, blue: 0.486, alpha: 1),
            UIColor(red: 1.000, green: 0.980, blue: 0.886, alpha: 1),
            UIColor(red: 0.600, green: 0.878, blue: 0.847, alpha: 1),
            UIColor(red: 0.365, green: 0.345, blue: 0.424, alpha: 1)
        ]
        
        let lightYellow = UIColor(red: 254.0/255.0, green: 251.0/255.0, blue: 247.0/255.0, alpha: 1)
        let lightPurple = UIColor.init(red: 237/255.0, green: 237/255.0, blue: 249/255.0, alpha: 1)
//        return ColorUtil.dynamicColor(dark: UIColor(red: 0.012, green: 0.000, blue: 0.118, alpha: 1), light: lightPurple)
        return ColorUtil.dynamicColor(dark: UIColor.black, light: UIColor.white)
        
    }
    

    class func getBackgroundColorStyle2() -> UIColor{
        return ColorUtil.dynamicColor(dark: UIColor(red: 0.698, green: 0.600, blue: 0.867, alpha: 0.1), light: UIColor(red: 254.0/255.0, green: 251.0/255.0, blue: 247.0/255.0, alpha: 0.2))
    }
    
    /// 浅色模式——白色   深色模式——深紫
    class func getBackgroundColorStyle3() -> UIColor{
        return ColorUtil.dynamicColor(dark: UIColor(red: 0.012, green: 0.000, blue: 0.118, alpha: 1), light: UIColor.white)
        
        
    }
    
    /// 浅色模式——白色   深色模式——深灰
    class func getCellBackgroundColorStyle() -> UIColor{
        return ColorUtil.dynamicColor(dark: UIColor(red: 15.0/255.0, green: 15.0/255.0, blue: 15.0/255.0, alpha: 1), light: UIColor.white)
    }
    

    
    /// 12个月跑量 黑 - 红 / 白 - 红渐变
    class func getGradTextStyle2() -> [UIColor] {
        let colors = [
            dynamicColor(dark: UIColor.white, light: UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1)),
            UIColor(red: 0.906, green: 0.298, blue: 0.235, alpha: 1)
        ]
        return colors
    }
    
    ///  紫色渐变
    class func getGradTextStyle3() -> [CGColor] {

        let colors = [
            UIColor.init(red: 127/255.0, green: 121/255.0, blue: 203/255.0, alpha: 1),
            UIColor(red: 0.812, green: 0.545, blue: 0.953, alpha: 1),
            UIColor.init(red: 127/255.0, green: 121/255.0, blue: 203/255.0, alpha: 1),
            ]
        
        return colors.map{$0.cgColor}
    }
    
    
    
    
    class func getGradOrange() -> [UIColor] {
        let colors = [
            UIColor(red: 0.949, green: 0.600, blue: 0.290, alpha: 1),
            UIColor(red: 0.949, green: 0.788, blue: 0.298, alpha: 1)
            ]

        return colors
    }
    
    class func getGradGray() -> [CGColor] {
        let colors = [
            dynamicColor(dark: UIColor.white, light: UIColor.black),
            UIColor(red: 0.173, green: 0.243, blue: 0.314, alpha: 1)
            ]
        return colors.map{$0.cgColor}
        
    }
    


    /// root VC中紫色渐变图像背景
    class func rootVCPurpleGradColor() -> [UIColor] {
        
        
        //        let c1 = dynamicColor(dark: UIColor.black, light: UIColor.white)
        ////        let c2 = dynamicColor(dark: UIColor(red: 0.133, green: 0.102, blue: 0.267, alpha: 1), light: UIColor(red: 241/255, green: 240/255, blue: 254/255, alpha: 1))
        //        let c2 = dynamicColor(dark: UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1), light: UIColor(red: 241/255, green: 240/255, blue: 254/255, alpha: 1))
        //        let c3 = dynamicColor(dark: UIColor(red: 0.133, green: 0.102, blue: 0.267, alpha: 1), light: UIColor(red: 225/255, green: 225/255, blue: 253/255, alpha: 1))
        let c2 = dynamicColor(dark: UIColor(red: 0.133, green: 0.102, blue: 0.267, alpha: 1), light: UIColor(red: 249/255, green: 248/255, blue: 253/255, alpha: 1))
        
        let c3 = dynamicColor(dark: UIColor(red: 0.133, green: 0.102, blue: 0.267, alpha: 1), light: UIColor(red: 239/255, green: 238/255, blue: 254/255, alpha: 1))
        return [c2, c3]
        
    }
    
    /// 正方形指标的颜色
    class func rootVCSquareGradColorStyle1() -> [UIColor] {
        
        let c2 = dynamicColor(dark: UIColor(red: 0.133, green: 0.102, blue: 0.267, alpha: 1), light: UIColor(red: 249/255, green: 248/255, blue: 253/255, alpha: 1))
        
        let c3 = dynamicColor(dark: UIColor(red: 0.133, green: 0.102, blue: 0.267, alpha: 1), light: UIColor(red: 239/255, green: 238/255, blue: 254/255, alpha: 1))
        let c4 = dynamicColor(dark: UIColor(red: 0.133, green: 0.102, blue: 0.267, alpha: 0.7), light: getPurpleSet()[2])
        
        return [c2, c3, c4]
    }
    class func rootVCSquareGradColorStyle2() -> UIColor {
        
//        let c2 = dynamicColor(dark: UIColor(red: 0.133, green: 0.102, blue: 0.267, alpha: 1), light: UIColor(red: 249/255, green: 248/255, blue: 253/255, alpha: 1))
//
//        let c3 = dynamicColor(dark: UIColor(red: 0.133, green: 0.102, blue: 0.267, alpha: 1), light: UIColor(red: 239/255, green: 238/255, blue: 254/255, alpha: 1))
//
//        return [c2, c3]
        let darkColor = UIColor.init(red: 27/255.0, green: 27/255.0, blue: 27/255.0, alpha: 1)
        // UIColor(red: 0.133, green: 0.102, blue: 0.267, alpha: 1)
        return dynamicColor(dark: darkColor, light: UIColor.white)
        
    }
    
    
    
    class func rootVCRectGradColor() -> [UIColor] {
        let c2 = dynamicColor(dark: UIColor(red: 0.133, green: 0.102, blue: 0.267, alpha: 1), light: UIColor(red: 249/255, green: 248/255, blue: 253/255, alpha: 1))
        
        let c3 = UIColor.systemGray6
        // dynamicColor(dark: UIColor(red: 0.133, green: 0.102, blue: 0.267, alpha: 1), light: UIColor(red: 239/255, green: 238/255, blue: 254/255, alpha: 1))
        //        let c4 = dynamicColor(dark: UIColor.black, light: UIColor.white)
        return [c2, c3]
    }
    
    class func getPurpleSet() -> [UIColor] {
        let colors = [
            UIColor(red: 0.290, green: 0.302, blue: 0.639, alpha: 1),
            UIColor(red: 0.502, green: 0.522, blue: 0.835, alpha: 0.2),
            UIColor(red: 0.776, green: 0.800, blue: 0.941, alpha: 0.4),
            UIColor(red: 0.894, green: 0.910, blue: 0.949, alpha: 1),
            UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1)
        ]
        return colors
    }
    
    
    /// 返回series图各个月的颜色
    class func getMonthSeriesColor() -> [UIColor] {
        let colors = [
            UIColor(red: 0.965, green: 0.816, blue: 0.800, alpha: 1),
            UIColor(red: 0.910, green: 0.761, blue: 0.792, alpha: 1),
            UIColor(red: 0.816, green: 0.702, blue: 0.773, alpha: 1),
            UIColor(red: 0.698, green: 0.573, blue: 0.675, alpha: 1),
            UIColor(red: 0.451, green: 0.365, blue: 0.467, alpha: 1)
        ]
        
        return colors
    }
    
    /// 分段控件颜色设置
    class func getSegConColor() -> (bk: UIColor, border: UIColor, highlight: UIColor, normalTxt: UIColor, selectedTxt: UIColor) {
//        let bkColor = dynamicColor(dark: UIColor(red: 0.133, green: 0.102, blue: 0.267, alpha: 1), light: UIColor.init(red: 202/255.0, green: 200/255.0, blue: 244/255.0, alpha: 1))
        let bkColor = UIColor.systemGroupedBackground
        
        
        let borderColor = dynamicColor(dark: UIColor.systemGroupedBackground, light: UIColor.black)
        
        //
        //UIColor.init(red: 159/255.0, green: 151/255.0, blue: 254/255.0, alpha: 1)
        let highlightColor = ColorUtil.getBarBtnColor()
        
        let normalTextColor = UIColor.label
        let selectedTextColor = dynamicColor(dark: UIColor(red: 0.012, green: 0.000, blue: 0.118, alpha: 1), light: UIColor.white)
        return (bkColor, borderColor, highlightColor, normalTextColor, selectedTextColor)
    }
    
    class func getMonthlyStatViewBKColor() -> UIColor {
        //        let darkColor = UIColor.init(red: 41/255.0, green: 51/255.0, blue: 60/255.0, alpha: 1)
        let darkColor = UIColor.init(red: 27/255.0, green: 27/255.0, blue: 27/255.0, alpha: 1)
        // UIColor(red: 0.133, green: 0.102, blue: 0.267, alpha: 1)
        
        return dynamicColor(dark: darkColor, light: UIColor.white)
//        return UIColor.systemGray6
    }
    
    /// 主页 line图序列的颜色
    /// df
    class func getSeriesColor() -> UIColor{
        
        return dynamicColor(dark: UIColor.init(red: 230/255.0, green: 230/255.0, blue: 250/255.0, alpha: 1), light: UIColor(red: 40.0/255.0, green: 26.0/255.0, blue: 200.0/255.0, alpha: 1))
    }
    
    
    /// AILab 的渐变绿色
    class func getAILabGreen() -> [UIColor] {
        let colors = [
            UIColor(red: 0.082, green: 0.600, blue: 0.341, alpha: 1),
            UIColor(red: 0.082, green: 0.341, blue: 0.600, alpha: 1)
            ]
        return colors
        
    }
    
    class func updateAppearance(_ view: UIView) {
        switch UserDefaults.standard.integer(forKey: "appAppearance") {
        case 0:
            //
            break
            
        case 1:
            DispatchQueue.main.async {
                view.overrideUserInterfaceStyle = .light
            }
        case 2:
            DispatchQueue.main.async {
                view.overrideUserInterfaceStyle = .dark
            }
        default:
            break
        }
    }
    
    /// 心率区间的颜色
    class func getHRZoneColors() -> [UIColor] {
        let colorsSet1 = [UIColor.init(red: 60/255.0, green: 163/255.0, blue: 247/255.0, alpha: 0.3),
                          UIColor.init(red: 68/255.0, green: 240/255.0, blue: 225/255.0, alpha: 0.3),
                          UIColor.init(red: 188/255.0, green: 254/255.0, blue: 0/255.0, alpha: 0.3),
                          UIColor.init(red: 254/255.0, green: 128/255.0, blue: 6/255.0, alpha: 0.3),
                          UIColor.init(red: 253/255.0, green: 11/255.0, blue: 108/255.0, alpha: 0.3)
        
        ]
        let colorsSet2 = [UIColor.init(red: 60/255.0, green: 163/255.0, blue: 247/255.0, alpha: 1),
                          UIColor.init(red: 68/255.0, green: 240/255.0, blue: 225/255.0, alpha: 1),
                          UIColor.init(red: 188/255.0, green: 254/255.0, blue: 0/255.0, alpha: 1),
                          UIColor.init(red: 254/255.0, green: 128/255.0, blue: 6/255.0, alpha: 1),
                          UIColor.init(red: 253/255.0, green: 11/255.0, blue: 108/255.0, alpha: 1)
        
        ]
        
        return colorsSet1
    }
    /// 心率区间的颜色Hex
    class func getHRZoneColorsInHex() -> [String] {
        return [AAColor.rgbaColor(60, 163, 247, 0.3),
                AAColor.rgbaColor(68, 240, 225, 0.3),
                AAColor.rgbaColor(188, 254, 0, 0.3),
                AAColor.rgbaColor(254, 128, 6, 0.3),
                AAColor.rgbaColor(253, 11, 108, 0.3),
        ]
    }
    
}


