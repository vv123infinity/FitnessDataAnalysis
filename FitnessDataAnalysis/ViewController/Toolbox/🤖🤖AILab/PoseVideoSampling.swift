//
//  PoseVideoSampling.swift
//  FitnessWithML
//
//  Created by Infinity vv123 on 2022/10/1.
//

import AVFoundation
import UIKit
import VideoToolbox
import CoreData


class PoseVideoSampling: UIViewController {
    var isPlaying = false

    // MARK: - Outlet
    @IBOutlet private var previewImageView: PoseImageView!
    @IBOutlet weak var startSamplingButton: UIButton!
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var neckAngleLabel: UILabel!
    @IBOutlet weak var imgSegView: UIImageView!     // 查看语义分割结果的img view

    @IBOutlet weak var saveResView: UIView!
    @IBOutlet weak var genResView: UIView!
    @IBOutlet weak var saveResButton: UIButton!

    @IBOutlet weak var checkPoseMisRes: UILabel!

    @IBOutlet weak var samplingReportGenTitle: UILabel!   // 采样等待界面的title
    @IBOutlet weak var samplingReportImageHint: UIImageView!    // 采样界面的提示图像



    // MARK: - Properties
    var player: AVAudioPlayer?
    private let videoCapture = VideoCapture()
    private var poseNet: PoseNet!
    private var currentFrame: CGImage?
    private var algorithm: Algorithm = .single
    private var poseBuilderConfiguration = PoseBuilderConfiguration()
    private var popOverPresentationManager: PopOverPresentationManager?

    private var startSamplingFlag: Bool = false
    private var saveFlag: Bool = false
    var counter = 5     // time
    var poseManagedContext: NSManagedObjectContext!
    var currentPose: PoseCapture!
    private var numOfFrameCaptured = 5  // the number of pose captured in `counter` second(s)
    var currNumOfFrameCaptured = 0
    var xxToStore: [CGFloat] = []
    var yyToStore: [CGFloat] = []

    //----------- 关键点处理  -----------
    // 存储关键点的x和y，存储顺序：[x0], [y0], [x1], [y1]
    var totalKeypointsArray: [[CGFloat]] = [[], [], [], [], [], [],
                                            [], [], [], [], [], [],
                                            [], [], [], [], [], [],
                                            [], [], [], [], [], [],
                                            [], [], [], [], [], [],
                                            [], [], [], []]
    // 从 t = 0 - t=5的总帧数
    var totalFrameCount = 0
    // `madRatio` 越大，对关键点的筛选越严格
    let madRatio: CGFloat = 0.6
    // 关键点的选择模式：
    private var kpMode: String = "mean"


    // --------------- 站立姿态 -----------------------
    var knn: KNearestNeighborsClassifier!
    // knn分类结果 - side / front
    var knnResSideOrFront: String!
    // 侧面——面向左还是面向右边  - left right
    var towardDir: String!
    var towardLeftCount: Int = 0

    // --------------knnResSideOrFront="side"时姿态评估的变量-------------------
    // 1 - 脖子前倾的角度 暂存
    var neckFwTiltAngle: [CGFloat] = []   // 在评估线程中计算level

    // 2 - 骨盆前倾数据
    var palmThickness: CGFloat = 3.0    // 女性手掌厚度 ~ 用于估算人体自然生理曲度
    var femalePalmThickness: CGFloat = 2.74      // 女性手掌厚度
    var malePalmThickness: CGFloat = 3.0   // 待决定
    var allShoulderPos: [CGFloat] = []     // 肩部的y轴坐标
    var allHipPos: [CGFloat] = []          // 臀部的y轴坐标
    var allCGImageSeg: [CGImage] = []   // 语义分割后的CGIMG
    var allEdgePoints: [[Int]] = []      // 边缘分界点坐标

    // 3 - 驼背数据 ~ CGImage数据使用骨盆前倾的
    var hunchbackEdgePoints: [[Int]] = []    // 驼背的分界点
    var allEarPos: [CGFloat] = []


    // MARK: - Life
    override func viewDidLoad() {
        super.viewDidLoad()

        initSettings()
        theUISettings()

        // 关键点识别模型
        do {
            poseNet = try PoseNet()
        } catch {
            fatalError("Failed to load model. \(error.localizedDescription)")
        }

        poseNet.delegate = self
        setupAndBeginCapturingVideoFrames()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        poseManagedContext = appDelegate!.persistentContainer.viewContext


        let de = UserDefaults.standard
        if de.integer(forKey: "DelayedTimeIdx") == 1 {
            counter += 4
        }
        else if de.integer(forKey: "DelayedTimeIdx") == 2 {
            counter += 6
        }
        else if de.integer(forKey: "DelayedTimeIdx") == 3 {
            counter += 11
        }
        else {
            counter += 0
        }
        self.hintLabel.text = "Pose Sampling"


    }

