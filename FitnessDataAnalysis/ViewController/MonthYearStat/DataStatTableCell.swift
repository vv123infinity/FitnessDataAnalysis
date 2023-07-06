//
//  DataStatTableCell.swift
//  FitnessDataAnalysis
//
//  Created by Infinity vv123 on 2023/5/8.
//

import UIKit

class DataStatTableCell: UITableViewCell {
    
    /// 表单元的logo
    @IBOutlet weak var cellLogo: UIImageView!
    /// 标题
    @IBOutlet weak var cellTitle: UILabel!
    /// 显眼的数据
    @IBOutlet weak var cellData: UILabel!
    /// 部分指标的日期
    @IBOutlet weak var detailDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
