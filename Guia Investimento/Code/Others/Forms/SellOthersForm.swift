//
//  SellOthersForm.swift
//  Guia Investimento
//
//  Created by Felipe on 13/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
import UIKit
class SellOthersForm: UIViewController, UITextFieldDelegate{
    @IBOutlet var symbolTextField: UITextField!
    @IBOutlet var totalTextField: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    var symbol: String = ""
    var id: Int = 0
    var prealodedTransaction: OthersTransaction!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Insert others button added on the right side of the bar menu
        let btInsert = UIBarButtonItem(title: "Vender", style: UIBarButtonItemStyle.plain, target: self, action: #selector(SellOthersForm.sellOthers))
        self.navigationItem.rightBarButtonItem = btInsert
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        
        // Delegade UITextFieldDelagate to self
        symbolTextField.delegate = self
        totalTextField.delegate = self
        totalTextField.keyboardType = UIKeyboardType.numberPad
        datePicker.timeZone = TimeZone(abbreviation: "UTC")
        
        // Always selling a already bougth others
        symbolTextField.text = symbol
        
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
    
    @IBAction func sellOthers(){
        let symbol = symbolTextField.text
        let total = totalTextField.text
        
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
            let doubleTotal = Double(total!)
            let isQuantityEnough = Utils.isValidSellOthers(total: doubleTotal!, symbol: symbol!)
                if(isQuantityEnough){
                        let isFutureDate = Utils.isFutureDate(timestamp: Int(timestamp))
                            if(!isFutureDate){
                                // Sucesso em todos os casos, inserir o others
                                let othersTransaction = OthersTransaction()
                                // In case it is editing to update othersTransaction
                                if(id != 0){
                                    othersTransaction.id = id
                                }
                                othersTransaction.symbol = symbol!
                                othersTransaction.boughtTotal = Double(total!)!
                                othersTransaction.brokerage = 0
                                othersTransaction.timestamp = Int(timestamp)
                                othersTransaction.type = Constants.TypeOp.SELL
                                
                                // Save OthersTransaction
                                let db = OthersTransactionDB()
                                db.save(othersTransaction)
                                db.close()
                                
                                let general = OthersGeneral()
                                _ = general.updateOthersData(symbol!, type: Constants.TypeOp.SELL)
                                _ = Utils.updateOthersPortfolio()
                                
                                // Dismiss current view
                                self.navigationController?.popViewController(animated: true)
                                // Show Alert
                                alert.title = ""
                                alert.message = "Investimento vendido com sucesso"
                                alert.show()
                            } else {
                                // Show Alert
                                alert.message = "Data de venda não pode ser futura a data atual"
                                alert.show()
                            }
                } else {
                    // Show Alert
                    alert.message = "Quantidade deve ter o suficiente desse investimento na carteira"
                    alert.show()
                }
        } else {
            // Show Alert
            alert.message = "Código do investimento inválido"
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
