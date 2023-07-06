//
//  SmileyFontSize.swift
//  FitnessDataAnalysis
//
//  Created by 十口V🌼 on 2023/3/21.
//

import Foundation
import UIKit

class SmileyFontSize {
    class func getFootnote() -> UIFont {
        return UIFont(name: "Smiley Sans", size: 14)!
    }
    class func getButton() -> UIFont {
        return UIFont(name: "Smiley Sans", size: 17)!
    }
    
    class func getNormal() -> UIFont {
        return UIFont(name: "Smiley Sans", size: 17)!
    }
    class func getMedium() -> UIFont {
        return UIFont(name: "Smiley Sans", size: 19)!
    }
    
    
    class func getBig() -> UIFont {
        return UIFont(name: "Smiley Sans", size: 21)!
    }
    
    class func getInSize(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Smiley Sans", size: size)!
    }
    
    
    class func getBigger() -> UIFont{
        return UIFont(name: "Smiley Sans", size: 23)!
    }
    
    
    class func getLarge() -> UIFont{
        return UIFont(name: "Smiley Sans", size: 28)!
    }
    class func getHuge() -> UIFont{
        return UIFont(name: "Smiley Sans", size: 45)!
    }
    
    /// 已经进行了判断 if UserDefaults.standard.bool(forKey: "useSmiley")
    class func getCellFont() -> UIFont {
        if UserDefaults.standard.bool(forKey: "useSmiley"){
            return getNormal()
        }
        else{
//            return UIFont.systemFont(ofSize: 16, weight: .semibold)
//            return UIFont.systemFont(ofSize: 16, weight: .regular)
            return UIFont.systemFont(ofSize: 15, weight: .medium)
        }
    }
    
    /// 已经进行了判断 if UserDefaults.standard.bool(forKey: "useSmiley")
    class func getCellFontSecond() -> UIFont {
        if UserDefaults.standard.bool(forKey: "useSmiley"){
            return getFootnote()
        }
        else{
            return UIFont.systemFont(ofSize: 13, weight: .regular)
        }
    }
    
}
