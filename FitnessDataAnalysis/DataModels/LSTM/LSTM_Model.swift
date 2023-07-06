//
//  LSTM_Model.swift
//  FitnessDataAnalysis
//
//  Created by 十口V🌼 on 2023/4/2.
//

import Foundation
import CoreML

struct CurLSTM_io_name {
    var model_name = "lstm_dist"
//    var model_name = "personalized_LSTM"
    var inputArrayName = "lstm_input"
    var outputName = "Identity"
}

//class LSTM {
//    var lstm_model: MLModel!
//
//    init(lstm_model: MLModel!) {
//        self.lstm_model = lstm_model
//    }
//
//
//    func predict_val(_ model_input_in_double: [Float32]) -> Float32 {
//        let array = try? MLMultiArray(shape: [1, 7, 1], dataType: .float32)
//
//        let inputInMultiArray = LSTM_Util.assignInput(array!, model_input_in_double)
//        let input = lstm_dist(lstm_input: inputInMultiArray!)
//
//        do {
//
//            let pred = try! lstm_model.prediction(from: input)
//
//            let lstmOutput = LSTM_testOutput(features: pred)
//            let res = lstmOutput.Identity[[0, 0]]
//            return res as! Float32
//        }
//    }
//
//
//
//}

    /*

/// class for model loading and predcition
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
class LSTM_model {
    let model: MLModel
    
    /// URL of model assuming it was installed in the same bundle as this class
    class var urlOfModelInThisBundle : URL {
        let bundle = Bundle(for: self)
//        print("模型位置")
//        print("\(bundle.url(forResource: CurLSTM_io_name().model_name, withExtension:"mlmodelc")!)")
        return bundle.url(forResource: CurLSTM_io_name().model_name, withExtension:"mlmodelc")!
    }
    /**
        用一个现有的MLModel对象构造LSTM_model实例。

        通常情况下，应用程序不使用这个初始化器，除非它做一个 LSTM_model 的子类。
        这样的应用程序可能希望使用`MLModel(contentsOfURL:configuration:)`和`UpdatableDrawingClassifier.urlOfModelInThisBundle`来创建一个MLModel对象以传入。

        - 参数：
          - 模型： MLModel对象
    */
    init(model: MLModel) {
        self.model = model
    }
    
    @available(*, deprecated, message: "Use init(configuration:) instead and handle errors appropriately.")
    convenience init() {
        try! self.init(contentsOf: type(of:self).urlOfModelInThisBundle)
    }

    
    
    /**
        Construct a model with configuration

        - parameters:
           - configuration: the desired model configuration

        - throws: an NSError object that describes the problem
    */
    convenience init(configuration: MLModelConfiguration) throws {
        try self.init(contentsOf: type(of:self).urlOfModelInThisBundle, configuration: configuration)
    }

    /**
        Construct UpdatableDrawingClassifier instance with explicit path to mlmodelc file
        - parameters:
           - modelURL: the file url of the model

        - throws: an NSError object that describes the problem
    */
    convenience init(contentsOf modelURL: URL) throws {
        try self.init(model: MLModel(contentsOf: modelURL))
    }

    /**
        Construct a model with URL of the .mlmodelc directory and configuration

        - parameters:
           - modelURL: the file url of the model
           - configuration: the desired model configuration

        - throws: an NSError object that describes the problem
    */
    convenience init(contentsOf modelURL: URL, configuration: MLModelConfiguration) throws {
        try self.init(model: MLModel(contentsOf: modelURL, configuration: configuration))
    }

    /**
        Construct UpdatableDrawingClassifier instance asynchronously with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - configuration: the desired model configuration
          - handler: the completion handler to be called when the model loading completes successfully or unsuccessfully
    */
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    class func load(configuration: MLModelConfiguration = MLModelConfiguration(), completionHandler handler: @escaping (Swift.Result<LSTM_model, Error>) -> Void) {
        return self.load(contentsOf: self.urlOfModelInThisBundle, configuration: configuration, completionHandler: handler)
    }

    /**
        Construct UpdatableDrawingClassifier instance asynchronously with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - configuration: the desired model configuration
    */
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    class func load(configuration: MLModelConfiguration = MLModelConfiguration()) async throws -> LSTM_model {
        return try await self.load(contentsOf: self.urlOfModelInThisBundle, configuration: configuration)
    }

    /**
        Construct UpdatableDrawingClassifier instance asynchronously with URL of the .mlmodelc directory with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - modelURL: the URL to the model
          - configuration: the desired model configuration
          - handler: the completion handler to be called when the model loading completes successfully or unsuccessfully
    */
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    class func load(contentsOf modelURL: URL, configuration: MLModelConfiguration = MLModelConfiguration(), completionHandler handler: @escaping (Swift.Result<LSTM_model, Error>) -> Void) {
        MLModel.load(contentsOf: modelURL, configuration: configuration) { result in
            switch result {
            case .failure(let error):
                handler(.failure(error))
            case .success(let model):
                handler(.success(LSTM_model(model: model)))
            }
        }
    }

    /**
        Construct UpdatableDrawingClassifier instance asynchronously with URL of the .mlmodelc directory with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - modelURL: the URL to the model
          - configuration: the desired model configuration
    */
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    class func load(contentsOf modelURL: URL, configuration: MLModelConfiguration = MLModelConfiguration()) async throws -> LSTM_model{
        let model = try await MLModel.load(contentsOf: modelURL, configuration: configuration)
        return LSTM_model(model: model)
    }

    /**
        Make a prediction using the structured interface

        - parameters:
           - input: the input to the prediction as UpdatableDrawingClassifierInput

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as UpdatableDrawingClassifierOutput
    */
    func prediction(input: LSTMInput) throws -> LSTMOutput {
        return try self.prediction(input: input, options: MLPredictionOptions())
    }

    /**
        Make a prediction using the structured interface

        - parameters:
           - input: the input to the prediction as UpdatableDrawingClassifierInput
           - options: prediction options

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as UpdatableDrawingClassifierOutput
    */
    func prediction(input: LSTMInput, options: MLPredictionOptions) throws -> LSTMOutput {
        let outFeatures = try model.prediction(from: input, options:options)
        return LSTMOutput(features: outFeatures)
    }

    /**
        Make a prediction using the convenience interface

        - parameters:
            - drawing: Input sketch image with black background and white strokes as grayscale (kCVPixelFormatType_OneComponent8) image buffer, 28 pixels wide by 28 pixels high

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as UpdatableDrawingClassifierOutput
    */
    func prediction(inputArray: MLMultiArray) throws -> LSTMOutput {
        let input_ = LSTMInput(inputArr: inputArray)
        return try self.prediction(input: input_)
    }

    /**
        Make a batch prediction using the structured interface

        - parameters:
           - inputs: the inputs to the prediction as [UpdatableDrawingClassifierInput]
           - options: prediction options

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as [UpdatableDrawingClassifierOutput]
    */
    func predictions(inputs: [LSTMInput], options: MLPredictionOptions = MLPredictionOptions()) throws -> [LSTMOutput] {
        let batchIn = MLArrayBatchProvider(array: inputs)
        let batchOut = try model.predictions(from: batchIn, options: options)
        var results : [LSTMOutput] = []
        results.reserveCapacity(inputs.count)
        for i in 0..<batchOut.count {
            let outProvider = batchOut.features(at: i)
            let result =  LSTMOutput(features: outProvider)
            results.append(result)
        }
        return results
    }
    
                                        
}


