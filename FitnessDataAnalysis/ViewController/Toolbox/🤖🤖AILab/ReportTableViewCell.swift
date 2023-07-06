//
//  ReportTableViewCell.swift
//  FitnessWithML
//
//  Created by Infinity vv123 on 2022/10/28.
//

import UIKit

class ReportTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var poseMistakesSeg: UISegmentedControl!
    @IBOutlet weak var detailButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var textViewInfo: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
