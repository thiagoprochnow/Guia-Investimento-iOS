//
//  FiiData.swift
//  Guia Investimento
//
//  Created by Felipe on 01/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
import UIKit

class SoldFiiDataView: UIViewController, UITableViewDataSource, UITableViewDelegate{
    @IBOutlet var fiiTable: UITableView!
    @IBOutlet var fab: UIImageView!
    @IBOutlet var emptyListView: UILabel!
    var soldFiiDatas: Array<SoldFiiData> = []
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
        let xib = UINib(nibName: "SoldFiiDataCell", bundle: nil)
        self.fiiTable.register(xib, forCellReuseIdentifier: "cell")
        
        // Load fab (Floating action button)
        // Set images for each icon
        let fabImg = UIImage(named: "fab")
        fab.image = fabImg
        // Add action to open buy form when tapped
        fab.isUserInteractionEnabled = true
        let tapBuyFii = UITapGestureRecognizer(target: self, action: #selector(SoldFiiDataView.buyFii))
        fab.addGestureRecognizer(tapBuyFii)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Load all Sold Fii Datas to show on this list
        let dataDB = SoldFiiDataDB()
        soldFiiDatas = dataDB.getSoldData()
        if (soldFiiDatas.isEmpty){
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
        if (soldFiiDatas.isEmpty){
            return 0
        } else {
            // +1 to leave a empty field for Floating Button to scroll
            return soldFiiDatas.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let linha = indexPath.row
        let cell = self.fiiTable.dequeueReusableCell(withIdentifier: "cell") as! SoldFiiDataCell
        // Do not show highlight when selected
        cell.selectionStyle = .none
        
        if(linha < (soldFiiDatas.count)){
            // Load each Sold Fii Data information on cell
            let data = soldFiiDatas[linha]
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
        // When a fii is selected in the table view, it will show menu asking for action
        // View details, Buy, Sell, Delete
        let linha = indexPath.row
        let data = soldFiiDatas[linha]
        selectedSymbol = data.symbol
        let dataDB = FiiDataDB()
        let buyData = dataDB.getDataBySymbol(selectedSymbol)
        mediumBuy = String(buyData.mediumPrice)
        dataDB.close()
        mediumSell = String(data.mediumPrice)
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
        if(linha < (soldFiiDatas.count)){
            let detailAction = UIAlertAction(title: NSLocalizedString("Mais Detalhes", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                self.fiiDetails()
            })
            let buyAction = UIAlertAction(title: NSLocalizedString("Comprar", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                self.buyFii()
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
            alertController.addAction(deleteAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: false, completion: nil)
        }
    }
    
    // Open fii details view
    @IBAction func buyFii(){
        let buyFiiForm = BuyFiiForm()
        if(selectedSymbol != ""){
            buyFiiForm.symbol = selectedSymbol
        }
        self.navigationController?.pushViewController(buyFiiForm, animated: true)
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
        soldFiiDatas = soldDataDB.getSoldData()
        Utils.updateFiiPortfolio()
        dataDB.close()
        transactionDB.close()
        soldDataDB.close()
        incomeDB.close()
    }
    
    // Open form to buy fiis
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
