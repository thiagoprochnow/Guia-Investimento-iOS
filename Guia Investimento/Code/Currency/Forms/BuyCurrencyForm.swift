//
//  BuyCurrencyForm.swift
//  Guia Investimento
//
//  Created by Felipe on 13/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
import UIKit

class BuyCurrencyForm: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource{
    @IBOutlet var symbolTextField: UIPickerView!
    @IBOutlet var quantityTextField: UITextField!
    @IBOutlet var priceTextField: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var scrollView: UIScrollView!
    var symbol: String = "USD"
    var id: Int = 0
    var prealodedTransaction: CurrencyTransaction!
    let symbolKeys = ["USD","EUR","BTC","LTC","ETH"]
    let symbolValues = ["Dolar","Euro","Bitcoin","Litecoin","Etherium"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Insert currency button added on the right side of the bar menu
        let btInsert = UIBarButtonItem(title: "Inserir", style: UIBarButtonItemStyle.plain, target: self, action: #selector(BuyCurrencyForm.insertCurrency))
        let font = UIFont.init(name: "Arial", size: 14)
        btInsert.setTitleTextAttributes([NSAttributedStringKey.font: font], for: .normal)
        self.navigationItem.rightBarButtonItem = btInsert
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        
        // Delegade UITextFieldDelagate to self
        quantityTextField.delegate = self
        priceTextField.delegate = self
        symbolTextField.delegate = self
        symbolTextField.dataSource = self
        quantityTextField.keyboardType = UIKeyboardType.numbersAndPunctuation
        priceTextField.keyboardType = UIKeyboardType.numbersAndPunctuation
        datePicker.timeZone = TimeZone(abbreviation: "UTC")
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // Buying a repeated currency, already shows symbol of the new buy
        if(symbol != ""){
            let row = Utils.getCurrencyPickerIndex(symbol: symbol)
            symbolTextField.selectRow(row, inComponent: 0, animated: false)
        }
        
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
    
    @IBAction func insertCurrency(){
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
                let isValidPrice = Utils.isValidDouble(text: price!)
                if(isValidPrice){
                    let isFutureDate = Utils.isFutureDate(timestamp: Int(timestamp))
                        if(!isFutureDate){
                            // Sucesso em todos os casos, inserir a currency
                            let currencyTransaction = CurrencyTransaction()
                            // In case it is editing to update currencyTransaction
                            if(id != 0){
                                currencyTransaction.id = id
                            }
                            currencyTransaction.symbol = symbol
                            currencyTransaction.price = Double(price!)!
                            currencyTransaction.quantity = Double(quantity!)!

                            currencyTransaction.timestamp = Int(timestamp)
                            currencyTransaction.type = Constants.TypeOp.BUY
                            
                            // Save CurrencyTransaction
                            let db = CurrencyTransactionDB()
                            db.save(currencyTransaction)
                            db.close()
                            
                            let general = CurrencyGeneral()
                            _ = general.updateCurrencyData(symbol, type: Constants.TypeOp.BUY)
                            
                            let currencyDB = CurrencyDataDB()
                            let currency = currencyDB.getDataBySymbol(symbol)
                            currencyDB.close()
                            var updateCurrencies:Array<CurrencyData> = []
                            updateCurrencies.append(currency)
                            
                            // Update Quote
                            CurrencyService.updateCurrencyQuotes(updateCurrencies, callback: {(_ currencies:Array<CurrencyData>,error:String) -> Void in
                                let currencyDB = CurrencyDataDB()
                                currencies.forEach{ currency in
                                    let currentTotal = currency.quantity * currency.currentPrice
                                    let variation = currentTotal - currency.buyValue
                                    let totalGain = currentTotal - currency.buyValue
                                    currency.currentTotal = currentTotal
                                    currency.variation = variation
                                    currency.totalGain = totalGain
                                    currencyDB.save(currency)
                                }
                                currencyDB.close()
                                Utils.updateCurrencyPortfolio()
                                Utils.updatePortfolio()
                            })
                            
                            // Dismiss current view
                            self.navigationController?.popViewController(animated: true)
                            // Show Alert
                            alert.title = ""
                            alert.message = "Moeda comprada com sucesso"
                            alert.show()
                        } else {
                            // Show Alert
                            alert.message = "Data de compra não pode ser futura a data atual"
                            alert.show()
                        }
                    } else {
                    // Show Alert
                    alert.message = "Preço da moeda deve conter apenas números e ponto"
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
    
    @objc func keyboardWillShow(notification:NSNotification){
        //give room at the bottom of the scroll view, so it doesn't cover up anything the user needs to tap
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset = contentInset
    }
    
    @objc func keyboardWillHide(notification:NSNotification){
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
}