    func initSettings() {
        if UserDefaults.isFirstLaunch() {
            let alert = UIAlertController(title: "Sampling is performed 3 seconds after pressing 'Start Sampling'.", message: "You can set the duration of the delay in the settings", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK OK", style: .default)
            alert.addAction(action)
            present(alert, animated: true)
        }

    }


    func theUISettings() {

        self.view.backgroundColor = ColorUtil.dynamicColor(dark: .white, light: .white)
        hintLabel.textColor = ColorUtil.dynamicColor(dark: UIColor.black, light: UIColor.black)
        cancelButton.layer.cornerRadius = 10
        cancelButton.backgroundColor = UIColor.init(red: 245/255.0, green: 222/255.0, blue: 179/255.0, alpha: 0.4)
        cancelButton.setTitleColor(ColorUtil.dynamicColor(dark: UIColor.black, light: UIColor.black), for: .normal)
//        deleteResButton.layer.cornerRadius = 10
//        deleteResButton.backgroundColor = UIColor.init(red: 245/255.0, green: 222/255.0, blue: 179/255.0, alpha: 0.4)
//        deleteResButton.setTitleColor(ColorUtil.dynamicColor(dark: UIColor.black, light: UIColor.black), for: .normal)
        saveResButton.layer.cornerRadius = 10
//        saveResButton.backgroundColor = UIColor.init(red: 218/255.0, green: 165/255.0, blue: 32/255.0, alpha: 0.5)
        saveResButton.backgroundColor = UIColor.white


        saveResButton.setTitleColor(ColorUtil.dynamicColor(dark: UIColor.black, light: UIColor.black), for: .normal)


        // Do any additional setup after loading the view.
        startSamplingButton.layer.cornerRadius = 10
        startSamplingButton.setTitle("Start Sampling", for: .normal)
        startSamplingButton.backgroundColor = UIColor.init(red: 218/255.0, green: 165/255.0, blue: 32/255.0, alpha: 0.5)
//        startSamplingButton.backgroundColor = UIColor.init(red: 165/255.0, green: 194/255.0, blue: 176/255.0, alpha: 1)


        startSamplingButton.setTitleColor(ColorUtil.dynamicColor(dark: UIColor.black, light: UIColor.black), for: .normal)

    }


    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true)

    }
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
    //音频结束时的回调
    func audioServicesPlaySystemSoundCompleted(soundID: SystemSoundID) {
        print("Completion")
        isPlaying = false
        AudioServicesRemoveSystemSoundCompletion(soundID)
        AudioServicesDisposeSystemSoundID(soundID)
    }


    @objc func updateCounter() {
        //example functionality
        if !startSamplingFlag{
            if counter > 0 {
                hintLabel.text = "Start after \(counter-5-1) s"
                counter -= 1
                if counter == 5{
                    startSamplingFlag = true
                }
            }
        }

        
        if startSamplingFlag {
            
            if counter > 0 {
//                self.title = "Countdown \(counter) s"
                hintLabel.text = "Countdown \(counter) s"

                if counter == 5{
                    self.view.backgroundColor = UIColor.init(red: 255/255.0, green: 255/255.0, blue: 167/255.0, alpha: 1)

                }
                else if counter == 4{
                    self.view.backgroundColor = UIColor.init(red: 255/255.0, green: 255/255.0, blue: 187/255.0, alpha: 1)
                }
                else if counter == 3{
                    self.view.backgroundColor = UIColor.init(red: 255/255.0, green: 255/255.0, blue: 199/255.0, alpha: 1)
                }
                else if counter == 2{
                    self.view.backgroundColor = UIColor.init(red: 255/255.0, green: 255/255.0, blue: 221/255.0, alpha: 1)
                }
                else if counter == 1{
                    self.view.backgroundColor = UIColor.init(red: 255/255.0, green: 255/255.0, blue: 235/255.0, alpha: 1)
                }
                else{
                    self.view.backgroundColor = .systemBackground
                }
                
                
//                if !isPlaying {
//                            //建立的SystemSoundID对象
//                            var soundID:SystemSoundID = 0
//                            //获取声音地址
//                            let path = Bundle.main.path(forResource: "cd\(counter)", ofType: "mp3")
//                            //地址转换
//                            let baseURL = NSURL(fileURLWithPath: path!)
//                            //赋值
//                            AudioServicesCreateSystemSoundID(baseURL, &soundID)
//
//                            //添加音频结束时的回调
//                            let observer = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
//                            AudioServicesAddSystemSoundCompletion(soundID, nil, nil, {
//                                (soundID, inClientData) -> Void in
//                                let mySelf = Unmanaged<PoseVideoSampling>.fromOpaque(inClientData!)
//                                    .takeUnretainedValue()
//                                mySelf.audioServicesPlaySystemSoundCompleted(soundID: soundID)
//                            }, observer)
//
//                            //播放声音
//                            AudioServicesPlaySystemSound(soundID)
//                            isPlaying = true
//                }


                counter -= 1
            }
            else {
                DispatchQueue.main.async { [self] in
                    keypointsProcessing()
                    self.title = "Body Data Capture"
                    self.videoCapture.captureSession.stopRunning()
                    self.saveResView.bounds = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
                    self.saveResView.center = self.view.center
                    self.samplingReportImageHint.layer.cornerRadius = 10
                    // 侧面站立位置

    //                keypointsProcessing()


                    let topColor = UIColor.white

    //                let topColor = UIColor.init(red: 180/255.0, green: 207/255.0, blue: 190/255.0, alpha: 1)
                    let buttomColor = UIColor.init(red: 165/255.0, green: 194/255.0, blue: 176/255.0, alpha: 1)
                    //将颜色和颜色的位置定义在数组内
                    let gradientColors: [CGColor] = [topColor.cgColor, buttomColor.cgColor]
                    let gradientLocations: [NSNumber] = [0.0, 1.0]

                    //创建CAGradientLayer实例并设置参数
                    let gradientLayer: CAGradientLayer = CAGradientLayer()
                    gradientLayer.colors = gradientColors
                    gradientLayer.locations = gradientLocations

                    //设置其frame以及插入view的layer
                    gradientLayer.frame = self.view.frame
                    self.view.addSubview(self.saveResView)
                    saveResView.layer.insertSublayer(gradientLayer, at: 0)
    //                self.view.layer.insertSublayer(gradientLayer, at: 0)

                }




            }

        }
    }


    // MARK: - Actions and helper functions

    @IBAction func saveResButtonPressed(_ sender: UIButton) {
        self.saveResButton.isUserInteractionEnabled = false
        self.saveResButton.setTitle("Generating...", for: .normal)
        self.saveResButton.backgroundColor = UIColor.init(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1)
        self.saveResButton.setTitleColor(UIColor.init(red: 255/255.0, green: 250/255.0, blue: 205/255.0, alpha: 1), for: .normal)

        let semaA = DispatchSemaphore(value: 1)
        let semaB = DispatchSemaphore(value: 0)
        let semaC = DispatchSemaphore(value: 0)
        DispatchQueue.global().async {
            semaA.wait()
            self.startPoseAnalysis()
            semaB.signal()
        }


        DispatchQueue.main.async {
            semaB.wait()
            semaC.signal()
        }


        DispatchQueue.main.async {
            semaC.wait()
            self.dismiss(animated: true)
            PoseAnaTableViewController().tableView.reloadData()
            semaA.signal()
        }





    }

    func addNeckFwTiltLevelToDB(_ level: Int) {
        let sidePoseEvalEntity = SidePostureEvaluation(context: poseManagedContext)
        sidePoseEvalEntity.neckForwardTiltLevel = Int32(level)

        currentPose.genSideEvaluation = sidePoseEvalEntity

//        if let currPoseEntity = currentPose,
//           let sidePSMember = currPoseEntity.genSideEvaluation{
//            currPoseEntity.genSideEvaluation = sidePSMember
//        }
        do{
            try poseManagedContext.save()
//            print("关系添加成功")

        }catch{}
    }


    func startPoseAnalysis(){

//        keypointsProcessing()
        self.insertPoseCaptureEntity(self.xxToStore, self.yyToStore)
        let sidePoseEvalEntity = SidePostureEvaluation(context: poseManagedContext)
        let frontPoseEvalEntity = FrontPostureEvaluation(context: poseManagedContext)

        // ----------------------- 侧面站立姿态问题 ----------------------
        if knnResSideOrFront == "side" {
            // 1 -
            let neckFwTiltLevelToDB: Int = neckFwTiltProcessing()
            if neckFwTiltLevelToDB != -1 {
                sidePoseEvalEntity.neckForwardTiltLevel = Int32(neckFwTiltLevelToDB)
            }
            if towardDir == "right" {
                // 2 -
                let anteriorTiltLevelToDB: Int = anteriorTiltProcessing()
                if anteriorTiltLevelToDB != -1 {
                    sidePoseEvalEntity.anteriorPelvicTiltLevel = Int32(anteriorTiltLevelToDB)
                }
                // 3 -
                let hunchbackLevel: Int = hunchbackProcessing()

                // 暂时只存了 normal - 正常的程度
                sidePoseEvalEntity.hunchbackLevel = Int32(hunchbackLevel)
            }
            // 最后统一插入数据库
            currentPose.genSideEvaluation = sidePoseEvalEntity

            do{
                try poseManagedContext.save()
            }catch{}
        }

        else if knnResSideOrFront == "front" {
            print("正面站立！开始判断！")
            let highAndLowShouldersLevelToDB: Int = shouldersProcessing()
            let bowLeggednessLevelToDB: Int = bowLeggednessProcessing()
            let knockKneesLevelToDB: Int = knockKneesProcessing()

            frontPoseEvalEntity.highLowShouldersLevel = Int32(highAndLowShouldersLevelToDB)
            frontPoseEvalEntity.bowLeggedness = Int32(bowLeggednessLevelToDB)
            frontPoseEvalEntity.knockKnees = Int32(knockKneesLevelToDB)

            currentPose.genFrontEvaluation = frontPoseEvalEntity

            do{
                try poseManagedContext.save()
            }catch{}
        }


    }
    func shouldersProcessing() -> Int {
        // 正面的中轴线 X 轴坐标
//        let selectedIdx = [2, 4, 10, 12]   // 眼睛和肩部
//        let dataPoints = getLatestSdpose()
//        var pointsXCor: [Double] = []
//        for idx in selectedIdx{
//            pointsXCor.append(dataPoints[idx])
//        }
//        var axleWireFront = pointsXCor.reduce(0, +) / Double(pointsXCor.count)



        return 0
    }
    func bowLeggednessProcessing() -> Int {
        return 0
    }

    func knockKneesProcessing() -> Int {
        return 0
    }

    func neckFwTiltProcessing() -> Int {
        // 判断脖子前倾
        let avgNeckAngle = CGFloat(self.neckFwTiltAngle.reduce(0, +)) / CGFloat(self.neckFwTiltAngle.count)
        let level = getNeckFwTiltLevel(avgNeckAngle)
        return level
    }

    func hunchbackProcessing() -> Int {
        print("🌱🌱🌱🌱🌱🌱🌱🌱🌱🌱🌱🌱🌱🌱🌱🌱🌱🌱🌱🌱🌱")
        let dataPoints = getLatestSdpose()
        // 如果是侧面站立 - 选取以下关键点的X轴坐标 - 再计算均值（均值受离群点影响太大，可以找个替代方法）
        // 肩部 臀部 膝盖 脚踝
//        let usefulIndex = [10, 12, 22, 24, 26, 28, 30, 32]
        // 耳朵 脚踝
//        let usefulIndex = [6, 8, 30, 32]
        //  肩部 臀部 脚踝
        let usefulIndex = [10, 12, 22, 24, 30, 32]
        // 耳朵 肩部 臀部
//        let usefulIndex = [6, 8, 10, 12, 22, 24]

        //肩部 臀部
//        let usefulIndex = [10, 12, 22, 24]

        //肩部
//        let usefulIndex = [10, 12]


        var pointsXCor: [Double] = []
        for idx in usefulIndex {
            pointsXCor.append(dataPoints[idx])
        }

        var axleWire = pointsXCor.reduce(0, +) / Double(pointsXCor.count)
        print("人体中轴线：x = \(axleWire)")
//        axleWire -= 0.085
        var axleWireV1 = 0.0
        if UserDefaults.standard.integer(forKey: "height") < 160 {
            axleWireV1 = 0.033
        }
        else if UserDefaults.standard.integer(forKey: "height") >= 160 && UserDefaults.standard.integer(forKey: "height") < 170{
            axleWireV1 = 0.035
        }
        else if UserDefaults.standard.integer(forKey: "height") >= 170 && UserDefaults.standard.integer(forKey: "height") < 180{
            axleWireV1 = 0.037
        }
        else{
            axleWireV1 = 0.039
        }

        // 映射到二值图像中
        var axleWireInCGImageList: [Double] = []

        // MARK: - 曲线拟合数据点获取
        var shoulderPartPixelHeight: [Int] = []   // 以肩部为中心
        var humanPixelHeight: [Int] = []     // 人体像素高度
        var humanHeightRatio: [CGFloat] = []       // 人体像素高度/真实身高
        var selectedCurveRatioArr: [CGFloat] = []    // 所选取的曲线占整体人体像素高度的比例
        var processedCurRatioArr: [CGFloat] = []    // 人体像素高度/真实身高
//        var hunchbackLevelArray: [Int] = []


        // 人体像素高度
        for imgimg in self.allCGImageSeg {
            let height = getHumanPartLength(imgimg)
            humanPixelHeight.append(height)
            humanHeightRatio.append(CGFloat(height)/CGFloat(UserDefaults.standard.integer(forKey: "height")))
            axleWireInCGImageList.append(axleWire*Double(imgimg.width))
        }
        for i in 0..<self.allEarPos.count {
            shoulderPartPixelHeight.append(2 * Int(abs(self.allShoulderPos[i] - self.allEarPos[i])))
        }

        for j in 0..<self.allEarPos.count {
            selectedCurveRatioArr.append(CGFloat(shoulderPartPixelHeight[j])/CGFloat(humanPixelHeight[j]))
        }

        processedCurRatioArr = mad(humanHeightRatio, 1)
        let finalRatio = CGFloat(processedCurRatioArr.reduce(0, +)) / CGFloat(processedCurRatioArr.count)
        var maxYInSampling: [CGFloat] = []
        // 研究驼背的曲线在现实世界中的高度


        for j in 0..<self.allCGImageSeg.count {
            let hunchbackPointsRes = hunchbackPoints(self.allCGImageSeg[j], axleWireInCGImageList[j], self.allEarPos[j], self.allShoulderPos[j])
            let xx = hunchbackPointsRes[0]
            let yy = hunchbackPointsRes[1]
//            print("xx = \(xx)")
//            print("yy = \(yy)")
            if xx.count <= 1 || yy.count <= 1{

                print("未找到边缘！")
                maxYInSampling.append(0.0)
                continue
            }
            else {
                var points: [CGPoint] = []    // 当前的离散数据点
                for j in 0..<xx.count {
                    points.append(CGPoint(x: xx[j], y: yy[j]))
                }

                // 对当前数据点进行回归
                let regression = PolynomialRegression.regression(withPoints: points, degree: 6)

                var allCoeff: [CGFloat] = []   // 当前曲线拟合的参数
                for i in 0..<regression!.count {
                    allCoeff.append(CGFloat(regression![i]))
                }
                var curveFittingXY: [CGPoint] = []
                for varX in xx {
                    curveFittingXY.append(CGPoint(x: CGFloat(varX), y: objectiveFunc(allCoeff, CGFloat(varX))))
                }
                let maxYPoint = curveFittingXY.max(by: {$0.y < $1.y})!
                maxYInSampling.append(maxYPoint.y - axleWireV1*Double(self.allCGImageSeg[j].width))
            }

        }

        let filterMaxY = mad(maxYInSampling, 1)
        let maxYmean = CGFloat(filterMaxY.reduce(0, +)) / CGFloat(filterMaxY.count)
        let initialDist = maxYmean/finalRatio

        print("驼背即胸椎过度后凸的距离 = \(maxYmean/finalRatio) cm")
        var biasDis = 0.0
        if UserDefaults.standard.integer(forKey: "height") >= 178 {
            biasDis += 1.6
        }
        if initialDist <= 8 + biasDis {
            return 0
        }
        else if initialDist > 8 + biasDis && initialDist <= 11 + biasDis {
            return 1
        }
        else if initialDist > 11 + biasDis && initialDist <= 13 + biasDis {
            return 2

        }
        else {
            return 3
        }

    }

    func anteriorTiltProcessing() -> Int{
        // MARK: - Parameters
//        var res: [[CGPoint]] = []   // 用于曲线拟合
        var humanPixelHeight: [Int] = []     // 主体（人物）像素高度
        var curvePixelHeight: [Int] = []     // 研究的曲线部分像素高度
        var curveRatio: [CGFloat] = []   // 选取曲线占整体高度的比例
        var newCurveRatio: [CGFloat] = []     // 对`curveRatio`去除离群值
        var avgCurveRatioBeta: CGFloat = 0.0
        var anteriorTiltLevelArray: [Int] = []

        for imgimg in self.allCGImageSeg {
            humanPixelHeight.append(getHumanPartLength(imgimg))
        }
        for i in 0..<self.allHipPos.count {
            curvePixelHeight.append(Int(abs(self.allHipPos[i] - self.allShoulderPos[i])))
        }
        for pp in 0..<self.allHipPos.count{
            curveRatio.append(CGFloat(curvePixelHeight[pp]) / CGFloat(humanPixelHeight[pp]))
        }
        newCurveRatio = mad(curveRatio, 1)
//        比率beta —— MAD后使用均值
        avgCurveRatioBeta = CGFloat(newCurveRatio.reduce(0, +)) / CGFloat(newCurveRatio.count)
        let de = UserDefaults.standard   // 获取用户身高
        let actDist = avgCurveRatioBeta * CGFloat(de.integer(forKey: "height"))   // 实际距离

        var anDistLi: [CGFloat] = []




        for i in 0..<self.allHipPos.count {
            // MARK: - 遍历采样期间内捕获的所有离散点
            // 图像的x坐标集合代表了曲线的走向
            if self.allShoulderPos[i] >= self.allHipPos[i] {
                return -1
            }

            let arr = getCurveDataPoints(self.allShoulderPos[i], self.allHipPos[i], self.allCGImageSeg[i])

            var points: [CGPoint] = []    // 当前的离散数据点
            let xArr = arr[0]
            let yArr = arr[1]
            for j in 0..<xArr.count {
                points.append(CGPoint(x: xArr[j], y: yArr[j]))
            }

            let pointsCount: Int = points.count    // 离散数据点的个数

            // 对当前数据点进行回归
            let regression = PolynomialRegression.regression(withPoints: points, degree: 6)
            var allCoeff: [CGFloat] = []   // 当前曲线拟合的参数
            for i in 0..<regression!.count {
                allCoeff.append(CGFloat(regression![i]))
            }

            if pointsCount > Int(actDist) {
                var newXYCGPoints: [CGPoint] = []    // 所有曲线部分的数据点
                // 缩小m倍 (m>1)
                let m: CGFloat = CGFloat(pointsCount) / CGFloat(actDist)
                // 生成新的x轴坐标
//                var newX: [CGFloat] = []
//                var newY: [CGFloat] = []
                for idx in 0..<Int(actDist) {
                    // g(x) = 1/m * f(mx)
                    newXYCGPoints.append(CGPoint(x: CGFloat(idx), y: transformFuncDes(allCoeff, CGFloat(idx), m)))
//                    newX.append(CGFloat(idx))
//                    newY.append(CGFloat(transformFuncDes(allCoeff, CGFloat(idx), m)))
                }
//                print("系数：")
//                print(allCoeff)
//                print("模拟函数：")
//                print("xx = \(newX)")
//                print("yy = \(newY)")

            // 最大值 - 在腰部附近
               let maxYPoint = newXYCGPoints.max(by: {$0.y < $1.y}) //(1241.0, 1111.0)
//                let maxYPoint = upperPartPoints.max(by: {$0.y < $1.y})!   // 背部最外侧的点
                var anteriorTiltLevel = -1
//                print("最外侧点的y坐标：\(maxYPoint.y)")
                let anDist = maxYPoint!.y - femalePalmThickness
                anDistLi.append(anDist)
//                print("🌱🌱🌱🌱🌱🌱🌱🌱🌱🌱🌱🌱🌱")

                if maxYPoint!.y >= 0 && maxYPoint!.y <= femalePalmThickness {
                    anteriorTiltLevel = 0   // 正常
                }
                else if anDist > 0 && anDist <= 3 {
                    anteriorTiltLevel = 1   // 轻微
                }
                else if anDist > 3 && anDist <= 5 {
                    anteriorTiltLevel = 2
                }
                else if anDist > 5 {
                    anteriorTiltLevel = 3
                }
                else {
                    anteriorTiltLevel = -1
                }
                anteriorTiltLevelArray.append(anteriorTiltLevel)

            }
        }
        let anAVG = CGFloat(anDistLi.reduce(0, +)) / CGFloat(anDistLi.count)
//        print("超过自然生理曲度的平均距离：\(anAVG)")

        let results = mostFrequent(array: anteriorTiltLevelArray)
        let anteriorTiltLevelModeArray = results?.mostFrequent
        let finalReturnLevel = anteriorTiltLevelModeArray!.min()!

        return finalReturnLevel

    }

    func objectiveFunc(_ coeff: [CGFloat], _ x: CGFloat) -> CGFloat {
        var sum: CGFloat = 0.0
        for nn in 0..<coeff.count {
            sum += CGFloat(coeff[nn])*pow(x, CGFloat(nn))
        }
        return sum
    }

    func transformFuncDes(_ coeff: [CGFloat], _ x: CGFloat, _ m: CGFloat) -> CGFloat {
//        print("减小函数的scale")
        return (1/m) * (objectiveFunc(coeff, m*x))
    }

    func transformFuncInc(_ coeff: [CGFloat], _ x: CGFloat, _ m: CGFloat) -> CGFloat {
//        print("增大函数的scale")
        return m * (objectiveFunc(coeff, (1/m)*x))
    }

    func derivative1ObjFunc(_ coeff: [CGFloat], _ x: CGFloat) -> CGFloat {
        return CGFloat(coeff[1] + 2*coeff[2]*pow(x, 2) + 3*coeff[3]*pow(x, 2) + 4*coeff[4]*pow(x, 3) + 5*coeff[5]*pow(x, 4) + 6*coeff[6]*pow(x, 5))
    }

    func calcCavatureDes(_ coeff: [CGFloat], _ x: CGFloat, _ m: CGFloat) -> CGFloat {
        let fenzi = sqrt(Double(pow(2*coeff[2], 2)+pow(6*coeff[3], 2)+pow(12*coeff[4], 2)+pow(20*coeff[5], 2)+pow(30*coeff[6], 2)))
        let newFenzi = abs((1/m)) * fenzi

        let fenmu = pow((1+pow(derivative1ObjFunc(coeff, m*x), 2)), 1.5)

        return CGFloat(newFenzi)/CGFloat(fenmu)
    }


    func keypointsProcessing(){
        self.saveFlag = true
        var newKeypointsArray: [[CGFloat]] = [[], [], [], [], [], [],
                                              [], [], [], [], [], [],
                                              [], [], [], [], [], [],
                                              [], [], [], [], [], [],
                                              [], [], [], [], [], [],
                                              [], [], [], []]
        // 对于每个关键点维度，对所有关键点求平均/求中位数
        var keypoints_mean: [CGFloat] = []
        var keypoints_median: [CGFloat] = []

        for idx in 0..<self.totalKeypointsArray.count {
            newKeypointsArray[idx] = mad(self.totalKeypointsArray[idx], self.madRatio)
        }


        for idx in 0..<newKeypointsArray.count {
            let average: CGFloat = CGFloat(newKeypointsArray[idx].reduce(0.0, +)) / CGFloat(newKeypointsArray[idx].count)
            keypoints_mean.append(average)
            keypoints_median.append(calculateMedian(newKeypointsArray[idx]))
        }

        self.xxToStore = []
        self.yyToStore = []
        if self.kpMode == "mean" {
            for i in 0..<keypoints_mean.count {
                if i % 2 == 0{
                    self.xxToStore.append(keypoints_mean[i])
                }
                else {
                    self.yyToStore.append(keypoints_mean[i])
                }
            }
        }
        else if self.kpMode == "median" {
            for i in 0..<keypoints_median.count {
                if i % 2 == 0{
                    self.xxToStore.append(keypoints_mean[i])
                }
                else {
                    self.yyToStore.append(keypoints_mean[i])
                }
            }
        }
        else {
            print("Wrong mode, please check!!")
        }

        // 将处理后的关键点插入数据库  - 赋值给xxToStore和yyToStore，同时插入数据库时也更新了UserDefaults
        getKnnRes(self.xxToStore, self.yyToStore)
//        self.insertPoseCaptureEntity(self.xxToStore, self.yyToStore)
    }

    // MARK:  翻转摄像头
    @IBAction func onCameraButtonTapped(_ sender: Any) {

        videoCapture.flipCamera { error in
            if let error = error {
                print("Failed to flip camera with error \(error)")
            }
        }
    }

    // MARK:  开始采样
    @IBAction func startSamplingButtonPressed(_ sender: UIButton) {

        if counter > 5 {
            self.startSamplingFlag = false

        }
        if counter == 5 {
            self.startSamplingFlag = true

        }
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)



    }

    func playSound() {
        guard let path = Bundle.main.path(forResource: "beep", ofType:"m4a") else {
            return }
        let url = URL(fileURLWithPath: path)

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()

        } catch let error {
            print(error.localizedDescription)
        }
    }



    // MARK: - KNN predict
    func knnPredict(_ savedPosePosition: [Double]) -> String {
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
        knn = KNearestNeighborsClassifier(data: data, labels: labels)

        let predictionLabels = knn.predict([savedPosePosition])

        let predictionStandType = predictionLabels.map({ HumanPose.fromLabel($0) })

        return predictionStandType[0]
    }


    func getKnnRes(_ xx:[CGFloat], _ yy:[CGFloat]) {
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
            self.samplingReportGenTitle.text = "Sampling is complete and you are detected in the side standing position!"
            self.samplingReportImageHint.image = UIImage(named: "sideExample")

        }
        else {
            self.samplingReportGenTitle.text = "Sampling is complete and you are detected in the front standing position!"
            self.samplingReportImageHint.image = UIImage(named: "frontExample")
        }
    }

    // MARK: - 插入数据库
    /*
                    输入：frame上的关键点坐标（未经归一化）
     */
    private func insertPoseCaptureEntity(_ xx:[CGFloat], _ yy:[CGFloat]) {
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

        // MARK: - 1 - 插入数据库，更新键值对
        let currentDate = Date()
        let defaults = UserDefaults.standard
        let weightToDB = defaults.integer(forKey: "weight")
        let heightToDB = defaults.integer(forKey: "height")
//        let xAttr: [String] = ["id0x", "id1x", "id2x", "id3x", "id4x", "id5x", "id6x", "id7x", "id8x", "id9x", "id10x", "id11x", "id12x", "id13x", "id14x", "id15x", "id16x"]
//        let yAttr: [String] = ["id0y", "id1y", "id2y", "id3y", "id4y", "id5y", "id6y", "id7y", "id8y", "id9y", "id10y", "id11y", "id12y", "id13y", "id14y", "id15y", "id16y"]
//        let fetch: NSFetchRequest<PoseCapture> = PoseCapture.fetchRequest()
        // 1 - 上下文
        currentPose = PoseCapture(context: poseManagedContext)

        // 2 - 数据
        currentPose?.captureDate = currentDate
        currentPose?.height = Int32(heightToDB)
        currentPose?.weight = Int32(weightToDB)
        currentPose?.id0x = Float(normX[0])
        currentPose?.id0y = Float(normY[0])
        currentPose?.id1x = Float(normX[1])
        currentPose?.id1y = Float(normY[1])
        currentPose?.id2x = Float(normX[2])
        currentPose?.id2y = Float(normY[2])
        currentPose?.id3x = Float(normX[3])
        currentPose?.id3y = Float(normY[3])
        currentPose?.id4x = Float(normX[4])
        currentPose?.id4y = Float(normY[4])
        currentPose?.id5x = Float(normX[5])
        currentPose?.id5y = Float(normY[5])
        currentPose?.id6x = Float(normX[6])
        currentPose?.id6y = Float(normY[6])
        currentPose?.id7x = Float(normX[7])
        currentPose?.id7y = Float(normY[7])
        currentPose?.id8x = Float(normX[8])
        currentPose?.id8y = Float(normY[8])
        currentPose?.id9x = Float(normX[9])
        currentPose?.id9y = Float(normY[9])
        currentPose?.id10x = Float(normX[10])
        currentPose?.id10y = Float(normY[10])
        currentPose?.id11x = Float(normX[11])
        currentPose?.id11y = Float(normY[11])
        currentPose?.id12x = Float(normX[12])
        currentPose?.id12y = Float(normY[12])
        currentPose?.id13x = Float(normX[13])
        currentPose?.id13y = Float(normY[13])
        currentPose?.id14x = Float(normX[14])
        currentPose?.id14y = Float(normY[14])
        currentPose?.id15x = Float(normX[15])
        currentPose?.id15y = Float(normY[15])
        currentPose?.id16x = Float(normX[16])
        currentPose?.id16y = Float(normY[16])

        var normXToStore: [Any] = []
        var normYToStore: [Any] = []
        for ix in normX {
            normXToStore.append(ix)
        }
        for iy in normY {
            normYToStore.append(iy)
        }

        defaults.set(normXToStore, forKey: "lastNormX")
        defaults.set(normYToStore, forKey: "lastNormY")

        let temp_input = getLatestSdpose()
        UIPasteboard.general.string = "\(temp_input)"
        // MARK: - KNN predict（后端执行预测任务）
        // 开始执行KNN预测
        let res = knnPredict(temp_input)
        defaults.set(res, forKey: "LatestPosture")
        currentPose?.standingPosition = res
        self.knnResSideOrFront = res


        // 判断是朝左还是朝右
        if res == "side" {
            if normX[0] > normX[3] || normX[0] > normX[4] {
                towardDir = "right"
            }
            if normX[0] < normX[3] || normX[0] < normX[4] {
                towardDir = "left"
                towardLeftCount += 1
            }

        }
        else {
            towardDir = "front"
        }

        // 3 - 保存
        do {
            try poseManagedContext.save()
            self.currNumOfFrameCaptured += 1
            print("插入数据库成功！站立姿势：\(res)")
            print("allEdge")
            print(allEdgePoints.count)
            print(allEdgePoints)
        }catch{}

    }





    // MARK: -

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

}




