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
        self.initDatePicker()
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
//        if self.datePickerArray[0].date < self.datePickerArray[1].date {
//            UserDefaults.standard.set(datePickerArray[0].date, forKey: "lastQueryDateStart")
//            UserDefaults.standard.set(datePickerArray[1].date, forKey: "lastQueryDateEnd")
//            
//        }
        
    }
    
    func initDatePicker() {
        
        for datePicker in self.datePickerArray {
            datePicker.tintColor = ColorUtil.getBarBtnColor()
        }
        
        let dateFormatter4 = DateFormatter()
        let res = AssistantMethods.getThisMonthStartEndDate(Date.init(), Date.init(), false)
        
        self.datePickerArray[0].date = res.startDate
        self.datePickerArray[1].date = res.endDate
    }
    

}
