//
//  DataPlotVC.swift
//  FitnessDataAnalysis
//
//  Created by Infinity vv123 on 2023/7/12.
//

import UIKit

class DataPlotVC: UIViewController {

    
    /// 指标名称
    @IBOutlet weak var title1: UILabel!
    /// 指标的数据
    @IBOutlet weak var mainData: UILabel!
    /// 数据的单位
    @IBOutlet weak var unitLabel: UILabel!
    /// 输入的日期范围
    @IBOutlet weak var inputDateRange: UILabel!
    
    @IBOutlet weak var chart1View: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
