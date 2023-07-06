//
//  StartUseV.swift
//  FitnessDataAnalysis
//
//  Created by Infinity vv123 on 2023/3/22.
//

import UIKit

class StartUse: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.setNavigationBarHidden(true, animated: true)

        self.navigationController?.navigationBar.backItem?.title = ""
        let backItem = UIBarButtonItem()
        backItem.title = ""
        self.navigationItem.backBarButtonItem = backItem // This will
        
        UserDefaults.standard.set(true, forKey: "startUse")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func startUse(_ sender: UIButton) {
        DispatchQueue.main.async {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "RootTabBar")

            self.navigationController?.pushViewController(viewController, animated: true)
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        self.navigationItem.backBarButtonItem = backItem // This will
    }

}
