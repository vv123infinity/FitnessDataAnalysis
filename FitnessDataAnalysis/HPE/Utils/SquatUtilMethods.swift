//
//  SquatUtilMethods.swift
//  FitnessDataAnalysis
//
//  Created by 十口V🌼 on 2023/3/31.
//

import Foundation
// MARK: - Squat Methods

func + (left: CGPoint, right: CGPoint) -> CGPoint {
   return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (_ left: CGPoint, _ right: CGPoint) -> CGPoint {
   return CGPoint(x: left.x - right.x, y: left.y - right.y)
}


func cosine_angle_CGPoint(_ edge1: CGPoint, _ edge2: CGPoint) -> CGFloat {
    let dotProduct = edge1.x * edge2.x + edge1.y * edge2.y
    let edge1Dist = sqrt(edge1.x * edge1.x + edge1.y * edge1.y)
    let edge2Dist = sqrt(edge2.x * edge2.x + edge2.y * edge2.y)
    let res = dotProduct / (edge1Dist*edge2Dist)
    return res
}

func angle_between_points(_ pointA: CGPoint, _ pointB: CGPoint, _ pointC: CGPoint) -> CGFloat {
    let edgeAB: CGPoint = pointB - pointA
    let edgeBC: CGPoint = pointC - pointB
    let res = cosine_angle_CGPoint(edgeAB, edgeBC)
    let radAngle = acos(res)
    let degAngle = (radAngle*180)/Double.pi
    return degAngle
}


func get_knee_angle(_ leftHipPoint: CGPoint, _ rightHipPoint: CGPoint,
                    _ leftKneePoint: CGPoint, _ rightKneePoint: CGPoint,
                    _ leftAnklePoint: CGPoint, _ rightAnklePoint: CGPoint) -> [CGFloat] {
    let hipSum = leftHipPoint + rightHipPoint
    let hipMean = CGPoint(x: hipSum.x/2, y: hipSum.y/2)
    let kneeSum = leftKneePoint + rightKneePoint
    let kneeMean = CGPoint(x: kneeSum.x/2, y: kneeSum.y/2)
    let ankleSum = leftAnklePoint + rightAnklePoint
    let ankleMean = CGPoint(x: ankleSum.x/2, y: ankleSum.y/2)
    // 右膝角度
    let rAngle = angle_between_points(rightHipPoint, rightKneePoint, rightAnklePoint)
    // 左膝角度
    let lAngle = angle_between_points(leftHipPoint, leftKneePoint, leftAnklePoint)
    // 平均角度
    let midAngle = angle_between_points(hipMean, kneeMean, ankleMean)
    let res: [CGFloat] = [rAngle, lAngle, midAngle]
    return res
}
