//
//  Test.swift
//  FitnessDataAnalysis
//
//  Created by 十口V🌼 on 2023/3/1.
//

import UIKit

class Test: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //首先创建一个模糊效果
        let blurEffect = UIBlurEffect(style: .light)
        //接着创建一个承载模糊效果的视图
        let blurView = UIVisualEffectView(effect: blurEffect)
        //设置模糊视图的大小（全屏）
        blurView.frame.size = CGSize(width: view.frame.width, height: view.frame.height)
         
        //创建并添加vibrancy视图
        let vibrancyView = UIVisualEffectView(effect:
                                                UIVibrancyEffect(blurEffect: blurEffect))
        vibrancyView.frame.size = CGSize(width: view.frame.width, height: view.frame.height)
        blurView.contentView.addSubview(vibrancyView)
         
        //将文本标签添加到vibrancy视图中
        let label = UILabel(frame:CGRectMake(10,20, 300, 100))
        label.text = "hangge.com"
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 40)
        label.textAlignment = .center
        label.textColor = UIColor.white
        vibrancyView.contentView.addSubview(label)
         
        self.view.addSubview(blurView)
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
