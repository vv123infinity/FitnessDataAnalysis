//
//  ColorUtil.swift
//  FitnessDataAnalysis
//
//  Created by Infinity vv123 on 2023/2/24.
//

import UIKit
class ColorUtil {
    public class func dynamicColor(dark:UIColor, light:UIColor) -> UIColor {
        if #available(iOS 13, *) {  // 版本号大于等于13
            return UIColor { (traitCollection: UITraitCollection) -> UIColor in
                return traitCollection.userInterfaceStyle == UIUserInterfaceStyle.dark ?
                dark : light
            }
        }
        return light
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
        return ColorUtil.dynamicColor(dark: UIColor(red: 0.012, green: 0.000, blue: 0.118, alpha: 1), light: lightPurple)
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
    
    
    
    class func getGradTextStyle1() -> [UIColor] {
        let color1 = UIColor(red: 255.0/255.0, green: 140.0/255.0, blue: 171.0/255.0, alpha: 1)
        let color2 = UIColor(red: 40.0/255.0, green: 26.0/255.0, blue: 200.0/255.0, alpha: 1)
        return [color1, color2]
    }
    
    /// 12个月跑量 黑 - 红 / 白 - 红渐变
    class func getGradTextStyle2() -> [UIColor] {
        let colors = [
            dynamicColor(dark: UIColor.white, light: UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1)),
            UIColor(red: 0.906, green: 0.298, blue: 0.235, alpha: 1)
        ]
        return colors
    }
    
    /// 上个月跑量 蓝色渐变
    class func getGradTextStyle3() -> [CGColor] {
        let colors = [
            // UIColor.init(red: 176/255.0, green: 224/255.0, blue: 230/255.0, alpha: 1)
            dynamicColor(dark: UIColor.init(red: 176/255.0, green: 224/255.0, blue: 230/255.0, alpha: 1), light: UIColor.init(red: 47/255.0, green: 48/255.0, blue: 145/255.0, alpha: 1)),
            
            UIColor.init(red: 41/255.0, green: 92/255.0, blue: 170/255.0, alpha: 1),
            UIColor(red: 0.647, green: 0.996, blue: 0.796, alpha: 1)
        ]
        return colors.map{$0.cgColor}
    }
    
    
    class func getTextFieldHighlightColor() -> UIColor {
        let colors = [
            UIColor(red: 0.439, green: 0.176, blue: 0.741, alpha: 1),
            UIColor(red: 0.651, green: 0.388, blue: 0.800, alpha: 1),
            UIColor(red: 0.698, green: 0.600, blue: 0.867, alpha: 1),
            UIColor(red: 0.722, green: 0.816, blue: 0.922, alpha: 1),
            UIColor(red: 0.725, green: 0.980, blue: 0.973, alpha: 1)
        ]
        return ColorUtil.dynamicColor(dark: UIColor(red: 0.439, green: 0.176, blue: 0.741, alpha: 1), light: UIColor(red: 40.0/255.0, green: 26.0/255.0, blue: 200.0/255.0, alpha: 1))
    }
    
    /// bar button 的颜色 深色模式——白色 浅色模式——紫色
    class func getBarBtnColor() -> UIColor{
        return ColorUtil.dynamicColor(dark: UIColor.white, light: UIColor(red: 40.0/255.0, green: 26.0/255.0, blue: 200.0/255.0, alpha: 1))
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
    class func rootVCSquareGradColorStyle2() -> [UIColor] {
        
//        let c2 = dynamicColor(dark: UIColor(red: 0.133, green: 0.102, blue: 0.267, alpha: 1), light: UIColor(red: 249/255, green: 248/255, blue: 253/255, alpha: 1))
//
//        let c3 = dynamicColor(dark: UIColor(red: 0.133, green: 0.102, blue: 0.267, alpha: 1), light: UIColor(red: 239/255, green: 238/255, blue: 254/255, alpha: 1))
//
//        return [c2, c3]
        let darkColor = UIColor.init(red: 27/255.0, green: 27/255.0, blue: 27/255.0, alpha: 1)
        // UIColor(red: 0.133, green: 0.102, blue: 0.267, alpha: 1)
        return [dynamicColor(dark: darkColor, light: UIColor.white), dynamicColor(dark: darkColor, light: UIColor.white)]
        
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
        let bkColor = dynamicColor(dark: UIColor(red: 0.133, green: 0.102, blue: 0.267, alpha: 1), light: UIColor.init(red: 202/255.0, green: 200/255.0, blue: 244/255.0, alpha: 1))
        let borderColor = dynamicColor(dark: UIColor.white, light: UIColor.black)
        
        //
        //UIColor.init(red: 159/255.0, green: 151/255.0, blue: 254/255.0, alpha: 1)
        let highlightColor = dynamicColor(dark: UIColor.white, light: UIColor.init(red: 127/255.0, green: 121/255.0, blue: 203/255.0, alpha: 1))
        
        let normalTextColor = dynamicColor(dark: UIColor.white, light: UIColor.black)
        let selectedTextColor = dynamicColor(dark: UIColor(red: 0.012, green: 0.000, blue: 0.118, alpha: 1), light: UIColor.white)
        return (bkColor, borderColor, highlightColor, normalTextColor, selectedTextColor)
    }
    
    class func getMonthlyStatViewBKColor() -> UIColor {
        //        let darkColor = UIColor.init(red: 41/255.0, green: 51/255.0, blue: 60/255.0, alpha: 1)
        let darkColor = UIColor.init(red: 27/255.0, green: 27/255.0, blue: 27/255.0, alpha: 1)
        // UIColor(red: 0.133, green: 0.102, blue: 0.267, alpha: 1)
        return dynamicColor(dark: darkColor, light: UIColor.white)
    }
    
    /// 主页 line图序列的颜色
    /// df
    class func getSeriesColor() -> UIColor{
        
        return dynamicColor(dark: UIColor.init(red: 230/255.0, green: 230/255.0, blue: 250/255.0, alpha: 1), light: UIColor(red: 40.0/255.0, green: 26.0/255.0, blue: 200.0/255.0, alpha: 1))
    }
    
}