/// Model Prediction Input Type
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
class LSTMInput: MLFeatureProvider {
    
    private static let inputFeatureName = CurLSTM_io_name().inputArrayName

    var inputArr: MLMultiArray



    var featureNames: Set<String> {
        return [LSTMInput.inputFeatureName]
    }
    
    
    init(inputArr: MLMultiArray) {
        self.inputArr = inputArr
    }
    
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        guard featureName == LSTMInput.inputFeatureName else {
            return nil
        }

        return MLFeatureValue(multiArray: self.inputArr)
    }
    
    
}

/// Model Prediction Output Type
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
class LSTMOutput: MLFeatureProvider {
    
    /// Source provided by CoreML
    private let provider : MLFeatureProvider
    
    /// Predicted Identity. Defaults to 'unknown' as string value
    var identity: MLMultiArray {
        return self.provider.featureValue(for: CurLSTM_io_name().outputName)!.multiArrayValue!
        
    }

    var featureNames: Set<String> {
        return self.provider.featureNames
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        return self.provider.featureValue(for: featureName)
    }
    
    
    init(identity: MLMultiArray) {
        self.provider = MLFeatureValue(multiArray: identity) as! any MLFeatureProvider
    }
    
    init(features: MLFeatureProvider) {
        self.provider = features
    }
                                                                      
                                                                      
}

/// Model Update Input Type
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
class UpdateLSTMTrainingInput: MLFeatureProvider {
    
    
    var historyDistanceArray: MLMultiArray
    
    var futureDistanceArray: MLMultiArray
    
    var featureNames: Set<String> {
        get {
            return [CurLSTM_io_name().inputArrayName, CurLSTM_io_name().outputName]
        }
        
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        if (featureName == CurLSTM_io_name().inputArrayName) {
            return MLFeatureValue(multiArray: historyDistanceArray)
        }
        if (featureName == CurLSTM_io_name().outputName) {
            return MLFeatureValue(multiArray: futureDistanceArray)
        }
        return nil
    }
    
    
    /// 给输入和输出赋值
    init(historyDistanceArray: MLMultiArray, futureDistanceArray: MLMultiArray) {
        self.historyDistanceArray = historyDistanceArray
        self.futureDistanceArray = futureDistanceArray
    }
    
    
    
    
}



*/

class LSTM_Util {
    class func assignInput(_ inputMLArray: MLMultiArray, _ inputInDouble: [Float32]) -> MLMultiArray! {

        inputMLArray[[0, 0, 0]] = inputInDouble[0] as NSNumber
        inputMLArray[[0, 1, 0]] = inputInDouble[1] as NSNumber
        inputMLArray[[0, 2, 0]] = inputInDouble[2] as NSNumber
        inputMLArray[[0, 3, 0]] = inputInDouble[3] as NSNumber
        inputMLArray[[0, 4, 0]] = inputInDouble[4] as NSNumber
        inputMLArray[[0, 5, 0]] = inputInDouble[5] as NSNumber
        inputMLArray[[0, 6, 0]] = inputInDouble[6] as NSNumber
        return inputMLArray
    }
    
    class func assignOutput(_ inputMLArray: MLMultiArray, _ inputInDouble: [Float32]) -> MLMultiArray! {
        inputMLArray[[0, 0]] = inputInDouble[0] as NSNumber
        return inputMLArray
    }

    class func assignOutputInDouble(_ inputMLArray: MLMultiArray, _ inputInDouble: [Double]) -> MLMultiArray! {
        inputMLArray[[0, 0]] = inputInDouble[0] as NSNumber
        return inputMLArray
    }

}

