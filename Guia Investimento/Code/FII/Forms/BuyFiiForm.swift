//
//  BuyFiiForm.swift
//  Guia Investimento
//
//  Created by Felipe on 13/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
import UIKit

class BuyFiiForm: UIViewController, UITextFieldDelegate{
    @IBOutlet var symbolTextField: SearchTextField!
    @IBOutlet var quantityTextField: UITextField!
    @IBOutlet var priceTextField: UITextField!
    @IBOutlet var brokerageTextField: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    var symbol: String = ""
    var id: Int = 0
    var prealodedTransaction: FiiTransaction!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Insert fii button added on the right side of the bar menu
        let btInsert = UIBarButtonItem(title: "Inserir", style: UIBarButtonItemStyle.plain, target: self, action: #selector(BuyFiiForm.insertFii))
        let font = UIFont.init(name: "Arial", size: 14)
        btInsert.setTitleTextAttributes([NSAttributedStringKey.font: font], for: .normal)
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
        
        // Insert Autocomplete
        symbolTextField.filterStrings(Constants.Symbols.FII)
        symbolTextField.theme.bgColor = UIColor (red: 1, green: 1, blue: 1, alpha: 1)
        symbolTextField.maxNumberOfResults = 5
        symbolTextField.theme.font = UIFont.systemFont(ofSize: 14)
        datePicker.timeZone = TimeZone(abbreviation: "UTC")
        
        // Buying a repeated fii, already shows symbol of the new buy
        if(symbol != ""){
            symbolTextField.text = symbol
        }
        
        // It is a Edit mode, preload inserted information to be edited and saved
        if(id != 0){
            let transactionDB = FiiTransactionDB()
            prealodedTransaction = transactionDB.getTransactionById(id)
            symbolTextField.text = prealodedTransaction.symbol
            quantityTextField.text = String(format: "%.0f", prealodedTransaction.quantity)
            priceTextField.text = String(prealodedTransaction.price)
            brokerageTextField.text = String(prealodedTransaction.brokerage)
            let date = Date(timeIntervalSince1970: TimeInterval(prealodedTransaction.timestamp))
            datePicker.setDate(date, animated: false)
            transactionDB.close()
        }
    }
    
    @IBAction func insertFii(){
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
        
        // Create alert saying the fii information is invalid
        let alert = UIAlertView()
        alert.title = "Campo Inválido"
        alert.delegate = self
        alert.addButton(withTitle: "OK")
        
        // Check if inserted values are valid, if all are valid, insert the new fii
        let isValidSymbol = Utils.isValidFiiSymbol(symbol: symbol!)
        if(isValidSymbol){
            let isValidQuantity = Utils.isValidInt(text: quantity!)
            if(isValidQuantity){
                let isValidPrice = Utils.isValidDouble(text: price!)
                if(isValidPrice){
                    let isValidBrokerage = Utils.isValidDouble(text: brokerage!)
                    if(isValidBrokerage){
                        let isFutureDate = Utils.isFutureDate(timestamp: Int(timestamp))
                        if(!isFutureDate){
                            // Sucesso em todos os casos, inserir a fii
                            let fiiTransaction = FiiTransaction()
                            // In case it is editing to update fiiTransaction
                            if(id != 0){
                                fiiTransaction.id = id
                            }
                            fiiTransaction.symbol = symbol!
                            fiiTransaction.price = Double(price!)!
                            fiiTransaction.quantity = Double(quantity!)!
                            fiiTransaction.brokerage = Double(brokerage!)!
                            fiiTransaction.timestamp = Int(timestamp)
                            fiiTransaction.type = Constants.TypeOp.BUY
                            
                            // Save FiiTransaction
                            let db = FiiTransactionDB()
                            db.save(fiiTransaction)
                            db.close()
                            
                            let general = FiiGeneral()
                            general.updateFiiIncomes(symbol!, timestamp: Int(timestamp))
                            _ = general.updateFiiData(symbol!, type: Constants.TypeOp.BUY)
                            
                            let fiiDB = FiiDataDB()
                            let fii = fiiDB.getDataBySymbol(symbol!)
                            fiiDB.close()
                            var updateFiis:Array<FiiData> = []
                            updateFiis.append(fii)
                            
                            // FII
                            FiiService.updateFiiQuotes(updateFiis, callback: {(_ fiis:Array<FiiData>,error:Bool) -> Void in
                                // Fii
                                let fiiDB = FiiDataDB()
                                fiis.forEach{ fii in
                                    let currentTotal = Double(fii.quantity) * fii.currentPrice
                                    let variation = currentTotal - fii.buyValue
                                    let totalGain = currentTotal + fii.netIncome - fii.buyValue - fii.brokerage
                                    fii.currentTotal = currentTotal
                                    fii.variation = variation
                                    fii.totalGain = totalGain
                                    fiiDB.save(fii)
                                }
                                fiiDB.close()
                                Utils.updateFiiPortfolio()
                                Utils.updatePortfolio()
                            })
                            
                            // Dismiss current view
                            self.navigationController?.popViewController(animated: true)
                            // Show Alert
                            alert.title = ""
                            alert.message = "Fundo imobiliário comprado com sucesso"
                            alert.show()
                        } else {
                            // Show Alert
                            alert.message = "Data de compra não pode ser futura a data atual"
                            alert.show()
                        }
                    } else {
                        // Show Alert
                        alert.message = "Corretagem do fundo imobiliário deve conter apenas números e ponto"
                        alert.show()
                    }
                } else {
                    // Show Alert
                    alert.message = "Preço do fundo imobiliário deve conter apenas números e ponto"
                    alert.show()
                }
            } else {
                // Show Alert
                alert.message = "Quantidade de fundo imobiliário deve conter apenas números"
                alert.show()
            }
        } else {
            // Show Alert
            alert.message = "Código do fundo imobiliário inválido"
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
