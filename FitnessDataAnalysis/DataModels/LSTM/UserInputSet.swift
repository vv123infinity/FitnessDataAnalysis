//
//  UserInputSet.swift
//  FitnessDataAnalysis
//
//  Created by 十口V🌼 on 2023/4/3.
//

import CoreML
struct UserInputSet {
    
    /// The desired number of drawings to update the model
    private let requiredDataCount = 1
    
    
    /// Collection of the training data
    private var trainingData = [MLMultiArray]()
    
    /// A Boolean that indicates whether the instance has all the required data
    var isReadyForTraining: Bool { trainingData.count == requiredDataCount }
    
    
    let outputVal: MLMultiArray
    
    
    init(for outputVal: MLMultiArray) {
        self.outputVal = outputVal
    }
    
    
    /// Creates a batch provider of training data given the contents of `trainingDrawings`.
    /// - Tag: DrawingBatchProvider
     var featureBatchProvider: MLBatchProvider {
         var featureProviders = [MLFeatureProvider]()

         let inputName = "lstm_input"
         let outputName = "Identity_true"
//         let outputName = "Identity"
         for data in trainingData {
             let inputValue = MLFeatureValue(multiArray: data)
             let outputValue = MLFeatureValue(multiArray: outputVal)
             
             let dataPointFeatures: [String: MLFeatureValue] = [inputName: inputValue,
                                                                outputName: outputValue]
             
             if let provider = try? MLDictionaryFeatureProvider(dictionary: dataPointFeatures) {
                 featureProviders.append(provider)
             }
         }
         
        return MLArrayBatchProvider(array: featureProviders)
    }
    
    /// Adds a array to the private array, but only if the type requires more.
    mutating func addUserInput(_ drawing: MLMultiArray) {
        if trainingData.count < requiredDataCount {
            trainingData.append(drawing)
        }
    }
}
