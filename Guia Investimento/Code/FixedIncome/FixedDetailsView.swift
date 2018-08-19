//
//  FixedDetailsView.swift
//  Guia Investimento
//
//  Created by Felipe on 29/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
import UIKit
class FixedDetailsView: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var transactionTable: UITableView!
    @IBOutlet var bgView: UIView!
    @IBOutlet var currentLabel: UILabel!
    @IBOutlet var soldLabel: UILabel!
    @IBOutlet var boughtLabel: UILabel!
    @IBOutlet var gainLabel: UILabel!
    
    var symbol: String = ""
    var current: String = ""
    var sold: String = ""
    var bought: String = ""
    var gain: String = ""
    
    var fixedTransactions: Array<FixedTransaction> = []
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
        if(current != ""){
            self.currentLabel.text = Utils.doubleToRealCurrency(value: Double(current)!)
        } else {
            self.currentLabel.text = ""
        }
        
        if(sold != ""){
            self.soldLabel.text = Utils.doubleToRealCurrency(value: Double(sold)!)
        } else {
            self.soldLabel.text = ""
        }
        
        if(bought != ""){
            self.boughtLabel.text = Utils.doubleToRealCurrency(value: Double(bought)!)
        } else {
            self.boughtLabel.text = ""
        }
        
        if(gain != ""){
            self.gainLabel.text = Utils.doubleToRealCurrency(value: Double(gain)!)
        } else {
            self.gainLabel.text = ""
        }
        
        // Table View
        self.transactionTable.dataSource = self
        self.transactionTable.delegate = self
        self.transactionTable.separatorStyle = .none
        let xib = UINib(nibName: "FixedTransactionCell", bundle: nil)
        self.transactionTable.register(xib, forCellReuseIdentifier: "cell")
        
        // Load Fixed Transactions values
        let transactionDB = FixedTransactionDB()
        fixedTransactions = transactionDB.getTransactionsBySymbol(symbol)
        transactionDB.close()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Load all Fixed Transactions of a symbol to show on this list
        let transactionDB = FixedTransactionDB()
        fixedTransactions = transactionDB.getTransactionsBySymbol(symbol)
        if (fixedTransactions.isEmpty){
            self.transactionTable.isHidden = true
        } else {
            self.transactionTable.isHidden = false
        }
        transactionDB.close()
        // Reload data every time FixedDataView is shown
        self.transactionTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (fixedTransactions.isEmpty){
            return 0
        } else {
            // +1 to leave a empty field for Floating Button to scroll
            return fixedTransactions.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // When a fixed transaction is selected in the table view, it will show menu asking for action
        // Edit, Delete
        let linha = indexPath.row
        let transaction = fixedTransactions[linha]
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
        if(linha < (fixedTransactions.count)){
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
        let cell = self.transactionTable.dequeueReusableCell(withIdentifier: "cell") as! FixedTransactionCell
        // Do not show highlight when selected
        cell.selectionStyle = .none
        
        if(linha < (fixedTransactions.count)){
            // Get Transaction and populat table
            let transaction = fixedTransactions[linha]
            if(transaction.type == Constants.TypeOp.BUY){
                cell.type.text = "Compra"
            } else if (transaction.type == Constants.TypeOp.SELL){
                cell.type.text = "Venda"
            }
            
            //Get Date
            let timestamp = transaction.timestamp
            let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone(identifier: "UTC")
            formatter.dateFormat = "dd/MM/yyyy"
            let dateString = formatter.string(from: date)
            cell.date.text = dateString
            
            cell.total.text = Utils.doubleToRealCurrency(value: transaction.boughtTotal)
        } else {
            cell.isHidden = true
        }
        return cell
    }
    
    func editTransaction(_ transaction: FixedTransaction){
        // Sets id of already existing transaction to be edited in BuyForm
        if(transaction.type == Constants.TypeOp.BUY){
            let buyFixedForm = BuyFixedForm()
            buyFixedForm.symbol = transaction.symbol
            buyFixedForm.id = transaction.id
            self.navigationController?.pushViewController(buyFixedForm, animated: true)
        } else if (transaction.type == Constants.TypeOp.SELL){
            let sellFixedForm = SellFixedForm()
            sellFixedForm.symbol = transaction.symbol
            sellFixedForm.id = transaction.id
            self.navigationController?.pushViewController(sellFixedForm, animated: true)
        }
    }
    
    // Delete Transaction and update FixedData
    func deleteTransaction(_ transaction: FixedTransaction){
        let transactionDB = FixedTransactionDB()
        let fixedGeneral = FixedGeneral()
        
        transactionDB.delete(transaction)
        _ = fixedGeneral.updateFixedData(transaction.symbol, type: Constants.TypeOp.DELETE_TRANSACTION)
        fixedTransactions = transactionDB.getTransactionsBySymbol(symbol)
        transactionDB.close()
        self.transactionTable.reloadData()
        
        // If there is no more buy transaction for this symbol, delete the fixed and finish activity
        if(fixedTransactions.count == 0){
            fixedGeneral.deleteFixed(symbol)
            // Dismiss current view
            self.navigationController?.popViewController(animated: true)
        }
    }
}
