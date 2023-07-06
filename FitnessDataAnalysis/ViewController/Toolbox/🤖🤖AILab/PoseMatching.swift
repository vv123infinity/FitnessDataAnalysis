//
//  PoseMatching.swift
//  FitnessDataAnalysis
//
//  Created by Infinity vv123 on 2023/4/19.
//


import AVFoundation
import UIKit
import VideoToolbox
import CoreData


class PoseMatching: UIViewController {
    // MARK: - Outlets
    @IBOutlet private var previewImageViewOfPoseMatching: PoseImageView!
//    @IBOutlet weak var startMatchingSwitch: UISwitch!
//    @IBOutlet weak var scoreLabel: UILabel!
//    @IBOutlet weak var distLabel: UILabel!
    @IBOutlet var imgViewPoses: [UIImageView]!
    
    
    // MARK: - Properties
    private let videoCapture = VideoCapture()
    private var poseNet: PoseNet!
    private var currentFrame: CGImage?
    private var algorithm: Algorithm = .single
    private var poseBuilderConfiguration = PoseBuilderConfiguration()
    private var popOverPresentationManager: PopOverPresentationManager?
    
    var currentFrameIdx: Int = 0
    
    var knn: KNearestNeighborsClassifier!
    var posesMark: [[Int]] = [[], [], [], [], [], []]
    
//    @IBOutlet weak var knnResLabel: UILabel!
    
    
//    var outputIdx: Int = 0
//    private var startMatchingFlag: Bool = false
    
    
    // MARK: - 应用生命周期
    override func viewDidLoad() {
        super.viewDidLoad()

        theUISettings()
        // Do any additional setup after loading the view.
        

        
//        startMatchingButton.layer.cornerRadius = 10
//        startMatchingButton.setTitle("Start Matching", for: .normal)
//        startMatchingButton.backgroundColor = UIColor.init(red: 218/255.0, green: 165/255.0, blue: 32/255.0, alpha: 0.5)
        
        do {
            poseNet = try PoseNet()
        } catch {
            fatalError("Failed to load model. \(error.localizedDescription)")
        }

        poseNet.delegate = self
        setupAndBeginCapturingVideoFrames()
        
    }
    
    
    func theUISettings() {
        self.navigationController?.navigationBar.tintColor = ColorUtil.getBarBtnColor()
        for imgVi in self.imgViewPoses {
            
            imgVi.layer.cornerRadius = 10
//            imgVi.layer.borderWidth = 2
//            imgVi.layer.masksToBounds = true
//            imgVi.layer.borderColor = UIColor.black.cgColor
        }
    }
    
    @IBAction func onCameraButtonTapped(_ sender: Any) {
        videoCapture.flipCamera { error in
            if let error = error {
                print("Failed to flip camera with error \(error)")
            }
        }
    }
    
    
    func knnPosturesPredict(_ savedPosePosition: [Double]) -> String {
        enum HumanPostures: String {
            // {'Left Extension', 'Left Leg Lift', 'Right Extension', 'Right Leg Lift'}
            
            case leftExtension, leftLegLift, rightExtension, rightLegLift
            static func fromString(_ s: String) -> Int {
              switch s {
              case HumanPostures.leftExtension.rawValue: return 0
              case HumanPostures.leftLegLift.rawValue: return 1
              case HumanPostures.rightExtension.rawValue: return 2
              case HumanPostures.rightLegLift.rawValue: return 3
              default: return 0
              }
            }
            
            static func fromLabel(_ l: Int) -> String {
              switch l {
              case 0: return HumanPostures.leftExtension.rawValue
              case 1: return HumanPostures.leftLegLift.rawValue
              case 2: return HumanPostures.rightExtension.rawValue
              case 3: return HumanPostures.rightLegLift.rawValue
              default: return HumanPostures.leftExtension.rawValue
              }
            }
            
        }
        guard let humanPoseCSV = Bundle.main.path(forResource: "SamplePoses2", ofType: "csv") else {
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
          let label = HumanPostures.fromString(row[rowOfClasses])
          return label
        }
        let data = humanPoseData.map { row in
          return row.enumerated().filter { $0.offset != rowOfClasses }.map { Double($0.element)! }
        }
        knn = KNearestNeighborsClassifier(data: data, labels: labels)
        
        let predictionLabels = knn.predict([savedPosePosition])
        
        let predictionStandType = predictionLabels.map({ HumanPostures.fromLabel($0) })
        
        return predictionStandType[0]
    }
    
    
    
