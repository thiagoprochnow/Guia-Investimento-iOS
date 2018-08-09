//
//  CurrencyDetailsView.swift
//  Guia Investimento
//
//  Created by Felipe on 29/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
import UIKit
class CurrencyDetailsView: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var transactionTable: UITableView!
    @IBOutlet var bgView: UIView!
    @IBOutlet var mediumSellLabel: UILabel!
    @IBOutlet var mediumBuyLabel: UILabel!
    var symbol: String = ""
    var mediumBuy: String = ""
    var mediumSell: String = ""
    var currencyTransactions: Array<CurrencyTransaction> = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set rounded border and shadow to Details Overview
        bgView.layer.masksToBounds = false
        bgView.layer.cornerRadius = 6
        bgView.layer.shadowColor = UIColor.black.cgColor
        bgView.layer.shadowOpacity = 0.5
        bgView.layer.shadowOffset = CGSize(width: -1, height: 1)
        bgView.layer.shadowRadius = 5
        
        // Overview
        if(mediumBuy != ""){
            self.mediumBuyLabel.text = Utils.doubleToRealCurrency(value: Double(mediumBuy)!)
        } else {
            self.mediumBuyLabel.text = ""
        }
        
        let medium = mediumSell
        if(mediumSell != ""){
            self.mediumSellLabel.text = Utils.doubleToRealCurrency(value: Double(mediumSell)!)
        } else {
            self.mediumSellLabel.text = ""
        }
        
        // Table View
        self.transactionTable.dataSource = self
        self.transactionTable.delegate = self
        self.transactionTable.separatorStyle = .none
        let xib = UINib(nibName: "CurrencyTransactionCell", bundle: nil)
        self.transactionTable.register(xib, forCellReuseIdentifier: "cell")
        
        // Load Currency Transactions values
        let transactionDB = CurrencyTransactionDB()
        currencyTransactions = transactionDB.getTransactionsBySymbol(symbol)
        transactionDB.close()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Load all Currency Transactions of a symbol to show on this list
        let transactionDB = CurrencyTransactionDB()
        currencyTransactions = transactionDB.getTransactionsBySymbol(symbol)
        if (currencyTransactions.isEmpty){
            self.transactionTable.isHidden = true
        } else {
            self.transactionTable.isHidden = false
        }
        transactionDB.close()
        // Reload data every time CurrencyDataView is shown
        self.transactionTable.reloadData()
        updateMediumPrices()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (currencyTransactions.isEmpty){
            return 0
        } else {
            // +1 to leave a empty field for Floating Button to scroll
            return currencyTransactions.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // When a currency transaction is selected in the table view, it will show menu asking for action
        // Edit, Delete
        let linha = indexPath.row
        let transaction = currencyTransactions[linha]
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
        if(linha < (currencyTransactions.count)){
            let editAction = UIAlertAction(title: NSLocalizedString("Editar", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                self.editTransaction(transaction)
            })
            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancelar", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                
            })
            let deleteAction = UIAlertAction(title: NSLocalizedString("Deletar", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                let deleteAlertController = UIAlertController(title: "Deletar essa operação do seu portfolio?", message: "Tem certeza que deseja deletar essa operação do seu portfolio? ", preferredStyle: .alert)
                let okAction = UIAlertAction(title: NSLocalizedString("Deletar", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                        self.deleteTransaction(transaction)
                })
                
                deleteAlertController.addAction(cancelAction)
                deleteAlertController.addAction(okAction)
                self.present(deleteAlertController, animated: false, completion: nil)
                
            })
            alertController.addAction(editAction)
            alertController.addAction(deleteAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: false, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let linha = indexPath.row
        let cell = self.transactionTable.dequeueReusableCell(withIdentifier: "cell") as! CurrencyTransactionCell
        // Do not show highlight when selected
        cell.selectionStyle = .none
        
        if(linha < (currencyTransactions.count)){
            // Get Transaction and populat table
            let transaction = currencyTransactions[linha]
            if(transaction.type == Constants.TypeOp.BUY){
                cell.type.text = "Compra"
            } else if (transaction.type == Constants.TypeOp.SELL){
                cell.type.text = "Venda"
            }
            
            cell.quantity.text = String(transaction.quantity)
            
            //Get Date
            let timestamp = transaction.timestamp
            let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone(identifier: "UTC")
            formatter.dateFormat = "dd/MM/yyyy"
            let dateString = formatter.string(from: date)
            cell.date.text = dateString
            
            cell.price.text = Utils.doubleToRealCurrency(value: transaction.price)
            cell.total.text = Utils.doubleToRealCurrency(value: transaction.price * Double(transaction.quantity))
        } else {
            cell.isHidden = true
        }
        return cell
    }
    
    func editTransaction(_ transaction: CurrencyTransaction){
        // Sets id of already existing transaction to be edited in BuyForm
        if(transaction.type == Constants.TypeOp.BUY){
            let buyCurrencyForm = BuyCurrencyForm()
            buyCurrencyForm.symbol = transaction.symbol
            buyCurrencyForm.id = transaction.id
            self.navigationController?.pushViewController(buyCurrencyForm, animated: true)
        } else if (transaction.type == Constants.TypeOp.SELL){
            let sellCurrencyForm = SellCurrencyForm()
            sellCurrencyForm.symbol = transaction.symbol
            sellCurrencyForm.id = transaction.id
            self.navigationController?.pushViewController(sellCurrencyForm, animated: true)
        }
    }
    
    // Delete Transaction and update CurrencyData
    func deleteTransaction(_ transaction: CurrencyTransaction){
        let transactionDB = CurrencyTransactionDB()
        let currencyGeneral = CurrencyGeneral()
        
        transactionDB.delete(transaction)
        _ = currencyGeneral.updateCurrencyData(transaction.symbol, type: Constants.TypeOp.DELETE_TRANSACTION)
        currencyTransactions = transactionDB.getTransactionsBySymbol(symbol)
        transactionDB.close()
        self.transactionTable.reloadData()
        updateMediumPrices()
        
        // If there is no more buy transaction for this symbol, delete the currency and finish activity
        if(currencyTransactions.count == 0){
            currencyGeneral.deleteCurrency(symbol)
            // Dismiss current view
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // Update medium buy and sell after a change in transactions
    func updateMediumPrices(){
        let dataDB = CurrencyDataDB()
        let currencyData = dataDB.getDataBySymbol(symbol)
        dataDB.close()
        let soldDataDB = SoldCurrencyDataDB()
        let soldData = soldDataDB.getDataBySymbol(symbol)
        soldDataDB.close()
        self.mediumSellLabel.text = Utils.doubleToRealCurrency(value: soldData.mediumPrice)
        self.mediumBuyLabel.text = Utils.doubleToRealCurrency(value: currencyData.mediumPrice)
    }
    
}
