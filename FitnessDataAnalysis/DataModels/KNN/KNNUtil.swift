//
//  KNNUtil.swift
//  FitnessDataAnalysis
//
//  Created by 十口V🌼 on 2023/4/1.
//

import Foundation
class KNNUtil {
    
    class func calculateMedian(_ array: [CGFloat]) -> CGFloat {
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



    class func mad(_ keypointsArr: [CGFloat], _ n: CGFloat) -> [CGFloat]{
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




    
    
    /// 判断当前的站姿
    class func determinePosition(_ poses: [Pose]) -> String {
        // `madRatio` 越大，对关键点的筛选越严格
        let madRatio: CGFloat = 0.6
        // 关键点的选择模式：
        var kpMode: String = "mean"
        
        
        
        let noseJoint: Joint = {return (poses.first?.joints[Joint.Name.nose])!}()
        let leftEyeJoint: Joint = {return (poses.first?.joints[Joint.Name.leftEye])!}()
        let rightEyeJoint: Joint = {return (poses.first?.joints[Joint.Name.rightEye])!}()
        let leftEarJoint: Joint = {return (poses.first?.joints[Joint.Name.leftEar])!}()
        let rightEarJoint: Joint = {return (poses.first?.joints[Joint.Name.rightEar])!}()
        let leftShoulderJoint: Joint = {return (poses.first?.joints[Joint.Name.leftShoulder])!}()
        let rightShoulderJoint: Joint = {return (poses.first?.joints[Joint.Name.rightShoulder])!}()
        let leftElbowJoint: Joint = {return (poses.first?.joints[Joint.Name.leftElbow])!}()
        let rightElbowJoint: Joint = {return (poses.first?.joints[Joint.Name.rightElbow])!}()
        let leftWristJoint: Joint = {return (poses.first?.joints[Joint.Name.leftWrist])!}()
        let rightWristJoint: Joint = {return (poses.first?.joints[Joint.Name.rightWrist])!}()
        let leftHipJoint: Joint = {return (poses.first?.joints[Joint.Name.leftHip])!}()
        let rightHipJoint: Joint = {return (poses.first?.joints[Joint.Name.rightHip])!}()
        let leftKneeJoint: Joint = {return (poses.first?.joints[Joint.Name.leftKnee])!}()
        let rightKneeJoint: Joint = {return (poses.first?.joints[Joint.Name.rightKnee])!}()
        let leftAnkleJoint: Joint = {return (poses.first?.joints[Joint.Name.leftAnkle])!}()
        let rightAnkleJoint: Joint = {return (poses.first?.joints[Joint.Name.rightAnkle])!}()
        
        
        let myJoints: [Joint] = [noseJoint, leftEyeJoint, rightEyeJoint, leftEarJoint, rightEarJoint, leftShoulderJoint, rightShoulderJoint, leftElbowJoint, rightElbowJoint, leftWristJoint, rightWristJoint, leftHipJoint, rightHipJoint, leftKneeJoint, rightKneeJoint, leftAnkleJoint, rightAnkleJoint]
        
        var xx: [CGFloat] = []
        var yy: [CGFloat] = []
        for ii in 0..<myJoints.count {
            xx.append(myJoints[ii].position.x)
            yy.append(myJoints[ii].position.y)
        }
        
        
        var totalKeypointsArray: [[CGFloat]] = [[], [], [], [], [], [],
                                                [], [], [], [], [], [],
                                                [], [], [], [], [], [],
                                                [], [], [], [], [], [],
                                                [], [], [], [], [], [],
                                                [], [], [], []]
        for jj in 0..<2*myJoints.count {
            if jj % 2 == 0 {
                totalKeypointsArray[jj].append(myJoints[Int(jj/2)].position.x)
            }
            else {
                totalKeypointsArray[jj].append(myJoints[Int(jj/2)].position.y)
            }
        }
        
        var newKeypointsArray: [[CGFloat]] = [[], [], [], [], [], [],
                                              [], [], [], [], [], [],
                                              [], [], [], [], [], [],
                                              [], [], [], [], [], [],
                                              [], [], [], [], [], [],
                                              [], [], [], []]
        // 对于每个关键点维度，对所有关键点求平均/求中位数
        var keypoints_mean: [CGFloat] = []
        var keypoints_median: [CGFloat] = []
        
