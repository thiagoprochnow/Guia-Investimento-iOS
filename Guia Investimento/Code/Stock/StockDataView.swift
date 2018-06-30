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
        
        // Load all Active Stock Datas to show on this list
        let dataDB = StockDataDB()
        stockDatas = dataDB.getDataByStatus(Constants.Status.ACTIVE)
        if (stockDatas.isEmpty){
            self.stockTable.isHidden = true
        } else {
            self.stockTable.isHidden = false
        }
        dataDB.close()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Load all Active Stock Datas to show on this list
        let dataDB = StockDataDB()
        stockDatas = dataDB.getDataByStatus(Constants.Status.ACTIVE)
        if (stockDatas.isEmpty){
            self.stockTable.isHidden = true
        } else {
            self.stockTable.isHidden = false
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
            let data = stockDatas[linha]
            cell.symbolLabel.text = data.symbol
            let totalValue = data.currentPrice * Double(data.quantity)
            cell.quantityLabel.text = "Quantidade: " + String(data.quantity)
            cell.currentLabel.text = Utils.doubleToRealCurrency(value: totalValue)
            cell.boughtLabel.text = Utils.doubleToRealCurrency(value: data.buyValue)
            cell.variationLabel.text = Utils.doubleToRealCurrency(value: data.variation)
            cell.incomeLabel.text = Utils.doubleToRealCurrency(value: data.netIncome)
            cell.brokerageLabel.text = Utils.doubleToRealCurrency(value: data.brokerage)
            cell.gainLabel.text = Utils.doubleToRealCurrency(value: data.totalGain)
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
        mediumSell = ""
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
        if(linha < (stockDatas.count)){
            let detailAction = UIAlertAction(title: NSLocalizedString("Mais Detalhes", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                self.stockDetails()
            })
            let buyAction = UIAlertAction(title: NSLocalizedString("Comprar", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                self.buyStock()
            })
            let sellAction = UIAlertAction(title: NSLocalizedString("Vender", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                //Add your code
            })
            let deleteAction = UIAlertAction(title: NSLocalizedString("Deletar", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                //Add your code
            })
            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancelar", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                self.selectedSymbol = ""
                self.mediumBuy = ""
                self.mediumSell = ""
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
