//
//  SquatCounter.swift
//  FitnessDataAnalysis
//
//  Created by 十口V🌼 on 2023/3/31.
//

import UIKit

class SquatCounter: UIViewController {

    @IBOutlet weak var squatCountLabel: GradientLabel!
    /// 各种提示的Label
    
    
    @IBOutlet weak var hintLabel: UILabel!
    
    @IBOutlet weak var hintImage: UIImageView!
    
    
    @IBOutlet private var previewImageView: PoseImageView!
    
    @IBOutlet weak var startButton: UIButton!
    
    @IBOutlet var borderUIView: [UIView]!
    

    @IBOutlet weak var myNavRightItem: UIBarButtonItem!
    // MARK: Properties
    
    //    > > > > properties of squat < < < <
    // last number of squat
    
    // the number of squat
    var squatCount: Int = 0
    
    // Does the squat count start
    var squatStartFlag: Bool = false
    
    // Start time for deep squats
    var startTime: CGFloat = 0.0
         
    // Angle of the previous period
    var prevKneeAngle: CGFloat = 0.0
    
    // Current state of the squat
    var squatPos = 0
    
    // The state of deep squatting some time ago
    var prevSqautPos = 0
    
    private let videoCapture = VideoCapture()
    private var poseNet: PoseNet!
    // The frame the PoseNet model is currently making pose predictions from.
    private var currentFrame: CGImage?
    // The algorithm the controller uses to extract poses from the current frame.
    private var algorithm: Algorithm = .single
    // The set of parameters passed to the pose builder when detecting poses.
    private var poseBuilderConfiguration = PoseBuilderConfiguration()
    private var popOverPresentationManager: PopOverPresentationManager?

    /// 用来辅助开始和结束按钮，0：无状态/结束，1：正在进行
    var buttonState: Int = 0
    
    /// 当前的站姿 正面/侧面
    var curPostion: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()


        if !UserDefaults.standard.bool(forKey: "noSquatHint") {
            self.showGuide()
        }
        
        self.setUpUI()
        
        self.setUpPoseNet()

        self.setupCapturingVideoFrames()
        

    }
    
    
    func setUpPoseNet(){
        do {
            poseNet = try PoseNet()
        } catch {
            fatalError("Failed to load model. \(error.localizedDescription)")
        }
        poseNet.delegate = self
    }
    
    func setUpButton(){
        
        self.startButton.setTitle(NSLocalizedString("startstart", comment: ""), for: .highlighted)
        self.startButton.setTitle(NSLocalizedString("startstart", comment: ""), for: .normal)
        
    }
    
    func setUpUI() {
        self.setUpButton()
        self.previewImageView.isHidden = true
        self.squatCountLabel.gradientColors = ColorUtil.getAILabGreen().map{$0.cgColor}
        self.hintImage.isHidden = false
        self.hintLabel.isHidden = false
        self.myNavRightItem.tintColor = ColorUtil.getBarBtnColor()
    }
    
    func setUPBorderLine() {


        for vv in self.borderUIView {
            let gradient = CAGradientLayer()
            gradient.frame = vv.bounds
            gradient.colors = ColorUtil.getAILabGreen().map{$0.cgColor}
            vv.layer.insertSublayer(gradient, at: 0)
            
        }
        for vv in self.borderUIView {
            vv.isHidden = true
        }
    }
    
    func showGuide() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "AILabGuide") as? AILabGuide
        vc?.typeID = 0
        self.present(vc!, animated: true)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        videoCapture.stopCapturing {
            super.viewWillDisappear(animated)
        }
    }

    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        // Reinitilize the camera to update its output stream with the new orientation.
        setupCapturingVideoFrames()
    }
    
    
    private func setupCapturingVideoFrames() {
        videoCapture.setUpAVCapture { error in
            if let error = error {
                print("Failed to setup camera with error \(error)")
                return
            }

            self.videoCapture.delegate = self
        }
    }
    // MARK: - IBAction
    @IBAction func startBtnPressed(_ sender: UIButton) {
        switch self.buttonState {
        case 0:
            // 无状态 -> 开始
            self.previewImageView.isHidden = false
            self.videoCapture.startCapturing()
            self.squatStartFlag = true
            self.squatCount = 0
            self.squatCountLabel.text = "0"
            DispatchQueue.main.async {
                self.startButton.setTitle(NSLocalizedString("stopstop", comment: ""), for: .highlighted)
                self.startButton.setTitle(NSLocalizedString("stopstop", comment: ""), for: .normal)
            }

            
            self.buttonState = 1
        case 1:
            // 开始 -> 结束
            self.previewImageView.isHidden = true
            self.videoCapture.stopCapturing()
            self.squatStartFlag = false
            DispatchQueue.main.async {
                self.startButton.setTitle(NSLocalizedString("startstart", comment: ""), for: .highlighted)
                self.startButton.setTitle(NSLocalizedString("startstart", comment: ""), for: .normal)
            }
            self.buttonState = 0

            
        default:
            break
        }
        
        
        
    }
    

    @IBAction func onCameraButtonTapped(_ sender: Any) {
        videoCapture.flipCamera { error in
            if let error = error {
                print("Failed to flip camera with error \(error)")
            }
        }
    }
    

    
    

}


