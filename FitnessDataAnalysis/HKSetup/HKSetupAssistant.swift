//
//  HKSetupAssistant.swift
//  FitnessDataAnalysis
//
//  Created by 十口V🌼 on 2023/2/24.
//

import HealthKit

class HKSetupAssistant {
    
    private enum HKSetupError: Error {
        case notAvailableOnDevice
        case dataTypeNotAvailable
    }
    
    ///
    /// class func 可直接被其他类访问 而不需要创建实例。
    /// 如：HKSetupAssistant.authorizeHealthKit()
    class func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Swift.Void) {
       
            // 1. check to see if HK is avaliable on this device
            guard HKHealthStore.isHealthDataAvailable() else {
                completion(false, HKSetupError.notAvailableOnDevice)
                return
            }
            
            // 2. prepare the necessary data types
            guard
              let dateOfBirth = HKObjectType.characteristicType(forIdentifier: .dateOfBirth),
              let height = HKObjectType.quantityType(forIdentifier: .height),
              let weight = HKObjectType.quantityType(forIdentifier: .bodyMass),
              let activeEnergy = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned),
              let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate),
              let distance = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)
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
                                                           HKObjectType.workoutType()
                                                           ]
            
        DispatchQueue.main.async {
            // 4. request authorization
            HKHealthStore().requestAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead) {
                (success, error) in
                completion(success, error)
            }
            
        }
            
        }
        
    
    
    
    class func authorizeHealthKitWK(completion: @escaping (Bool, Error?) -> Swift.Void) {
        // 1. check to see if HK is avaliable on this device
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, HKSetupError.notAvailableOnDevice)
            return
        }
        
        // 3. prepare a list of types we want HK to read and write
        let healthKitTypesToWrite: Set<HKSampleType> = []
        
        let healthKitTypesToRead: Set<HKObjectType> = [
                                                       HKObjectType.workoutType()
                                                       ]
        
        
        // 4. request authorization
        HKHealthStore().requestAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead) {
            (success, error) in
            completion(success, error)
        }
        
    }
    
    
}

