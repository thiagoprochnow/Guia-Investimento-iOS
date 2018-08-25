//
//  BuyFixedForm.swift
//  Guia Investimento
//
//  Created by Felipe on 13/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
import UIKit

class BuyFixedForm: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource{
    @IBOutlet var symbolTextField: SearchTextField!
    @IBOutlet var gainRateLabel: UILabel!
    @IBOutlet var gainRateTextField: UITextField!
    @IBOutlet var indexPicker: UIPickerView!
    @IBOutlet var totalTextField: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    
    var indexes = ["CDI", "IPCA", "Pré Fixado"]
    
    var symbol: String = ""
    var row: Int = 0
    var id: Int = 0
    var prealodedTransaction: FixedTransaction!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Insert fixed button added on the right side of the bar menu
        let btInsert = UIBarButtonItem(title: "Inserir", style: UIBarButtonItemStyle.plain, target: self, action: #selector(BuyFixedForm.insertFixed))
        self.navigationItem.rightBarButtonItem = btInsert
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        
        // Delegade UITextFieldDelagate to self
        symbolTextField.delegate = self
        gainRateTextField.delegate = self
        totalTextField.delegate = self
        indexPicker.delegate = self
        indexPicker.dataSource = self
        totalTextField.keyboardType = UIKeyboardType.decimalPad
        gainRateTextField.keyboardType = UIKeyboardType.decimalPad
        datePicker.timeZone = TimeZone(abbreviation: "UTC")
        
        // Buying a repeated fixed, already shows symbol of the new buy
        if(symbol != ""){
            symbolTextField.text = symbol
        }
        
        // It is a Edit mode, preload inserted information to be edited and saved
        if(id != 0){
            let transactionDB = FixedTransactionDB()
            prealodedTransaction = transactionDB.getTransactionById(id)
            symbolTextField.text = prealodedTransaction.symbol
            totalTextField.text = String(prealodedTransaction.boughtTotal)
            gainRateTextField.text = String(prealodedTransaction.gainRate * 100)
            if(prealodedTransaction.gainType == Constants.FixedType.CDI){
                indexPicker.selectRow(0, inComponent: 0, animated: false)
                self.row = 0
            } else if (prealodedTransaction.gainType == Constants.FixedType.IPCA){
                indexPicker.selectRow(1, inComponent: 0, animated: false)
                self.row = 1
            } else {
                indexPicker.selectRow(2, inComponent: 0, animated: false)
                self.row = 2
            }
            
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
        return indexes.count
    }
    
    // This function sets the text of the picker view to the content of the "salutations" array
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return indexes[row]
    }
    
    // When user selects an option, this function will set the text of the text field to reflect
    // the selected option.
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.row = row
        if(row == 0){
            // CDI
            gainRateLabel.text = "Total de Ganho (%CDI)"
            gainRateTextField.placeholder = "Ex: 110"
        } else if (row == 1){
            // IPCA
            gainRateLabel.text = "Total de Ganho (IPCA + %)"
            gainRateTextField.placeholder = "Ex: 6.33"
        } else {
            // PRE
            gainRateLabel.text = "Total de Ganho (% Pré Fixada)"
            gainRateTextField.placeholder = "Ex: 10.54"
        }
    }
    
    @IBAction func insertFixed(){
        let symbol = symbolTextField.text
        let boughtTotal = totalTextField.text
        let gainRate = gainRateTextField.text
        
        // Get selected date as 00:00
        let date = datePicker.date
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "UTC")!
        let startOfDay = calendar.startOfDay(for: date)
        let timestamp = startOfDay.timeIntervalSince1970
        
        // Create alert saying the fixed information is invalid
        let alert = UIAlertView()
        alert.title = "Campo Inválido"
        alert.delegate = self
        alert.addButton(withTitle: "OK")
        
        // Check if inserted values are valid, if all are valid, insert the new fixed
        let isValidSymbol = Utils.isValidFixedSymbol(symbol: symbol!)
        if(isValidSymbol){
            let isValidTotal = Utils.isValidDouble(text: boughtTotal!)
            if(isValidTotal){
                let isValidGainRate = Utils.isValidDouble(text: gainRate!)
                if(isValidGainRate){
                    let isFutureDate = Utils.isFutureDate(timestamp: Int(timestamp))
                        if(!isFutureDate){
                            // Sucesso em todos os casos, inserir a fixed
                            let fixedTransaction = FixedTransaction()
                            // In case it is editing to update fixedTransaction
                            if(id != 0){
                                fixedTransaction.id = id
                            }
                            fixedTransaction.symbol = symbol!
                            fixedTransaction.boughtTotal = Double(boughtTotal!)!
                            fixedTransaction.gainRate = Double(gainRate!)!/100
                            
                            if(row == 0){
                                // CDI
                                fixedTransaction.gainType = Constants.FixedType.CDI
                            } else if(row == 1){
                                // IPCA
                                fixedTransaction.gainType = Constants.FixedType.IPCA
                            } else {
                                // Pré
                                fixedTransaction.gainType = Constants.FixedType.PRE
                            }
                            
                            fixedTransaction.timestamp = Int(timestamp)
                            fixedTransaction.type = Constants.TypeOp.BUY
                            
                            // Save FixedTransaction
                            let db = FixedTransactionDB()
                            db.save(fixedTransaction)
                            db.close()
                            
                            let general = FixedGeneral()
                            _ = general.updateFixedData(symbol!, type: Constants.TypeOp.BUY)
                            _ = Utils.updateFixedPortfolio()
                            
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
                    alert.message = "Taxa de ganho deve conter apenas números e ponto"
                    alert.show()
                }
            } else {
                // Show Alert
                alert.message = "Quantidade de renda fixa deve conter apenas números e ponto"
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
        gainRateTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField == symbolTextField){
            totalTextField.becomeFirstResponder()
        } else if (textField == totalTextField){
            gainRateTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}
