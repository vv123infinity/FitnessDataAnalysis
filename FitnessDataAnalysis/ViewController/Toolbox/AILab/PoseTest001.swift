//
//  PoseTest001.swift
//  FitnessDataAnalysis
//
//  Created by 十口V🌼 on 2023/3/4.
//

import UIKit
import MobileCoreServices
import AVFoundation
import UniformTypeIdentifiers
import AssetsLibrary

class PoseTest001: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: - Outlets
    @IBOutlet weak var userVideoUIView: PoseImageView!
    @IBOutlet weak var playView: UIView!
    // MARK: - Properties
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    let imagePickerController = UIImagePickerController()
    private var poseNet: PoseNet!
    private var currentFrame: CGImage?
    private var algorithm: Algorithm = .single
    private var poseBuilderConfiguration = PoseBuilderConfiguration()
    private var popOverPresentationManager: PopOverPresentationManager?
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the image picker controller
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = [UTType.movie.identifier as String]
        imagePickerController.videoQuality = .typeHigh
        
        // Set up the AVPlayerLayer
        playerLayer = AVPlayerLayer()
        playerLayer?.frame = self.userVideoUIView.frame
        playerLayer?.videoGravity = .resizeAspectFill
        
        // 关键点识别模型
        do {
            poseNet = try PoseNet()
        } catch {
            fatalError("Failed to load model. \(error.localizedDescription)")
        }

        poseNet.delegate = self
        
        self.playView.layer.addSublayer(playerLayer!)
        
    }

    // MARK: - Actions
    
    @IBAction func chooseVideoButtonPressed(_ sender: UIButton) {
        // Present the image picker controller
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    @IBAction func playBtnPressed(_ sender: UIButton) {
        // Play the video
        self.player?.play()
        
    }

    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Get the URL of the selected video
        guard info[UIImagePickerController.InfoKey.mediaURL] is URL else {
            return
        }
        
        guard let videoURL = info[UIImagePickerController.InfoKey.mediaURL] else {
            return
        }
        // Do something with the video URL, such as upload it to a server
        // ...
        // Create a new AVPlayer with the video URL
        player = AVPlayer(url: videoURL as! URL)
        
        // Set the AVPlayerLayer's player to the new AVPlayer
        playerLayer?.player = player
        let videoAsset = AVAsset(url: videoURL as! URL)
        
        
        let t1 = CMTime(value: 0, timescale: 1)
        let t2 = CMTime(value: 1, timescale: 1)
        let t3 = CMTime(value: 2, timescale: 1)
        let timesArray = [
                    NSValue(time: t1),
                    NSValue(time: t2),
                    NSValue(time: t3)
                ]
        
        let generator = AVAssetImageGenerator(asset: videoAsset)
        generator.requestedTimeToleranceBefore = .zero //Optional generator.requestedTimeToleranceAfter = .zero //Optional
        
        generator.generateCGImagesAsynchronously(forTimes: timesArray ) { requestedTime, image, actualTime, result, error in
                    
            self.currentFrame = image!
            self.poseNet.predict(self.currentFrame!)
//             let img = UIImage(cgImage: image!)
            
        }
        
        // Dismiss the image picker controller
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the image picker controller
        picker.dismiss(animated: true, completion: nil)
    }
    


    

}


// MARK: - PoseNetDelegate
extension PoseTest001: PoseNetDelegate {
    // 对一帧的处理
    func poseNet(_ poseNet: PoseNet, didPredict predictions: PoseNetOutput) {
        defer {
            // Release `currentFrame` when exiting this method.
            self.currentFrame = nil
        }
        
//        let img = UIImage(named: "骨盆前倾example2-modified")

        guard let currentFrame = self.currentFrame else {
            return
        }

        let poseBuilder = PoseBuilder(output: predictions,
                                      configuration: poseBuilderConfiguration,
                                      inputImage: currentFrame)

        let poses = algorithm == .single
        ? [poseBuilder.pose]
        : poseBuilder.poses

        //.show(poses: poses, on: currentFrame)
        self.userVideoUIView.show(poses: poses, on: currentFrame)
        
    }
    
}
