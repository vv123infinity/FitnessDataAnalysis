//
//  TestSmile.swift
//  FitnessDataAnalysis
//
//  Created by 十口V🌼 on 2023/3/21.
//

import UIKit

class TestSmile: UIViewController {

    
    @IBOutlet var smileLabel: [UILabel]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.smileLabel[0].text = "得意黑\nSmiley Sans"
        
        self.smileLabel[0].font = UIFont(name: "Smiley Sans", size: 28)
        
        self.smileLabel[1].text = "红豆生南国，春来发几枝。\n愿君多采撷，此物最相思。"
        
        self.smileLabel[1].font = UIFont(name: "Smiley Sans", size: 18)
        
//        for fontFamily in UIFont.familyNames {
//            print(fontFamily)
//
//            for font in UIFont.fontNames(forFamilyName: fontFamily) {
//                print(fontFamily + ": " + font)
//            }
//        }
   
        /*
         Smiley Sans
         Smiley Sans: SmileySans-Oblique
         */

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
