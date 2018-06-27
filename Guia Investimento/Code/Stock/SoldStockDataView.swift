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
    var stockDatas: Array<StockData> = []
    
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
            cell.quantityLabel.text = "Quantidade: " + String(data.quantity)
            cell.currentLabel.text = "R$" + String(data.currentPrice * Double(data.quantity))
            cell.boughtLabel.text = "R$" + String(data.buyValue)
            cell.variationLabel.text = "R$" + String(data.variation)
            cell.incomeLabel.text = "R$" + String(data.netIncome)
            cell.brokerageLabel.text = "R$" + String(data.brokerage)
            cell.gainLabel.text = "R$" + String(data.totalGain)
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
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
        if(linha < (stockDatas.count)){
            let detailAction = UIAlertAction(title: NSLocalizedString("Mais Detalhes", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                //Add your code
            })
            let buyAction = UIAlertAction(title: NSLocalizedString("Comprar", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                //Add your code
            })
            let sellAction = UIAlertAction(title: NSLocalizedString("Vender", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                //Add your code
            })
            let deleteAction = UIAlertAction(title: NSLocalizedString("Deletar", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                //Add your code
            })
            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancelar", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
            })
            alertController.addAction(detailAction)
            alertController.addAction(buyAction)
            alertController.addAction(sellAction)
            alertController.addAction(deleteAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: false, completion: nil)
        }
    }
    
    // Open form to buy stocks
    @IBAction func buyStock(){
        let buyStockForm = BuyStockForm()
        self.navigationController?.pushViewController(buyStockForm, animated: true)
    }
}
