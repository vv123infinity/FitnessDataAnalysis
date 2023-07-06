//
//  LSTM_Updater.swift
//  FitnessDataAnalysis
//
//  Created by 十口V🌼 on 2023/4/3.
//


import CoreML


/// Class that handles predictions and updating of LSTM model.
struct LSTM_Model_Updater {
    
    // MARK: - Private Type Properties
    /// The updated model
    /// 根据用户的数据
    private static var updatedLSTMModel: LSTM_test!
    /// 默认的LSTM模型 —— 来自随机生成的序列
    private static var defaultLSTMModel: LSTM_test {
        do {
            return try LSTM_test(configuration: .init())
        } catch {
            fatalError("Couldn't load LSTM due to: \(error.localizedDescription)")
        }
    }
    
    /// 正在使用的LSTM的模型
    private static var liveModel: LSTM_test {
        updatedLSTMModel ?? defaultLSTMModel
    }
    
    /// The location of the app's Application Support directory for the user.
    private static let appDirectory = FileManager.default.urls(for: .applicationSupportDirectory,
                                                               in: .userDomainMask).first!
    
    
    /// The default LSTM model's file URL.
    private static let defaultModelURL = LSTM_test.urlOfModelInThisBundle
    /// 更新后的LSTM模型的位置（持久化）
    private static var updatedModelURL = appDirectory.appendingPathComponent("personalized_LSTM.mlmodelc")

    /// 更新后的LSTM模型的位置（暂时）
    private static var tempUpdatedModelURL = appDirectory.appendingPathComponent("personalized_tmp_LSTM" + "\(Date())" + ".mlmodelc")
    
//    / 更新后的LSTM模型的位置（持久化）
//    private static var updatedModelURL = appDirectory.appendingPathComponent("LSTM_test.mlmodelc")
//    /// 更新后的LSTM模型的位置（暂时）
//    private static var tempUpdatedModelURL = appDirectory.appendingPathComponent("personalized_tmp_LSTM.mlmodelc")
    
    
    
    /// 在第一次预测时触发代码，（可能）及时加载先前保存的更新模型。
    private static var hasMadeFirstPrediction = false
    
    /// The Model Updater type doesn't use instances of itself.
    private init() { }
    
    
    // MARK: - Public Properties

    // MARK: - Public Type Methods
    static func predictLabelFor(_ value: MLFeatureValue) -> MLMultiArray {
        if !hasMadeFirstPrediction {
            hasMadeFirstPrediction = true
            
            // Load the updated model the app saved on an earlier run, if available.
            loadUpdatedModel()
        }
        
        return liveModel.predictLabelFor(value)
    }
    
    
    /// 更新模型以识别与 "inputBatchProvider "中的给定序列
    /// - 参数：
    /// - trainingData： 一组时间序列数据，每一组都有一个预测值
    /// - completionHandler： 由视图控制器提供的完成处理程序。
    /// - Tag： CreateUpdateTask
    static func updateWith(trainingData: MLBatchProvider,
                           completionHandler: @escaping () -> Void) {
        
        /// The URL of the currently active Drawing Classifier.
        let usingUpdatedModel = updatedLSTMModel != nil
        let currentModelURL = usingUpdatedModel ? updatedModelURL : defaultModelURL
        print(currentModelURL)
        print(trainingData)
        /// The closure an MLUpdateTask calls when it finishes updating the model.
        func updateModelCompletionHandler(updateContext: MLUpdateContext) {
            
            print("更新成功？开始保存模型")
            
            // Save the updated model to the file system.
            saveUpdatedModel(updateContext)
            
            // Begin using the saved updated model.
            loadUpdatedModel()
            
            // Inform the calling View Controller when the update is complete
            DispatchQueue.main.async { completionHandler() }
        }
        
        LSTM_test.updateModel(at: currentModelURL,
                                               with: trainingData,
                                               completionHandler: updateModelCompletionHandler)
        
    }
    
    /// Deletes the updated model and reverts back to original Drawing Classifier.
    static func resetDrawingClassifier() {
        // Clear the updated Drawing Classifier.
        updatedLSTMModel = nil
        
        // Remove the updated model from its designated path.
        if FileManager.default.fileExists(atPath: updatedModelURL.path) {
            try? FileManager.default.removeItem(at: updatedModelURL)
        }
    }
    
    // MARK: - Private Type Helper Methods
    /// Saves the model in the given Update Context provided by an MLUpdateTask.
    /// - Parameter updateContext: The context from the Update Task that contains the updated model.
    /// - Tag: SaveUpdatedModel
    private static func saveUpdatedModel(_ updateContext: MLUpdateContext) {
        let updatedModel = updateContext.model
        let fileManager = FileManager.default
        do {
            // Create a directory for the updated model.
            try fileManager.createDirectory(at: tempUpdatedModelURL,
                                            withIntermediateDirectories: false,
                                            attributes: nil)
            
            // Save the updated model to temporary filename.

            try updatedModel.write(to: tempUpdatedModelURL)
                
               
            
            // Replace any previously updated model with this one.
            _ = try fileManager.replaceItemAt(updatedModelURL,
                                              withItemAt: tempUpdatedModelURL)
            
            print("Updated model saved to:\n\t\(updatedModelURL)")
        } catch let error {
            print("Could not save updated model to the file system: \(error)")
            return
        }
    }
    
    
    /// Loads the updated Drawing Classifier, if available.
    /// - Tag: LoadUpdatedModel
    private static func loadUpdatedModel() {
        guard FileManager.default.fileExists(atPath: updatedModelURL.path) else {
            print("不存在的！")
            // The updated model is not present at its designated path.
            return
        }
        print("更新模型存在！")
        // Create an instance of the updated model.
        guard let model = try? LSTM_test(contentsOf: updatedModelURL) else {
            return
        }
        
        // Use this updated model to make predictions in the future.
        updatedLSTMModel = model
    }
    
    
}
