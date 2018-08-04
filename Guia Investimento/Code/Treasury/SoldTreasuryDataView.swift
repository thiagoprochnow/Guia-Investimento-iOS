//
//  TreasuryData.swift
//  Guia Investimento
//
//  Created by Felipe on 01/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
import UIKit

class SoldTreasuryDataView: UIViewController, UITableViewDataSource, UITableViewDelegate{
    @IBOutlet var treasuryTable: UITableView!
    @IBOutlet var fab: UIImageView!
    @IBOutlet var emptyListView: UILabel!
    var soldTreasuryDatas: Array<SoldTreasuryData> = []
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
        let xib = UINib(nibName: "SoldTreasuryDataCell", bundle: nil)
        self.treasuryTable.register(xib, forCellReuseIdentifier: "cell")
        
        // Load fab (Floating action button)
        // Set images for each icon
        let fabImg = UIImage(named: "fab")
        fab.image = fabImg
        // Add action to open buy form when tapped
        fab.isUserInteractionEnabled = true
        let tapBuyTreasury = UITapGestureRecognizer(target: self, action: #selector(SoldTreasuryDataView.buyTreasury))
        fab.addGestureRecognizer(tapBuyTreasury)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Load all Sold Treasury Datas to show on this list
        let dataDB = SoldTreasuryDataDB()
        soldTreasuryDatas = dataDB.getSoldData()
        if (soldTreasuryDatas.isEmpty){
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
        if (soldTreasuryDatas.isEmpty){
            return 0
        } else {
            // +1 to leave a empty field for Floating Button to scroll
            return soldTreasuryDatas.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let linha = indexPath.row
        let cell = self.treasuryTable.dequeueReusableCell(withIdentifier: "cell") as! SoldTreasuryDataCell
        // Do not show highlight when selected
        cell.selectionStyle = .none
        
        if(linha < (soldTreasuryDatas.count)){
            // Load each Sold Treasury Data information on cell
            let data = soldTreasuryDatas[linha]
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
        // When a treasury is selected in the table view, it will show menu asking for action
        // View details, Buy, Sell, Delete
        let linha = indexPath.row
        let data = soldTreasuryDatas[linha]
        selectedSymbol = data.symbol
        let dataDB = TreasuryDataDB()
        let buyData = dataDB.getDataBySymbol(selectedSymbol)
        mediumBuy = String(buyData.mediumPrice)
        dataDB.close()
        mediumSell = String(data.mediumPrice)
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
        if(linha < (soldTreasuryDatas.count)){
            let detailAction = UIAlertAction(title: NSLocalizedString("Mais Detalhes", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                self.treasuryDetails()
            })
            let buyAction = UIAlertAction(title: NSLocalizedString("Comprar", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                self.buyTreasury()
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
                let deleteAlertController = UIAlertController(title: "Deletar fundo imobiliário da sua carteira?", message: "Se vendeu o fundo imobiliário, escolha Vender no menu de opções. Deletar esse fundo imobiliário irá remover todos os dados sobre ele, inclusive proventos recebidos.", preferredStyle: .alert)
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
            alertController.addAction(deleteAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: false, completion: nil)
        }
    }
    
    // Open treasury details view
    @IBAction func buyTreasury(){
        let buyTreasuryForm = BuyTreasuryForm()
        if(selectedSymbol != ""){
            buyTreasuryForm.symbol = selectedSymbol
        }
        self.navigationController?.pushViewController(buyTreasuryForm, animated: true)
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
        soldTreasuryDatas = soldDataDB.getSoldData()
        Utils.updateTreasuryPortfolio()
        dataDB.close()
        transactionDB.close()
        soldDataDB.close()
        incomeDB.close()
    }
    
    // Open form to buy treasuries
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