    // MARK: - Actions
    // MARK:  翻转摄像头

    

    
    // MARK: -
    private func setupAndBeginCapturingVideoFrames() {
        videoCapture.setUpAVCapture { error in
            if let error = error {
                print("Failed to setup camera with error \(error)")
                return
            }

            self.videoCapture.delegate = self
            self.videoCapture.startCapturing()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        videoCapture.stopCapturing {
            super.viewWillDisappear(animated)
        }
    }

    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        // Reinitilize the camera to update its output stream with the new orientation.
        setupAndBeginCapturingVideoFrames()
    }
    // MARK: - Helper Methods
    func accessUserInputJointsPosition(_ poses: [Pose]) -> [[Double]] {
        
        var userInputPositionXX: [CGFloat] = []
        var userInputPositionYY: [CGFloat] = []

        // 各个关键点的置信度 - 按顺序 (1, 17)
        var userInputConf: [Double] = []
        
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
        
        let jointsArr: [Joint] = [noseJoint, leftEyeJoint, rightEyeJoint, leftEarJoint,
                                  rightEarJoint, leftShoulderJoint, rightShoulderJoint,
                                  leftElbowJoint, rightElbowJoint, leftWristJoint,
                                  rightWristJoint, leftHipJoint, rightHipJoint,
                                  leftKneeJoint, rightKneeJoint, leftAnkleJoint, rightAnkleJoint]
        
        for i in 0..<jointsArr.count {
//            guard let tempX:CGFloat = jointsArr[i].position.x else {
//                return 0.0
//            }
//            guard let tempX:CGFloat = jointsArr[i].position.y else {
//                return 0.0
//            }
            
            
//            if jointsArr[i].position.x == nil {
//                userInputPositionXX.append(0.0)
//            }else{
//                userInputPositionXX.append(jointsArr[i].position.x)
//            }
//            if jointsArr[i].position.y == nil {
//                userInputPositionYY.append(0.0)
//            }else{
//                userInputPositionYY.append(jointsArr[i].position.y)
//            }
            userInputPositionXX.append(jointsArr[i].position.x)
            userInputPositionYY.append(jointsArr[i].position.y)
//            userInputPosition.append(jointsArr[i].position.x)
//            userInputPosition.append(jointsArr[i].position.y)
            userInputConf.append(jointsArr[i].confidence)
        }
        // ------------------------------ 归一化 ------------------------------
        var normX:[CGFloat] = []
        var normY:[CGFloat] = []
        
        let xyRatio: CGFloat = getRange(userInputPositionXX) / getRange(userInputPositionYY)
        let yxRatio: CGFloat = getRange(userInputPositionYY) / getRange(userInputPositionXX)
        
        if xyRatio <= 1 {
            normX = normalizeWithRatio(userInputPositionXX, xyRatio)
            normY = normalizationRange(userInputPositionYY)
        }
        if yxRatio <= 1 {
            normX = normalizationRange(userInputPositionXX)
            normY = normalizeWithRatio(userInputPositionYY, yxRatio)
        }
        // ---------------------------- 对 normX 和 normY 中心化 -------------------------
        let cenRes = centralization(normX, normY)
        let norm_cen_xx = cenRes[0]
        let norm_cen_yy = cenRes[1]
        // 将新的值赋给normX和normY
        normX = norm_cen_xx
        normY = norm_cen_yy
        
        
        // 格式转换
        // 模型预测的关键点位置 x0, y0, x1, y1, ...     shape  (1, 34)
        var tempRes: [CGFloat] = []
        for i in 0..<17{
            tempRes.append(normX[i])
            tempRes.append(normY[i])
        }
        
        var res0: [Double] = []
        res0 = tempRes.map{Double($0)}
        let res: [[Double]] = [res0, userInputConf]
        return res
    }
    

    // MARK: - Pose Matching Algo
    func getMatchingDegree(_ userInputPoints: [Double], _ userInputPointsConf: [Double], _ sdPosePoints: [Double]) -> Double {
        let dist1: Double = confidenceDistance(userInputPoints, userInputPointsConf, sdPosePoints)
        let subScore = -97.43073274 * dist1 + 95.80606116
        
        if subScore > 100 {
            return 100.0
        }
        else if subScore < 0 {
            return 0.0
        }
        else {
            return subScore
        }

    }
    func getMatchingDegreeStr(_ userInputPoints: [Double], _ userInputPointsConf: [Double], _ sdPosePoints: [Double]) -> String {
        /// input - 归一化后的实时关键点坐标    实时关键点置信度    标准姿势坐标（归一化）
        /// output
        ///         - 目前返回等级字符串
        ///
        
        // 计算加权距离
        let dist1: Double = confidenceDistance(userInputPoints, userInputPointsConf, sdPosePoints)
        
//        let subScore = -92.48154194 * dist1 + 95.50145975
        let subScore = -97.43073274 * dist1 + 95.80606116
        
        if subScore > 100 {
            return "100"
        }
        else if subScore < 0 {
            return "0"
        }
        else {
            return "\(subScore)"
        }
//        return "暂时只测试KNN"
        
    }
    
    
    
