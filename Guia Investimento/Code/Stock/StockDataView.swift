//
//  StockData.swift
//  Guia Investimento
//
//  Created by Felipe on 01/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
import UIKit

class StockDataView: UIViewController, UITableViewDataSource, UITableViewDelegate{
    @IBOutlet var stockTable: UITableView!
    @IBOutlet var fab: UIImageView!
    @IBOutlet var emptyListView: UILabel!
    var stockDatas: Array<StockData> = []
    var selectedSymbol: String = ""
    var mediumBuy: String = ""
    var mediumSell: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Background Color
        self.view.backgroundColor = UIColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1)
        
        // Table View
        self.stockTable.dataSource = self
        self.stockTable.delegate = self
        self.stockTable.separatorStyle = .none
        let xib = UINib(nibName: "StockDataCell", bundle: nil)
        self.stockTable.register(xib, forCellReuseIdentifier: "cell")
        
        // Load fab (Floating action button)
        // Set images for each icon
        let fabImg = UIImage(named: "fab")
        fab.image = fabImg
        // Add action to open buy form when tapped
        fab.isUserInteractionEnabled = true
        let tapBuyStock = UITapGestureRecognizer(target: self, action: #selector(StockDataView.buyStock))
        fab.addGestureRecognizer(tapBuyStock)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Load all Active Stock Datas to show on this list
        let dataDB = StockDataDB()
        stockDatas = dataDB.getDataByStatus(Constants.Status.ACTIVE)
        self.selectedSymbol = ""
        self.mediumBuy = ""
        self.mediumSell = ""
        if (stockDatas.isEmpty){
            self.stockTable.isHidden = true
            self.emptyListView.isHidden = false
        } else {
            self.stockTable.isHidden = false
            self.emptyListView.isHidden = true
        }
        dataDB.close()
        // Reload data every time StockDataView is shown
        self.stockTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (stockDatas.isEmpty){
            return 0
        } else {
            // +1 to leave a empty field for Floating Button to scroll
            return stockDatas.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let linha = indexPath.row
        let cell = self.stockTable.dequeueReusableCell(withIdentifier: "cell") as! StockDataCell
        // Do not show highlight when selected
        cell.selectionStyle = .none
        
        if(linha < (stockDatas.count)){
            // Load each Stock Data information on cell
            let locale = Locale(identifier: "pt_BR")
            let data = stockDatas[linha]
            let stockAppreciation = data.variation
            let totalIncome = data.netIncome
            let brokerage = data.brokerage
            let totalGain = data.totalGain
            let buyTotal = data.buyValue
            let variationPercent = "(" + String(format: "%.2f", locale: locale, arguments: [stockAppreciation/buyTotal * 100]) + "%)"
            let netIncomePercent = "(" + String(format: "%.2f", locale: locale, arguments: [totalIncome/buyTotal * 100]) + "%)"
            let brokeragePercent = "(" + String(format: "%.2f", locale: locale, arguments: [brokerage/buyTotal * 100]) + "%)"
            let totalGainPercent = "(" + String(format: "%.2f", locale: locale, arguments: [totalGain/buyTotal * 100]) + "%)"
            let currentPercent = String(format: "%.2f", locale: locale, arguments: [data.currentPercent]) + "%"
            
            cell.symbolLabel.text = data.symbol
            let totalValue = data.currentPrice * Double(data.quantity)
            cell.quantityLabel.text = "Quantidade: " + String(data.quantity)
            cell.currentLabel.text = Utils.doubleToRealCurrency(value: totalValue)
            cell.boughtLabel.text = Utils.doubleToRealCurrency(value: buyTotal)
            cell.variationLabel.text = Utils.doubleToRealCurrency(value: stockAppreciation)
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
                cell.currentPriceLabel.isHidden = true
            } else {
                cell.errorIconView.isHidden = true
                cell.currentPriceLabel.isHidden = false
                let locale = Locale(identifier: "pt_BR")
                let dailyGain = (data.currentPrice - data.closingPrice)/data.closingPrice * 100
                let currentPrice = Utils.doubleToRealCurrency(value: data.currentPrice) + "(" + String(format: "%.2f", locale: locale, arguments: [dailyGain]) + ")"
                cell.currentPriceLabel.text = currentPrice
                
                // Set color depending on value
                if(dailyGain >= 0){
                    cell.currentPriceLabel.textColor = UIColor(red: 139/255, green: 195/255, blue: 74/255, alpha: 1)
                } else {
                    cell.currentPriceLabel.textColor = UIColor(red: 253/255, green: 143/255, blue: 134/255, alpha: 1)
                }
            }
            return cell
        } else {
            cell.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // When a stock is selected in the table view, it will show menu asking for action
        // View details, Buy, Sell, Delete
        let linha = indexPath.row
        let data = stockDatas[linha]
        selectedSymbol = data.symbol
        mediumBuy = String(data.mediumPrice)
        let soldDataDB = SoldStockDataDB()
        let soldData = soldDataDB.getDataBySymbol(selectedSymbol)
        soldDataDB.close()
        mediumSell = String(soldData.mediumPrice)
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
        if(linha < (stockDatas.count)){
            let detailAction = UIAlertAction(title: NSLocalizedString("Mais Detalhes", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                self.stockDetails()
            })
            let buyAction = UIAlertAction(title: NSLocalizedString("Comprar", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                self.buyStock()
            })
            let sellAction = UIAlertAction(title: NSLocalizedString("Vender", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                self.sellStock()
            })
            let editAction = UIAlertAction(title: NSLocalizedString("Editar Preço", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                self.editStock(stock: data)
            })
            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancelar", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                self.selectedSymbol = ""
                self.mediumBuy = ""
                self.mediumSell = ""
            })
            let deleteAction = UIAlertAction(title: NSLocalizedString("Deletar", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                let deleteAlertController = UIAlertController(title: "Deletar ação da sua carteira?", message: "Se vendeu a ação, escolha Vender no menu de opções. Deletar essa ação irá remover todos os dados sobre ela, inclusive proventos recebidos.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: NSLocalizedString("Deletar", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                    self.deleteData(self.selectedSymbol)
                    self.stockTable.reloadData()
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
    
    // Open form to buy stocks
    @IBAction func buyStock(){
        let buyStockForm = BuyStockForm()
        if(selectedSymbol != ""){
            buyStockForm.symbol = selectedSymbol
        }
        self.navigationController?.pushViewController(buyStockForm, animated: true)
    }
    
    // Open form to sell stocks
    @IBAction func sellStock(){
        let sellStockForm = SellStockForm()
        if(selectedSymbol != ""){
            sellStockForm.symbol = selectedSymbol
        }
        self.navigationController?.pushViewController(sellStockForm, animated: true)
    }
    
    func editStock(stock:StockData){
        let editStockForm = StockEditPriceForm()
        editStockForm.prealodedData = stock
        self.navigationController?.pushViewController(editStockForm, animated: true)
    }
    
    // Delete stock data, all its transactions and incomes
    func deleteData(_ symbol: String){
        let dataDB = StockDataDB()
        let transactionDB = StockTransactionDB()
        let soldDataDB = SoldStockDataDB()
        let incomeDB = StockIncomeDB()
        
        dataDB.deleteBySymbol(symbol)
        transactionDB.deleteBySymbol(symbol)
        soldDataDB.deleteBySymbol(symbol)
        incomeDB.deleteBySymbol(symbol)
        stockDatas = dataDB.getDataByStatus(Constants.Status.ACTIVE)
        Utils.updateStockPortfolio()
        dataDB.close()
        transactionDB.close()
        soldDataDB.close()
        incomeDB.close()
    }
    
    // Open stock details view
    @IBAction func stockDetails(){
        let stockDetails = StockDetailsView()
        let stockIncomes = StockIncomesView()
        let tabController = TabController()

        stockDetails.tabBarItem.title = ""
        stockDetails.tabBarItem.image =  Utils.makeThumbnailFromText(text: "Operações")
        stockIncomes.tabBarItem.title = ""
        stockIncomes.tabBarItem.image = Utils.makeThumbnailFromText(text: "Rendimentos")
        
        if(selectedSymbol != ""){
            stockDetails.symbol = selectedSymbol
            stockDetails.mediumBuy = mediumBuy
            stockDetails.mediumSell = mediumSell
            stockIncomes.symbol = selectedSymbol
            tabController.title = selectedSymbol
        }
        
        // Create custom Back Button
        let backButton = UIBarButtonItem(title: "Voltar", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        let font = UIFont.init(name: "Arial", size: 14)
        backButton.setTitleTextAttributes([NSAttributedStringKey.font: font], for: .normal)
        tabController.navigationItem.backBarButtonItem = backButton
        tabController.navigationItem.backBarButtonItem?.tintColor = UIColor.white
        tabController.viewControllers = [stockDetails, stockIncomes]
        
        self.navigationController?.pushViewController(tabController, animated: true)
    }
}
