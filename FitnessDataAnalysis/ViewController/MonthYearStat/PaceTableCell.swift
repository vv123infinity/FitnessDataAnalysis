//
//  PaceTableCell.swift
//  FitnessDataAnalysis
//
//  Created by Infinity vv123 on 2023/6/1.
//

import UIKit
import AAInfographics
class PaceTableCell: UITableViewCell {

    @IBOutlet weak var chartContentView: UIView!
    /// 绘制具有明显上升和下降趋势的图表
    @IBOutlet weak var chartView: UIView!
    /// logo-显示上升/下降的logo
    @IBOutlet weak var imgView: UIImageView!
    /// 时间范围
    @IBOutlet weak var dateRange: UILabel!
    /// 滑动图表时显示的日期
    @IBOutlet weak var dynamicDate: UILabel!
    /// 滑动图表时显示的数据
    @IBOutlet weak var dynamicData: UILabel!
    /// 提示语句
    @IBOutlet weak var hintTextLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
