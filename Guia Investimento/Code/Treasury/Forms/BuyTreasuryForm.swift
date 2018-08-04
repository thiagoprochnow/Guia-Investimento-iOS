//
//  BuyTreasuryForm.swift
//  Guia Investimento
//
//  Created by Felipe on 13/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
import UIKit

class BuyTreasuryForm: UIViewController, UITextFieldDelegate{
    @IBOutlet var symbolTextField: SearchTextField!
    @IBOutlet var quantityTextField: UITextField!
    @IBOutlet var priceTextField: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    var symbol: String = ""
    var id: Int = 0
    var prealodedTransaction: TreasuryTransaction!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Insert treasury button added on the right side of the bar menu
        let btInsert = UIBarButtonItem(title: "Inserir", style: UIBarButtonItemStyle.plain, target: self, action: #selector(BuyTreasuryForm.insertTreasury))
        self.navigationItem.rightBarButtonItem = btInsert
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        
        // Delegade UITextFieldDelagate to self
        symbolTextField.delegate = self
        quantityTextField.delegate = self
        priceTextField.delegate = self
        quantityTextField.keyboardType = UIKeyboardType.numberPad
        priceTextField.keyboardType = UIKeyboardType.decimalPad
        
        // Insert Autocomplete
        symbolTextField.filterStrings(Constants.Symbols.TREASURY)
        symbolTextField.theme.bgColor = UIColor (red: 1, green: 1, blue: 1, alpha: 1)
        symbolTextField.maxNumberOfResults = 5
        symbolTextField.theme.font = UIFont.systemFont(ofSize: 14)
        
        // Buying a repeated treasury, already shows symbol of the new buy
        if(symbol != ""){
            symbolTextField.text = symbol
        }
        
        // It is a Edit mode, preload inserted information to be edited and saved
        if(id != 0){
            let transactionDB = TreasuryTransactionDB()
            prealodedTransaction = transactionDB.getTransactionById(id)
            symbolTextField.text = prealodedTransaction.symbol
            quantityTextField.text = String(format: "%.0f", prealodedTransaction.quantity)
            priceTextField.text = String(prealodedTransaction.price)
            let date = Date(timeIntervalSince1970: TimeInterval(prealodedTransaction.timestamp))
            datePicker.timeZone = TimeZone(abbreviation: "UTC")
            datePicker.setDate(date, animated: false)
            transactionDB.close()
        }
    }
    
    @IBAction func insertTreasury(){
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
                let isValidPrice = Utils.isValidDouble(text: price!)
                if(isValidPrice){
                    let isFutureDate = Utils.isFutureDate(timestamp: Int(timestamp))
                        if(!isFutureDate){
                            // Sucesso em todos os casos, inserir a treasury
                            let treasuryTransaction = TreasuryTransaction()
                            // In case it is editing to update treasuryTransaction
                            if(id != 0){
                                treasuryTransaction.id = id
                            }
                            treasuryTransaction.symbol = symbol!
                            treasuryTransaction.price = Double(price!)!
                            treasuryTransaction.quantity = Double(quantity!)!

                            treasuryTransaction.timestamp = Int(timestamp)
                            treasuryTransaction.type = Constants.TypeOp.BUY
                            
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
                            alert.message = "Titulo do tesouro comprado com sucesso"
                            alert.show()
                        } else {
                            // Show Alert
                            alert.message = "Data de compra não pode ser futura a data atual"
                            alert.show()
                        }
                    } else {
                    // Show Alert
                    alert.message = "Preço do titulo deve conter apenas números e ponto"
                    alert.show()
                }
            } else {
                // Show Alert
                alert.message = "Quantidade do titulo deve conter apenas números e ponto"
                alert.show()
            }
        } else {
            // Show Alert
            alert.message = "Código do titulo é inválido"
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
