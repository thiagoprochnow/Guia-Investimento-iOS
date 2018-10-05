//
//  BuyStockForm.swift
//  Guia Investimento
//
//  Created by Felipe on 13/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
import UIKit
class StockDividendForm: UIViewController, UITextFieldDelegate{
    @IBOutlet var symbolTextField: UITextField!
    @IBOutlet var perTextField: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    var symbol: String = ""
    var incomeType: Int = -1
    var id: Int = 0
    var prealodedIncome: StockIncome!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add Dividend button added on the right side of the bar menu
        let btInsert = UIBarButtonItem(title: "Inserir", style: UIBarButtonItemStyle.plain, target: self, action: #selector(StockDividendForm.insertJcpDiv))
        let font = UIFont.init(name: "Arial", size: 14)
        btInsert.setTitleTextAttributes([NSAttributedStringKey.font: font], for: .normal)
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
            let incomeDB = StockIncomeDB()
            prealodedIncome = incomeDB.getIncomesById(id)
            symbolTextField.text = prealodedIncome.symbol
            perTextField.text = String(prealodedIncome.perStock)
            let date = Date(timeIntervalSince1970: TimeInterval(prealodedIncome.exdividendTimestamp))
            datePicker.setDate(date, animated: false)
            incomeType = prealodedIncome.type
            incomeDB.close()
        }
    }
    
    @IBAction func insertJcpDiv(){
        let perStock = perTextField.text
        let stockSymbol = symbolTextField.text
        
        // Get selected date as 00:00
        let date = datePicker.date
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "UTC")!
        let startOfDay = calendar.startOfDay(for: date)
        let timestamp = startOfDay.timeIntervalSince1970
        
        // Create alert saying the stock information is invalid
        let alert = UIAlertView()
        alert.title = "Campo Inválido"
        alert.delegate = self
        alert.addButton(withTitle: "OK")
        
        // Check if inserted values are valid, if all are valid, insert the new stock
        let isValidSymbol = Utils.isValidStockSymbol(symbol: stockSymbol!)
        if(isValidSymbol){
            let isValidPer = Utils.isValidDouble(text: perStock!)
            if(isValidPer){
                // Sucesso em todos os casos, inserir o provento
                let stockIncome = StockIncome()
                // In case it is editing to update stockTransaction
                if(id != 0){
                    stockIncome.id = id
                }
                let general = StockGeneral()
                let stockQuantity = Int(general.getStockQuantity(symbol: symbol, incomeTimestamp: Int(timestamp)))
                var grossIncome: Double = 0.0
                var liquidIncome: Double = 0.0
                var tax: Double = 0.0
                stockIncome.affectedQuantity = stockQuantity
                stockIncome.symbol = stockSymbol!
                stockIncome.perStock = Double(perStock!)!
                grossIncome = Double(stockQuantity) * Double(perStock!)!
                liquidIncome = grossIncome
                if(incomeType == Constants.IncomeType.JCP){
                    tax = grossIncome * 0.15
                    liquidIncome -= tax
                }
                stockIncome.grossIncome = grossIncome
                stockIncome.tax = tax
                stockIncome.liquidIncome = liquidIncome
                stockIncome.exdividendTimestamp = Int(timestamp)
                stockIncome.type = incomeType
                
                // Save StockTransaction
                let db = StockIncomeDB()
                db.save(stockIncome)
                db.close()
                
                general.updateStockDataIncome(symbol, valueReceived: liquidIncome, tax: tax)
                
                // Dismiss current view
                self.navigationController?.popViewController(animated: true)
                // Show Alert
                alert.title = ""
                if(incomeType == Constants.IncomeType.DIVIDEND){
                    alert.message = "Dividendo inserido com sucesso"
                } else {
                    alert.message = "Juros Sobre Capital inserido com sucesso"
                }
                alert.show()
            } else {
                // Show Alert
                alert.message = "Valor do dividendo deve conter apenas números e ponto"
                alert.show()
            }
        } else {
            // Show Alert
            alert.message = "Código da Ação inválido"
            alert.show()
        }
    }
    
    // Gives first responder back to view and closes keyboard when clicking outside of text field
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        perTextField.resignFirstResponder()
    }
}
