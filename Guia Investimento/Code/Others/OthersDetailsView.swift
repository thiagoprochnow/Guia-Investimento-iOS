//
//  OthersDetailsView.swift
//  Guia Investimento
//
//  Created by Felipe on 29/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
import UIKit
class OthersDetailsView: UIViewController, UITableViewDataSource, UITableViewDelegate {
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
    
    var othersTransactions: Array<OthersTransaction> = []
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
        let xib = UINib(nibName: "OthersTransactionCell", bundle: nil)
        self.transactionTable.register(xib, forCellReuseIdentifier: "cell")
        
        // Load Others Transactions values
        let transactionDB = OthersTransactionDB()
        othersTransactions = transactionDB.getTransactionsBySymbol(symbol)
        transactionDB.close()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Load all Others Transactions of a symbol to show on this list
        let transactionDB = OthersTransactionDB()
        othersTransactions = transactionDB.getTransactionsBySymbol(symbol)
        if (othersTransactions.isEmpty){
            self.transactionTable.isHidden = true
        } else {
            self.transactionTable.isHidden = false
        }
        transactionDB.close()
        // Reload data every time OthersDataView is shown
        self.transactionTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (othersTransactions.isEmpty){
            return 0
        } else {
            // +1 to leave a empty field for Floating Button to scroll
            return othersTransactions.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // When a others transaction is selected in the table view, it will show menu asking for action
        // Edit, Delete
        let linha = indexPath.row
        let transaction = othersTransactions[linha]
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
        if(linha < (othersTransactions.count)){
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
        let cell = self.transactionTable.dequeueReusableCell(withIdentifier: "cell") as! OthersTransactionCell
        // Do not show highlight when selected
        cell.selectionStyle = .none
        
        if(linha < (othersTransactions.count)){
            // Get Transaction and populat table
            let transaction = othersTransactions[linha]
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
    
    func editTransaction(_ transaction: OthersTransaction){
        // Sets id of already existing transaction to be edited in BuyForm
        if(transaction.type == Constants.TypeOp.BUY){
            let buyOthersForm = BuyOthersForm()
            buyOthersForm.symbol = transaction.symbol
            buyOthersForm.id = transaction.id
            self.navigationController?.pushViewController(buyOthersForm, animated: true)
        } else if (transaction.type == Constants.TypeOp.SELL){
            let sellOthersForm = SellOthersForm()
            sellOthersForm.symbol = transaction.symbol
            sellOthersForm.id = transaction.id
            self.navigationController?.pushViewController(sellOthersForm, animated: true)
        }
    }
    
    // Delete Transaction and update OthersData
    func deleteTransaction(_ transaction: OthersTransaction){
        let transactionDB = OthersTransactionDB()
        let othersGeneral = OthersGeneral()
        
        transactionDB.delete(transaction)
        _ = othersGeneral.updateOthersData(transaction.symbol, type: Constants.TypeOp.DELETE_TRANSACTION)
        othersTransactions = transactionDB.getTransactionsBySymbol(symbol)
        transactionDB.close()
        self.transactionTable.reloadData()
        
        // If there is no more buy transaction for this symbol, delete the others and finish activity
        if(othersTransactions.count == 0){
            othersGeneral.deleteOthers(symbol)
            // Dismiss current view
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    //Shows alert yo choose income type
    @IBAction func incomeMenu(){
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
        let dividendAction = UIAlertAction(title: NSLocalizedString("Rendimento", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
            self.addIncome(Constants.IncomeType.OTHERS)
        })
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancelar", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
            
        })
        
        alertController.addAction(dividendAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: false, completion: nil)
    }
    
    func addIncome(_ type: Int){
        switch (type) {
        case Constants.IncomeType.OTHERS:
            let dividendForm = TreasuryDividendForm()
            dividendForm.symbol = symbol
            dividendForm.incomeType = type
            self.navigationController?.pushViewController(dividendForm, animated: true)
            break
        default:
            break
        }
    }
}
