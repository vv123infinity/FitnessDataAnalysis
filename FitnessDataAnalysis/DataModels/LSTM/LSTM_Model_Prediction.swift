//
//  LSTM_Model_Prediction.swift
//  FitnessDataAnalysis
//
//  Created by 十口V🌼 on 2023/4/3.
//

import CoreML
extension LSTM_test{
    
    static let unknownArray = try? MLMultiArray(shape: [1, 1], dataType: .double)
    
    /// Predicts a label for the given drawing.
    /// - Parameter value: A user's drawing represented as a feature value.
    /// - Returns: The predicted string label, if known; otherwise `LSTM_model.unknownArray`.
    func predictLabelFor(_ value: MLFeatureValue) -> MLMultiArray {
        // Get the array  from the feature value as a `CVPixelBuffer`.
        guard let pixelBuffer = value.multiArrayValue else {
            fatalError("Could not extract array")
        }
        
        // Use the Drawing Classifier to predict a label for the drawing.
        guard let prediction = try? prediction(lstm_input: pixelBuffer).Identity else {
            return LSTM_test.unknownArray!
        }
        
        // A label of "unknown" means the model has no prediction for the image.
        // This typically means the Drawing Classifier hasn't been updated with any image/label pairs.
        guard prediction != LSTM_test.unknownArray else {
            return LSTM_test.unknownArray!
        }
        
        return prediction
    }
}

