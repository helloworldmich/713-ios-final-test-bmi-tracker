//
//  PersonalDetailsViewController.swift
//  bmi-tracker
//
//  Created by Yat Man Chan 301279592 on 12/12/2022.
//

import UIKit

class PersonalDetailsViewController: UIViewController {
    
    @IBOutlet weak var firstWeightLabel: UILabel!
    @IBOutlet weak var firstHeightLabel: UILabel!
    @IBOutlet weak var usemetricFirst: UISwitch!
    @IBOutlet weak var editFirstWeight: UITextField!
    @IBOutlet weak var editFirstHeight: UITextField!
    @IBOutlet weak var firstBMI: UILabel!
    @IBOutlet weak var firstBMICategory: UILabel!
    var weight:Float = 0.0 //may hv to change to another variable name
    var height:Float = 0.0
    var bmi:Float = 0.0
    var BMICategory = ""

    // because these variables have to use for different functions: initalizeDB(), saveDataToDB(),
    var dataNewWeight = ""
    var dataNewHeight = ""
    var dataRecordTime = ""
    var dataBMI = ""
    var dataCategory = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        usemetricFirst.isOn = true
        initializeDB()
     
    }
    func initializeDB(){
        var database:OpaquePointer? = nil
        var result = sqlite3_open(recordListDataFilePath(), &database)
        
        if result != SQLITE_OK {
            sqlite3_close(database)
            print("Failed to open database")
            return
        }
        let createSQL = "CREATE TABLE IF NOT EXISTS RECORD_TABLE " +
                        "(RECORD_ID INTEGER PRIMARY KEY AUTOINCREMENT, WEIGHT TEXT, HEIGHT TEXT, RECORD_TIME TEXT, BMI TEXT, BMI_CATEGORY TEXT);"
        var errMsg:UnsafeMutablePointer<Int8>? = nil
                
        result = sqlite3_exec(database, createSQL, nil, nil, &errMsg)
        print("initialize db done")
        if (result != SQLITE_OK) {
            sqlite3_close(database)
            print("Failed to create table")
            return
        }
        
        else{
            print(String(cString: sqlite3_errmsg(database)))
            
        }
    }
    func recordListDataFilePath() -> String{
        let urls = FileManager.default.urls(for:.documentDirectory, in: .userDomainMask)
        var url:String?
        url = urls.first?.appendingPathComponent("recordListDatabase1.sqlite").path
        return url!
    }
    @IBAction func useMetricAtFirst(_ sender: UISwitch) {        
        if(usemetricFirst.isOn){
            firstWeightLabel.text = "weight(in kg)"
            firstHeightLabel.text = "height(in m)"
        }
        else{
            firstWeightLabel.text = "weight(in lb)"
            firstHeightLabel.text = "height(in ft)"
        }
    }
    
