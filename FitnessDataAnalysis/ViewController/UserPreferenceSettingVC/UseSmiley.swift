//
//  UseSmiley.swift
//  FitnessDataAnalysis
//
//  Created by Infinity vv123 on 2023/3/22.
//

import UIKit

class UseSmiley: UIViewController {

    @IBOutlet var smileyImg: [UIImageView]!
    
    @IBOutlet weak var useMode: UIButton!
    
    @IBOutlet weak var unuseMode: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpImg()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
    }
    func setUpImg() {
        if traitCollection.userInterfaceStyle == .dark {
            self.smileyImg[0].image = UIImage(named: "smileyDark")
//            self.smileyImg[1].image = UIImage(named: "smileyDemoDark")
        }
        else{
            self.smileyImg[0].image = UIImage(named: "smileyLight")
//            self.smileyImg[1].image = UIImage(named: "smileyDemoLight")
        }
    }
    
    
    @IBAction func usePressed(_ sender: UIButton) {
        self.unuseMode.layer.borderWidth = 0
//        self.unuseMode.layer.shadowOpacity = 0
        
        UserDefaults.standard.set(true, forKey: "useSmiley")
        self.useMode.layer.borderWidth = 1.5
        let bc = ColorUtil.dynamicColor(dark: UIColor.white, light: UIColor.black)
        self.useMode.layer.borderColor = bc.cgColor
        self.useMode.layer.cornerRadius = 20

//        self.useMode.layer.shadowOpacity = 0.6
//        self.useMode.layer.shadowColor = ColorUtil.dynamicColor(dark: UIColor.white, light: UIColor.black).cgColor
//        self.useMode.layer.shadowRadius = 2
//
//        self.useMode.layer.shadowOffset = .zero
    }
    
    @IBAction func unusePressed(_ sender: UIButton) {
        self.useMode.layer.borderWidth = 0
//        self.useMode.layer.shadowOpacity = 0
        
        UserDefaults.standard.set(false, forKey: "useSmiley")
        self.unuseMode.layer.borderWidth = 1.5
        let bc = ColorUtil.dynamicColor(dark: UIColor.white, light: UIColor.black)
        self.unuseMode.layer.borderColor = bc.cgColor
        self.unuseMode.layer.cornerRadius = 20
        
//        self.unuseMode.layer.shadowOpacity = 0.6
//        self.unuseMode.layer.shadowColor = ColorUtil.dynamicColor(dark: UIColor.white, light: UIColor.black).cgColor
//        self.unuseMode.layer.shadowRadius = 2
//
//        self.unuseMode.layer.shadowOffset = .zero

    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.setUpImg()
    }

}
