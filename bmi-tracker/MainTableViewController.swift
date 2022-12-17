//
//  MainTableViewController.swift
//  bmi-tracker
//
//  Created by Yat Man Chan 301279592 on 14/12/2022.
//

import UIKit

class MainTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var tableView: UITableView! // NOT connect table view CELL!!!!!
  
    var record:[RecordList] = []
    var selectedRecordID:Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "BMI Tracker"
        // Do any additional setup after loading the view.
        buildInitialRecordListValue()
//        retrieveRecordFromDB()       // should not also put here after putting in viewDidAppear, otherwise, duplicate the views
    }
    func buildInitialRecordListValue()->Void{
        record.append(RecordList(recordID: 1, weight: "62.0",height:"1.595",recordTime: Date().formatted(), bmi: "23.5", bmiCategory: "Normal"))
        
        record.append(RecordList(recordID: 2, weight: "61.0",height:"1.595",recordTime: Date().formatted(), bmi: "23.05",  bmiCategory: "Normal"))
    }
   let recordTableIdentifier = "RecordTableIdentifier"
    
    
    @IBAction func ButtonAdd_Pressed(_ sender: UIBarButtonItem) {
        let addRecordVC = storyboard?.instantiateViewController(withIdentifier: "AddRecord") as! AddRecordViewController
        
        addRecordVC.title = "Add New Record"
        navigationController?.pushViewController(addRecordVC, animated: true)
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return record.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) // CELL's identfier, NOT TABLE's !!!!!!!!!!!!!!!!!
        //define only by clicking CELL, NOT Table!!!!!!!!!!!!
        
        selectedRecordID = record[indexPath.row].recordID
        print(selectedRecordID)
        let recordTimeString = record[indexPath.row].recordTime
        
        if let recordWeight = cell.contentView.viewWithTag(1) as? UILabel{
            recordWeight.text =
            String(record[indexPath.row].weight)
        }
        if let recordBMI = cell.contentView.viewWithTag(2) as? UILabel{
            recordBMI.text = String(record[indexPath.row].bmi)
        }
        if let recordDateTime = cell.contentView.viewWithTag(3) as? UILabel{
            recordDateTime.text = recordTimeString
        }
        if let recordCategory = cell.contentView.viewWithTag(4) as? UILabel{
            recordCategory.text = record[indexPath.row].bmiCategory
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath)-> CGFloat{
        return 120
    }
    func retrieveRecordFromDB(){
        var database:OpaquePointer? = nil
                var result = sqlite3_open(recordListDataFilePath(), &database)
                
                if result != SQLITE_OK {
                    sqlite3_close(database)
                    print("Failed to open database")
                    return
                }
               let query = "SELECT RECORD_ID, WEIGHT,HEIGHT, RECORD_TIME, BMI, BMI_CATEGORY FROM RECORD_TABLE ORDER BY RECORD_ID ASC"
        
               var statement:OpaquePointer? = nil
               
               if sqlite3_prepare_v2(database, query, -1, &statement, nil) == SQLITE_OK {
                   
                   while sqlite3_step(statement) == SQLITE_ROW {
                       
                       let recordID = Int(sqlite3_column_int(statement, 0))
                       let weight = sqlite3_column_text(statement, 1)
                       let height = sqlite3_column_text(statement, 2)
                       let recordTime = sqlite3_column_text(statement, 3)
                       let BMI = sqlite3_column_text(statement, 4)
                       let category = sqlite3_column_text(statement, 5)
                    

                       let stringWeight = String.init(cString: weight!)
                       let stringHeight = String.init(cString: height!)
                       let stringRecordTime = String.init(cString: recordTime!)
                       let stringBMI = String.init(cString: BMI!)
                       let stringCategory = String.init(cString: category!)
                       
                       record.append(RecordList(recordID: recordID,weight: stringWeight,  height: stringHeight, recordTime: stringRecordTime, bmi:stringBMI, bmiCategory: stringCategory))
        print(stringWeight,stringHeight,stringRecordTime, stringBMI,stringCategory)
//                       print(weight, height, recordTime, BMI, category)
                   }
                   
                   sqlite3_finalize(statement)
                        
               }
               
               sqlite3_close(database)
    }
    func recordListDataFilePath() -> String{
        let urls = FileManager.default.urls(for:.documentDirectory, in: .userDomainMask)
        var url:String?
        url = urls.first?.appendingPathComponent("recordListDatabase1.sqlite").path
        return url!
    }
    
    @IBAction func DeleteButton_Clicked(_ sender: UIButton) {
//        let point = sender.convert(CGPoint.zero, to: tableView)
//        guard let indexPath = tableView.indexPathForRow(at: point)
//        else{return}
//
//        selectedRecordID = record[indexPath.row].recordID
        
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
                print(selectedRecordID)
            }
            else {
                print("Could not delete row.")
            }

        }

        sqlite3_finalize(statement)

        sqlite3_close(database)

        func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            return true
        }
        func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
               print("Deleted")
//               self.catNames.remove(at: indexPath.row)
               self.tableView.beginUpdates()
               self.tableView.deleteRows(at: [indexPath], with: .automatic)
               self.tableView.endUpdates()
            }
        }
//        func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//          if editingStyle == .delete {
//            print("Deleted this row")
//
//    //        self.catNames.remove(at: indexPath.row)
//            self.tableView.deleteRows(at: [indexPath], with: .automatic)
//                        }
//        }
        
    }
    
    @IBAction func OpenButton_clicked(_ sender: UIButton) {
        
        let point = sender.convert(CGPoint.zero, to: tableView)
        guard let indexPath = tableView.indexPathForRow(at: point)
        else{return}
        
        selectedRecordID = record[indexPath.row].recordID
        
        let showRecordVC = storyboard?.instantiateViewController(withIdentifier: "ShowRecord") as! ShowRecordViewController
        
        showRecordVC.title = "Open"
        navigationController?.pushViewController(showRecordVC, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
         super.viewDidAppear(animated)
//         record.removeAll()
         retrieveRecordFromDB()
         tableView.reloadData()
     }
}
