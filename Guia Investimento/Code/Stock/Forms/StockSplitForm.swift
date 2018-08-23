//
//  BuyStockForm.swift
//  Guia Investimento
//
//  Created by Felipe on 13/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
import UIKit
class StockSplitForm: UIViewController, UITextFieldDelegate{
    @IBOutlet var quantityField: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    var symbol: String = ""
    var transactionType: Int = Constants.TypeOp.SPLIT
    var id: Int = 0
    var prealodedTransaction: StockTransaction!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add Dividend button added on the right side of the bar menu
        let btInsert = UIBarButtonItem(title: "Inserir", style: UIBarButtonItemStyle.plain, target: self, action: #selector(StockSplitForm.insertSplit))
        self.navigationItem.rightBarButtonItem = btInsert
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        datePicker.timeZone = TimeZone(abbreviation: "UTC")
        
        // Delegade UITextFieldDelagate to self
        quantityField.delegate = self
        quantityField.keyboardType = UIKeyboardType.decimalPad
        
        // It is a Edit mode, preload inserted information to be edited and saved
        if(id != 0){
            let transactionDB = StockTransactionDB()
            prealodedTransaction = transactionDB.getTransactionById(id)
            quantityField.text = String(prealodedTransaction.quantity)
            let date = Date(timeIntervalSince1970: TimeInterval(prealodedTransaction.timestamp))
            datePicker.setDate(date, animated: false)
            transactionType = prealodedTransaction.type
            transactionDB.close()
        }
    }
    
    @IBAction func insertSplit(){
        let quantity = quantityField.text
        
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
        let isValidQuantity = Utils.isValidDouble(text: quantity!)
        if(isValidQuantity){
            // Sucesso em todos os casos, inserir o provento
            let stockTransaction = StockTransaction()
            // In case it is editing to update stockTransaction
            if(id != 0){
                stockTransaction.id = id
            }
            stockTransaction.symbol = symbol
            stockTransaction.quantity = Double(quantity!)!
            stockTransaction.price = 0.0
            stockTransaction.timestamp = Int(timestamp)
            stockTransaction.type = Constants.TypeOp.SPLIT
                            
            // Save StockTransaction
            let db = StockTransactionDB()
            db.save(stockTransaction)
            db.close()
            
            let general = StockGeneral()
            general.updateStockIncomes(symbol, timestamp: Int(timestamp))
            general.updateStockData(symbol, type: Constants.TypeOp.SPLIT)
            
            // Dismiss current view
            self.navigationController?.popViewController(animated: true)
            // Show Alert
            alert.title = ""
            alert.message = "Desdobramento inserido com sucesso"
            alert.show()
        } else {
            // Show Alert
            alert.message = "Quantidade deve ser apenas numeros"
            alert.show()
        }
    }
    
    // Gives first responder back to view and closes keyboard when clicking outside of text field
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        quantityField.resignFirstResponder()
    }
}
