//
//  BodyInfo.swift
//  FitnessDataAnalysis
//
//  Created by Infinity vv123 on 2023/3/22.
//

import UIKit

import HealthKit


class BodyInfo: UIViewController {

    @IBOutlet var synHealthDataButton: UIButton!
    
//    @IBOutlet weak var ageLabel: UILabel!
//    @IBOutlet var indicatorValLabel: [UILabel]!
    
    
    var weight: String = ""
    var height: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        if HKHealthStore.isHealthDataAvailable() {
            self.authorizeHK()
        }
        
        
        
    }
    
    @IBAction func synHealthDataBtnPressed(_ sender: UIButton) {
        self.synHealthDataButton.isUserInteractionEnabled = false
    }
    
    
    
    func authorizeHK() {
        HKSetupAssistant.authorizeHealthKit() { (s, error) in
            guard s else {
                
                let baseMessage = "HealthKit Authorization Failed"
                if let error = error {
                  print("\(baseMessage). Reason: \(error.localizedDescription)")
                } else {
                  print(baseMessage)
                }
                return
              }
              print("HealthKit Successfully Authorized.")
            
            UserDefaults.standard.set(true, forKey: "ShowRunningOverviewChart")
            
        }
        
    }
    
    
    func loadAge() {
        let healthKitStore = HKHealthStore()
        do {
            
            //1. This method throws an error if these data are not available.
            do {
                let birthdayComponents = try healthKitStore.dateOfBirthComponents()
                //2. Use Calendar to calculate age.
                let today = Date()
                let calendar = Calendar.current
                let todayDateComponents = calendar.dateComponents([.year],
                                                                    from: today)
                let thisYear = todayDateComponents.year!
                let age = thisYear - birthdayComponents.year!
                
            }catch {
                
            }
            

        }
    }
    
    func loadAndDisplayMostRecentHeight(){
        let healthKitStore = HKHealthStore()
        do {
            //1. Use HealthKit to create the Height Sample Type
            guard let heightSampleType = HKSampleType.quantityType(forIdentifier: .height) else {
              print("Height Sample Type is no longer available in HealthKit")
              return
            }
                
            GetBodyData.getMostRecentSample(for: heightSampleType) { (sample, error) in
                  
              guard let sample = sample else {
                  
                if let error = error {
                    
                }
                    
                return
              }
                  
              //2. Convert the height sample to meters, save to the profile model,
              //   and update the user interface.
                let heightInMeters = sample.quantity.doubleValue(for: HKUnit.meter())
                self.height = "\(heightInMeters)"
                
            }
            
            guard let weightSampleType = HKSampleType.quantityType(forIdentifier: .bodyMass) else {
              print("Body Mass Sample Type is no longer available in HealthKit")
              return
            }
                
            GetBodyData.getMostRecentSample(for: weightSampleType) { (sample, error) in
                  
              guard let sample = sample else {
                    
                if let error = error {
                }
                return
              }
                  
              let weightInKilograms = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
                self.weight = "\(weightInKilograms)"
            }
        }


    }
    
    
    /*
    func updateLabel() {
        DispatchQueue.main.async {
            self.indicatorValLabel[1].text = self.height
            self.indicatorValLabel[2].text = self.weight
            
        }
    }
*/

}
