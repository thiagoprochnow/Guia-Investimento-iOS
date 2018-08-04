//
//  TreasuryDetailsView.swift
//  Guia Investimento
//
//  Created by Felipe on 29/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
import UIKit
class TreasuryDetailsView: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var transactionTable: UITableView!
    @IBOutlet var bgView: UIView!
    @IBOutlet var mediumSellLabel: UILabel!
    @IBOutlet var mediumBuyLabel: UILabel!
    @IBOutlet var fab: UIImageView!
    var symbol: String = ""
    var mediumBuy: String = ""
    var mediumSell: String = ""
    var treasuryTransactions: Array<TreasuryTransaction> = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set rounded border and shadow to Details Overview
        bgView.layer.masksToBounds = false
        bgView.layer.cornerRadius = 6
        bgView.layer.shadowColor = UIColor.black.cgColor
        bgView.layer.shadowOpacity = 0.5
        bgView.layer.shadowOffset = CGSize(width: -1, height: 1)
        bgView.layer.shadowRadius = 5
        
        // Load fab (Floating action button)
        // Set images for each icon
        let fabImg = UIImage(named: "fab")
        fab.image = fabImg
        // Add action to open buy form when tapped
        fab.isUserInteractionEnabled = true
        let tapBuyTreasury = UITapGestureRecognizer(target: self, action: #selector(TreasuryDetailsView.incomeMenu))
        fab.addGestureRecognizer(tapBuyTreasury)
        
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
        let xib = UINib(nibName: "TreasuryTransactionCell", bundle: nil)
        self.transactionTable.register(xib, forCellReuseIdentifier: "cell")
        
        // Load Treasury Transactions values
        let transactionDB = TreasuryTransactionDB()
        treasuryTransactions = transactionDB.getTransactionsBySymbol(symbol)
        transactionDB.close()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Load all Treasury Transactions of a symbol to show on this list
        let transactionDB = TreasuryTransactionDB()
        treasuryTransactions = transactionDB.getTransactionsBySymbol(symbol)
        if (treasuryTransactions.isEmpty){
            self.transactionTable.isHidden = true
        } else {
            self.transactionTable.isHidden = false
        }
        transactionDB.close()
        // Reload data every time TreasuryDataView is shown
        self.transactionTable.reloadData()
        updateMediumPrices()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (treasuryTransactions.isEmpty){
            return 0
        } else {
            // +1 to leave a empty field for Floating Button to scroll
            return treasuryTransactions.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // When a treasury transaction is selected in the table view, it will show menu asking for action
        // Edit, Delete
        let linha = indexPath.row
        let transaction = treasuryTransactions[linha]
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
        if(linha < (treasuryTransactions.count)){
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
        let cell = self.transactionTable.dequeueReusableCell(withIdentifier: "cell") as! TreasuryTransactionCell
        // Do not show highlight when selected
        cell.selectionStyle = .none
        
        if(linha < (treasuryTransactions.count)){
            // Get Transaction and populat table
            let transaction = treasuryTransactions[linha]
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
    
    func editTransaction(_ transaction: TreasuryTransaction){
        // Sets id of already existing transaction to be edited in BuyForm
        if(transaction.type == Constants.TypeOp.BUY){
            let buyTreasuryForm = BuyTreasuryForm()
            buyTreasuryForm.symbol = transaction.symbol
            buyTreasuryForm.id = transaction.id
            self.navigationController?.pushViewController(buyTreasuryForm, animated: true)
        } else if (transaction.type == Constants.TypeOp.SELL){
            let sellTreasuryForm = SellTreasuryForm()
            sellTreasuryForm.symbol = transaction.symbol
            sellTreasuryForm.id = transaction.id
            self.navigationController?.pushViewController(sellTreasuryForm, animated: true)
        }
    }
    
    // Delete Transaction and update TreasuryData
    func deleteTransaction(_ transaction: TreasuryTransaction){
        let transactionDB = TreasuryTransactionDB()
        let treasuryGeneral = TreasuryGeneral()
        
        transactionDB.delete(transaction)
        _ = treasuryGeneral.updateTreasuryData(transaction.symbol, type: Constants.TypeOp.DELETE_TRANSACTION)
        treasuryTransactions = transactionDB.getTransactionsBySymbol(symbol)
        transactionDB.close()
        self.transactionTable.reloadData()
        updateMediumPrices()
        
        // If there is no more buy transaction for this symbol, delete the treasury and finish activity
        if(treasuryTransactions.count == 0){
            treasuryGeneral.deleteTreasury(symbol)
            // Dismiss current view
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // Update medium buy and sell after a change in transactions
    func updateMediumPrices(){
        let dataDB = TreasuryDataDB()
        let treasuryData = dataDB.getDataBySymbol(symbol)
        dataDB.close()
        let soldDataDB = SoldTreasuryDataDB()
        let soldData = soldDataDB.getDataBySymbol(symbol)
        soldDataDB.close()
        self.mediumSellLabel.text = Utils.doubleToRealCurrency(value: soldData.mediumPrice)
        self.mediumBuyLabel.text = Utils.doubleToRealCurrency(value: treasuryData.mediumPrice)
    }
    
    //Shows alert yo choose income type
    @IBAction func incomeMenu(){
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
        let dividendAction = UIAlertAction(title: NSLocalizedString("Cupom Semestral", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                self.addIncome(Constants.IncomeType.TREASURY)
            })
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancelar", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in

        })

        alertController.addAction(dividendAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: false, completion: nil)
    }
    
    func addIncome(_ type: Int){
        switch (type) {
        case Constants.IncomeType.TREASURY:
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
