//
//  FiiData.swift
//  Guia Investimento
//
//  Created by Felipe on 01/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
import UIKit

class FiiDataView: UIViewController, UITableViewDataSource, UITableViewDelegate{
    @IBOutlet var fiiTable: UITableView!
    @IBOutlet var fab: UIImageView!
    @IBOutlet var emptyListView: UILabel!
    var fiiDatas: Array<FiiData> = []
    var selectedSymbol: String = ""
    var mediumBuy: String = ""
    var mediumSell: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Background Color
        self.view.backgroundColor = UIColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1)
        
        // Table View
        self.fiiTable.dataSource = self
        self.fiiTable.delegate = self
        self.fiiTable.separatorStyle = .none
        let xib = UINib(nibName: "FiiDataCell", bundle: nil)
        self.fiiTable.register(xib, forCellReuseIdentifier: "cell")
        
        // Load fab (Floating action button)
        // Set images for each icon
        let fabImg = UIImage(named: "fab")
        fab.image = fabImg
        // Add action to open buy form when tapped
        fab.isUserInteractionEnabled = true
        let tapBuyFii = UITapGestureRecognizer(target: self, action: #selector(FiiDataView.buyFii))
        fab.addGestureRecognizer(tapBuyFii)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Load all Active Fii Datas to show on this list
        let dataDB = FiiDataDB()
        fiiDatas = dataDB.getDataByStatus(Constants.Status.ACTIVE)
        if (fiiDatas.isEmpty){
            self.fiiTable.isHidden = true
            self.emptyListView.isHidden = false
        } else {
            self.fiiTable.isHidden = false
            self.emptyListView.isHidden = true
        }
        dataDB.close()
        // Reload data every time FiiDataView is shown
        self.fiiTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (fiiDatas.isEmpty){
            return 0
        } else {
            // +1 to leave a empty field for Floating Button to scroll
            return fiiDatas.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let linha = indexPath.row
        let cell = self.fiiTable.dequeueReusableCell(withIdentifier: "cell") as! FiiDataCell
        // Do not show highlight when selected
        cell.selectionStyle = .none
        
        if(linha < (fiiDatas.count)){
            // Load each Fii Data information on cell
            let locale = Locale(identifier: "pt_BR")
            let data = fiiDatas[linha]
            let fiiAppreciation = data.variation
            let totalIncome = data.netIncome
            let brokerage = data.brokerage
            let totalGain = data.totalGain
            let buyTotal = data.buyValue
            let variationPercent = "(" + String(format: "%.2f", locale: locale, arguments: [fiiAppreciation/buyTotal * 100]) + "%)"
            let netIncomePercent = "(" + String(format: "%.2f", locale: locale, arguments: [totalIncome/buyTotal * 100]) + "%)"
            let brokeragePercent = "(" + String(format: "%.2f", locale: locale, arguments: [brokerage/buyTotal * 100]) + "%)"
            let totalGainPercent = "(" + String(format: "%.2f", locale: locale, arguments: [totalGain/buyTotal * 100]) + "%)"
            let currentPercent = String(format: "%.2f", locale: locale, arguments: [data.currentPercent]) + "%"
            
            cell.symbolLabel.text = data.symbol
            let totalValue = data.currentPrice * Double(data.quantity)
            cell.quantityLabel.text = "Quantidade: " + String(data.quantity)
            cell.currentLabel.text = Utils.doubleToRealCurrency(value: totalValue)
            cell.boughtLabel.text = Utils.doubleToRealCurrency(value: buyTotal)
            cell.variationLabel.text = Utils.doubleToRealCurrency(value: fiiAppreciation)
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
        // When a fii is selected in the table view, it will show menu asking for action
        // View details, Buy, Sell, Delete
        let linha = indexPath.row
        let data = fiiDatas[linha]
        selectedSymbol = data.symbol
        mediumBuy = String(data.mediumPrice)
        let soldDataDB = SoldFiiDataDB()
        let soldData = soldDataDB.getDataBySymbol(selectedSymbol)
        soldDataDB.close()
        mediumSell = String(soldData.mediumPrice)
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
        if(linha < (fiiDatas.count)){
            let detailAction = UIAlertAction(title: NSLocalizedString("Mais Detalhes", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                self.fiiDetails()
            })
            let buyAction = UIAlertAction(title: NSLocalizedString("Comprar", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                self.buyFii()
            })
            let sellAction = UIAlertAction(title: NSLocalizedString("Vender", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                self.sellFii()
            })
            let editAction = UIAlertAction(title: NSLocalizedString("Editar Preço", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                self.editFii(fii: data)
            })
            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancelar", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                self.selectedSymbol = ""
                self.mediumBuy = ""
                self.mediumSell = ""
            })
            let deleteAction = UIAlertAction(title: NSLocalizedString("Deletar", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                let deleteAlertController = UIAlertController(title: "Deletar fundo imobiliário da sua carteira?", message: "Se vendeu o fundo imobiliário, escolha Vender no menu de opções. Deletar esse fundo imobiliário irá remover todos os dados sobre ele, inclusive proventos recebidos.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: NSLocalizedString("Deletar", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                    self.deleteData(self.selectedSymbol)
                    self.fiiTable.reloadData()
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
    
    // Open form to buy fiis
    @IBAction func buyFii(){
        let buyFiiForm = BuyFiiForm()
        if(selectedSymbol != ""){
            buyFiiForm.symbol = selectedSymbol
        }
        self.navigationController?.pushViewController(buyFiiForm, animated: true)
    }
    
    // Open form to sell fiis
    @IBAction func sellFii(){
        let sellFiiForm = SellFiiForm()
        if(selectedSymbol != ""){
            sellFiiForm.symbol = selectedSymbol
        }
        self.navigationController?.pushViewController(sellFiiForm, animated: true)
    }
    
    func editFii(fii:FiiData){
        let editFiiForm = FiiEditPriceForm()
        editFiiForm.prealodedData = fii
        self.navigationController?.pushViewController(editFiiForm, animated: true)
    }
    
    // Delete fii data, all its transactions and incomes
    func deleteData(_ symbol: String){
        let dataDB = FiiDataDB()
        let transactionDB = FiiTransactionDB()
        let soldDataDB = SoldFiiDataDB()
        let incomeDB = FiiIncomeDB()
        
        dataDB.deleteBySymbol(symbol)
        transactionDB.deleteBySymbol(symbol)
        soldDataDB.deleteBySymbol(symbol)
        incomeDB.deleteBySymbol(symbol)
        fiiDatas = dataDB.getDataByStatus(Constants.Status.ACTIVE)
        Utils.updateFiiPortfolio()
        dataDB.close()
        transactionDB.close()
        soldDataDB.close()
        incomeDB.close()
    }
    
    // Open fii details view
    @IBAction func fiiDetails(){
        let fiiDetails = FiiDetailsView()
        let fiiIncomes = FiiIncomesView()
        let tabController = TabController()

        fiiDetails.tabBarItem.title = ""
        fiiDetails.tabBarItem.image =  Utils.makeThumbnailFromText(text: "Operações")
        fiiIncomes.tabBarItem.title = ""
        fiiIncomes.tabBarItem.image = Utils.makeThumbnailFromText(text: "Rendimentos")
        
        if(selectedSymbol != ""){
            fiiDetails.symbol = selectedSymbol
            fiiDetails.mediumBuy = mediumBuy
            fiiDetails.mediumSell = mediumSell
            fiiIncomes.symbol = selectedSymbol
            tabController.title = selectedSymbol
        }
        
        // Create custom Back Button
        let backButton = UIBarButtonItem(title: "Voltar", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        tabController.navigationItem.backBarButtonItem = backButton
        tabController.navigationItem.backBarButtonItem?.tintColor = UIColor.white
        tabController.viewControllers = [fiiDetails, fiiIncomes]
        
        self.navigationController?.pushViewController(tabController, animated: true)
    }
}
