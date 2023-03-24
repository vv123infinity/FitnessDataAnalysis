//
//  LoadWorkoutData.swift
//  FitnessDataAnalysis
//
//  Created by 十口V🌼 on 2023/2/24.
//

import UIKit
import HealthKit


class LoadWorkoutData: UITableViewController {

    
    private enum WorkoutsSegues: String {
      case showCreateWorkout
      case finishedCreatingWorkout
    }
    
    private var workouts: [HKWorkout]?
    private let cellID = "myRunningRecordID"
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .medium
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = false
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadWorkouts()
    }
    
    func reloadWorkouts() {
        WorkoutDataStore.loadWorkouts() { (workouts, error) in
            self.workouts = workouts
            print("Test DIY date!!!!")
            _ = QueryWorkoutsAssistant.getTargetDistanceWithStartEndDate(workouts!, 2023, 2, 20, 2023, 2, 26)
            
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return workouts?.count ?? 0
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // 1. Make sure that the workout is avaliable
        guard let workouts = workouts else {
            fatalError("No Workout Avaliable !!! ")
        }
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        var content = cell.defaultContentConfiguration()
        
        // 2. get current workout
        let workout = workouts[indexPath.row]
        
        // 3. show the date and duration time (second)
        let startDate = dateFormatter.string(from: workout.startDate)
        let durationTimeInSec = String(format: "Duration: %.2f", workout.duration)
        content.secondaryText = startDate + "\t" + durationTimeInSec
        
        // 4. Show the running distance
        let runningDistanceOldVersion = workout.totalDistance!
        
        let runningType = HKQuantityType(.distanceWalkingRunning)
        let runningDistanceNewVersion = workout.statistics(for: runningType)?.sumQuantity()?.doubleValue(for: .meter())
        
        content.text = "\(runningDistanceNewVersion!)"
        
        cell.contentConfiguration = content
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 65
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}



extension LoadWorkoutData{
    func popAlert(_ inputTitle: String, _ detailMessage: String) {
        let alertController = UIAlertController(title: inputTitle, message: detailMessage, preferredStyle: .alert)

        let okAction = UIAlertAction(title: "确定", style: .default) { (_) in
            HKSetupAssistant.authorizeHealthKit() { (s, error) in
                guard s else {
                    print("Still not")
                    return
                }
                
            }
        }

        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
