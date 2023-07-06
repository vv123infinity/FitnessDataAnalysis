//
//  AnalysisPageVC.swift
//  FitnessDataAnalysis
//
//  Created by Infinity vv123 on 2023/6/3.
//

import UIKit

class AnalysisPageVC: UIPageViewController {

//    weak var analysisDelegate: AnalysisPageVCDelegate?
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.newColoredViewController("IntensityVC"),
            self.newColoredViewController("PaceVC"),
                self.newColoredViewController("DistanceVC"),
                self.newColoredViewController("ComprehensiveVC"),
                
            self.newColoredViewController("BlueVC")]
    }()
    /// 起始日期
    public var startDate: Date!
    /// 结束日期
    public var endDate: Date!
    /// 输入日期范围
    var dateLabelTxt: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        dataSource = self
//        delegate = self
        if let firstViewController = orderedViewControllers.first {
               setViewControllers([firstViewController],
                                  direction: .forward,
                   animated: true,
                   completion: nil)
           }
        
        
    }
    

    
    private func newColoredViewController(_ color: String) -> UIViewController {
        
        switch color {
        case "IntensityVC":
            let vc = UIStoryboard(name: "Assistant", bundle: nil).instantiateViewController(withIdentifier: color) as? IntensityVC
            vc?.startDate = startDate
            vc?.endDate = endDate
            vc?.dateLabelTxt = dateLabelTxt
            return vc!
        case "PaceVC":
            let vc = UIStoryboard(name: "Assistant", bundle: nil).instantiateViewController(withIdentifier: color) as? PaceVC
            vc?.startDate = startDate
            vc?.endDate = endDate
            vc?.dateLabelTxt = dateLabelTxt
            return vc!
            //
        case "DistanceVC":
            let vc = UIStoryboard(name: "Assistant", bundle: nil).instantiateViewController(withIdentifier: color) as? DistanceVC
            vc?.startDate = startDate
            vc?.endDate = endDate
            vc?.dateLabelTxt = dateLabelTxt
            return vc!
        case "ComprehensiveVC":
            let vc = UIStoryboard(name: "Assistant", bundle: nil).instantiateViewController(withIdentifier: color) as? ComprehensiveVC
            vc?.startDate = startDate
            vc?.endDate = endDate
            vc?.dateLabelTxt = dateLabelTxt
            return vc!
        default:
            let vc = UIStoryboard(name: "Assistant", bundle: nil).instantiateViewController(withIdentifier: color)
            return vc
            
        }

        
        
        

    }


}


// MARK: - Data Source

extension AnalysisPageVC: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }
            
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count

        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }

    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
              let firstViewControllerIndex = orderedViewControllers.firstIndex(of: firstViewController) else {
                return 0
        }
        
        return firstViewControllerIndex
    }
    
}



