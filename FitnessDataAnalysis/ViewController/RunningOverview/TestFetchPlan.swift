//
//  TestFetchPlan.swift
//  FitnessDataAnalysis
//
//  Created by 十口V🌼 on 2023/3/25.
//

import UIKit
import CoreData

class TestFetchPlan: UIViewController {
    
    var currentRunFeelingInstance: OneDayPlan!
    var managedObjectContext: NSManagedObjectContext!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedObjectContext = appDelegate!.persistentContainer.viewContext

        
        let req: NSFetchRequest<OneDayPlan> = OneDayPlan.fetchRequest()
        let res = try! managedObjectContext.fetch(req)
        
        for plan in res {
            print(plan.runningDate)
            print(plan.note)
            print(plan.feeling)
            print("______________________")
        }
        
    

        
        
        
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
