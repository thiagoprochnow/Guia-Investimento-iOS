//
//  BuyOthersForm.swift
//  Guia Investimento
//
//  Created by Felipe on 13/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
import UIKit

class BuyOthersForm: UIViewController, UITextFieldDelegate{
    @IBOutlet var symbolTextField: SearchTextField!
    @IBOutlet var totalTextField: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    
    var symbol: String = ""
    var row: Int = 0
    var id: Int = 0
    var prealodedTransaction: OthersTransaction!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Insert others button added on the right side of the bar menu
        let btInsert = UIBarButtonItem(title: "Inserir", style: UIBarButtonItemStyle.plain, target: self, action: #selector(BuyOthersForm.insertOthers))
        self.navigationItem.rightBarButtonItem = btInsert
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        
        // Delegade UITextFieldDelagate to self
        symbolTextField.delegate = self
        totalTextField.delegate = self
        totalTextField.keyboardType = UIKeyboardType.decimalPad
        datePicker.timeZone = TimeZone(abbreviation: "UTC")
        
        // Buying a repeated others, already shows symbol of the new buy
        if(symbol != ""){
            symbolTextField.text = symbol
        }
        
        // It is a Edit mode, preload inserted information to be edited and saved
        if(id != 0){
            let transactionDB = OthersTransactionDB()
            prealodedTransaction = transactionDB.getTransactionById(id)
            symbolTextField.text = prealodedTransaction.symbol
            totalTextField.text = String(prealodedTransaction.boughtTotal)
            
            let date = Date(timeIntervalSince1970: TimeInterval(prealodedTransaction.timestamp))
            datePicker.setDate(date, animated: false)
            transactionDB.close()
        }
    }
    
    @IBAction func insertOthers(){
        let symbol = symbolTextField.text
        let boughtTotal = totalTextField.text
        
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
        let isValidSymbol = Utils.isValidOthersSymbol(symbol: symbol!)
        if(isValidSymbol){
            let isValidTotal = Utils.isValidDouble(text: boughtTotal!)
            if(isValidTotal){
                    let isFutureDate = Utils.isFutureDate(timestamp: Int(timestamp))
                        if(!isFutureDate){
                            // Sucesso em todos os casos, inserir a others
                            let othersTransaction = OthersTransaction()
                            // In case it is editing to update othersTransaction
                            if(id != 0){
                                othersTransaction.id = id
                            }
                            othersTransaction.symbol = symbol!
                            othersTransaction.boughtTotal = Double(boughtTotal!)!
                            
                            othersTransaction.timestamp = Int(timestamp)
                            othersTransaction.type = Constants.TypeOp.BUY
                            
                            // Save OthersTransaction
                            let db = OthersTransactionDB()
                            db.save(othersTransaction)
                            db.close()
                            
                            let general = OthersGeneral()
                            _ = general.updateOthersData(symbol!, type: Constants.TypeOp.BUY)
                            _ = Utils.updateOthersPortfolio()
                            
                            // Dismiss current view
                            self.navigationController?.popViewController(animated: true)
                            // Show Alert
                            alert.title = ""
                            alert.message = "Renda Fixa comprada com sucesso"
                            alert.show()
                        } else {
                            // Show Alert
                            alert.message = "Data de compra não pode ser futura a data atual"
                            alert.show()
                        }
            } else {
                // Show Alert
                alert.message = "Quantidade de investimento deve conter apenas números e ponto"
                alert.show()
            }
        } else {
            // Show Alert
            alert.message = "Nomenclatura da renda fixa é inválida"
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