// MARK: - VideoCaptureDelegate
extension PoseVideoSampling: VideoCaptureDelegate {
    func videoCapture(_ videoCapture: VideoCapture, didCaptureFrame capturedImage: CGImage?) {
        guard currentFrame == nil else {
            return
        }
        guard let image = capturedImage else {
            fatalError("Captured image is null")
        }

        currentFrame = image
//        if totalFrameCount == 100 {
        poseNet.predict(image)
    }
}



// MARK: - PoseNetDelegate
extension PoseVideoSampling: PoseNetDelegate {
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


        previewImageView.show(poses: poses, on: currentFrame)
        if startSamplingFlag{
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


            // MARK: -  脖子前倾  脖子前倾  脖子前倾   脖子前倾
            let leftEarPoint: CGPoint = CGPoint(x: leftEarJoint.position.x, y: leftEarJoint.position.y)
            let rightEarPoint: CGPoint = CGPoint(x: rightEarJoint.position.x, y: rightEarJoint.position.y)
            let leftShoulderPoint: CGPoint = CGPoint(x: leftShoulderJoint.position.x, y: leftShoulderJoint.position.y)
            let rightShoulderPoint: CGPoint = CGPoint(x: rightShoulderJoint.position.x, y: rightShoulderJoint.position.y)

//            let selectedEar = leftEarJoint.position.x < rightEarJoint.position.x ? leftEarPoint: rightEarPoint
//            let selectedSh = leftShoulderJoint.position.x < rightShoulderJoint.position.x ? leftShoulderPoint : rightShoulderPoint
//            let neckAngle = calcNeckForwardTiltAngle(selectedEar-selectedSh)

            let earPointSum = leftEarPoint + rightEarPoint
            let shoulderPointSum = leftShoulderPoint + rightShoulderPoint
            let earPointMean = CGPoint(x: earPointSum.x/2, y: earPointSum.y/2)
            let shoulderPointMean = CGPoint(x: shoulderPointSum.x/2, y: shoulderPointSum.y/2)
            let neckAngle = calcNeckForwardTiltAngle(earPointMean - shoulderPointMean)
            neckAngleLabel.text = "Neck forward tilt angle: \(neckAngle)"
            neckFwTiltAngle.append(neckAngle)

            // MARK: - 姿势评估 - 骨盆前倾
            // 离y轴更近的肩部关节点
            let shoulderY01 = leftShoulderPoint.x < rightShoulderPoint.x ?  leftShoulderPoint.y : rightShoulderPoint.y
            let hipY01 = leftHipJoint.position.x < rightHipJoint.position.x ? leftHipJoint.position.y : rightHipJoint.position.y
            let ear01 = leftEarJoint.position.x < rightEarJoint.position.x ? leftEarJoint.position.y : rightEarJoint.position.y

            allShoulderPos.append(shoulderY01)
            allHipPos.append(hipY01)
            allEarPos.append(ear01)
            // just add image segmentation result

            let srcImg: UIImage =  UIImage(cgImage: currentFrame)
//            if totalFrameCount == 0{
//                let saveTo = srcImg
//                let data = saveTo.pngData()
//                let filename = getDocumentsDirectory().appendingPathComponent("test0_src_\(totalFrameCount).png")
//                try? data!.write(to: filename)
//            }

            if let cgImg = srcImg.segmentation(){
//                if totalFrameCount == 0{
//                    let saveTo = UIImage(cgImage: cgImg)
//                    let data = saveTo.pngData()
//                    let filename = getDocumentsDirectory().appendingPathComponent("test0_seg_\(totalFrameCount).png")
//                    try? data!.write(to: filename)
//                }
                allCGImageSeg.append(cgImg)
            }




            // MARK: - 添加数据点

            for jj in 0..<2*myJoints.count {
                if jj % 2 == 0 {
                    totalKeypointsArray[jj].append(myJoints[Int(jj/2)].position.x)
                }
                else {
                    totalKeypointsArray[jj].append(myJoints[Int(jj/2)].position.y)
                }
            }
            totalFrameCount += 1
        }

        }
    }






