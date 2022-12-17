//
//  ShowRecordViewController.swift
//  bmi-tracker
//
//  Created by Yat Man Chan 301279592 on 11/12/2022.
//

import UIKit
var selectedRecordID: Int = 0

class ShowRecordViewController: UIViewController {
    
    
    @IBOutlet weak var editWeightText: UITextField!
    
    @IBOutlet weak var editHeightText: UITextField!
    
    @IBOutlet weak var updatedBMILabel: UILabel!
    
    
    @IBOutlet weak var categoryUpdatedLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        editWeightText.text = "60.0"
        editHeightText.text = "159.5"
        updatedBMILabel.text = "23.4"
        // Do any additional setup after loading the view.
        
        var database:OpaquePointer? = nil
        var result = sqlite3_open(recordListDataFilePath(), &database)
                
        if result != SQLITE_OK {
            sqlite3_close(database)
            print("Failed to open database")
            return
    }
        let query = "SELECT RECORD_ID, WEIGHT, HEIGHT, RECORD_TIME, BMI,BMI_CATEGORY FROM RECORD_TABLE WHERE RECORD_ID = '\(selectedRecordID)'"
        print(selectedRecordID)
        var statement:OpaquePointer? = nil
               
        if sqlite3_prepare_v2(database, query, -1, &statement, nil) == SQLITE_OK {
                   
            while sqlite3_step(statement) == SQLITE_ROW {
                       
                let recordID = Int(sqlite3_column_int(statement, 0))
                let weight = sqlite3_column_text(statement, 1)
                let height = sqlite3_column_text(statement, 2)
                let recordTime = sqlite3_column_text(statement, 3)
                let bmi = sqlite3_column_text(statement, 4)
                let category = sqlite3_column_text(statement, 5)
                       
                let stringWeight = String.init(cString: weight!)
                let stringHeight = String.init(cString: height!)
                let stringRecordTime = String.init(cString: recordTime!)
                let stringBMI = String.init(cString: bmi!)
                let stringCategory = String.init(cString: category!)

                       
                print("\(recordID) | \(stringWeight) | \(stringHeight) | \(stringRecordTime) | \(stringBMI) | \(stringCategory)")
                editWeightText.text = stringWeight
                editHeightText.text = stringHeight
                updatedBMILabel.text = stringBMI
                categoryUpdatedLabel.text = stringCategory
               
            print(stringWeight,stringHeight, stringBMI,stringBMI,stringCategory )
            }
            sqlite3_finalize(statement)
        }
        sqlite3_close(database)
    }
    
    func recordListDataFilePath() -> String {
        let urls = FileManager.default.urls(for:.documentDirectory, in: .userDomainMask)
        var url:String?
        url = urls.first?.appendingPathComponent("recordListDatabase1.sqlite").path
        return url!
    }
    
    
    @IBAction func DeleteRecord_Clicked(_ sender: UIButton) {
        var database:OpaquePointer? = nil
        let result = sqlite3_open(recordListDataFilePath(), &database)
        if result != SQLITE_OK {
            sqlite3_close(database)
            print("Failed to open database")
            return
        }

        let deleteString = "DELETE FROM RECORD_TABLE WHERE RECORD_ID = '\(selectedRecordID)';"
             
        var statement:OpaquePointer? = nil

        if sqlite3_prepare_v2(database, deleteString, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(selectedRecordID))   //--> record ID number
                    
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Successfully deleted row.")
            }
            else {
                print("Could not delete row.")
            }
            
        }
                    
        sqlite3_finalize(statement)
              
        sqlite3_close(database)
        
        navigationController?.popViewController(animated: true)

    }
    
    
    @IBAction func UpdateButton_Clicked(_ sender: UIButton) {
        var database:OpaquePointer? = nil
        let result = sqlite3_open(recordListDataFilePath(), &database)
        if result != SQLITE_OK {
            sqlite3_close(database)
            print("Failed to open database")
            return
        }
        

        let recordID = selectedRecordID
        let weight = editWeightText.text
        let height =  editHeightText.text
        let recordTime = Date().formatted()
        let bmi = updatedBMILabel.text
        let category = categoryUpdatedLabel.text
        
        
        
        let updateString = "UPDATE RECORD_TABLE SET WEIGHT = '\(weight!)', HEIGHT = '\(height!)', RECORD_TIME = '\(recordTime)', BMI = '\(bmi)' BMI_CATEGORY = \(category);"
                    
        var statement:OpaquePointer? = nil
                    
        if sqlite3_prepare_v2(database, updateString, -1, &statement, nil) == SQLITE_OK {
                    
            if sqlite3_step(statement) != SQLITE_DONE {
                print("Error updating table")
                sqlite3_close(database)
                return
            }
            else
            {
                print(String(cString: sqlite3_errmsg(database)))
            }
        }
                    
                        
        sqlite3_finalize(statement)
              
        sqlite3_close(database)
        
        navigationController?.popViewController(animated: true)
    }
    
    // can put back to table view controller later
//    @IBAction func buttonAdd_Clicked(_ sender: UIBarButtonItem) {
//
//        let addRecordVC = storyboard?.instantiateViewController(withIdentifier: "AddRecord") as! AddRecordViewController
//        addRecordVC.title = "Add New Record"
//        navigationController?.pushViewController(addRecordVC, animated: true)
//
//    }
    
}
