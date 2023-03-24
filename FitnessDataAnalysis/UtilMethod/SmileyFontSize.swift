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
    class func getBig() -> UIFont {
        return UIFont(name: "Smiley Sans", size: 21)!
    }
    
    class func getBigger() -> UIFont{
        return UIFont(name: "Smiley Sans", size: 23)!
    }
    
    class func getCellFont() -> UIFont {
        if UserDefaults.standard.bool(forKey: "useSmiley"){
            return getNormal()
        }
        else{
            return UIFont.systemFont(ofSize: 16, weight: .medium)
        }
    }
    
}