extension PoseVideoSampling{
    
    
    func angle_between_edges(_ vec1: CGPoint, _ vec2: CGPoint) -> CGFloat{
        let res = cosine_angle_CGPoint(vec1, vec2)
        let radAngle = acos(res)
        let degAngle = (radAngle*180)/Double.pi
        return degAngle
    }


    // Neck forward tilt angle
    // 脖子前倾角度计算
    func calcNeckForwardTiltAngle(_ vecEarMinusShoulder: CGPoint) -> CGFloat{
        let horizontalVec: CGPoint = CGPoint(x: 1, y: 0)
        let degreeAngle = angle_between_edges(vecEarMinusShoulder, horizontalVec)
        if degreeAngle > 0 && degreeAngle <= 90 {
            return degreeAngle
        }
        else if degreeAngle > 90 && degreeAngle < 180 {
            return abs(180-degreeAngle)
        }
        else {
            return 0.0
        }
    }

    // 脖子前倾程度 - 0, 1, 2, 3
    // 正常 80~95
    func getNeckFwTiltLevel(_ avgAng: CGFloat) -> Int {
        if avgAng <= 95 && avgAng >= 0{
            if avgAng >= 80{
                return 0    // 正常
            }
            else if avgAng >= 75 && avgAng < 80 {
                return 1
            }
            else if avgAng >= 70 && avgAng < 75{
                return 2
            }
            else if avgAng < 70{
                return 3
            }
            else {
                return -1
            }
        }
        else{
            return -1
        }
        
    }


