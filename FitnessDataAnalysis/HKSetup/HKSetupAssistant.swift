//
//  HKSetupAssistant.swift
//  FitnessDataAnalysis
//
//  Created by 十口V🌼 on 2023/2/24.
//

import HealthKit

class HKSetupAssistant {
    
    /// 可能的错误类型
    private enum HKSetupError: Error {
        case notAvailableOnDevice
        case dataTypeNotAvailable
    }
    

    
    /// class func 可直接被其他类访问 而不需要创建实例。
    /// 如：HKSetupAssistant.authorizeHealthKit()
    class func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Swift.Void) {
        // 1. check to see if HK is avaliable on this device
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, HKSetupError.notAvailableOnDevice)
            return
        }
        
        
        let healthStore = HKHealthStore()
        
        // 2. prepare the necessary data types
        guard
          // 出生日期
          let dateOfBirth = HKObjectType.characteristicType(forIdentifier: .dateOfBirth),
          // 身高
          let height = HKObjectType.quantityType(forIdentifier: .height),
          // 体重
          let weight = HKObjectType.quantityType(forIdentifier: .bodyMass),
          // 活动能量
          let activeEnergy = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned),
          // 心率
          let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate),
          // 步行+跑步距离
          let distance = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning),
          // 体脂率
          let bodyFat = HKObjectType.quantityType(forIdentifier: .bodyFatPercentage)
          else {
            completion(false, HKSetupError.dataTypeNotAvailable)
            return
        }
        
        // 3. prepare a list of types we want HK to read and write
        let healthKitTypesToWrite: Set<HKSampleType> = []
        
        let healthKitTypesToRead: Set<HKObjectType> = [dateOfBirth,
                                                       height,
                                                       weight,
                                                       activeEnergy,
                                                       heartRate,
                                                       distance,
                                                       bodyFat,
                                                       // 体能训练
                                                       HKObjectType.workoutType()
                                                       ]
        // 4. request authorization
        healthStore.requestAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead) {
            (success, error) in
            completion(success, error)
        }
        
        
        
        
    }
    
    
}

