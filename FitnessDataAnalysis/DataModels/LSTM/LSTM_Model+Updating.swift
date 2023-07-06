//
//  LSTM_Model+Updating.swift
//  FitnessDataAnalysis
//
//  Created by 十口V🌼 on 2023/4/3.
//

import CoreML

extension LSTM_test {
    ///从给定的模型URL和训练数据中创建一个更新模型。
    ///
    /// - 参数：
    /// - URL： 更新任务要更新的模型的位置。
    /// - trainingData： 更新任务用于更新模型的训练数据。
    /// - completionHandler： 更新任务在完成更新模型时调用的一个闭包。
    /// - Tag: CreateUpdateTask
    static func updateModel(at url: URL,
                            with trainingData: MLBatchProvider,
                            completionHandler: @escaping (MLUpdateContext) -> Void) {
        
        // Create an Update Task.
        guard let updateTask = try? MLUpdateTask(forModelAt: url,
                                           trainingData: trainingData,
                                           configuration: nil,
                                           completionHandler: completionHandler)
            else {
                print("Could't create an MLUpdateTask.")
                return
        }
        
        updateTask.resume()
    }
}