    func mostFrequent(array: [Int]) -> (mostFrequent: [Int], count: Int)? {
        var counts: [Int: Int] = [:]
            
        array.forEach { counts[$0] = (counts[$0] ?? 0) + 1 }
        if let count = counts.max(by: {$0.value < $1.value})?.value {
            return (counts.compactMap { $0.value == count ? $0.key : nil }, count)
        }
        return nil
    }


    // MARK: - 方法说明
    //  - input：以图像: UIImage以及姿势作为输入
    //  - 具体步骤：
    //              1 - 获取肩部，臀部的坐标
    //              2 -
    //              3 -
    //  - output：数据点

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    // MARK: - 曲线部分的垂直长度，离散数据点
    func getCurveDataPoints(_ shoulderYCoord: CGFloat, _ hipYCoord: CGFloat, _ cgImage: CGImage) -> [[Int]] {
    //    print("肩部：\(Int(shoulderYCoord))")
    //    print("臀部：\(Int(hipYCoord))")
        let upperBound = Int(hipYCoord + (hipYCoord-shoulderYCoord)*0.2)
        
        var xArr: [Int] = []   // 新的x
        var yArr: [Int] = []    // 新的y
        var upperYArr: [Int] = []
        var resCGPoint: [CGPoint] = []     // 该CGPoint的x坐标是图像中的y坐标，图像中的y坐标是连续变化的
        
        
        let data = cgImage.dataProvider?.data
        let bytes = CFDataGetBytePtr(data)!
        let bytesPerPixel = cgImage.bitsPerPixel / cgImage.bitsPerComponent
        for y in Int(shoulderYCoord)...upperBound {
            var flag = -1
            for x in 0 ..< cgImage.width {
                let offset = (y * cgImage.bytesPerRow) + (x * bytesPerPixel)
                let components = (r: bytes[offset], g: bytes[offset + 1], b: bytes[offset + 2])
                if (x+1) < cgImage.width {
                    let off2 = (y * cgImage.bytesPerRow) + ((x+1) * bytesPerPixel)
                    let rightCo = (r: bytes[off2], g: bytes[off2 + 1], b: bytes[off2 + 2])
                    if components != rightCo {
                        if flag == -1 {
                            xArr.append(y)
                            yArr.append(x)
                            if y < Int(shoulderYCoord) + Int((hipYCoord - shoulderYCoord)*0.3) {
                                upperYArr.append(x)
                            }
                            flag += 1
                        }
                    }
                }
            }
        }
    //    let xMin = xArr.min()!
        
        guard let xMin = xArr.min() else {return [[0]]}
    //    let yMin = yArr.min()!
        
        
        guard let yMin = yArr.min() else {return [[0]]}
        guard let upYMin = upperYArr.min() else {return [[0]]}
    //    print("上半部分背部的最小值：\(upYMin)")
    //    print("肩部 - 臀部的最小值：\(yMin)")
        var newX: [Int] = []
        var newY: [Int] = []
        for ele in xArr{
            newX.append(ele-xMin)
        }
        for ele in yArr{
            newY.append(ele-upYMin)
        }
        return [newX, newY]
    }





