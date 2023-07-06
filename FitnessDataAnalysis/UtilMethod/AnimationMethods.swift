//
//  AnimationMethods.swift
//  FitnessDataAnalysis
//
//  Created by 十口V🌼 on 2023/4/1.
//

import Foundation
import UIKit


class AnimationMethods {
    
    
    /// 按钮从底部往上弹跳出
    class func buttonAnimationStyle1BottomUp(_ btn: UIButton) {
        let originalPos = btn.center
        let startPos = CGPoint(x: originalPos.x, y: originalPos.y + 40)
        btn.center = startPos
        ///在UIView.animate方法中，我们使用了一些参数来控制动画效果。例如，usingSpringWithDamping参数可以设置弹簧动画的阻尼系数，initialSpringVelocity参数可以设置弹簧动画的初始速度，options参数可以设置动画的加速度曲线。这些参数可以根据需要进行调整，以获得不同的动画效果。
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            btn.isHidden = false
            btn.center = originalPos
        }, completion: nil)
    }
    
    
    
}