//    @IBAction func calculatefirstBMI(_ sender: UIButton) {
        func calculatefirstBMI(){
            weight =  Float(editFirstWeight.text!) ?? 0.0
            height = Float(editFirstHeight.text!) ?? 0.0
        if (usemetricFirst.isOn){
            let heightSq = height*height
            bmi = weight / heightSq
            firstBMI.text = String(bmi)
            print(bmi)
            print(BMICategory)
            
            if (bmi<16.0){
                BMICategory = "severe thinness" }
            else if (bmi >= 16.0 && bmi < 17.0){
                BMICategory = "moderate thinness"}
            else if (bmi >= 17.0 && bmi < 18.5){
                BMICategory = "mild thinness"}
            else if (bmi >= 18.5 && bmi < 25.0){
                BMICategory = "normal"
                print(BMICategory)
            }
            else if (bmi >= 25 && bmi < 30){
                BMICategory = "overweight"}
            else if (bmi >= 30 && bmi < 35){
                BMICategory = "obese class I"}
            else if (bmi >= 35 && bmi < 40){
                BMICategory = "obese class II"}
            else if (bmi >= 40){
                BMICategory = "obese class III"}
            firstBMICategory.text = BMICategory
           
        }
        else{
        let heightToInchSq = height*12*height*12
            bmi = weight*703/heightToInchSq
            firstBMI.text = String(bmi)            
            if (bmi<16){BMICategory = "severe thinness" }
            else if (bmi >= 16 && bmi < 17){BMICategory = "moderate thinness"}
            else if (bmi >= 17 && bmi < 18.5){BMICategory = "mild thinness"}
            else if (bmi >= 18.5 && bmi < 25){BMICategory = "normal"}
            else if (bmi >= 25 && bmi < 30){BMICategory = "overweight"}
            else if (bmi >= 30 && bmi < 35){BMICategory = "obese class I"}
            else if (bmi >= 35 && bmi < 40){BMICategory = "obese class II"}
            else if (bmi >= 40){BMICategory = "obese class III"}
            print(BMICategory)
            firstBMICategory.text = BMICategory
        }
        
    }

    @IBAction func AddFirstRecordButton_Clicked(_ sender: UIButton) {
        if (weight <= 0.0 || height <= 0.0){
            
            calculatefirstBMI()
            
            dataNewWeight = String(weight)       //weight is the only user clicks submit. editFirstWeight.text
            dataNewHeight = String(height)      //height is the only user clicks submit. editFirstHeight.text
            dataRecordTime = Date().formatted()
            dataBMI = String(bmi)
            dataCategory = BMICategory
            
            navigationController?.popViewController(animated: true)
            
            saveDataToDB()
            let showRecordTableVC = storyboard?.instantiateViewController(withIdentifier: "ShowRecordTable") as! MainTableViewController
            showRecordTableVC.title = "Open"
            navigationController?.pushViewController(showRecordTableVC, animated: true)
        }
        else {
            
        }
            }
    
    func saveDataToDB(){
        
        var database:OpaquePointer? = nil
        
        let result = sqlite3_open(recordListDataFilePath(), &database)
        
        if result != SQLITE_OK {
            sqlite3_close(database)
            print("Failed to open database")
            return
        }
        let update = "INSERT INTO RECORD_TABLE (WEIGHT, HEIGHT, RECORD_TIME, BMI, BMI_CATEGORY) VALUES (?, ?, ?, ?, ?);"
//        let update = "INSERT INTO RECORD_TABLE (WEIGHT, HEIGHT, RECORD_TIME, BMI, BMI_CATEGORY) VALUES (62.0, 1.7, 16-12-2022, 22.5, 'normal');"
        var statement:OpaquePointer? = nil


        if sqlite3_prepare_v2(database, update, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (dataNewWeight as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (dataNewHeight as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 3, (dataRecordTime as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 4, (dataBMI as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 5, (dataCategory as NSString).utf8String, -1, nil)
            
            print(dataNewWeight, dataNewHeight,dataRecordTime, dataBMI,dataCategory )
        }
                    
        if sqlite3_step(statement) != SQLITE_DONE {
            print("Error Inserting Data")
            sqlite3_close(database)
            return
        }
        else
        {
            print(String(cString: sqlite3_errmsg(database)))
        }
                        
        sqlite3_finalize(statement)
              
        sqlite3_close(database)

        navigationController?.popViewController(animated: true)
        
    }
   // no reaction when clicked
    @IBAction func goToRecordTable_clicked(_ sender: UIButton) {
        
        let goToRecordTableVC = storyboard?.instantiateViewController(identifier: "ShowRecordTable") as! MainTableViewController
        goToRecordTableVC.modalPresentationStyle = .automatic       // suggestion from K: .fullscreen
                present(goToRecordTableVC,animated: true)
        
//        navigationController?.popViewController(animated: true)    // added by me, but no navigation bar shown
        
//   previous method:
//        let goToRecordTableVC = storyboard?.instantiateViewController(withIdentifier: "ShowRecordTable") as! MainTableViewController
//        goToRecordTableVC.title = "Open"
//        navigationController?.pushViewController(goToRecordTableVC, animated: true)
//
//        print("clicked") //printed but not action
    }
    
}
