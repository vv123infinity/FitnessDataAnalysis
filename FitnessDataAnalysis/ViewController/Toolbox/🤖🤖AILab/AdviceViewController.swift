//
//  AdviceViewController.swift
//  FitnessWithML
//
//  Created by Infinity vv123 on 2022/11/23.
//

import UIKit

class AdviceViewController: UIViewController {

    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet var tipsTitleLabel: [UILabel]!
    @IBOutlet var infoTextLabel: [UILabel]!
    
    var passedTitle: String!
    var subTitle: String!
    var tipsTitle: [String?]!
    var infoText: [String?]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        UISettings()

        // Do any additional setup after loading the view.
    }
    
    func UISettings() {
//        self.title = passedTitle
//        for i in 0..<tipsTitle.count {
//            tipsTitleLabel[i].text = tipsTitle[i]
//            infoTextLabel[i].text = infoText[i]
//        }
        
        
    }
    
    
    
    @IBAction func donePressed(_ sender: UIButton) {
        self.dismiss(animated: true)
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
