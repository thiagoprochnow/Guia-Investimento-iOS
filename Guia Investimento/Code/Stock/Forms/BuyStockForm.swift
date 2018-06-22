//
//  BuyStockForm.swift
//  Guia Investimento
//
//  Created by Felipe on 13/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
import UIKit
class BuyStockForm: UIViewController, UITextFieldDelegate{
    @IBOutlet var symbolTextField: UITextField!
    @IBOutlet var quantityTextField: UITextField!
    @IBOutlet var priceTextField: UITextField!
    @IBOutlet var brokerageTextField: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Insert stock button added on the right side of the bar menu
        let btInsert = UIBarButtonItem(title: "Inserir", style: UIBarButtonItemStyle.plain, target: self, action: #selector(BuyStockForm.insertStock))
        self.navigationItem.rightBarButtonItem = btInsert
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        
        // Delegade UITextFieldDelagate to self
        symbolTextField.delegate = self
        quantityTextField.delegate = self
        priceTextField.delegate = self
        brokerageTextField.delegate = self
        symbolTextField.autocapitalizationType = UITextAutocapitalizationType.allCharacters
        quantityTextField.keyboardType = UIKeyboardType.numberPad
        priceTextField.keyboardType = UIKeyboardType.decimalPad
        brokerageTextField.keyboardType = UIKeyboardType.decimalPad
    }
    
    @IBAction func insertStock(){
        let symbol = symbolTextField.text
        let price = priceTextField.text
        let quantity = quantityTextField.text
        let brokerage = brokerageTextField.text
        
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
        let isValidSymbol = Utils.isValidStockSymbol(symbol: symbol!)
        if(isValidSymbol){
            let isValidQuantity = Utils.isValidInt(text: quantity!)
            if(isValidQuantity){
                let isValidPrice = Utils.isValidDouble(text: price!)
                if(isValidPrice){
                    let isValidBrokerage = Utils.isValidDouble(text: brokerage!)
                    if(isValidBrokerage){
                        let isFutureDate = Utils.isFutureDate(timestamp: Int(timestamp))
                        if(!isFutureDate){
                            // Sucesso em todos os casos, inserir a ação
                            let stockTransaction = StockTransaction()
                            stockTransaction.symbol = symbol!
                            stockTransaction.price = Double(price!)!
                            stockTransaction.quantity = Int(quantity!)!
                            stockTransaction.brokerage = Double(brokerage!)!
                            stockTransaction.timestamp = Int(timestamp)
                            
                            // Dismiss current view
                            self.navigationController?.popViewController(animated: true)
                        } else {
                            // Show Alert
                            alert.message = "Data de compra não pode ser futura a data atual"
                            alert.show()
                        }
                    } else {
                        // Show Alert
                        alert.message = "Corretagem da ação deve conter apenas números e ponto"
                        alert.show()
                    }
                } else {
                    // Show Alert
                    alert.message = "Preço da ação deve conter apenas números e ponto"
                    alert.show()
                }
            } else {
                // Show Alert
                alert.message = "Quantidade da ação deve conter apenas números"
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
        symbolTextField.resignFirstResponder()
        quantityTextField.resignFirstResponder()
        priceTextField.resignFirstResponder()
        brokerageTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField == symbolTextField){
            quantityTextField.becomeFirstResponder()
        } else if (textField == quantityTextField){
            priceTextField.becomeFirstResponder()
        } else if (textField == priceTextField){
            brokerageTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}
