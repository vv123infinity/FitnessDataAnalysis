//
//  WelcomeNav.swift
//  FitnessDataAnalysis
//
//  Created by 十口V🌼 on 2023/3/18.
//

import UIKit

class WelcomeNav: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "AboutPrivacyViewController")
        self.navigationController?.pushViewController(vc, animated: true)
        let backItem = UIBarButtonItem()
        backItem.title = ""
        self.navigationItem.backBarButtonItem = backItem
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
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
