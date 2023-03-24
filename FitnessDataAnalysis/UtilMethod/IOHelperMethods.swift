//
//  IOHelperMethods.swift
//  FitnessDataAnalysis
//
//  Created by 十口V🌼 on 2023/3/3.
//

import Foundation


class IOHelperMethods {
    /// 将数据写入CSV文档
    /// 数据格式示例
    /// let data = [["name", "age", "email"],["John", "24", "john@example.com"],["Alice", "32", "alice@example.com"],["Bob", "41", "bob@example.com"]]
    class func writeToCSV(_ date: [String], _ distance: [Double]) {
        var csvString = "date, distance\n"
        for i in 0..<date.count {
            let dataString = date[i] + "," + "\(distance[i])" + "\n"
            csvString = csvString.appending(dataString)
        }

        let fileManager = FileManager.default
        do {
            let path = try fileManager.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: false)
            print("PATH: \(path)")
            let fileURL = path.appendingPathComponent("CSVData.csv")
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print("error creating file")
        }
        
    }
}
