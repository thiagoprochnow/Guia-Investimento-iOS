//
//  SellTreasuryForm.swift
//  Guia Investimento
//
//  Created by Felipe on 13/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
import UIKit
class SellTreasuryForm: UIViewController, UITextFieldDelegate{
    @IBOutlet var symbolTextField: UITextField!
    @IBOutlet var quantityTextField: UITextField!
    @IBOutlet var priceTextField: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    var symbol: String = ""
    var id: Int = 0
    var prealodedTransaction: TreasuryTransaction!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Insert treasury button added on the right side of the bar menu
        let btInsert = UIBarButtonItem(title: "Vender", style: UIBarButtonItemStyle.plain, target: self, action: #selector(SellTreasuryForm.sellTreasury))
        self.navigationItem.rightBarButtonItem = btInsert
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        
        // Delegade UITextFieldDelagate to self
        symbolTextField.delegate = self
        quantityTextField.delegate = self
        priceTextField.delegate = self
        quantityTextField.keyboardType = UIKeyboardType.numberPad
        priceTextField.keyboardType = UIKeyboardType.decimalPad
        
        // Always selling a already bougth treasury
        symbolTextField.text = symbol
        
        // It is a Edit mode, preload inserted information to be edited and saved
        if(id != 0){
            let transactionDB = TreasuryTransactionDB()
            prealodedTransaction = transactionDB.getTransactionById(id)
            symbolTextField.text = prealodedTransaction.symbol
            quantityTextField.text = String(format: "%.0f",prealodedTransaction.quantity)
            priceTextField.text = String(prealodedTransaction.price)
            let date = Date(timeIntervalSince1970: TimeInterval(prealodedTransaction.timestamp))
            datePicker.timeZone = TimeZone(abbreviation: "UTC")
            datePicker.setDate(date, animated: false)
            transactionDB.close()
        }
    }
    
    @IBAction func sellTreasury(){
        let symbol = symbolTextField.text
        let price = priceTextField.text
        let quantity = quantityTextField.text
        
        // Get selected date as 00:00
        let date = datePicker.date
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "UTC")!
        let startOfDay = calendar.startOfDay(for: date)
        let timestamp = startOfDay.timeIntervalSince1970
        
        // Create alert saying the treasury information is invalid
        let alert = UIAlertView()
        alert.title = "Campo Inválido"
        alert.delegate = self
        alert.addButton(withTitle: "OK")
        
        // Check if inserted values are valid, if all are valid, insert the new treasury
        let isValidSymbol = Utils.isValidTreasurySymbol(symbol: symbol!)
        if(isValidSymbol){
            let isValidQuantity = Utils.isValidDouble(text: quantity!)
            if(isValidQuantity){
                let doubleQuantity = Double(quantity!)
                let isQuantityEnough = Utils.isValidSellTreasury(quantity: doubleQuantity!, symbol: symbol!)
                if(isQuantityEnough){
                let isValidPrice = Utils.isValidDouble(text: price!)
                    if(isValidPrice){
                        let isFutureDate = Utils.isFutureDate(timestamp: Int(timestamp))
                            if(!isFutureDate){
                                // Sucesso em todos os casos, inserir o treasury
                                let treasuryTransaction = TreasuryTransaction()
                                // In case it is editing to update treasuryTransaction
                                if(id != 0){
                                    treasuryTransaction.id = id
                                }
                                treasuryTransaction.symbol = symbol!
                                treasuryTransaction.price = Double(price!)!
                                treasuryTransaction.quantity = Double(quantity!)!
                                treasuryTransaction.brokerage = 0
                                treasuryTransaction.timestamp = Int(timestamp)
                                treasuryTransaction.type = Constants.TypeOp.SELL
                                
                                // Save TreasuryTransaction
                                let db = TreasuryTransactionDB()
                                db.save(treasuryTransaction)
                                db.close()
                                
                                let general = TreasuryGeneral()
                                _ = general.updateTreasuryData(symbol!, type: Constants.TypeOp.BUY)
                                
                                // Dismiss current view
                                self.navigationController?.popViewController(animated: true)
                                // Show Alert
                                alert.title = ""
                                alert.message = "Titulo do tesouro vendido com sucesso"
                                alert.show()
                            } else {
                                // Show Alert
                                alert.message = "Data de venda não pode ser futura a data atual"
                                alert.show()
                            }
                        } else {
                        // Show Alert
                        alert.message = "Preço do titulo deve conter apenas números e ponto"
                        alert.show()
                    }
                } else {
                    // Show Alert
                    alert.message = "Quantidade deve ter o suficiente desse titulo na carteira"
                    alert.show()
                }
            } else {
                // Show Alert
                alert.message = "Quantidade do titulo deve conter apenas números e ponto"
                alert.show()
            }
        } else {
            // Show Alert
            alert.message = "Código do titulo do tesouro inválido"
            alert.show()
        }
    }
    
    // Gives first responder back to view and closes keyboard when clicking outside of text field
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        symbolTextField.resignFirstResponder()
        quantityTextField.resignFirstResponder()
        priceTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField == symbolTextField){
            quantityTextField.becomeFirstResponder()
        } else if (textField == quantityTextField){
            priceTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}
