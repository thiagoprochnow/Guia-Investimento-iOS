//
//  TreasuryData.swift
//  Guia Investimento
//
//  Created by Felipe on 01/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
import UIKit

class TreasuryDataView: UIViewController, UITableViewDataSource, UITableViewDelegate{
    @IBOutlet var treasuryTable: UITableView!
    @IBOutlet var fab: UIImageView!
    @IBOutlet var emptyListView: UILabel!
    var treasuryDatas: Array<TreasuryData> = []
    var selectedSymbol: String = ""
    var mediumBuy: String = ""
    var mediumSell: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Background Color
        self.view.backgroundColor = UIColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1)
        
        // Table View
        self.treasuryTable.dataSource = self
        self.treasuryTable.delegate = self
        self.treasuryTable.separatorStyle = .none
        let xib = UINib(nibName: "TreasuryDataCell", bundle: nil)
        self.treasuryTable.register(xib, forCellReuseIdentifier: "cell")
        
        // Load fab (Floating action button)
        // Set images for each icon
        let fabImg = UIImage(named: "fab")
        fab.image = fabImg
        // Add action to open buy form when tapped
        fab.isUserInteractionEnabled = true
        let tapBuyTreasury = UITapGestureRecognizer(target: self, action: #selector(TreasuryDataView.buyTreasury))
        fab.addGestureRecognizer(tapBuyTreasury)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Load all Active Treasury Datas to show on this list
        let dataDB = TreasuryDataDB()
        treasuryDatas = dataDB.getDataByStatus(Constants.Status.ACTIVE)
        var selectedSymbol: String = ""
        var mediumBuy: String = ""
        var mediumSell: String = ""
        if (treasuryDatas.isEmpty){
            self.treasuryTable.isHidden = true
            self.emptyListView.isHidden = false
        } else {
            self.treasuryTable.isHidden = false
            self.emptyListView.isHidden = true
        }
        dataDB.close()
        // Reload data every time TreasuryDataView is shown
        self.treasuryTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (treasuryDatas.isEmpty){
            return 0
        } else {
            // +1 to leave a empty field for Floating Button to scroll
            return treasuryDatas.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let linha = indexPath.row
        let cell = self.treasuryTable.dequeueReusableCell(withIdentifier: "cell") as! TreasuryDataCell
        // Do not show highlight when selected
        cell.selectionStyle = .none
        
        if(linha < (treasuryDatas.count)){
            // Load each Treasury Data information on cell
            let locale = Locale(identifier: "pt_BR")
            let data = treasuryDatas[linha]
            let treasuryAppreciation = data.variation
            let totalIncome = data.netIncome
            let brokerage = data.brokerage
            let totalGain = data.totalGain
            let buyTotal = data.buyValue
            let variationPercent = "(" + String(format: "%.2f", locale: locale, arguments: [treasuryAppreciation/buyTotal * 100]) + "%)"
            let netIncomePercent = "(" + String(format: "%.2f", locale: locale, arguments: [totalIncome/buyTotal * 100]) + "%)"
            let brokeragePercent = "(" + String(format: "%.2f", locale: locale, arguments: [brokerage/buyTotal * 100]) + "%)"
            let totalGainPercent = "(" + String(format: "%.2f", locale: locale, arguments: [totalGain/buyTotal * 100]) + "%)"
            let currentPercent = String(format: "%.2f", locale: locale, arguments: [data.currentPercent]) + "%"
            
            cell.symbolLabel.text = data.symbol
            let quantity = Double(round(data.quantity * 100) / 100)
            let totalValue = data.currentPrice * Double(quantity)
            cell.quantityLabel.text = "Quantidade: " + String(quantity)
            cell.currentLabel.text = Utils.doubleToRealCurrency(value: totalValue)
            cell.boughtLabel.text = Utils.doubleToRealCurrency(value: buyTotal)
            cell.variationLabel.text = Utils.doubleToRealCurrency(value: treasuryAppreciation)
            cell.variationPercent.text = variationPercent
            cell.currentPercent.text = currentPercent
            if(data.variation >= 0){
                cell.variationLabel.textColor = UIColor(red: 139/255, green: 195/255, blue: 74/255, alpha: 1)
                cell.variationPercent.textColor = UIColor(red: 139/255, green: 195/255, blue: 74/255, alpha: 1)
            } else {
                cell.variationLabel.textColor = UIColor(red: 244/255, green: 67/255, blue: 54/255, alpha: 1)
                cell.variationPercent.textColor = UIColor(red: 244/255, green: 67/255, blue: 54/255, alpha: 1)
            }
            cell.incomeLabel.text = Utils.doubleToRealCurrency(value: totalIncome)
            cell.incomeLabel.textColor = UIColor(red: 139/255, green: 195/255, blue: 74/255, alpha: 1)
            cell.incomePercent.text = netIncomePercent
            cell.incomePercent.textColor = UIColor(red: 139/255, green: 195/255, blue: 74/255, alpha: 1)
            cell.brokerageLabel.text = Utils.doubleToRealCurrency(value: brokerage)
            cell.brokerageLabel.textColor = UIColor(red: 244/255, green: 67/255, blue: 54/255, alpha: 1)
            cell.brokeragePercent.text = brokeragePercent
            cell.brokeragePercent.textColor = UIColor(red: 244/255, green: 67/255, blue: 54/255, alpha: 1)
            cell.gainLabel.text = Utils.doubleToRealCurrency(value: totalGain)
            cell.gainPercent.text = totalGainPercent
            if(data.totalGain >= 0){
                cell.gainLabel.textColor = UIColor(red: 139/255, green: 195/255, blue: 74/255, alpha: 1)
                cell.gainPercent.textColor = UIColor(red: 139/255, green: 195/255, blue: 74/255, alpha: 1)
            } else {
                cell.gainLabel.textColor = UIColor(red: 244/255, green: 67/255, blue: 54/255, alpha: 1)
                cell.gainPercent.textColor = UIColor(red: 244/255, green: 67/255, blue: 54/255, alpha: 1)
            }
            if(data.updateStatus == Constants.UpdateStatus.NOT_UPDATED){
                cell.errorIconView.isHidden = false
            } else {
                cell.errorIconView.isHidden = true
                let locale = Locale(identifier: "pt_BR")
            }
            return cell
        } else {
            cell.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // When a treasury is selected in the table view, it will show menu asking for action
        // View details, Buy, Sell, Delete
        let linha = indexPath.row
        let data = treasuryDatas[linha]
        selectedSymbol = data.symbol
        mediumBuy = String(data.mediumPrice)
        let soldDataDB = SoldTreasuryDataDB()
        let soldData = soldDataDB.getDataBySymbol(selectedSymbol)
        soldDataDB.close()
        mediumSell = String(soldData.mediumPrice)
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
        if(linha < (treasuryDatas.count)){
            let detailAction = UIAlertAction(title: NSLocalizedString("Mais Detalhes", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                self.treasuryDetails()
            })
            let buyAction = UIAlertAction(title: NSLocalizedString("Comprar", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                self.buyTreasury()
            })
            let sellAction = UIAlertAction(title: NSLocalizedString("Vender", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                self.sellTreasury()
            })
            let editAction = UIAlertAction(title: NSLocalizedString("Editar Preço", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                self.editTreasury(treasury: data)
            })
            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancelar", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                self.selectedSymbol = ""
                self.mediumBuy = ""
                self.mediumSell = ""
            })
            let deleteAction = UIAlertAction(title: NSLocalizedString("Deletar", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                let deleteAlertController = UIAlertController(title: "Deletar titulo do tesouro da sua carteira?", message: "Se vendeu esse titulo, escolha Vender no menu de opções. Deletar ele irá remover todos os dados sobre ele, inclusive cupons recebidos.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: NSLocalizedString("Deletar", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                    self.deleteData(self.selectedSymbol)
                    self.treasuryTable.reloadData()
                    self.selectedSymbol = ""
                    self.mediumBuy = ""
                    self.mediumSell = ""
                })
                
                deleteAlertController.addAction(cancelAction)
                deleteAlertController.addAction(okAction)
                self.present(deleteAlertController, animated: false, completion: nil)
            })
            alertController.addAction(detailAction)
            alertController.addAction(buyAction)
            alertController.addAction(sellAction)
            if(data.updateStatus != Constants.UpdateStatus.UPDATED){
                alertController.addAction(editAction)
            }
            alertController.addAction(deleteAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: false, completion: nil)
        }
    }
    
    // Open form to buy treasuries
    @IBAction func buyTreasury(){
        let buyTreasuryForm = BuyTreasuryForm()
        if(selectedSymbol != ""){
            buyTreasuryForm.symbol = selectedSymbol
        }
        self.navigationController?.pushViewController(buyTreasuryForm, animated: true)
    }
    
    // Open form to sell treasuries
    @IBAction func sellTreasury(){
        let sellTreasuryForm = SellTreasuryForm()
        if(selectedSymbol != ""){
            sellTreasuryForm.symbol = selectedSymbol
        }
        self.navigationController?.pushViewController(sellTreasuryForm, animated: true)
    }
    
    func editTreasury(treasury:TreasuryData){
        let editTreasuryForm = TreasuryEditPriceForm()
        editTreasuryForm.prealodedData = treasury
        self.navigationController?.pushViewController(editTreasuryForm, animated: true)
    }
    
    // Delete treasury data, all its transactions and incomes
    func deleteData(_ symbol: String){
        let dataDB = TreasuryDataDB()
        let transactionDB = TreasuryTransactionDB()
        let soldDataDB = SoldTreasuryDataDB()
        let incomeDB = TreasuryIncomeDB()
        
        dataDB.deleteBySymbol(symbol)
        transactionDB.deleteBySymbol(symbol)
        soldDataDB.deleteBySymbol(symbol)
        incomeDB.deleteBySymbol(symbol)
        treasuryDatas = dataDB.getDataByStatus(Constants.Status.ACTIVE)
        Utils.updateTreasuryPortfolio()
        dataDB.close()
        transactionDB.close()
        soldDataDB.close()
        incomeDB.close()
    }
    
    // Open treasury details view
    @IBAction func treasuryDetails(){
        let treasuryDetails = TreasuryDetailsView()
        let treasuryIncomes = TreasuryIncomesView()
        let tabController = TabController()

        treasuryDetails.tabBarItem.title = ""
        treasuryDetails.tabBarItem.image =  Utils.makeThumbnailFromText(text: "Operações")
        treasuryIncomes.tabBarItem.title = ""
        treasuryIncomes.tabBarItem.image = Utils.makeThumbnailFromText(text: "Rendimentos")
        
        if(selectedSymbol != ""){
            treasuryDetails.symbol = selectedSymbol
            treasuryDetails.mediumBuy = mediumBuy
            treasuryDetails.mediumSell = mediumSell
            treasuryIncomes.symbol = selectedSymbol
            tabController.title = selectedSymbol
        }
        
        // Create custom Back Button
        let backButton = UIBarButtonItem(title: "Voltar", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        tabController.navigationItem.backBarButtonItem = backButton
        tabController.navigationItem.backBarButtonItem?.tintColor = UIColor.white
        tabController.viewControllers = [treasuryDetails, treasuryIncomes]
        
        self.navigationController?.pushViewController(tabController, animated: true)
    }
}
