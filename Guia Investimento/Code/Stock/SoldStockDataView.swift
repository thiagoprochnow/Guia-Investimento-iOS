//
//  StockData.swift
//  Guia Investimento
//
//  Created by Felipe on 01/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
import UIKit

class SoldStockDataView: UIViewController, UITableViewDataSource, UITableViewDelegate{
    @IBOutlet var stockTable: UITableView!
    @IBOutlet var fab: UIImageView!
    var soldStockDatas: Array<SoldStockData> = []
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
        let xib = UINib(nibName: "SoldStockDataCell", bundle: nil)
        self.stockTable.register(xib, forCellReuseIdentifier: "cell")
        
        // Load fab (Floating action button)
        // Set images for each icon
        let fabImg = UIImage(named: "fab")
        fab.image = fabImg
        // Add action to open buy form when tapped
        fab.isUserInteractionEnabled = true
        let tapBuyStock = UITapGestureRecognizer(target: self, action: #selector(SoldStockDataView.buyStock))
        fab.addGestureRecognizer(tapBuyStock)
        
        // Load all Active Stock Datas to show on this list
        let dataDB = SoldStockDataDB()
        soldStockDatas = dataDB.getSoldData()
        if (soldStockDatas.isEmpty){
            self.stockTable.isHidden = true
        } else {
            self.stockTable.isHidden = false
        }
        dataDB.close()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Load all Sold Stock Datas to show on this list
        let dataDB = SoldStockDataDB()
        soldStockDatas = dataDB.getSoldData()
        if (soldStockDatas.isEmpty){
            self.stockTable.isHidden = true
        } else {
            self.stockTable.isHidden = false
        }
        dataDB.close()
        // Reload data every time StockDataView is shown
        self.stockTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (soldStockDatas.isEmpty){
            return 0
        } else {
            // +1 to leave a empty field for Floating Button to scroll
            return soldStockDatas.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let linha = indexPath.row
        let cell = self.stockTable.dequeueReusableCell(withIdentifier: "cell") as! SoldStockDataCell
        // Do not show highlight when selected
        cell.selectionStyle = .none
        
        if(linha < (soldStockDatas.count)){
            // Load each Sold Stock Data information on cell
            let data = soldStockDatas[linha]
            let locale = Locale(identifier: "pt_BR")
            let sellGainPercent = "(" + String(format: "%.2f", locale: locale, arguments: [data.sellGain/data.buyValue * 100]) + "%)"
            cell.symbolLabel.text = data.symbol
            let totalValue = data.mediumPrice * Double(data.quantity)
            cell.quantityLabel.text = "Quantidade: " + String(data.quantity)
            cell.soldLabel.text = Utils.doubleToRealCurrency(value: data.currentTotal)
            cell.boughtLabel.text = Utils.doubleToRealCurrency(value: data.buyValue)
            cell.brokerageLabel.text = Utils.doubleToRealCurrency(value: data.brokerage)
            cell.gainLabel.text = Utils.doubleToRealCurrency(value: data.sellGain)
            cell.gainPercent.text = sellGainPercent
            if(data.sellGain > 0){
                cell.gainLabel.textColor = UIColor(red: 139/255, green: 195/255, blue: 74/255, alpha: 1)
                cell.gainPercent.textColor = UIColor(red: 139/255, green: 195/255, blue: 74/255, alpha: 1)
            } else {
                cell.gainPercent.textColor = UIColor(red: 244/255, green: 67/255, blue: 54/255, alpha: 1)
                cell.gainLabel.textColor = UIColor(red: 244/255, green: 67/255, blue: 54/255, alpha: 1)
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
        let data = soldStockDatas[linha]
        selectedSymbol = data.symbol
        let dataDB = StockDataDB()
        let buyData = dataDB.getDataBySymbol(selectedSymbol)
        mediumBuy = String(buyData.mediumPrice)
        dataDB.close()
        mediumSell = String(data.mediumPrice)
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
        if(linha < (soldStockDatas.count)){
            let detailAction = UIAlertAction(title: NSLocalizedString("Mais Detalhes", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                self.stockDetails()
            })
            let buyAction = UIAlertAction(title: NSLocalizedString("Comprar", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                self.buyStock()
            })
            let sellAction = UIAlertAction(title: NSLocalizedString("Vender", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                //Add your code
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
            alertController.addAction(deleteAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: false, completion: nil)
        }
    }
    
    // Open stock details view
    @IBAction func buyStock(){
        let buyStockForm = BuyStockForm()
        if(selectedSymbol != ""){
            buyStockForm.symbol = selectedSymbol
        }
        self.navigationController?.pushViewController(buyStockForm, animated: true)
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
        soldStockDatas = soldDataDB.getSoldData()
        Utils.updateStockPortfolio()
        dataDB.close()
        transactionDB.close()
        soldDataDB.close()
        incomeDB.close()
    }
    
    // Open form to buy stocks
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
        tabController.navigationItem.backBarButtonItem = backButton
        tabController.navigationItem.backBarButtonItem?.tintColor = UIColor.white
        tabController.viewControllers = [stockDetails, stockIncomes]
        
        self.navigationController?.pushViewController(tabController, animated: true)
    }
}
