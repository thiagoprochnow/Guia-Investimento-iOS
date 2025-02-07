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
    @IBOutlet var symbolTextField: SearchTextField!
    @IBOutlet var quantityTextField: UITextField!
    @IBOutlet var priceTextField: UITextField!
    @IBOutlet var brokerageTextField: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var scrollView: UIScrollView!
    var symbol: String = ""
    var id: Int = 0
    var prealodedTransaction: StockTransaction!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Insert stock button added on the right side of the bar menu
        let btInsert = UIBarButtonItem(title: "Inserir", style: UIBarButtonItemStyle.plain, target: self, action: #selector(BuyStockForm.insertStock))
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
        
        // Insert Autocomplete
        symbolTextField.filterStrings(Constants.Symbols.STOCKS)
        symbolTextField.theme.bgColor = UIColor (red: 1, green: 1, blue: 1, alpha: 1)
        symbolTextField.maxNumberOfResults = 5
        symbolTextField.theme.font = UIFont.systemFont(ofSize: 14)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // Buying a repeated stock, already shows symbol of the new buy
        if(symbol != ""){
            symbolTextField.text = symbol
        }
        
        // It is a Edit mode, preload inserted information to be edited and saved
        if(id != 0){
            let transactionDB = StockTransactionDB()
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
                            // In case it is editing to update stockTransaction
                            if(id != 0){
                                stockTransaction.id = id
                            }
                            stockTransaction.symbol = symbol!
                            stockTransaction.price = Double(price!)!
                            stockTransaction.quantity = Double(quantity!)!
                            stockTransaction.brokerage = Double(brokerage!)!
                            stockTransaction.timestamp = Int(timestamp)
                            stockTransaction.type = Constants.TypeOp.BUY
                            
                            // Save StockTransaction
                            let db = StockTransactionDB()
                            db.save(stockTransaction)
                            db.close()
                            
                            let general = StockGeneral()
                            general.updateStockIncomes(symbol!, timestamp: Int(timestamp))
                            _ = general.updateStockData(symbol!, type: Constants.TypeOp.BUY)
                            let stockDB = StockDataDB()
                            let stock = stockDB.getDataBySymbol(symbol!)
                            stockDB.close()
                            var updateStocks:Array<StockData> = []
                            updateStocks.append(stock)
                            
                            // Dismiss current view
                            self.navigationController?.popViewController(animated: true)
                            
                            // updateQuote
                            StockService.updateStockQuotes(updateStocks, callback: {(_ stocks:Array<StockData>,error:String) -> Void in
                                let stockDB = StockDataDB()
                                stocks.forEach{ stock in
                                    let currentTotal = Double(stock.quantity) * stock.currentPrice
                                    let variation = currentTotal - stock.buyValue
                                    let totalGain = currentTotal + stock.netIncome - stock.buyValue - stock.brokerage
                                    stock.currentTotal = currentTotal
                                    stock.variation = variation
                                    stock.totalGain = totalGain
                                    stockDB.save(stock)
                                }
                                stockDB.close()
                                Utils.updateStockPortfolio()
                                Utils.updatePortfolio()
                            })
                            
                            // Show Alert
                            alert.title = ""
                            alert.message = "Ação comprada com sucesso"
                            alert.show()
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