    // MARK: - 返回人体总长度
    ///
    func getHumanPartLength(_ cgImage: CGImage) -> Int {
        let data = cgImage.dataProvider?.data
        let bytes = CFDataGetBytePtr(data)!
        let blackComponent = (r: UInt8(), g: UInt8(), b: UInt8())
        let bytesPerPixel = cgImage.bitsPerPixel / cgImage.bitsPerComponent
        var topYPos: Int = -1
        var bottomYPos: Int = -1
        
        for y in 0..<cgImage.height{
            for x in 0..<cgImage.width {
                if topYPos == -1 {
                    let currOff = (y * cgImage.bytesPerRow) + (x * bytesPerPixel)
                    let currCompo = (r: bytes[currOff], g: bytes[currOff + 1], b: bytes[currOff + 2])
                    if currCompo != blackComponent {
                        topYPos = y
                        break
                    }
                }
            }
        }
        
        
        for j in 0..<cgImage.height {
            let y = cgImage.height - 1 - j
            for x in 0..<cgImage.width {
                if bottomYPos == -1 {
                    let currOff = (y * cgImage.bytesPerRow) + (x * bytesPerPixel)
                    let currCompo = (r: bytes[currOff], g: bytes[currOff + 1], b: bytes[currOff + 2])
                    // 判断currCompo是不是白色的
                    if currCompo != blackComponent {
                        bottomYPos = y
                        break
                    }
                  }
                }
            }
        
        
        return abs(bottomYPos - topYPos)
    }



