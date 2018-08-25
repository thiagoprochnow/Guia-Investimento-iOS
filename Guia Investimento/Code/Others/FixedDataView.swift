//
//  FixedData.swift
//  Guia Investimento
//
//  Created by Felipe on 01/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
import UIKit

class FixedDataView: UIViewController, UITableViewDataSource, UITableViewDelegate{
    @IBOutlet var fixedTable: UITableView!
    @IBOutlet var fab: UIImageView!
    @IBOutlet var emptyListView: UILabel!
    var fixedDatas: Array<FixedData> = []
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
        self.fixedTable.dataSource = self
        self.fixedTable.delegate = self
        self.fixedTable.separatorStyle = .none
        let xib = UINib(nibName: "FixedDataCell", bundle: nil)
        self.fixedTable.register(xib, forCellReuseIdentifier: "cell")
        
        // Load fab (Floating action button)
        // Set images for each icon
        let fabImg = UIImage(named: "fab")
        fab.image = fabImg
        // Add action to open buy form when tapped
        fab.isUserInteractionEnabled = true
        let tapBuyFixed = UITapGestureRecognizer(target: self, action: #selector(FixedDataView.buyFixed))
        fab.addGestureRecognizer(tapBuyFixed)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Load all Active Fixed Datas to show on this list
        let dataDB = FixedDataDB()
        fixedDatas = dataDB.getData()
        var selectedSymbol: String = ""
        var current: String = ""
        var sold: String = ""
        var bought: String = ""
        var gain: String = ""
        if (fixedDatas.isEmpty){
            self.fixedTable.isHidden = true
            self.emptyListView.isHidden = false
        } else {
            self.fixedTable.isHidden = false
            self.emptyListView.isHidden = true
        }
        dataDB.close()
        // Reload data every time FixedDataView is shown
        self.fixedTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (fixedDatas.isEmpty){
            return 0
        } else {
            // +1 to leave a empty field for Floating Button to scroll
            return fixedDatas.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let linha = indexPath.row
        let cell = self.fixedTable.dequeueReusableCell(withIdentifier: "cell") as! FixedDataCell
        // Do not show highlight when selected
        cell.selectionStyle = .none
        
        if(linha < (fixedDatas.count)){
            // Load each Fixed Data information on cell
            let locale = Locale(identifier: "pt_BR")
            let data = fixedDatas[linha]
            let totalGain = data.totalGain
            let currentTotal = data.currentTotal
            let buyTotal = data.buyTotal
            let sellTotal = data.sellTotal
            let totalGainPercent = "(" + String(format: "%.2f", locale: locale, arguments: [totalGain/buyTotal * 100]) + "%)"
            let currentPercent = String(format: "%.2f", locale: locale, arguments: [data.currentPercent]) + "%"
            
            cell.symbolLabel.text = data.symbol
            cell.currentLabel.text = Utils.doubleToRealCurrency(value: currentTotal)
            cell.boughtLabel.text = Utils.doubleToRealCurrency(value: buyTotal)
            cell.soldLabel.text = Utils.doubleToRealCurrency(value: sellTotal)
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
        // When a fixed is selected in the table view, it will show menu asking for action
        // View details, Buy, Sell, Delete
        let linha = indexPath.row
        let data = fixedDatas[linha]
        selectedSymbol = data.symbol
        current = String(data.currentTotal)
        sold = String(data.sellTotal)
        bought = String(data.buyTotal)
        gain = String(data.totalGain)
        
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
        if(linha < (fixedDatas.count)){
            let detailAction = UIAlertAction(title: NSLocalizedString("Mais Detalhes", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                self.fixedDetails()
            })
            let buyAction = UIAlertAction(title: NSLocalizedString("Comprar", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                self.buyFixed()
            })
            let sellAction = UIAlertAction(title: NSLocalizedString("Vender", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                self.sellFixed()
            })
            let editAction = UIAlertAction(title: NSLocalizedString("Editar Total Atual", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                self.editFixed(fixed: data)
            })
            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancelar", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                self.selectedSymbol = ""
                self.current = ""
                self.sold = ""
                self.bought = ""
                self.gain = ""
            })
            let deleteAction = UIAlertAction(title: NSLocalizedString("Deletar", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                let deleteAlertController = UIAlertController(title: "Deletar renda fixa da sua carteira?", message: "Se vendeu a renda fixa, escolha Vender no menu de opções. Deletar essa renda fixa irá remover todos os dados sobre ela.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: NSLocalizedString("Deletar", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                    self.deleteData(self.selectedSymbol)
                    self.fixedTable.reloadData()
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
    
    // Open form to buy fixeds
    @IBAction func buyFixed(){
        let buyFixedForm = BuyFixedForm()
        if(selectedSymbol != ""){
            buyFixedForm.symbol = selectedSymbol
        }
        self.navigationController?.pushViewController(buyFixedForm, animated: true)
    }
    
    // Open form to sell fixeds
    @IBAction func sellFixed(){
        let sellFixedForm = SellFixedForm()
        if(selectedSymbol != ""){
            sellFixedForm.symbol = selectedSymbol
        }
        self.navigationController?.pushViewController(sellFixedForm, animated: true)
    }
    
    func editFixed(fixed:FixedData){
        let editFixedForm = FixedEditPriceForm()
        editFixedForm.prealodedData = fixed
        self.navigationController?.pushViewController(editFixedForm, animated: true)
    }
    
    // Delete fixed data, all its transactions and incomes
    func deleteData(_ symbol: String){
        let dataDB = FixedDataDB()
        let transactionDB = FixedTransactionDB()
        
        dataDB.deleteBySymbol(symbol)
        transactionDB.deleteBySymbol(symbol)
        fixedDatas = dataDB.getData()
        Utils.updateFixedPortfolio()
        dataDB.close()
        transactionDB.close()
    }
    
    // Open fixed details view
    @IBAction func fixedDetails(){
        let fixedDetails = FixedDetailsView()
        let tabController = TabController()

        fixedDetails.tabBarItem.title = ""
        fixedDetails.tabBarItem.image =  Utils.makeThumbnailFromText(text: "Operações")
        
        if(selectedSymbol != ""){
            fixedDetails.symbol = selectedSymbol
            fixedDetails.current = current
            fixedDetails.sold = sold
            fixedDetails.bought = bought
            fixedDetails.gain = gain
            tabController.title = selectedSymbol
        }
        
        // Create custom Back Button
        let backButton = UIBarButtonItem(title: "Voltar", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        tabController.navigationItem.backBarButtonItem = backButton
        tabController.navigationItem.backBarButtonItem?.tintColor = UIColor.white
        tabController.viewControllers = [fixedDetails]
        
        self.navigationController?.pushViewController(tabController, animated: true)
    }
}
