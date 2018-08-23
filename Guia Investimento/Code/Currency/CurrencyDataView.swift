//
//  CurrencyData.swift
//  Guia Investimento
//
//  Created by Felipe on 01/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
import UIKit

class CurrencyDataView: UIViewController, UITableViewDataSource, UITableViewDelegate{
    @IBOutlet var currencyTable: UITableView!
    @IBOutlet var fab: UIImageView!
    @IBOutlet var emptyListView: UILabel!
    var currencyDatas: Array<CurrencyData> = []
    var selectedSymbol: String = ""
    var mediumBuy: String = ""
    var mediumSell: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Background Color
        self.view.backgroundColor = UIColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1)
        
        // Table View
        self.currencyTable.dataSource = self
        self.currencyTable.delegate = self
        self.currencyTable.separatorStyle = .none
        let xib = UINib(nibName: "CurrencyDataCell", bundle: nil)
        self.currencyTable.register(xib, forCellReuseIdentifier: "cell")
        
        // Load fab (Floating action button)
        // Set images for each icon
        let fabImg = UIImage(named: "fab")
        fab.image = fabImg
        // Add action to open buy form when tapped
        fab.isUserInteractionEnabled = true
        let tapBuyCurrency = UITapGestureRecognizer(target: self, action: #selector(CurrencyDataView.buyCurrency))
        fab.addGestureRecognizer(tapBuyCurrency)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Load all Active Currency Datas to show on this list
        let dataDB = CurrencyDataDB()
        currencyDatas = dataDB.getDataByStatus(Constants.Status.ACTIVE)
        var selectedSymbol: String = ""
        var mediumBuy: String = ""
        var mediumSell: String = ""
        if (currencyDatas.isEmpty){
            self.currencyTable.isHidden = true
            self.emptyListView.isHidden = false
        } else {
            self.currencyTable.isHidden = false
            self.emptyListView.isHidden = true
        }
        dataDB.close()
        // Reload data every time CurrencyDataView is shown
        self.currencyTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (currencyDatas.isEmpty){
            return 0
        } else {
            // +1 to leave a empty field for Floating Button to scroll
            return currencyDatas.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let linha = indexPath.row
        let cell = self.currencyTable.dequeueReusableCell(withIdentifier: "cell") as! CurrencyDataCell
        // Do not show highlight when selected
        cell.selectionStyle = .none
        
        if(linha < (currencyDatas.count)){
            // Load each Currency Data information on cell
            let locale = Locale(identifier: "pt_BR")
            let data = currencyDatas[linha]
            let totalGain = data.totalGain
            let buyTotal = data.buyValue
            let totalGainPercent = "(" + String(format: "%.2f", locale: locale, arguments: [totalGain/buyTotal * 100]) + "%)"
            let currentPercent = String(format: "%.2f", locale: locale, arguments: [data.currentPercent]) + "%"
            
            cell.symbolLabel.text = Utils.getCurrencyLabel(symbol: data.symbol)
            let totalValue = data.currentPrice * Double(data.quantity)
            cell.quantityLabel.text = "Quantidade: " + String(data.quantity)
            cell.currentLabel.text = Utils.doubleToRealCurrency(value: totalValue)
            cell.boughtLabel.text = Utils.doubleToRealCurrency(value: buyTotal)
            cell.currentPercent.text = currentPercent
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
        // When a currency is selected in the table view, it will show menu asking for action
        // View details, Buy, Sell, Delete
        let linha = indexPath.row
        let data = currencyDatas[linha]
        selectedSymbol = data.symbol
        mediumBuy = String(data.mediumPrice)
        let soldDataDB = SoldCurrencyDataDB()
        let soldData = soldDataDB.getDataBySymbol(selectedSymbol)
        soldDataDB.close()
        mediumSell = String(soldData.mediumPrice)
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
        if(linha < (currencyDatas.count)){
            let detailAction = UIAlertAction(title: NSLocalizedString("Mais Detalhes", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                self.currencyDetails()
            })
            let buyAction = UIAlertAction(title: NSLocalizedString("Comprar", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                self.buyCurrency()
            })
            let sellAction = UIAlertAction(title: NSLocalizedString("Vender", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                self.sellCurrency()
            })
            let editAction = UIAlertAction(title: NSLocalizedString("Editar Preço", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                self.editCurrency(currency: data)
            })
            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancelar", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                self.selectedSymbol = ""
                self.mediumBuy = ""
                self.mediumSell = ""
            })
            let deleteAction = UIAlertAction(title: NSLocalizedString("Deletar", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                let deleteAlertController = UIAlertController(title: "Deletar moeda da sua carteira?", message: "Se vendeu essa moeda, escolha Vender no menu de opções. Deletar essa moeda irá remover todos os dados sobre ela.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: NSLocalizedString("Deletar", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                    self.deleteData(self.selectedSymbol)
                    self.currencyTable.reloadData()
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
    
    // Open form to buy currencies
    @IBAction func buyCurrency(){
        let buyCurrencyForm = BuyCurrencyForm()
        if(selectedSymbol != ""){
            buyCurrencyForm.symbol = selectedSymbol
        }
        self.navigationController?.pushViewController(buyCurrencyForm, animated: true)
    }
    
    // Open form to sell currencies
    @IBAction func sellCurrency(){
        let sellCurrencyForm = SellCurrencyForm()
        if(selectedSymbol != ""){
            sellCurrencyForm.symbol = selectedSymbol
        }
        self.navigationController?.pushViewController(sellCurrencyForm, animated: true)
    }
    
    func editCurrency(currency:CurrencyData){
        let editCurrencyForm = CurrencyEditPriceForm()
        editCurrencyForm.prealodedData = currency
        self.navigationController?.pushViewController(editCurrencyForm, animated: true)
    }
    
    // Delete currency data, all its transactions
    func deleteData(_ symbol: String){
        let dataDB = CurrencyDataDB()
        let transactionDB = CurrencyTransactionDB()
        let soldDataDB = SoldCurrencyDataDB()
        
        dataDB.deleteBySymbol(symbol)
        transactionDB.deleteBySymbol(symbol)
        soldDataDB.deleteBySymbol(symbol)
        currencyDatas = dataDB.getDataByStatus(Constants.Status.ACTIVE)
        Utils.updateCurrencyPortfolio()
        dataDB.close()
        transactionDB.close()
        soldDataDB.close()
    }
    
    // Open currency details view
    @IBAction func currencyDetails(){
        let currencyDetails = CurrencyDetailsView()
        let tabController = TabController()

        currencyDetails.tabBarItem.title = ""
        currencyDetails.tabBarItem.image =  Utils.makeThumbnailFromText(text: "Operações")
        
        if(selectedSymbol != ""){
            currencyDetails.symbol = selectedSymbol
            currencyDetails.mediumBuy = mediumBuy
            currencyDetails.mediumSell = mediumSell
            tabController.title = Utils.getCurrencyLabel(symbol: selectedSymbol)
        }
        
        // Create custom Back Button
        let backButton = UIBarButtonItem(title: "Voltar", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        tabController.navigationItem.backBarButtonItem = backButton
        tabController.navigationItem.backBarButtonItem?.tintColor = UIColor.white
        tabController.viewControllers = [currencyDetails]
        
        self.navigationController?.pushViewController(tabController, animated: true)
    }
}
