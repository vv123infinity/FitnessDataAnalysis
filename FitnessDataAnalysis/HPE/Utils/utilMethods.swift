//
//  utilMethods.swift
//  FitnessDataAnalysis
//
//  Created by Infinity vv123 on 2023/4/19.
//

import Foundation
//
//  utilMethods.swift
//  FitnessWithML
//
//  Created by Infinity vv123 on 2022/10/18.
//

import Foundation

func getLatestSdpose() -> [Double] {
    let defaults = UserDefaults.standard
    let normalXPosition: [Double] = defaults.array(forKey: "lastNormX") as! [Double]
    let normalYPosition: [Double] = defaults.array(forKey: "lastNormY") as! [Double]
    var res: [Double] = []
    for i in 0..<normalXPosition.count {
        res.append(normalXPosition[i])
        res.append(normalYPosition[i])
    }
    return res
    
}


func dot(A: [Double], B: [Double]) -> Double {
    var x: Double = 0
    for i in 0...A.count-1 {
        x += A[i] * B[i]
    }
    return x
}


func magnitude(A: [Double]) -> Double {
    var x: Double = 0
    for elt in A {
        x += elt * elt
    }
    return sqrt(x)
}


func consineDistance(_ userInputPose: [Double], _ sdPose: [Double]) -> Double {
    /// userInputPose ~ vec1 - Pose predicted by model
    /// standPose ~ vec2 - Standard Pose stored in DB
    return dot(A: userInputPose, B: sdPose) / (magnitude(A: userInputPose) * magnitude(A: sdPose))
}


func cosineDistanceMatching(_ userInputPose: [Double], _ sdPose: [Double]) -> Double {
    /// userInputPose ~ vec1 - Pose predicted by model
    /// standPose ~ vec2 - Standard Pose stored in DB
    let cosineSimilarity = consineDistance(userInputPose, sdPose)
    let distance = 2 * (1 - cosineSimilarity)
    return sqrt(distance)
}



func confidenceDistance(_ userInputPose: [Double], _ userInputPoseConf: [Double], _ sdPose: [Double]) -> Double {
    /// userInputPose ~ vec1 - Pose predicted by model
    ///                      - (1, 34)
    /// userInputPoseConf - the confidence of 17 joints
    ///                      - (1, 17)
    /// standPose ~ vec2 - Standard Pose stored in DB
    ///                      - (1, 34)
    let sumConfidence: Double = userInputPoseConf.reduce(0, +)
    let summation1: Double = Double(1.0 / sumConfidence)
    var summation2: Double = 0.0
    for i in 0..<userInputPose.count {
        let tempConf: Int = Int(i/2)
        let tempSum: Double = userInputPoseConf[tempConf] * abs(userInputPose[i] - sdPose[i])
        summation2 = summation2 + tempSum
    }
    return summation1 * summation2
}


