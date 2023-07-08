//
//  DatePickerVC.swift
//  FitnessDataAnalysis
//
//  Created by Infinity vv123 on 2023/7/8.
//

import UIKit

class DatePickerVC: UIViewController {

    @IBOutlet var datePickerArray: [UIDatePicker]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        for datePicker in self.datePickerArray {
            datePicker.tintColor = ColorUtil.getBarBtnColor()
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
