//
//  InfomationHintVC.swift
//  FitnessDataAnalysis
//
//  Created by Infinity vv123 on 2023/6/3.
//

import UIKit

class InfomationHintVC: UIViewController {
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
//    @IBOutlet weak var titleLabel: UILabel!
    
    
    var showText: String!
    var inputTitle: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.contentView.layer.cornerRadius = 15
        self.contentView.backgroundColor = ColorUtil.dynamicColor(dark: UIColor.systemGray6, light: UIColor.white)
        self.textLabel.text = showText
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
