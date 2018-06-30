//
//  StockDetailsView.swift
//  Guia Investimento
//
//  Created by Felipe on 29/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
import UIKit
class StockDetailsView: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var transactionTable: UITableView!
    @IBOutlet var bgView: UIView!
    @IBOutlet var mediumSellLabel: UILabel!
    @IBOutlet var mediumBuyLabel: UILabel!
    var symbol: String = ""
    var mediumBuy: String = ""
    var mediumSell: String = ""
    var stockTransactions: Array<StockTransaction> = []
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
        self.mediumBuyLabel.text = "R$" + mediumBuy
        self.mediumSellLabel.text = "R$" + mediumSell
        
        // Table View
        self.transactionTable.dataSource = self
        self.transactionTable.delegate = self
        self.transactionTable.separatorStyle = .none
        let xib = UINib(nibName: "StockTransactionCell", bundle: nil)
        self.transactionTable.register(xib, forCellReuseIdentifier: "cell")
        
        // Load Stock Transactions values
        let transactionDB = StockTransactionDB()
        stockTransactions = transactionDB.getTransactionsBySymbol(symbol)
        transactionDB.close()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Load all Stock Transactions of a symbol to show on this list
        let transactionDB = StockTransactionDB()
        stockTransactions = transactionDB.getTransactionsBySymbol(symbol)
        if (stockTransactions.isEmpty){
            self.transactionTable.isHidden = true
        } else {
            self.transactionTable.isHidden = false
        }
        transactionDB.close()
        // Reload data every time StockDataView is shown
        self.transactionTable.reloadData()
        updateMediumPrices()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (stockTransactions.isEmpty){
            return 0
        } else {
            // +1 to leave a empty field for Floating Button to scroll
            return stockTransactions.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // When a stock transaction is selected in the table view, it will show menu asking for action
        // Edit, Delete
        let linha = indexPath.row
        let transaction = stockTransactions[linha]
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
        if(linha < (stockTransactions.count)){
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
        let cell = self.transactionTable.dequeueReusableCell(withIdentifier: "cell") as! StockTransactionCell
        // Do not show highlight when selected
        cell.selectionStyle = .none
        
        if(linha < (stockTransactions.count)){
            // Get Transaction and populat table
            let transaction = stockTransactions[linha]
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
            formatter.dateFormat = "dd/MM/yyyy"
            let dateString = formatter.string(from: date)
            cell.date.text = dateString
            
            cell.price.text = "R$" + String(transaction.price)
            cell.total.text = "R$" + String(transaction.price * Double(transaction.quantity))
        } else {
            cell.isHidden = true
        }
        return cell
    }
    
    func editTransaction(_ transaction: StockTransaction){
        // Sets id of already existing transaction to be edited in BuyForm
        let buyStockForm = BuyStockForm()
        buyStockForm.symbol = transaction.symbol
        buyStockForm.id = transaction.id
        self.navigationController?.pushViewController(buyStockForm, animated: true)
    }
    
    // Delete Transaction and update StockData
    func deleteTransaction(_ transaction: StockTransaction){
        let transactionDB = StockTransactionDB()
        let stockGeneral = StockGeneral()
        
        transactionDB.delete(transaction)
        _ = stockGeneral.updateStockData(transaction.symbol, type: Constants.TypeOp.DELETE_TRANSACTION)
        stockTransactions = transactionDB.getTransactionsBySymbol(symbol)
        transactionDB.close()
        self.transactionTable.reloadData()
        updateMediumPrices()
    }
    
    // Update medium buy and sell after a change in transactions
    func updateMediumPrices(){
        let dataDB = StockDataDB()
        let stockData = dataDB.getDataBySymbol(symbol)
        dataDB.close()
        self.mediumSellLabel.text = "R$"
        self.mediumBuyLabel.text = "R$" + String(stockData.mediumPrice)
    }
}
