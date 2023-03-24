//
//  Date+Extension.swift
//  FitnessWithML
//
//  Created by Infinity vv123 on 2022/10/31.
//

import Foundation
extension Date {
   func getFormattedDate(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
}
