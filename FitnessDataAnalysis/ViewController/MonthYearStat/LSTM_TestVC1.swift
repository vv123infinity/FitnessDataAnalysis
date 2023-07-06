//
//  LSTM_TestVC1.swift
//  FitnessDataAnalysis
//
//  Created by 十口V🌼 on 2023/4/2.
//


import UIKit
import CoreML
import Vision

class LSTM_TestVC1: UIViewController {
    
//    private var lstm_model: MLModel!
//    var person: MLModel!
//    var temp: MLModel!
//
//    private var my_lstm_engine: LSTM!
//
//
//
//    var exampleDataset: UserInputSet!
    
    

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do{
//            self.person = try! personalized_LSTM(configuration: .init()).model
//            self.temp = try! personalized_tmp_LSTM(configuration: .init()).model
//            self.lstm_model = try! LSTM_test(configuration: .init()).model
//            self.lstm_model.
//            self.my_lstm_engine = LSTM(lstm_model: self.lstm_model)
//            self.test_LSTM()
        }
        
        
//        LSTM_Model_Updater.resetDrawingClassifier()
//        self.test_LSTM_04_03_mor()
        
        
    }
    
    
//    func test_LSTM_04_03_mor() {
//        let testInputArray: [Float32] = [5, 5, 5, 6, 6, 5, 7]
//        let testOutputArray: [Double] = [6]
//
//        let array1 = try? MLMultiArray(shape: [1, 7, 1], dataType: .float32)
//        let array2 = try? MLMultiArray(shape: [1, 1], dataType: .double)
//
//        let inputMLarray = LSTM_Util.assignInput(array1!, testInputArray)
//        let outputMLArray = LSTM_Util.assignOutputInDouble(array2!, testOutputArray)
//
//
//        var sample1 = UserInputSet(for: outputMLArray!)
//
//        sample1.addUserInput(inputMLarray!)
//        sample1.addUserInput(inputMLarray!)
//        sample1.addUserInput(inputMLarray!)
//        sample1.addUserInput(inputMLarray!)
//        sample1.addUserInput(inputMLarray!)
//        sample1.addUserInput(inputMLarray!)
//
//        print("样本")
//        print(sample1.outputVal)
//        print(sample1.featureBatchProvider.count)
//
//        let trainDataSample1 = sample1.featureBatchProvider
//
//        let inV = MLFeatureValue(multiArray: inputMLarray!)
//        print(LSTM_Model_Updater.predictLabelFor(inV))
//
//        DispatchQueue.global(qos: .userInitiated).async {
//            LSTM_Model_Updater.updateWith(trainingData: trainDataSample1) {
//                print("OK??")
//            }
//        }
//
//
//    }


    
//    func test_LSTM() {
//        print("hello, LSTM!🤖")
//        
//        let runningDistanceArrayInDouble: [Float32] = [7, 5, 5, 6, 7, 6, 5]
//
//        let res = self.my_lstm_engine.predict_val(runningDistanceArrayInDouble)
//        
//        print(res)
//        
//        
//        
//    }
//        
//    func addDrawing(_ drawing: MLMultiArray) {
//        exampleDataset.addUserInput(drawing)
//    }
        
}


