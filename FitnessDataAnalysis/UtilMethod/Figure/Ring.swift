//
//  RIng.swift
//  FitnessDataAnalysis
//
//  Created by Infinity vv123 on 2023/3/18.
//

import Foundation
import UIKit

class RingOutside: UIView {
    
    override func draw(_ rect: CGRect) {
        drawRingFittingInsideView()
    }
    
    internal func drawRingFittingInsideView() -> () {
        let halfSize:CGFloat = min( bounds.size.width/2, bounds.size.height/2)
        let desiredLineWidth:CGFloat = 2 // your desired value
            
        let circlePath = UIBezierPath(
                arcCenter: CGPoint(x:halfSize,y:halfSize),
                radius: CGFloat( halfSize - (desiredLineWidth/2) ),
                startAngle: CGFloat(0),
                endAngle:CGFloat(CGFloat.pi * 2),
                clockwise: true)
    
         let shapeLayer = CAShapeLayer()
         shapeLayer.path = circlePath.cgPath
//255, 229, 231, 254 255, 220, 220, 246
        shapeLayer.fillColor = UIColor(red: 229/255, green: 231/255, blue: 254/255, alpha: 1).cgColor
        shapeLayer.shadowColor = UIColor(red: 220/255, green: 220/255, blue: 246/255, alpha: 1).cgColor
        shapeLayer.shadowRadius = 10
        shapeLayer.shadowOffset = .zero
        shapeLayer.shadowOpacity = 1
        shapeLayer.strokeColor = UIColor.clear.cgColor
         shapeLayer.lineWidth = desiredLineWidth
    
         layer.addSublayer(shapeLayer)
     }
}


class RingInside: UIView {
    
    override func draw(_ rect: CGRect) {
        drawRingFittingInsideView()
    }
    
    internal func drawRingFittingInsideView() -> () {
        let halfSize:CGFloat = min( bounds.size.width/2, bounds.size.height/2)
        let desiredLineWidth:CGFloat = 4 // your desired value
            
        let circlePath = UIBezierPath(
                arcCenter: CGPoint(x:halfSize,y:halfSize),
                radius: CGFloat( halfSize - (desiredLineWidth/2) ),
                startAngle: CGFloat(0),
                endAngle:CGFloat(CGFloat.pi * 2),
                clockwise: true)
    
         let shapeLayer = CAShapeLayer()
         shapeLayer.path = circlePath.cgPath
//255, 229, 231, 254 255, 254, 250, 254
        shapeLayer.fillColor = UIColor.red.cgColor
//        shapeLayer.fillColor = UIColor(red: 254/255, green: 250/255, blue: 254/255, alpha: 1).cgColor
        
        shapeLayer.strokeColor = UIColor.white.cgColor
        
//        shapeLayer.shadowColor = UIColor.systemGray5.cgColor
        
        shapeLayer.lineWidth = desiredLineWidth
    
         layer.addSublayer(shapeLayer)
        
     }
}

