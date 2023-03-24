//
//  WelcomeViewController.swift .swift
//  FitnessDataAnalysis
//
//  Created by Infinity vv123 on 2023/3/9.
//

import Foundation
import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet weak var actionsStackView: UIStackView!

    let authManager = AppleAuthManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //MARK: 初始化设置
        UserPreferenceSetting.setUpUserPreference()
        
        let appleAuthButton = authManager.authorizationButton
        actionsStackView.addArrangedSubview(appleAuthButton)
        authManager.setAuthButtonTarget(viewController: self)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
    }
    
    @objc
    func handleAppleIdRequest() {
        authManager.handleAppleIdRequest()
//        self.dismiss(animated: true)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AboutPrivacyViewController") as UIViewController
        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func skipSignInBtnPressed(_ sender: UIButton) {
//        self.dismiss(animated: true)
    }
    
    
}
