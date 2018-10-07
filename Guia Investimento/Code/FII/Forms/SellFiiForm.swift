//
//  SellFiiForm.swift
//  Guia Investimento
//
//  Created by Felipe on 13/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
import UIKit
class SellFiiForm: UIViewController, UITextFieldDelegate{
    @IBOutlet var symbolTextField: UITextField!
    @IBOutlet var quantityTextField: UITextField!
    @IBOutlet var priceTextField: UITextField!
    @IBOutlet var brokerageTextField: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var scrollView: UIScrollView!
    var symbol: String = ""
    var id: Int = 0
    var prealodedTransaction: FiiTransaction!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Insert fii button added on the right side of the bar menu
        let btInsert = UIBarButtonItem(title: "Vender", style: UIBarButtonItemStyle.plain, target: self, action: #selector(SellFiiForm.sellFii))
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
        priceTextField.keyboardType = UIKeyboardType.numbersAndPunctuation
        brokerageTextField.keyboardType = UIKeyboardType.numbersAndPunctuation
        datePicker.timeZone = TimeZone(abbreviation: "UTC")
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // Always selling a already bougth fii
        symbolTextField.text = symbol
        
        // It is a Edit mode, preload inserted information to be edited and saved
        if(id != 0){
            let transactionDB = FiiTransactionDB()
            prealodedTransaction = transactionDB.getTransactionById(id)
            symbolTextField.text = prealodedTransaction.symbol
            quantityTextField.text = String(format: "%.0f",prealodedTransaction.quantity)
            priceTextField.text = String(prealodedTransaction.price)
            brokerageTextField.text = String(prealodedTransaction.brokerage)
            let date = Date(timeIntervalSince1970: TimeInterval(prealodedTransaction.timestamp))
            datePicker.setDate(date, animated: false)
            transactionDB.close()
        }
    }
    
    @IBAction func sellFii(){
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
                let isQuantityEnough = Utils.isValidSellFii(quantity: Int(quantity!)!, symbol: symbol!)
                if(isQuantityEnough){
                let isValidPrice = Utils.isValidDouble(text: price!)
                    if(isValidPrice){
                        let isValidBrokerage = Utils.isValidDouble(text: brokerage!)
                        if(isValidBrokerage){
                            let isFutureDate = Utils.isFutureDate(timestamp: Int(timestamp))
                            if(!isFutureDate){
                                // Sucesso em todos os casos, inserir o fii
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
                                fiiTransaction.type = Constants.TypeOp.SELL
                                
                                // Save FiiTransaction
                                let db = FiiTransactionDB()
                                db.save(fiiTransaction)
                                db.close()
                                
                                let general = FiiGeneral()
                                general.updateFiiIncomes(symbol!, timestamp: Int(timestamp))
                                _ = general.updateFiiData(symbol!, type: Constants.TypeOp.SELL)
                                Utils.updateFiiPortfolio()
                                
                                // Dismiss current view
                                self.navigationController?.popViewController(animated: true)
                                // Show Alert
                                alert.title = ""
                                alert.message = "Fundo Imobiliário vendido com sucesso"
                                alert.show()
                            } else {
                                // Show Alert
                                alert.message = "Data de venda não pode ser futura a data atual"
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
                    alert.message = "Quantidade deve ter o suficiente desse fundo imobiliário na carteira"
                    alert.show()
                }
            } else {
                // Show Alert
                alert.message = "Quantidade do fundo imobiliário deve conter apenas números"
                alert.show()
            }
        } else {
            // Show Alert
            alert.message = "Código do Fundo Imobiliário inválido"
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
