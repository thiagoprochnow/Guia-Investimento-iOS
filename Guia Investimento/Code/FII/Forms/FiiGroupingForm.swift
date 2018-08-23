//
//  FiiGroupingForm.swift
//  Guia Investimento
//
//  Created by Felipe on 13/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
import UIKit
class FiiGroupingForm: UIViewController, UITextFieldDelegate{
    @IBOutlet var quantityField: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    var symbol: String = ""
    var transactionType: Int = Constants.TypeOp.GROUPING
    var id: Int = 0
    var prealodedTransaction: FiiTransaction!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add Dividend button added on the right side of the bar menu
        let btInsert = UIBarButtonItem(title: "Inserir", style: UIBarButtonItemStyle.plain, target: self, action: #selector(FiiGroupingForm.insertGrouping))
        self.navigationItem.rightBarButtonItem = btInsert
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        
        // Delegade UITextFieldDelagate to self
        quantityField.delegate = self
        quantityField.keyboardType = UIKeyboardType.decimalPad
        datePicker.timeZone = TimeZone(abbreviation: "UTC")
        
        // It is a Edit mode, preload inserted information to be edited and saved
        if(id != 0){
            let transactionDB = FiiTransactionDB()
            prealodedTransaction = transactionDB.getTransactionById(id)
            quantityField.text = String(prealodedTransaction.quantity)
            let date = Date(timeIntervalSince1970: TimeInterval(prealodedTransaction.timestamp))
            datePicker.setDate(date, animated: false)
            transactionType = prealodedTransaction.type
            transactionDB.close()
        }
    }
    
    @IBAction func insertGrouping(){
        let quantity = quantityField.text
        
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
        let isValidQuantity = Utils.isValidDouble(text: quantity!)
        if(isValidQuantity){
            // Sucesso em todos os casos, inserir o provento
            let fiiTransaction = FiiTransaction()
            // In case it is editing to update fiiTransaction
            if(id != 0){
                fiiTransaction.id = id
            }
            fiiTransaction.symbol = symbol
            fiiTransaction.quantity = Double(quantity!)!
            fiiTransaction.price = 0.0
            fiiTransaction.timestamp = Int(timestamp)
            fiiTransaction.type = Constants.TypeOp.GROUPING
                            
            // Save FiiTransaction
            let db = FiiTransactionDB()
            db.save(fiiTransaction)
            db.close()
            
            let general = FiiGeneral()
            general.updateFiiIncomes(symbol, timestamp: Int(timestamp))
            general.updateFiiData(symbol, type: Constants.TypeOp.GROUPING)
            
            // Dismiss current view
            self.navigationController?.popViewController(animated: true)
            // Show Alert
            alert.title = ""
            alert.message = "Grupamento inserido com sucesso"
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
