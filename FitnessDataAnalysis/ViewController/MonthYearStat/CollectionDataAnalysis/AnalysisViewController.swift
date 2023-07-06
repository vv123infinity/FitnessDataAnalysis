//
//  AnalysisViewController.swift
//  FitnessDataAnalysis
//
//  Created by Infinity vv123 on 2023/6/3.
//

import UIKit

class AnalysisViewController: UIViewController {
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var containerView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.pageControl.layer.frame = CGRect(x: 0, y: 0, width: 40, height: 50)
//        self.containerView.addSubview(pageControl)
        self.view.addSubview(pageControl)
        
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tutorialPageViewController = segue.destination as? AnalysisPageVC {
            tutorialPageViewController.analysisDelegate = self
        }
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


extension AnalysisViewController: AnalysisPageVCDelegate {
    func tutorialPageViewController(tutorialPageViewController: AnalysisPageVC, didUpdatePageCount count: Int) {
        pageControl.numberOfPages = count
    }
    
    func tutorialPageViewController(tutorialPageViewController: AnalysisPageVC, didUpdatePageIndex index: Int) {
        pageControl.currentPage = index
    }
    
    
}