    func getDist(_ userInputPoints: [Double], _ userInputPointsConf: [Double], _ sdPosePoints: [Double]) -> String {
        let dist1: Double = confidenceDistance(userInputPoints, userInputPointsConf, sdPosePoints)
        return "\(dist1)"
    }

}


// MARK: - VideoCaptureDelegate
extension PoseMatching: VideoCaptureDelegate {
    func videoCapture(_ videoCapture: VideoCapture, didCaptureFrame capturedImage: CGImage?) {
        guard currentFrame == nil else {
            return
        }
        guard let image = capturedImage else {
            fatalError("Captured image is null")
        }

        currentFrame = image
        poseNet.predict(image)
    }
}



// MARK: - PoseNetDelegate
extension PoseMatching: PoseNetDelegate {
    // 对一帧的处理
    func poseNet(_ poseNet: PoseNet, didPredict predictions: PoseNetOutput) {
        defer {
            // Release `currentFrame` when exiting this method.
            self.currentFrame = nil
        }
        
        guard let currentFrame = currentFrame else {
            return
        }
        let poseBuilder = PoseBuilder(output: predictions,
                                      configuration: poseBuilderConfiguration,
                                      inputImage: currentFrame)
        
        let poses = algorithm == .single
        ? [poseBuilder.pose]
        : poseBuilder.poses
        
        previewImageViewOfPoseMatching.show(poses: poses, on: currentFrame)
        
        // MARK: -
        // MARK: 姿势匹配算法
        // 首先获取归一化后的实时关键点坐标以及对应的置信度
        let res: [[Double]] = accessUserInputJointsPosition(poses)
//        let resStr = knnPosturesPredict(res[0])
//        print("KNN 结果：\(resStr)")

        let userInputPoints: [Double] = res[0]
        let userInputPointsConf: [Double] = res[1]
        
        for i in 0..<6{
            let sdPosePoints: [Double] = getPoseMatchingDemoData()[i]
            let matchingRes: Double = getMatchingDegree(userInputPoints, userInputPointsConf, sdPosePoints)
            if posesMark[i].count > 3 {
                self.imgViewPoses[i].layer.borderWidth = 2.0
                self.imgViewPoses[i].layer.borderColor = UIColor.init(red: 178/255.0, green: 34/255.0, blue: 34/255.0, alpha: 1).cgColor
                
            }
            else{
                self.imgViewPoses[i].layer.borderWidth = 0
//                self.imgViewPoses[i].layer.borderColor = UIColor.init(red: 178/255.0, green: 34/255.0, blue: 34/255.0, alpha: 1).cgColor
            }
            
            if matchingRes > 89.5 {
                self.posesMark[i].append(currentFrameIdx)
            }
            else {
                self.posesMark[i] = []
            }
            
        }
        
        // 获取标准姿势 —— 暂定的标准姿势就是当前在设置中捕获的姿势

        
        
//        print("✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅")
//        print("userInputPoints\(currentFrameIdx) = \(userInputPoints)")
//
//        print("userInputPointsConf\(currentFrameIdx) = \(userInputPointsConf)")
//        print("\n")
//        print("标准姿势：\n")
//        print("\(sdPosePoints)")
//        print("\n")
//        print("🌻🌻🌻🌻🌻🌻🌻🌻🌻🌻🌻🌻🌻🌻🌻🌻🌻🌻🌻🌻🌻🌻🌻🌻🌻🌻🌻")
        // 获取匹配结果 —— 当前返回的是字符串
//        let matchingRes: String = getMatchingDegreeStr(userInputPoints, userInputPointsConf, sdPosePoints)
//        scoreLabel.text = matchingRes
//        distLabel.text = getDist(userInputPoints, userInputPointsConf, sdPosePoints)
        
        
        currentFrameIdx += 1
        
        // print
//        print("userInputPoints")
//        print("userInputPoints\(outputIdx) = \(userInputPoints)")
//        print("conf")
//        print(userInputPointsConf)
//        print("userInputPointsConf\(outputIdx) = \(userInputPointsConf)")
//        print("dist\(outputIdx) = \(getDist(userInputPoints, userInputPointsConf, sdPosePoints))")
//        print("\n\n\n")
        
//        outputIdx += 1
        
        
//        print("sd")
//        print(sdPosePoints)
//        print(matchingRes)
        
        
        // MARK: -
    }
    
}






