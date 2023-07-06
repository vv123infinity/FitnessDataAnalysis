//
//  GetBodyData.swift
//  FitnessDataAnalysis
//
//  Created by 十口V🌼 on 2023/3/24.
//

import Foundation
import HealthKit


class GetBodyData{

    class func getMostRecentSample(for sampleType: HKSampleType, completion: @escaping (HKQuantitySample?, Error?) -> Swift.Void) {
        // 1. Use HKQuery to load the most recent samples - 和 Core Data 中的 FetchRequest 类似
        let mostRecentPredicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let limit = 1
        
        let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: mostRecentPredicate, limit: limit, sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            // 完成处理程度段
            // 2. always dispatch to the main thread when complete -> UI can be updated
            
            DispatchQueue.main.async {
                guard let samples = samples,
                      let mostRecentSample = samples.first as? HKQuantitySample else {
                    completion(nil, error)
                    return
                }
                completion(mostRecentSample, nil)
            }
            
        }
        
        
        HKHealthStore().execute(sampleQuery)
            
    }

    class func getAllSample(for sampleType: HKSampleType, completion: @escaping ([HKQuantitySample?], Error?) -> Swift.Void) {
        // 1. Use HKQuery to load the most recent samples - 和 Core Data 中的 FetchRequest 类似
        let mostRecentPredicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let limit = 1000
        
        let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: mostRecentPredicate, limit: limit, sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            // 完成处理程度段
            // 2. always dispatch to the main thread when complete -> UI can be updated
            
            DispatchQueue.main.async {
                guard let samples = samples,
                      let mostRecentSample = samples as? [HKQuantitySample] else {
                    completion([], error)
                    return
                }
                completion(mostRecentSample, nil)
            }
            
        }
        
        
        HKHealthStore().execute(sampleQuery)
            
    }

}
