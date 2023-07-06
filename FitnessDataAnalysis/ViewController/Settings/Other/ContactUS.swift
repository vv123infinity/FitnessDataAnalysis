//
//  ContactUS.swift
//  FitnessDataAnalysis
//
//  Created by 十口V🌼 on 2023/3/31.
//

import UIKit

class ContactUS: UITableViewController {

    
    
    @IBOutlet weak var hintUIView: UIView!
    
    
    @IBOutlet weak var copyLabel: UILabel!
    
    lazy var cellName: [String] = [
        "vv123.infinity@gmail.com",
        "g1286731601@outlook.com"
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        self.setUpUI()
    }

    func setUpUI() {
        self.hintUIView.isHidden = true
        self.hintUIView.layer.cornerRadius = 20
        self.copyLabel.backgroundColor = ColorUtil.getBarBtnColor()
        self.hintUIView.backgroundColor = ColorUtil.getBarBtnColor()
        if UserDefaults.standard.bool(forKey: "useSmiley") {
            self.copyLabel.font = SmileyFontSize.getNormal()
        }
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.cellName.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "emailCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.textProperties.font = SmileyFontSize.getCellFont()
        
        content.text = self.cellName[indexPath.row]
        
//        content.secondaryText = self.cellName[indexPath.row]
        
        cell.contentConfiguration = content
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ps = UIPasteboard.general
        ps.string = self.cellName[indexPath.row]
        
        let originalPos = self.hintUIView.center
        let startPos = CGPoint(x: originalPos.x, y: originalPos.y + 40)
        self.hintUIView.center = startPos
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
            self.hintUIView.isHidden = false
            self.hintUIView.center = originalPos
        }, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.hintUIView.isHidden = true
        }
        
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
