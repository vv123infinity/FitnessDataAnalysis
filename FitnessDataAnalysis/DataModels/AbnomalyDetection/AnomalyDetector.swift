//
//  AbnomalyDetector.swift
//  FitnessDataAnalysis
//
//  Created by Infinity vv123 on 2023/6/1.

// MARK: - Packages
// SigmaSwiftStatistics详细的见https://github.com/evgenyneu/SigmaSwiftStatistics
// DBSCAN和simd是调包的，详细的见https://github.com/NSHipster/DBSCAN


import Foundation
import SigmaSwiftStatistics
import DBSCAN
import simd

class AnomalyDetector {
    /// 时间序列数据对应的时间
    var inputDate: [String]
    /// 需要被检测的序列数据，时间按过去到现在
    var inputData: [Double]
    /// 检测器的配置
    var anomalyDetectionConfig: AnomalyDetectionConfig
    
    /// 初始化
    init(inputDate: [String], inputData: [Double], anomalyDetectionConfig: AnomalyDetectionConfig) {
        self.inputDate = inputDate
        self.inputData = inputData
        self.anomalyDetectionConfig = anomalyDetectionConfig
    }
    
    
    // MARK: - 基于置信区间的检测算法（弃用）
    /// 分割序列数据，并计算置信区间，判断未来的数据是否位于区间内，返回异常点
    /// - Returns:
    /// ① data: [[Double]] 构建时间序列的数据和最新的一个数据
    /// ② trend: [Bool] 表示是上升还是下降，false-下降，true上升
    /// 注意：这个效果很垃圾，并没有在App中使用
    func analyzeDataCI() -> (data: [[Double]], trend: [Bool], startDate: [String], endDate: [String]) {
        let minN =  self.anomalyDetectionConfig.minLenOfCI
        // 至少预测一次
        if self.inputData.count < minN + 1 {
            return  ([[]], [], [], [])
        }
        var data: [[Double]] = []
        var trend: [Bool] = []
        var startDate: [String] = []
        var endDate: [String] = []
        for i in 0..<self.inputData.count {
            if (i+minN) >= self.inputData.count {
                break
            }
            let tempArr = Array(self.inputData[i..<i+minN])
            let varToPredict = self.inputData[i+minN]
            let res = calc_mu_sigma(tempArr)
            data.append(Array(self.inputData[i..<i+minN+1]))
            
            if varToPredict < res.leftVal {
                print("与 \(self.inputDate[i]) 至 \(self.inputDate[i+minN-1]) 的跑步表现相比，您的跑步速度在", terminator: "\t")
                print(self.inputDate[i+minN] + "\t有较大提升！")
                trend.append(true)
                startDate.append(self.inputDate[i])
                endDate.append(self.inputDate[i+minN])
            }
            
            else if varToPredict > res.rightVal {
                print("与 \(self.inputDate[i]) 至 \(self.inputDate[i+minN-1]) 的跑步表现相比，您的跑步速度在", terminator: "\t")
                print(self.inputDate[i+minN] + "\t有较大下降！")
                trend.append(false)
                startDate.append(self.inputDate[i])
                endDate.append(self.inputDate[i+minN])
            }
            else{}
            
        }
        return (data, trend, startDate, endDate)
    }
    
    /// 基于DBSCAN对时间序列分析进行分析
    /// - Returns:
    ///返回一组异常点的index
    func analyzeDataDBSCAN() -> Set<Int>{
        var anomalyPointIndex: Set<Int> = Set()
        // 一系列二维向量，将输入数据的时间也作为二维向量中的一个变量，另一个变量可以是跑步距离、配速等等
        var dbscanInput: [SIMD2<Double>] = []
        for i in 0..<self.inputData.count {
            let simdArr = SIMD2(x: Double(i+1), y: self.inputData[i])
            dbscanInput.append(simdArr)
        }
        // 初始化
        let dbscan = DBSCAN(dbscanInput)
        // 尝试一系列epsilon
        let epsilonList: [Double] = [1e-4, 3e-4, 1e-3, 3e-3, 1e-2, 3e-2, 0.1, 0.3, 1, 3, 10, 30, 100]
        for eps in epsilonList {
            let (clusters, outliers) = dbscan.callAsFunction(epsilon: eps, minimumNumberOfPoints: 1, distanceFunction: simd.distance)
            print("\(clusters.count)", terminator: "\t")
            print("\(outliers.count)", "\n")
            
//            if clusters.count == 2 {
//                print("cluster count = 2")
//                print(clusters)
//                print("\(eps)")
//                for iitem in clusters {
//                    if iitem.count == 1 {
//                        let idx = iitem.first![0]
//                        anomalyPointIndex.insert(Int(idx-Double(1)))
//                    }
//                }
//            }
            
            if clusters.count > 1 && clusters.count <= 5 {
                print("cluster count = 3")
                print(clusters)
                print("\(eps)")
                for iitem in clusters {
                    if iitem.count == 1 {
                        let idx = iitem.first![0]
                        anomalyPointIndex.insert(Int(idx-Double(1)))
                    }
                }
            }
        }
        return anomalyPointIndex
    }
    
    
    /// 计算均值和标准差
    func calc_mu_sigma(_ inputData: [Double]) -> (leftVal: Double, rightVal: Double) {
        let mu = Sigma.average(inputData)
        let sigma = Sigma.standardDeviationSample(inputData)
        // 计算置信区间
        let leftVal = mu! - 3*sigma!
        let rightVal = mu! + 3*sigma!
        return (leftVal, rightVal)
    }
    
    

    /// compute median
    func calculateMedian(_ array: [CGFloat]) -> CGFloat {
        let sorted = array.sorted()
        if sorted.count % 2 == 0 {
            if (sorted.count / 2 - 1) >= 0 {
                return CGFloat((sorted[(sorted.count / 2)] + sorted[(sorted.count / 2) - 1])) / 2
            }
            else {
                return 0.0
            }

        } else {
            return CGFloat(sorted[(sorted.count - 1) / 2])
        }
    }
    
    /// MAD数据处理
    func mad(_ keypointsArr: [CGFloat], _ n: CGFloat) -> [CGFloat]{
        let median = calculateMedian(keypointsArr)  // 获取中位数
        var deviations: [CGFloat] = []
        for xxx in keypointsArr {
            deviations.append(abs(xxx-median))
        }
        let madValue = calculateMedian(deviations)
        
        var newKeypointsArr: [CGFloat] = []
        
        for dataEle in keypointsArr {
            if abs(dataEle - median) > madValue * n {
                print("")
            }else{
                newKeypointsArr.append(dataEle)
            }
        }
        return newKeypointsArr
    }

    
    
    
}

