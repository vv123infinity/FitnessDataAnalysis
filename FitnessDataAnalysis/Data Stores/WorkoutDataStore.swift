//
//  WorkoutDataStore.swift
//  FitnessDataAnalysis
//
//  Created by 十口V🌼 on 2023/2/24.
//

import HealthKit




class WorkoutDataStore {
    
    
    class func loadRunningDistance(completion: @escaping([HKQuantitySample]?, Error?) -> Void) {
        
        
    }
    
    /// 查询最早的workout记录
    /// - Returns: workout数组
    class func loadEarliestWorkout(completion: @escaping([HKWorkout]?, Error?) -> Void) {
        // 1. get all workouts with the "Other" / "Running" activity type
        let workoutPredicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date.init())
        
        // 2. get all workouts that only came from this app?????🥲
        let sourcePredicate = HKQuery.predicateForWorkouts(with: .running)
        
        
        //3. Combine the predicates into a single predicate.
        let compound = NSCompoundPredicate(andPredicateWithSubpredicates:
            [workoutPredicate, sourcePredicate])
          
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate,
                                                ascending: true)
        
        
        // 4. define the limitation
        let limitation = 1
        
        
        let query = HKSampleQuery(
          sampleType: .workoutType(),
          predicate: compound,
          limit: limitation,
          sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            DispatchQueue.main.async {
              guard
                let samples = samples as? [HKWorkout],
                error == nil
                else {
                  completion(nil, error)
                  return
              }
              completion(samples, nil)
            }
          }
        HKHealthStore().execute(query)
    }
    
    
    /// 返回所有的体能训练记录 - 降序 - 时间从近到远
    class func loadWorkouts(completion: @escaping([HKWorkout]?, Error?) -> Void) {
        // 1. get all workouts with the "Other" / "Running" activity type
        let workoutPredicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date.init())
        
        // 2. get all workouts that only came from this app?????🥲
        let sourcePredicate = HKQuery.predicateForWorkouts(with: .running)
        
        
        //3. Combine the predicates into a single predicate.
        let compound = NSCompoundPredicate(andPredicateWithSubpredicates:
            [workoutPredicate, sourcePredicate])
          
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate,
                                                ascending: false)
        
        
        // 4. define the limitation
        let limitation = HKObjectQueryNoLimit
        
        let query = HKSampleQuery(
          sampleType: .workoutType(),
          predicate: compound,
          limit: limitation,
          sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            DispatchQueue.main.async {
              guard
                let samples = samples as? [HKWorkout],
                error == nil
                else {
                  completion(nil, error)
                  return
              }
              completion(samples, nil)
            }
          }
        HKHealthStore().execute(query)
    }
    
    /// 返回所有的体能训练记录 - 升序 - 时间从远到近
    class func loadWorkoutsPastToNow(completion: @escaping([HKWorkout]?, Error?) -> Void) {
        // 1. get all workouts with the "Other" / "Running" activity type
        let workoutPredicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date.init())
        
        // 2. get all workouts that only came from this app?????🥲
        let sourcePredicate = HKQuery.predicateForWorkouts(with: .running)
        
        
        //3. Combine the predicates into a single predicate.
        let compound = NSCompoundPredicate(andPredicateWithSubpredicates:
            [workoutPredicate, sourcePredicate])
          
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate,
                                                ascending: true)
        
        
        // 4. define the limitation
        let limitation = HKObjectQueryNoLimit
        
        let query = HKSampleQuery(
          sampleType: .workoutType(),
          predicate: compound,
          limit: limitation,
          sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            DispatchQueue.main.async {
              guard
                let samples = samples as? [HKWorkout],
                error == nil
                else {
                  completion(nil, error)
                  return
              }
              completion(samples, nil)
            }
          }
        HKHealthStore().execute(query)
    }
    
    
    
    // MARK: 本月workouts
    /// 返回本月的体能训练记录
    class func loadThisMonthWorkouts(completion: @escaping([HKWorkout]?, Error?) -> Void) {
        // 1. 获取本月的起始日期
        let calendar = Calendar.current
        let today = Date()
        let components = calendar.dateComponents([.year, .month], from: today)
        let startOfMonth = calendar.date(from: components)
        
        let workoutPredicate = HKQuery.predicateForSamples(withStart: startOfMonth!, end: Date.init())
        
        // 2. 获取所有跑步类型的记录
        let sourcePredicate = HKQuery.predicateForWorkouts(with: .running)
        
        //3. Combine the predicates into a single predicate.
        let compound = NSCompoundPredicate(andPredicateWithSubpredicates:
            [workoutPredicate, sourcePredicate])
          
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate,
                                                ascending: true)
        
        
        // 4. define the limitation
        let limitation = HKObjectQueryNoLimit
        
        let query = HKSampleQuery(
          sampleType: .workoutType(),
          predicate: compound,
          limit: limitation,
          sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            DispatchQueue.main.async {
              guard
                let samples = samples as? [HKWorkout],
                error == nil
                else {
                  completion(nil, error)
                  return
              }
              completion(samples, nil)
            }
          }
        HKHealthStore().execute(query)
    }
    
    
    
    // MARK: 上月workouts
    /// 默认上个月的workouts，也可用户自定义
    class func loadLastMonthWorkouts(_ fromDate: Date, _ toDate: Date, _ userRangeFlag: Bool, completion: @escaping([HKWorkout]?, Error?) -> Void) {
        // 1. 获取上月的起始日期和结束日期
        let res = AssistantMethods.getLastMonthStartEndDate(fromDate, toDate, userRangeFlag)
        
        let workoutPredicate = HKQuery.predicateForSamples(withStart: res.startDate, end: res.endDate)
        
        // 2. 获取所有跑步类型的记录
        let sourcePredicate = HKQuery.predicateForWorkouts(with: .running)
        
        //3. Combine the predicates into a single predicate.
        let compound = NSCompoundPredicate(andPredicateWithSubpredicates:
            [workoutPredicate, sourcePredicate])
          
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate,
                                                ascending: false)
        
        
        // 4. define the limitation
        let limitation = HKObjectQueryNoLimit
        
        let query = HKSampleQuery(
          sampleType: .workoutType(),
          predicate: compound,
          limit: limitation,
          sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            DispatchQueue.main.async {
              guard
                let samples = samples as? [HKWorkout],
                error == nil
                else {
                  completion(nil, error)
                  return
              }
              completion(samples, nil)
            }
          }
        HKHealthStore().execute(query)
    }
    
    
    
    class func loadThisMonthWorkouts(_ fromDate: Date, _ toDate: Date, _ userRangeFlag: Bool, completion: @escaping([HKWorkout]?, Error?) -> Void) {
        // 1. 获取上月的起始日期和结束日期
        let res = AssistantMethods.getThisMonthStartEndDate(fromDate, toDate, userRangeFlag)
        
        let workoutPredicate = HKQuery.predicateForSamples(withStart: res.startDate, end: res.endDate)
        
        // 2. 获取所有跑步类型的记录
        let sourcePredicate = HKQuery.predicateForWorkouts(with: .running)
        
        //3. Combine the predicates into a single predicate.
        let compound = NSCompoundPredicate(andPredicateWithSubpredicates:
            [workoutPredicate, sourcePredicate])
          
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate,
                                                ascending: false)
        
        
        // 4. define the limitation
        let limitation = HKObjectQueryNoLimit
        
        let query = HKSampleQuery(
          sampleType: .workoutType(),
          predicate: compound,
          limit: limitation,
          sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            DispatchQueue.main.async {
              guard
                let samples = samples as? [HKWorkout],
                error == nil
                else {
                  completion(nil, error)
                  return
              }
              completion(samples, nil)
            }
          }
        HKHealthStore().execute(query)
    }
    
    
    
    class func loadLastWorkouts(completion: @escaping([HKWorkout]?, Error?) -> Void) {
        
        
        // 1. get all workouts with the "Other" / "Running" activity type
        let workoutPredicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date.init())
        
        // 2. get all workouts that only came from this app?????🥲
//        let sourcePredicate = HKQuery.predicateForWorkouts(with:
        
        
        //3. Combine the predicates into a single predicate.
//        let compound = NSCompoundPredicate(andPredicateWithSubpredicates:
//            [workoutPredicate])
          
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate,
                                                ascending: false)
        
        
        // 4. define the limitation
        let limitation = 1
        
        let query = HKSampleQuery(
          sampleType: .workoutType(),
          predicate: workoutPredicate,
          limit: limitation,
          sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            DispatchQueue.main.async {
              guard
                let samples = samples as? [HKWorkout],
                error == nil
                else {
                  completion(nil, error)
                  return
              }
              completion(samples, nil)
            }
          }
        HKHealthStore().execute(query)
    }
    
    
}
