//
//  AddRecordViewController.swift
//  bmi-tracker
//
//  Created by Yat Man Chan 301279592 on 11/12/2022.
//

import UIKit

class AddRecordViewController: UIViewController {

    @IBOutlet weak var editNewWeight: UITextField!
    
    @IBOutlet weak var editNewHeight: UITextField!
    
    @IBOutlet weak var newBMILabel: UILabel!
    
    @IBOutlet weak var newWeightLabel: UILabel!
    
    @IBOutlet weak var newHeightLabel: UILabel!
    
    @IBOutlet weak var useMetric: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        editNewWeight.text = "62.0"
        editNewHeight.text = "159.5cm"
        newBMILabel.text = "22.5"
        useMetric.isOn = true
        
    }
    
    @IBAction func metricIsOn(_ sender: UISwitch) {
        if (useMetric.isOn){
            newHeightLabel.text = "Weight (in kg)"
            newWeightLabel.text = "Height (in m)"
        }
        else{
            newHeightLabel.text = "Weight (in lb)"
            newWeightLabel.text = "Height (in ft)"
        }
    }
    
    @IBAction func AddRecordButton_Clicked(_ sender: UIButton) {

//        let point = sender.convert(CGPoint.zero, to: tableView)
//        guard let indexpath = tableView.indexPathForRow(at: point)
//        else{return}
//
//        selectedTaskID = task[indexpath.row].taskID

        let showRecordTableVC = storyboard?.instantiateViewController(withIdentifier: "ShowRecordTable") as! MainTableViewController
        showRecordTableVC.title = "Open"
        navigationController?.pushViewController(showRecordTableVC, animated: true)

       
    }
    
    
    /*When cancel Button is pressed on top navigation it will go back to table view screen*/
    @IBAction func CancelButton_Clicked(_ sender: UIButton) {
        
        let cancel = storyboard?.instantiateViewController(withIdentifier: "ShowRecordTable") as! MainTableViewController
        cancel.title = "Go back"
        navigationController?.pushViewController(cancel, animated: true)
 
//        tableView.reloadData()
    }

    
}