    // MARK: - 返回 肩部-臀部部分的长度占人体总长度的比例

    func getCurveRatio(_ curveLen: Int, _ humanLen: Int) -> CGFloat {
        return CGFloat(curveLen) / CGFloat(humanLen)
    }



    // MARK: - 驼背研究 - 返回翻转后的数据点
    func hunchbackPoints(_ cgImage: CGImage, _ axleWire: Double, _ earPos: CGFloat, _ shoulderPos: CGFloat) -> [[Int]] {
     
        var newX: [Int] = []
        var newY: [Int] = []
        let data = cgImage.dataProvider?.data
        let bytes = CFDataGetBytePtr(data)!
        let bytesPerPixel = cgImage.bitsPerPixel / cgImage.bitsPerComponent
        let lowerBound = Int(earPos + 0.5*abs(shoulderPos - earPos))
        let upperBound = Int(lowerBound + 3*Int(abs(shoulderPos - earPos)))
        for y in lowerBound...upperBound{
            var flag = -1
            for x in 0...Int(axleWire) {
                let offset = (y * cgImage.bytesPerRow) + (x * bytesPerPixel)
                let components = (r: bytes[offset], g: bytes[offset + 1], b: bytes[offset + 2])
                if (x+1) < Int(axleWire) {
                    let off2 = (y * cgImage.bytesPerRow) + ((x+1) * bytesPerPixel)
                    let rightCo = (r: bytes[off2], g: bytes[off2 + 1], b: bytes[off2 + 2])
                    if components != rightCo {
                        if flag == -1 {
                            newX.append(y)
                            newY.append(Int(Int(axleWire)-x))
                            flag += 1
                        }
                    }
                }
            }
        }
        return [newX, newY]
    }
     


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



extension UIImage {
    
