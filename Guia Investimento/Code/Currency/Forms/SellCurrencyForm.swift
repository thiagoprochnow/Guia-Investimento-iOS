//
//  SellCurrencyForm.swift
//  Guia Investimento
//
//  Created by Felipe on 13/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
import UIKit
class SellCurrencyForm: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource{
    @IBOutlet var symbolTextField: UIPickerView!
    @IBOutlet var quantityTextField: UITextField!
    @IBOutlet var priceTextField: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    let symbolKeys = ["USD","EUR","BTC","LTC"]
    let symbolValues = ["Dolar","Euro","Bitcoin","Litecoin"]
    var symbol: String = "USD"
    var id: Int = 0
    var prealodedTransaction: CurrencyTransaction!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Insert currency button added on the right side of the bar menu
        let btInsert = UIBarButtonItem(title: "Vender", style: UIBarButtonItemStyle.plain, target: self, action: #selector(SellCurrencyForm.sellCurrency))
        let font = UIFont.init(name: "Arial", size: 14)
        btInsert.setTitleTextAttributes([NSAttributedStringKey.font: font], for: .normal)
        self.navigationItem.rightBarButtonItem = btInsert
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        
        // Delegade UITextFieldDelagate to self
        quantityTextField.delegate = self
        priceTextField.delegate = self
        symbolTextField.delegate = self
        symbolTextField.dataSource = self
        quantityTextField.keyboardType = UIKeyboardType.numberPad
        priceTextField.keyboardType = UIKeyboardType.decimalPad
        datePicker.timeZone = TimeZone(abbreviation: "UTC")
        
        // Always selling a already bougth currency
        let row = Utils.getCurrencyPickerIndex(symbol: symbol)
        symbolTextField.selectRow(row, inComponent: 0, animated: false)
        
        // It is a Edit mode, preload inserted information to be edited and saved
        if(id != 0){
            let transactionDB = CurrencyTransactionDB()
            prealodedTransaction = transactionDB.getTransactionById(id)
            let row = Utils.getCurrencyPickerIndex(symbol: prealodedTransaction.symbol)
            symbolTextField.selectRow(row, inComponent: 0, animated: false)
            quantityTextField.text = String(prealodedTransaction.quantity)
            priceTextField.text = String(prealodedTransaction.price)
            let date = Date(timeIntervalSince1970: TimeInterval(prealodedTransaction.timestamp))
            datePicker.setDate(date, animated: false)
            transactionDB.close()
        }
    }
    
    // Sets number of columns in picker view
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // Sets the number of rows in the picker view
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return symbolKeys.count
    }
    
    // This function sets the text of the picker view to the content of the "salutations" array
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return symbolValues[row]
    }
    
    // When user selects an option, this function will set the text of the text field to reflect
    // the selected option.
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        symbol = symbolKeys[row]
    }
    
    @IBAction func sellCurrency(){
        let price = priceTextField.text
        let quantity = quantityTextField.text
        
        // Get selected date as 00:00
        let date = datePicker.date
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "UTC")!
        let startOfDay = calendar.startOfDay(for: date)
        let timestamp = startOfDay.timeIntervalSince1970
        
        // Create alert saying the currency information is invalid
        let alert = UIAlertView()
        alert.title = "Campo Inválido"
        alert.delegate = self
        alert.addButton(withTitle: "OK")
        
        // Check if inserted values are valid, if all are valid, insert the new currency
        let isValidQuantity = Utils.isValidDouble(text: quantity!)
            if(isValidQuantity){
                let doubleQuantity = Double(quantity!)
                let isQuantityEnough = Utils.isValidSellCurrency(quantity: doubleQuantity!, symbol: symbol)
                if(isQuantityEnough){
                let isValidPrice = Utils.isValidDouble(text: price!)
                    if(isValidPrice){
                        let isFutureDate = Utils.isFutureDate(timestamp: Int(timestamp))
                            if(!isFutureDate){
                                // Sucesso em todos os casos, inserir o currency
                                let currencyTransaction = CurrencyTransaction()
                                // In case it is editing to update currencyTransaction
                                if(id != 0){
                                    currencyTransaction.id = id
                                }
                                currencyTransaction.symbol = symbol
                                currencyTransaction.price = Double(price!)!
                                currencyTransaction.quantity = Double(quantity!)!
                                currencyTransaction.brokerage = 0
                                currencyTransaction.timestamp = Int(timestamp)
                                currencyTransaction.type = Constants.TypeOp.SELL
                                
                                // Save CurrencyTransaction
                                let db = CurrencyTransactionDB()
                                db.save(currencyTransaction)
                                db.close()
                                
                                let general = CurrencyGeneral()
                                _ = general.updateCurrencyData(symbol, type: Constants.TypeOp.SELL)
                                
                                // Dismiss current view
                                self.navigationController?.popViewController(animated: true)
                                // Show Alert
                                alert.title = ""
                                alert.message = "Moeda vendido com sucesso"
                                alert.show()
                            } else {
                                // Show Alert
                                alert.message = "Data de venda não pode ser futura a data atual"
                                alert.show()
                            }
                        } else {
                        // Show Alert
                        alert.message = "Preço da moeda deve conter apenas números e ponto"
                        alert.show()
                    }
                } else {
                    // Show Alert
                    alert.message = "Quantidade deve ter o suficiente dessa moeda na carteira"
                    alert.show()
                }
            } else {
                // Show Alert
                alert.message = "Quantidade da moeda deve conter apenas números e ponto"
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
