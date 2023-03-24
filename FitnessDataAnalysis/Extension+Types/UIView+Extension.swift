//
//  UIView+Extension.swift
//  FitnessWithML
//
//  Created by Infinity vv123 on 2022/9/30.
//


import Foundation
import UIKit

extension UIView {

    func fadeIn() {
        //Swift 3, 4, 5
        UIView.animate(withDuration: 1.0, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0
        }, completion: nil)
    }


    func fadeOut() {
        //Swift 3, 4, 5
        UIView.animate(withDuration: 0.2, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.alpha = 0.0
        }, completion: nil)
    }


}
