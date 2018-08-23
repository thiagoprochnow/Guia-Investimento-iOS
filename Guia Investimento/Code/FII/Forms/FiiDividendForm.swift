//
//  FiiDividendForm.swift
//  Guia Investimento
//
//  Created by Felipe on 13/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
import UIKit
class FiiDividendForm: UIViewController, UITextFieldDelegate{
    @IBOutlet var symbolTextField: UITextField!
    @IBOutlet var perTextField: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    var symbol: String = ""
    var incomeType: Int = -1
    var id: Int = 0
    var prealodedIncome: FiiIncome!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add Dividend button added on the right side of the bar menu
        let btInsert = UIBarButtonItem(title: "Inserir", style: UIBarButtonItemStyle.plain, target: self, action: #selector(FiiDividendForm.insertIncome))
        self.navigationItem.rightBarButtonItem = btInsert
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        
        // Delegade UITextFieldDelagate to self
        symbolTextField.delegate = self
        symbolTextField.autocapitalizationType = UITextAutocapitalizationType.allCharacters
        perTextField.delegate = self
        perTextField.keyboardType = UIKeyboardType.decimalPad
        datePicker.timeZone = TimeZone(abbreviation: "UTC")
        
        if(symbol != ""){
            symbolTextField.text = symbol
        }
        
        // It is a Edit mode, preload inserted information to be edited and saved
        if(id != 0){
            let incomeDB = FiiIncomeDB()
            prealodedIncome = incomeDB.getIncomesById(id)
            symbolTextField.text = prealodedIncome.symbol
            perTextField.text = String(prealodedIncome.perFii)
            let date = Date(timeIntervalSince1970: TimeInterval(prealodedIncome.exdividendTimestamp))
            datePicker.setDate(date, animated: false)
            incomeType = prealodedIncome.type
            incomeDB.close()
        }
    }
    
    @IBAction func insertIncome(){
        let perFii = perTextField.text
        let fiiSymbol = symbolTextField.text
        
        // Get selected date as 00:00
        let date = datePicker.date
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "UTC")!
        let startOfDay = calendar.startOfDay(for: date)
        let timestamp = startOfDay.timeIntervalSince1970
        
        // Create alert saying the fii information is invalid
        let alert = UIAlertView()
        alert.title = "Campo Inválido"
        alert.delegate = self
        alert.addButton(withTitle: "OK")
        
        // Check if inserted values are valid, if all are valid, insert the new fii
        let isValidSymbol = Utils.isValidFiiSymbol(symbol: fiiSymbol!)
        if(isValidSymbol){
            let isValidPer = Utils.isValidDouble(text: perFii!)
            if(isValidPer){
                // Sucesso em todos os casos, inserir o provento
                let fiiIncome = FiiIncome()
                // In case it is editing to update fiiTransaction
                if(id != 0){
                    fiiIncome.id = id
                }
                let general = FiiGeneral()
                let fiiQuantity = Int(general.getFiiQuantity(symbol: symbol, incomeTimestamp: Int(timestamp)))
                var grossIncome: Double = 0.0
                var liquidIncome: Double = 0.0
                var tax: Double = 0.0
                fiiIncome.affectedQuantity = fiiQuantity
                fiiIncome.symbol = fiiSymbol!
                fiiIncome.perFii = Double(perFii!)!
                grossIncome = Double(fiiQuantity) * Double(perFii!)!
                liquidIncome = grossIncome
                fiiIncome.grossIncome = grossIncome
                fiiIncome.tax = tax
                fiiIncome.liquidIncome = liquidIncome
                fiiIncome.exdividendTimestamp = Int(timestamp)
                fiiIncome.type = Constants.IncomeType.FII
                
                // Save FiiIncome
                let db = FiiIncomeDB()
                db.save(fiiIncome)
                db.close()
                
                general.updateFiiDataIncome(symbol, valueReceived: liquidIncome, tax: tax)
                
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
            alert.message = "Código do fundo imobiliário inválido"
            alert.show()
        }
    }
    
    // Gives first responder back to view and closes keyboard when clicking outside of text field
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        perTextField.resignFirstResponder()
    }
}