    public func segmentation() -> CGImage? {
        guard var cgImage = self.coarseSegmentation() else {
            return nil
        }
        let outputWidth:CGFloat = 500.0
        let outputSize = CGSize(width: outputWidth, height: outputWidth * (self.size.height / self.size.width))
        let resizeImg = UIImage(cgImage: cgImage).resize(size: outputSize)!
        let ciImg = CIImage(cgImage: resizeImg.cgImage!)
        let smoothFilter = SmoothFilter.init()
        smoothFilter.inputImage = ciImg
 
        let outputImage = smoothFilter.outputImage!
        let ciContext = CIContext(options: nil)
        cgImage = ciContext.createCGImage(outputImage, from: ciImg.extent)!
        return cgImage
    }
    
    public func coarseSegmentation() -> CGImage? {

        let deeplab = Deeplab.init()
//        let deeplab = DeepLabV3FP16.init()
        //input size 513*513
        let pixBuf = self.pixelBuffer(width: 513, height: 513)
        
        guard let output = try? deeplab.prediction(ImageTensor__0: pixBuf!) else {
            return nil
        }
        
        let shape = output.ResizeBilinear_2__0.shape
        let (d,w,h) = (Int(truncating: shape[0]), Int(truncating: shape[1]), Int(truncating: shape[2]))
//        print("🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟")
//        print("输出")
//        print("depth: \(d)")
//        print("width: \(w)")
//        print("height: \(h)")

        let pageSize = w*h       // 像素个数？
        var res:Array<Int> = []
        var pageIndexs:Array<Int> = []     // RGB 通道索引
        for i in 0..<d {
            pageIndexs.append(pageSize * i)
        }
 
        func argmax(arr:Array<Int>) -> Int{
            precondition(arr.count > 0)
            var maxValue = arr[0]
            var maxValueIndex = 0
            for i in 1..<arr.count {
                if arr[i] > maxValue {
                    maxValue = arr[i]
                    maxValueIndex = i
                }
            }
            return maxValueIndex
        }
        
        for i in 0..<w {
            for j in 0..<h {
                var itemArr:Array<Int> = []      // 一行的数组
                let pageOffset = i * w + j       // 在整体数组中的索引
                for k in 0..<d {
                    let padding = pageIndexs[k]
                    itemArr.append(Int(truncating: output.ResizeBilinear_2__0[padding + pageOffset]))
                }
                /*
                types map  [
                    'background', 'aeroplane', 'bicycle', 'bird', 'boat', 'bottle', 'bus',
                    'car', 'cat', 'chair', 'cow', 'diningtable', 'dog', 'horse', 'motorbike',
                    'person', 'pottedplant', 'sheep', 'sofa', 'train', 'tv'
                    ]
                 */
                let type = argmax(arr: itemArr)
                res.append(type)
            }
        }
//        print("res.count: \(res.count)")
        let bytesPerComponent = MemoryLayout<UInt8>.size
        let bytesPerPixel = bytesPerComponent * 4
        let length = pageSize * bytesPerPixel
        var data = Data(count: length)
        data.withUnsafeMutableBytes { (bytes: UnsafeMutablePointer<UInt8>) -> Void in
            var pointer = bytes
            /*
            This reserved only [cat,dog,person]
            */
            let reserve = [8,12,15]
//            var lineIdx = 0
//            var line0Pixel:[UInt8] = []
            for pix in res{
                let v:UInt8 = reserve.contains(pix) ? 255 : 0
//                if lineIdx < 34*65-1 && lineIdx > 33*65{
//                    line0Pixel.append(v)
//                }
                for _ in 0...3 {
                    // 一个字节
                    //
                    pointer.pointee = v
                    pointer += 1
                }
//                lineIdx += 1
            }
//            print("🐶 🐶 🐶 狗子第34行像素 🐶 🐶 🐶")
//            print(line0Pixel.count)
//            print(line0Pixel)
        }
        let provider: CGDataProvider = CGDataProvider(data: data as CFData)!
        let cgimg = CGImage(
            width: w,
            height: h,
            bitsPerComponent: bytesPerComponent * 8,
            bitsPerPixel: bytesPerPixel * 8,
            bytesPerRow: bytesPerPixel * w,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Big.rawValue),
            provider: provider,
            decode: nil,
            shouldInterpolate: false,
            intent: CGColorRenderingIntent.defaultIntent
            )
        return cgimg
    }
}

extension UIImage {

  public func pixelBuffer(width: Int, height: Int) -> CVPixelBuffer? {
    return pixelBuffer(width: width, height: height,
                       pixelFormatType: kCVPixelFormatType_32ARGB,
                       colorSpace: CGColorSpaceCreateDeviceRGB(),
                       alphaInfo: .noneSkipFirst)
  }
 
  func pixelBuffer(width: Int, height: Int, pixelFormatType: OSType,
                   colorSpace: CGColorSpace, alphaInfo: CGImageAlphaInfo) -> CVPixelBuffer? {
    var maybePixelBuffer: CVPixelBuffer?
    let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                 kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue]
    let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                     width,
                                     height,
                                     pixelFormatType,
                                     attrs as CFDictionary,
                                     &maybePixelBuffer)

    guard status == kCVReturnSuccess, let pixelBuffer = maybePixelBuffer else {
      return nil
    }

    CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
    let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer)

    guard let context = CGContext(data: pixelData,
                                  width: width,
                                  height: height,
                                  bitsPerComponent: 8,
                                  bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
                                  space: colorSpace,
                                  bitmapInfo: alphaInfo.rawValue)
    else {
      return nil
    }

    UIGraphicsPushContext(context)
    context.translateBy(x: 0, y: CGFloat(height))
    context.scaleBy(x: 1, y: -1)
    self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
    UIGraphicsPopContext()
    CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
    return pixelBuffer
  }
}

extension UIImage {
    
    func resize(size: CGSize!) -> UIImage? {
        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(rect.size)
        self.draw(in:rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
 
}


fileprivate class SmoothFilter : CIFilter {
    
    private let kernel: CIColorKernel
    var inputImage: CIImage?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init() {
        let kernelStr = """
            kernel vec4 myColor(__sample source) {
                float maskValue = smoothstep(0.3, 0.5, source.r);
                return vec4(maskValue,maskValue,maskValue,1.0);
            }
        """
        let kernels = CIColorKernel.makeKernels(source:kernelStr)!
        kernel = kernels[0] as! CIColorKernel
        super.init()
    }
    
    override var outputImage: CIImage? {
        guard let inputImage = inputImage else {return nil}
        let blurFilter = CIFilter.init(name: "CIGaussianBlur")!
        blurFilter.setDefaults()
        blurFilter.setValue(inputImage.extent.width / 90.0, forKey: kCIInputRadiusKey)
        blurFilter.setValue(inputImage, forKey: kCIInputImageKey)
        let bluredImage = blurFilter.value(forKey:kCIOutputImageKey) as! CIImage
        return kernel.apply(extent: bluredImage.extent, arguments: [bluredImage])
    }
}



