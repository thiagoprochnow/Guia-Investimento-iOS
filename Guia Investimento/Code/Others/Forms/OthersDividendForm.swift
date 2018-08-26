//
//  OthersDividendForm.swift
//  Guia Investimento
//
//  Created by Felipe on 13/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
import UIKit
class OthersDividendForm: UIViewController, UITextFieldDelegate{
    @IBOutlet var symbolTextField: UITextField!
    @IBOutlet var totalTextField: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    var symbol: String = ""
    var incomeType: Int = -1
    var id: Int = 0
    var prealodedIncome: OthersIncome!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add Dividend button added on the right side of the bar menu
        let btInsert = UIBarButtonItem(title: "Inserir", style: UIBarButtonItemStyle.plain, target: self, action: #selector(OthersDividendForm.insertIncome))
        self.navigationItem.rightBarButtonItem = btInsert
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        
        // Delegade UITextFieldDelagate to self
        symbolTextField.delegate = self
        totalTextField.delegate = self
        totalTextField.keyboardType = UIKeyboardType.decimalPad
        datePicker.timeZone = TimeZone(abbreviation: "UTC")
        
        if(symbol != ""){
            symbolTextField.text = symbol
        }
        
        // It is a Edit mode, preload inserted information to be edited and saved
        if(id != 0){
            let incomeDB = OthersIncomeDB()
            prealodedIncome = incomeDB.getIncomesById(id)
            symbolTextField.text = prealodedIncome.symbol
            totalTextField.text = String(prealodedIncome.grossIncome)
            let date = Date(timeIntervalSince1970: TimeInterval(prealodedIncome.exdividendTimestamp))
            datePicker.setDate(date, animated: false)
            incomeType = prealodedIncome.type
            incomeDB.close()
        }
    }
    
    @IBAction func insertIncome(){
        let gross = totalTextField.text
        let othersSymbol = symbolTextField.text
        
        // Get selected date as 00:00
        let date = datePicker.date
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "UTC")!
        let startOfDay = calendar.startOfDay(for: date)
        let timestamp = startOfDay.timeIntervalSince1970
        
        // Create alert saying the others information is invalid
        let alert = UIAlertView()
        alert.title = "Campo Inválido"
        alert.delegate = self
        alert.addButton(withTitle: "OK")
        
        // Check if inserted values are valid, if all are valid, insert the new others
        let isValidSymbol = Utils.isValidOthersSymbol(symbol: othersSymbol!)
        if(isValidSymbol){
            let isValidPer = Utils.isValidDouble(text: gross!)
            if(isValidPer){
                // Sucesso em todos os casos, inserir o provento
                let othersIncome = OthersIncome()
                // In case it is editing to update othersTransaction
                if(id != 0){
                    othersIncome.id = id
                }

                var grossIncome: Double = 0.0
                var liquidIncome: Double = 0.0
                grossIncome = Double(gross!)!
                othersIncome.symbol = othersSymbol!
                let tax = grossIncome * 0.15
                liquidIncome = grossIncome - tax
                othersIncome.grossIncome = grossIncome
                othersIncome.tax = tax
                othersIncome.liquidIncome = liquidIncome
                othersIncome.exdividendTimestamp = Int(timestamp)
                othersIncome.type = Constants.IncomeType.TREASURY
                
                // Save OthersIncome
                let db = OthersIncomeDB()
                db.save(othersIncome)
                db.close()
                
                let general = OthersGeneral()
                general.updateOthersDataIncome(symbol, valueReceived: liquidIncome, tax: tax)
                
                // Dismiss current view
                self.navigationController?.popViewController(animated: true)
                // Show Alert
                alert.title = ""
                alert.message = "Rendimento inserido com sucesso"

                alert.show()
            } else {
                // Show Alert
                alert.message = "Valor do rendimento deve conter apenas números e ponto"
                alert.show()
            }
        } else {
            // Show Alert
            alert.message = "Código do investimento é inválido"
            alert.show()
        }
    }
    
    // Gives first responder back to view and closes keyboard when clicking outside of text field
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        totalTextField.resignFirstResponder()
    }
}