        for idx in 0..<totalKeypointsArray.count {
            newKeypointsArray[idx] = mad(totalKeypointsArray[idx], madRatio)
        }
        
        
        for idx in 0..<newKeypointsArray.count {
            let average: CGFloat = CGFloat(newKeypointsArray[idx].reduce(0.0, +)) / CGFloat(newKeypointsArray[idx].count)
            keypoints_mean.append(average)
            keypoints_median.append(calculateMedian(newKeypointsArray[idx]))
        }
        
        var xxToStore: [CGFloat] = []
        var yyToStore: [CGFloat] = []
        if kpMode == "mean" {
            for i in 0..<keypoints_mean.count {
                if i % 2 == 0{
                    xxToStore.append(keypoints_mean[i])
                }
                else {
                    yyToStore.append(keypoints_mean[i])
                }
            }
        }
        else if kpMode == "median" {
            for i in 0..<keypoints_median.count {
                if i % 2 == 0{
                    xxToStore.append(keypoints_mean[i])
                }
                else {
                    yyToStore.append(keypoints_mean[i])
                }
            }
        }
        else {
            print("Wrong mode, please check!!")
        }
        
        let res = getKnnRes(xxToStore, yyToStore)
        return res
    }
    
    
    class func getKnnRes(_ xx:[CGFloat], _ yy:[CGFloat]) -> String {
        // MARK: - 0.b —— 归一化
        var normX:[CGFloat] = []
        var normY:[CGFloat] = []
        
        let xyRatio: CGFloat = getRange(xx) / getRange(yy)
        let yxRatio: CGFloat = getRange(yy) / getRange(xx)
        
        if xyRatio <= 1 {
            normX = normalizeWithRatio(xx, xyRatio)
            normY = normalizationRange(yy)
        }
        if yxRatio <= 1 {
            normX = normalizationRange(xx)
            normY = normalizeWithRatio(yy, yxRatio)
        }
        // MARK: - 0.b —— 中心化
        let cenRes = centralization(normX, normY)
        let norm_cen_xx = cenRes[0]
        let norm_cen_yy = cenRes[1]
        // 将新的值赋给normX和normY
        normX = norm_cen_xx
        normY = norm_cen_yy
        var temp_input: [Double] = []
        for i in 0..<normX.count {
            temp_input.append(normX[i])
            temp_input.append(normY[i])
        }
        let res = knnPredict(temp_input)
        
        if res != "front"{

            
        }
        else {
            
        }
        
        return res
    }
    
    
    // MARK: - KNN predict
    class func knnPredict(_ savedPosePosition: [Double]) -> String {
        
        enum HumanPose: String {
            case front, side
            static func fromString(_ s: String) -> Int {
              switch s {
              case HumanPose.front.rawValue: return 0
              case HumanPose.side.rawValue: return 1
              default: return 0
              }
            }
            static func fromLabel(_ l: Int) -> String {
              switch l {
              case 0: return HumanPose.front.rawValue
              case 1: return HumanPose.side.rawValue
              default: return HumanPose.front.rawValue
              }
            }
        }
        
        guard let humanPoseCSV = Bundle.main.path(forResource: "humanPoseNormCen", ofType: "csv") else {
            print("Resource could not be found!")
            exit(0)
        }
        
        guard let csv = try? String(contentsOfFile: humanPoseCSV) else {
          print("File could not be read!")
          exit(0)
        }

        let rows: [String] = csv.split(separator: "\n").map { String($0) }
        
        let humanPoseData = rows.map { row -> [String] in
            let split = row.split(separator: ",")
          return split.map { String($0) }
        }
        let rowOfClasses = 34
        let labels = humanPoseData.map { row -> Int in
          let label = HumanPose.fromString(row[rowOfClasses])
          return label
        }
        let data = humanPoseData.map { row in
          return row.enumerated().filter { $0.offset != rowOfClasses }.map { Double($0.element)! }
        }
        let knn = KNearestNeighborsClassifier(data: data, labels: labels)
        
        let predictionLabels = knn.predict([savedPosePosition])
        
        let predictionStandType = predictionLabels.map({ HumanPose.fromLabel($0) })
        
        return predictionStandType[0]
    }

}
