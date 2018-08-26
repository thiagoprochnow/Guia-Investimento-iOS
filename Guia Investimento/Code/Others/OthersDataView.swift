//
//  OthersData.swift
//  Guia Investimento
//
//  Created by Felipe on 01/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
import UIKit

class OthersDataView: UIViewController, UITableViewDataSource, UITableViewDelegate{
    @IBOutlet var othersTable: UITableView!
    @IBOutlet var fab: UIImageView!
    @IBOutlet var emptyListView: UILabel!
    var othersDatas: Array<OthersData> = []
    var selectedSymbol: String = ""
    var current: String = ""
    var sold: String = ""
    var bought: String = ""
    var gain: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Background Color
        self.view.backgroundColor = UIColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1)
        
        // Table View
        self.othersTable.dataSource = self
        self.othersTable.delegate = self
        self.othersTable.separatorStyle = .none
        let xib = UINib(nibName: "OthersDataCell", bundle: nil)
        self.othersTable.register(xib, forCellReuseIdentifier: "cell")
        
        // Load fab (Floating action button)
        // Set images for each icon
        let fabImg = UIImage(named: "fab")
        fab.image = fabImg
        // Add action to open buy form when tapped
        fab.isUserInteractionEnabled = true
        let tapBuyOthers = UITapGestureRecognizer(target: self, action: #selector(OthersDataView.buyOthers))
        fab.addGestureRecognizer(tapBuyOthers)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Load all Active Others Datas to show on this list
        let dataDB = OthersDataDB()
        othersDatas = dataDB.getData()
        var selectedSymbol: String = ""
        var current: String = ""
        var sold: String = ""
        var bought: String = ""
        var gain: String = ""
        if (othersDatas.isEmpty){
            self.othersTable.isHidden = true
            self.emptyListView.isHidden = false
        } else {
            self.othersTable.isHidden = false
            self.emptyListView.isHidden = true
        }
        dataDB.close()
        // Reload data every time OthersDataView is shown
        self.othersTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (othersDatas.isEmpty){
            return 0
        } else {
            // +1 to leave a empty field for Floating Button to scroll
            return othersDatas.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let linha = indexPath.row
        let cell = self.othersTable.dequeueReusableCell(withIdentifier: "cell") as! OthersDataCell
        // Do not show highlight when selected
        cell.selectionStyle = .none
        
        if(linha < (othersDatas.count)){
            // Load each Others Data information on cell
            let locale = Locale(identifier: "pt_BR")
            let data = othersDatas[linha]
            let totalGain = data.totalGain
            let othersAppreciation = data.variation
            let currentTotal = data.currentTotal
            let totalIncome = data.liquidIncome
            let buyTotal = data.buyTotal
            let sellTotal = data.sellTotal
            let variationPercent = "(" + String(format: "%.2f", locale: locale, arguments: [othersAppreciation/buyTotal * 100]) + "%)"
            let netIncomePercent = "(" + String(format: "%.2f", locale: locale, arguments: [totalIncome/buyTotal * 100]) + "%)"
            let totalGainPercent = "(" + String(format: "%.2f", locale: locale, arguments: [totalGain/buyTotal * 100]) + "%)"
            let currentPercent = String(format: "%.2f", locale: locale, arguments: [data.currentPercent]) + "%"
            
            cell.symbolLabel.text = data.symbol
            cell.currentLabel.text = Utils.doubleToRealCurrency(value: currentTotal)
            cell.boughtLabel.text = Utils.doubleToRealCurrency(value: buyTotal)
            cell.soldLabel.text = Utils.doubleToRealCurrency(value: sellTotal)
            cell.currentPercent.text = currentPercent
            cell.variationLabel.text = Utils.doubleToRealCurrency(value: othersAppreciation)
            cell.variationPercent.text = variationPercent
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
        // When a others is selected in the table view, it will show menu asking for action
        // View details, Buy, Sell, Delete
        let linha = indexPath.row
        let data = othersDatas[linha]
        selectedSymbol = data.symbol
        current = String(data.currentTotal)
        sold = String(data.sellTotal)
        bought = String(data.buyTotal)
        gain = String(data.totalGain)
        
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
        if(linha < (othersDatas.count)){
            let detailAction = UIAlertAction(title: NSLocalizedString("Mais Detalhes", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                self.othersDetails()
            })
            let buyAction = UIAlertAction(title: NSLocalizedString("Comprar", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                self.buyOthers()
            })
            let sellAction = UIAlertAction(title: NSLocalizedString("Vender", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                self.sellOthers()
            })
            let editAction = UIAlertAction(title: NSLocalizedString("Editar Total Atual", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                self.editOthers(others: data)
            })
            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancelar", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                self.selectedSymbol = ""
                self.current = ""
                self.sold = ""
                self.bought = ""
                self.gain = ""
            })
            let deleteAction = UIAlertAction(title: NSLocalizedString("Deletar", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                let deleteAlertController = UIAlertController(title: "Deletar investimento da sua carteira?", message: "Se vendeu esse investimento, escolha Vender no menu de opções. Deletar irá remover todos os dados sobre ele.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: NSLocalizedString("Deletar", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                    self.deleteData(self.selectedSymbol)
                    self.othersTable.reloadData()
                    self.selectedSymbol = ""
                    self.current = ""
                    self.sold = ""
                    self.bought = ""
                    self.gain = ""
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
    
    // Open form to buy others
    @IBAction func buyOthers(){
        let buyOthersForm = BuyOthersForm()
        if(selectedSymbol != ""){
            buyOthersForm.symbol = selectedSymbol
        }
        self.navigationController?.pushViewController(buyOthersForm, animated: true)
    }
    
    // Open form to sell others
    @IBAction func sellOthers(){
        let sellOthersForm = SellOthersForm()
        if(selectedSymbol != ""){
            sellOthersForm.symbol = selectedSymbol
        }
        self.navigationController?.pushViewController(sellOthersForm, animated: true)
    }
    
    func editOthers(others:OthersData){
        let editOthersForm = OthersEditPriceForm()
        editOthersForm.prealodedData = others
        self.navigationController?.pushViewController(editOthersForm, animated: true)
    }
    
    // Delete others data, all its transactions and incomes
    func deleteData(_ symbol: String){
        let dataDB = OthersDataDB()
        let transactionDB = OthersTransactionDB()
        
        dataDB.deleteBySymbol(symbol)
        transactionDB.deleteBySymbol(symbol)
        othersDatas = dataDB.getData()
        Utils.updateOthersPortfolio()
        dataDB.close()
        transactionDB.close()
    }
    
    // Open others details view
    @IBAction func othersDetails(){
        let othersDetails = OthersDetailsView()
        let tabController = TabController()

        othersDetails.tabBarItem.title = ""
        othersDetails.tabBarItem.image =  Utils.makeThumbnailFromText(text: "Operações")
        
        if(selectedSymbol != ""){
            othersDetails.symbol = selectedSymbol
            othersDetails.current = current
            othersDetails.sold = sold
            othersDetails.bought = bought
            othersDetails.gain = gain
            tabController.title = selectedSymbol
        }
        
        // Create custom Back Button
        let backButton = UIBarButtonItem(title: "Voltar", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        tabController.navigationItem.backBarButtonItem = backButton
        tabController.navigationItem.backBarButtonItem?.tintColor = UIColor.white
        tabController.viewControllers = [othersDetails]
        
        self.navigationController?.pushViewController(tabController, animated: true)
    }
}
