//
//  AnomalyDetectionConfig.swift
//  FitnessDataAnalysis
//
//  Created by Infinity vv123 on 2023/6/1.
//

import Foundation


struct AnomalyDetectionConfig {
    /// 基于置信区间的最小次数跨度
    var mimCountCover: Int = 10
    /// 基于置信区间的最大次数跨度
    var maxCountCover: Int = 15
    /// 构建置信区间的长度
    var minLenOfCI: Int = 10
    
}