// MARK: - Squat Counter Algo
extension SquatCounter {
    func squatDetectionCount(_ poses: [Pose]) {
        // get all keypoints
        let leftHipJoint: Joint = {return (poses.first?.joints[Joint.Name.leftHip])!}()
        let rightHipJoint: Joint = {return (poses.first?.joints[Joint.Name.rightHip])!}()
        let leftKneeJoint: Joint = {return (poses.first?.joints[Joint.Name.leftKnee])!}()
        let rightKneeJoint: Joint = {return (poses.first?.joints[Joint.Name.rightKnee])!}()
        let leftAnkleJoint: Joint = {return (poses.first?.joints[Joint.Name.leftAnkle])!}()
        let rightAnkleJoint: Joint = {return (poses.first?.joints[Joint.Name.rightAnkle])!}()
        let leftHipPoint: CGPoint = CGPoint(x: leftHipJoint.position.x, y: leftHipJoint.position.y)
        let rightHipPoint: CGPoint = CGPoint(x: rightHipJoint.position.x, y: rightHipJoint.position.y)
        let leftKneePoint: CGPoint = CGPoint(x: leftKneeJoint.position.x, y: leftKneeJoint.position.y)
        let rightKneePoint: CGPoint = CGPoint(x: rightKneeJoint.position.x, y: rightKneeJoint.position.y)
        let leftAnklePoint: CGPoint = CGPoint(x: leftAnkleJoint.position.x, y: leftAnkleJoint.position.y)
        let rightAnklePoint: CGPoint = CGPoint(x: rightAnkleJoint.position.x, y: rightAnkleJoint.position.y)
        

        
        // Calculate the Angle of a particular position of the human body
        let squatKneeAngle = get_knee_angle(leftHipPoint, rightHipPoint, leftKneePoint, rightKneePoint, leftAnklePoint, rightAnklePoint)
        if squatKneeAngle[2] < prevKneeAngle {
//            print("Up Up Up !!!")
            prevKneeAngle = squatKneeAngle[2]
        }
        else {
//            print("Down Down Down !!!\n")
            prevKneeAngle = squatKneeAngle[2]
        }
        
        // compute the average angle
        let avgAngle = (squatKneeAngle[0] + squatKneeAngle[1]) / 2
        
        

        

//        self.hintLabel.text = self.curPostion
//        self.hintLabel.isHidden = false
        
        // Determine the squat status
        // Basically complete the knee Angle of the squat
        
        // 100 is just an arbitrary Angle that can be replaced with 80 or 120. The higher the value, the deeper the user will squat.
        var thresholdAngle: CGFloat = 80
        let pos: String = KNNUtil.determinePosition(poses)
//        self.curPostion = pos
        if pos == "front" {
            thresholdAngle = poseBuilderConfiguration.frontMediumAngleThreshold
        }
        else{
            thresholdAngle = poseBuilderConfiguration.sideMediumAngleThreshold
        }
        
        if round(avgAngle) > thresholdAngle {
            
            // Get the current time
            let now = Date()
            let timeInterval: TimeInterval = now.timeIntervalSince1970
            let timeStamp = CGFloat(timeInterval)
            
            let passTime = timeStamp - startTime
            
            if passTime > 0.1 && passTime < 3000 {
                squatPos = 1 // Reassign. This is not a squat
            }
            
        }
        else if round(avgAngle) < 10 {
                // Because the Angle of the knee cannot be 0 when the human body is standing directly in the squat, it is set to 10. Again, this value can be replaced with the value you want.
                // get current time
                let now = Date()
                let timeInterval: TimeInterval = now.timeIntervalSince1970
                let timeStamp = CGFloat(timeInterval)
                startTime = timeStamp
                squatPos = 0  // Squatting
            }
        else {
                squatPos = 999
        }

        if prevSqautPos - squatPos == 1 {
            squatCount += 1
            
            let originalPos = self.squatCountLabel.center
            let startPos = CGPoint(x: originalPos.x, y: originalPos.y + 40)
            self.squatCountLabel.center = startPos
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
                self.squatCountLabel.isHidden = false
                self.squatCountLabel.center = originalPos
                self.squatCountLabel.text = "\(self.squatCount)"
            }, completion: nil)
            
        }
        if squatPos == 0 || squatPos == 1{
            prevSqautPos = squatPos
        }
        
        

        
        
        }

    
    func calcDis(_ p1: CGPoint, _ p2: CGPoint) -> CGFloat{
        return sqrt(pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2))
    }
    
    
    

}




// MARK: - VideoCaptureDelegate

extension SquatCounter: VideoCaptureDelegate {
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
extension SquatCounter: PoseNetDelegate {
    func poseNet(_ poseNet: PoseNet, didPredict predictions: PoseNetOutput) {
        defer {
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
        
        previewImageView.show(poses: poses, on: currentFrame)
        
        
        print("姿势置信度\(Date())")
        print("\(poses.first?.confidence)")
        print("\n🤣\n")
        
        if poses.first!.confidence >= poseBuilderConfiguration.poseConfidenceThreshold {
            self.hintImage.isHidden = true
            self.hintLabel.isHidden = true
            // start counting
            print("判断中——————")
            if poses.first != nil && self.squatStartFlag == true {
                squatDetectionCount(poses)
            }
        }
        else {
            self.hintImage.isHidden = false
            self.hintLabel.isHidden = false
        }
        

        
    }
    
}
