//
//  myCollectionViewCell.swift
//  FitnessDataAnalysis
//
//  Created by 十口V🌼 on 2023/5/9.
//

import UIKit

class myCollectionViewCell: UICollectionViewCell {
    /// 方格logo
    @IBOutlet weak var cellLogo: UIImageView!
    /// 方格标题
    @IBOutlet weak var cellTitle: UILabel!
    /// 实际数据
    @IBOutlet weak var cellData: UILabel!
    /// 辅助的数据
    @IBOutlet var cellSupplementary: [UILabel]!
    /// 背景
    @IBOutlet weak var bkView: UIView!
    
}
