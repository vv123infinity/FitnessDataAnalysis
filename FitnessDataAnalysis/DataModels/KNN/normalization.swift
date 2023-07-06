//
//  normalization.swift
//  FitnessWithML
//
//  Created by Infinity vv123 on 2022/10/1.
//

import Foundation

func getRange(_ input: [CGFloat]) -> CGFloat {
    let maxVal: CGFloat = input.max() ?? 1
    let minVal: CGFloat = input.min() ?? 0
    return maxVal - minVal
}


// Y正常归一化，X带比例归一化
func normalizeWithRatio(_ xx:[CGFloat], _ ratio: CGFloat) -> [CGFloat]{
    var normOutput: [CGFloat] = []
    let maxVal: CGFloat = xx.max() ?? 1
    let minVal: CGFloat = xx.min() ?? 0
    let rangeMaxMin: CGFloat = maxVal - minVal
    for ii in xx {
        let newItem = ((ii - minVal) / rangeMaxMin) * ratio
        normOutput.append(newItem)
    }
    return normOutput
}

func normalizationRange(_ input: [CGFloat]) -> [CGFloat]{
    var normOutput: [CGFloat] = []
    
    let maxVal: CGFloat = input.max() ?? 1
    let minVal: CGFloat = input.min() ?? 0
    let rangeMaxMin: CGFloat = maxVal - minVal
    for ii in input {
        let newItem = (ii - minVal) / rangeMaxMin
        normOutput.append(newItem)
    }
    
    return normOutput
}
    


func centralization(_ xx: [CGFloat], _ yy: [CGFloat]) -> [[CGFloat]] {
    let avgX = CGFloat(xx.reduce(0, +)) / CGFloat(xx.count)
    let biasX = 0.5 - avgX
    let cenX = xx.map{$0+biasX}

    let avgY = CGFloat(yy.reduce(0, +)) / CGFloat(yy.count)
    let biasY = 0.5 - avgY
    let cenY = yy.map{$0+biasY}
    
    return [cenX, cenY]
}
