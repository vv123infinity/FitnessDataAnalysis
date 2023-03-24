//
//  GradientButton.swift
//  FitnessDataAnalysis
//
//  Created by Infinity vv123 on 2023/2/27.
//

import Foundation
import UIKit
class ActualGradientButtonRedToBlueCR5: UIButton {

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    private lazy var gradientLayer: CAGradientLayer = {
        let l = CAGradientLayer()
        l.frame = self.bounds
        let color1 = UIColor(red: 255.0/255.0, green: 140.0/255.0, blue: 171.0/255.0, alpha: 1)
        let color2 = UIColor(red: 40.0/255.0, green: 26.0/255.0, blue: 200.0/255.0, alpha: 1)
        let colors = [color1, color2]
        l.colors = colors.map{$0.cgColor}
        l.startPoint = CGPoint(x: 0.5, y:0)
        l.endPoint = CGPoint(x: 0.5, y: 1)
        l.cornerRadius = 5
        layer.insertSublayer(l, at: 0)
        return l
    }()
    
}

class ActualGradientButtonRedToBlueCR10: UIButton {

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    private lazy var gradientLayer: CAGradientLayer = {
        let l = CAGradientLayer()
        l.frame = self.bounds
//        let colors = [
//            UIColor(red: 0.114, green: 0.169, blue: 0.392, alpha: 1),
//            UIColor(red: 0.973, green: 0.804, blue: 0.855, alpha: 1)
//            ]
//        let colors = [
//            UIColor(red: 0.659, green: 0.753, blue: 1.000, alpha: 1),
//            UIColor(red: 0.247, green: 0.169, blue: 0.588, alpha: 1)
//            ]
        
//        let colors = [
//            UIColor(red: 0.396, green: 0.306, blue: 0.639, alpha: 1),
//            UIColor(red: 0.918, green: 0.686, blue: 0.784, alpha: 1)
//            ]
        let color1 = UIColor(red: 255.0/255.0, green: 140.0/255.0, blue: 171.0/255.0, alpha: 1)
        let color2 = UIColor(red: 40.0/255.0, green: 26.0/255.0, blue: 200.0/255.0, alpha: 1)
        let colors = [color1, color2]
        l.colors = colors.map{$0.cgColor}
        l.startPoint = CGPoint(x: 0.5, y:0)
        l.endPoint = CGPoint(x: 0.5, y: 1)
        l.cornerRadius = 10
        layer.insertSublayer(l, at: 0)
        return l
    }()
    
    override func draw(_ rect: CGRect) {
        updateLayerProperties()
    }

    func updateLayerProperties() {
        self.layer.shadowColor = ColorUtil.dynamicColor(dark: UIColor(red: 1, green: 1, blue: 1, alpha: 0.2), light: UIColor(red: 0, green: 0, blue: 0, alpha: 0.35)).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 10.0
        self.layer.masksToBounds = false
    }
}

class GradButtonPurple: UIButton {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    private lazy var gradientLayer: CAGradientLayer = {
        let l = CAGradientLayer()
        l.frame = self.bounds

        let colors = [
            UIColor(red: 0.788, green: 0.839, blue: 1.000, alpha: 0.2),
            UIColor(red: 0.886, green: 0.886, blue: 0.886, alpha: 0.2)
            ]

        l.colors = colors.map{$0.cgColor}
        l.startPoint = CGPoint(x: 0, y:0)
        l.endPoint = CGPoint(x: 1, y: 1)
        l.cornerRadius = 10
        layer.insertSublayer(l, at: 0)
        return l
    }()
    
    override func draw(_ rect: CGRect) {
        updateLayerProperties()
    }

    func updateLayerProperties() {
        self.layer.shadowColor = ColorUtil.dynamicColor(dark: UIColor(red: 1, green: 1, blue: 1, alpha: 0.2), light: UIColor(red: 0, green: 0, blue: 0, alpha: 0.35)).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowOpacity = 0.25
        self.layer.shadowRadius = 15.0
        self.layer.masksToBounds = false
    }

}

class ActualGradientGray1: UIButton {

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    private lazy var gradientLayer: CAGradientLayer = {
        let l = CAGradientLayer()
        l.frame = self.bounds
        l.colors = [
            UIColor(red: 0.671, green: 0.729, blue: 0.671, alpha: 1),
            UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1)
            ]
//        let colors = [
//            UIColor(red: 1.000, green: 0.933, blue: 0.933, alpha: 1),
//            UIColor(red: 0.867, green: 0.937, blue: 0.733, alpha: 1)
//            ]

        l.startPoint = CGPoint(x: 0, y: 0.5)
        l.endPoint = CGPoint(x: 1, y: 0.5)
        l.cornerRadius = 20
        
        layer.insertSublayer(l, at: 0)
        return l
    }()
    
    override func draw(_ rect: CGRect) {
           updateLayerProperties()
       }

       func updateLayerProperties() {
           self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
           self.layer.shadowOffset = CGSize(width: 0, height: 3)
           self.layer.shadowOpacity = 1.0
           self.layer.shadowRadius = 10.0
           self.layer.masksToBounds = false
       }
    
    
}

class ActualGradientGray2: UIButton {

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    private lazy var gradientLayer: CAGradientLayer = {
        let l = CAGradientLayer()
        l.frame = self.bounds

        let colors = [
            UIColor(red: 1.000, green: 0.933, blue: 0.933, alpha: 1),
            UIColor(red: 0.867, green: 0.937, blue: 0.733, alpha: 1)
            ]
        l.colors = colors

        l.startPoint = CGPoint(x: 0, y: 0.5)
        l.endPoint = CGPoint(x: 1, y: 0.5)
        l.cornerRadius = 20
        
        layer.insertSublayer(l, at: 0)
        return l
    }()
    
    override func draw(_ rect: CGRect) {
           updateLayerProperties()
       }

       func updateLayerProperties() {
           self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
           self.layer.shadowOffset = CGSize(width: 0, height: 3)
           self.layer.shadowOpacity = 1.0
           self.layer.shadowRadius = 10.0
           self.layer.masksToBounds = false
       }
    
    
}


class ActualGradientButtonBlueToGreen: UIButton {

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    private lazy var gradientLayer: CAGradientLayer = {
        let l = CAGradientLayer()
        l.frame = self.bounds

        let colors = [
            UIColor(red: 0.204, green: 0.910, blue: 0.620, alpha: 1),
            UIColor(red: 0.059, green: 0.204, blue: 0.263, alpha: 1)
            ]


        l.colors = colors.map{$0.cgColor}
        l.startPoint = CGPoint(x: 0, y:0)
        l.endPoint = CGPoint(x: 1, y: 1)
        l.cornerRadius = 10
        layer.insertSublayer(l, at: 0)
        return l
    }()
    
    override func draw(_ rect: CGRect) {
        updateLayerProperties()
    }

    func updateLayerProperties() {
        self.layer.shadowColor = ColorUtil.dynamicColor(dark: UIColor(red: 1, green: 1, blue: 1, alpha: 0.2), light: UIColor(red: 0, green: 0, blue: 0, alpha: 0.35)).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 10.0
        self.layer.masksToBounds = false
    }
}

