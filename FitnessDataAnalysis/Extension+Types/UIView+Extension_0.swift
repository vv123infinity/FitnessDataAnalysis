//
//  UIView+Extension.swift
//  FitnessDataAnalysis
//
//  Created by Infinity vv123 on 2023/2/27.
//

import Foundation
import UIKit
extension UIView {
    func applyBlurEffect(_ style: UIBlurEffect.Style = .light) {
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurEffectView)
    }
}
