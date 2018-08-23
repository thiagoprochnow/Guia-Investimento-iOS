//
//  SellFixedForm.swift
//  Guia Investimento
//
//  Created by Felipe on 13/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
import UIKit
class SellFixedForm: UIViewController, UITextFieldDelegate{
    @IBOutlet var symbolTextField: UITextField!
    @IBOutlet var totalTextField: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    var symbol: String = ""
    var id: Int = 0
    var prealodedTransaction: FixedTransaction!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Insert fixed button added on the right side of the bar menu
        let btInsert = UIBarButtonItem(title: "Vender", style: UIBarButtonItemStyle.plain, target: self, action: #selector(SellFixedForm.sellFixed))
        self.navigationItem.rightBarButtonItem = btInsert
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        
        // Delegade UITextFieldDelagate to self
        symbolTextField.delegate = self
        totalTextField.delegate = self
        totalTextField.keyboardType = UIKeyboardType.numberPad
        datePicker.timeZone = TimeZone(abbreviation: "UTC")
        
        // Always selling a already bougth fixed
        symbolTextField.text = symbol
        
        // It is a Edit mode, preload inserted information to be edited and saved
        if(id != 0){
            let transactionDB = FixedTransactionDB()
            prealodedTransaction = transactionDB.getTransactionById(id)
            symbolTextField.text = prealodedTransaction.symbol
            totalTextField.text = String(prealodedTransaction.boughtTotal)
            let date = Date(timeIntervalSince1970: TimeInterval(prealodedTransaction.timestamp))
            datePicker.setDate(date, animated: false)
            transactionDB.close()
        }
    }
    
    @IBAction func sellFixed(){
        let symbol = symbolTextField.text
        let total = totalTextField.text
        
        // Get selected date as 00:00
        let date = datePicker.date
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "UTC")!
        let startOfDay = calendar.startOfDay(for: date)
        let timestamp = startOfDay.timeIntervalSince1970
        
        // Create alert saying the fixed information is invalid
        let alert = UIAlertView()
        alert.title = "Campo Inválido"
        alert.delegate = self
        alert.addButton(withTitle: "OK")
        
        // Check if inserted values are valid, if all are valid, insert the new fixed
        let isValidSymbol = Utils.isValidFixedSymbol(symbol: symbol!)
        if(isValidSymbol){
            let doubleTotal = Double(total!)
            let isQuantityEnough = Utils.isValidSellFixed(total: doubleTotal!, symbol: symbol!)
                if(isQuantityEnough){
                        let isFutureDate = Utils.isFutureDate(timestamp: Int(timestamp))
                            if(!isFutureDate){
                                // Sucesso em todos os casos, inserir o fixed
                                let fixedTransaction = FixedTransaction()
                                // In case it is editing to update fixedTransaction
                                if(id != 0){
                                    fixedTransaction.id = id
                                }
                                fixedTransaction.symbol = symbol!
                                fixedTransaction.boughtTotal = Double(total!)!
                                fixedTransaction.brokerage = 0
                                fixedTransaction.timestamp = Int(timestamp)
                                fixedTransaction.type = Constants.TypeOp.SELL
                                
                                // Save FixedTransaction
                                let db = FixedTransactionDB()
                                db.save(fixedTransaction)
                                db.close()
                                
                                let general = FixedGeneral()
                                _ = general.updateFixedData(symbol!, type: Constants.TypeOp.SELL)
                                _ = Utils.updateFixedPortfolio()
                                
                                // Dismiss current view
                                self.navigationController?.popViewController(animated: true)
                                // Show Alert
                                alert.title = ""
                                alert.message = "Renda Fixa vendida com sucesso"
                                alert.show()
                            } else {
                                // Show Alert
                                alert.message = "Data de venda não pode ser futura a data atual"
                                alert.show()
                            }
                } else {
                    // Show Alert
                    alert.message = "Quantidade deve ter o suficiente dessa renda fixa na carteira"
                    alert.show()
                }
        } else {
            // Show Alert
            alert.message = "Código da Renda Fixa inválido"
            alert.show()
        }
    }
    
    // Gives first responder back to view and closes keyboard when clicking outside of text field
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        symbolTextField.resignFirstResponder()
        totalTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField == symbolTextField){
            totalTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}
