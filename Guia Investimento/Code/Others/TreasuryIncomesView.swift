//
//  OthersIncomesView.swift
//  Guia Investimento
//
//  Created by Felipe on 29/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
import UIKit
class OthersIncomesView: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var bgView: UIView!
    @IBOutlet var boughtLabel: UILabel!
    @IBOutlet var grossLabel: UILabel!
    @IBOutlet var taxLabel: UILabel!
    @IBOutlet var liquidLabel: UILabel!
    @IBOutlet var fab: UIImageView!
    @IBOutlet var incomeTable: UITableView!
    @IBOutlet var grossPercentLabel: UILabel!
    @IBOutlet var taxPercentLabel: UILabel!
    @IBOutlet var netPercentLabel: UILabel!
    
    var othersIncomes: Array<OthersIncome> = []
    
    var symbol: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set rounded border and shadow to Details Overview
        bgView.layer.masksToBounds = false
        bgView.layer.cornerRadius = 6
        bgView.layer.shadowColor = UIColor.black.cgColor
        bgView.layer.shadowOpacity = 0.5
        bgView.layer.shadowOffset = CGSize(width: -1, height: 1)
        bgView.layer.shadowRadius = 5
        
        // Load fab (Floating action button)
        // Set images for each icon
        let fabImg = UIImage(named: "fab")
        fab.image = fabImg
        // Add action to open buy form when tapped
        fab.isUserInteractionEnabled = true
        let tapBuyOthers = UITapGestureRecognizer(target: self, action: #selector(OthersDetailsView.incomeMenu))
        fab.addGestureRecognizer(tapBuyOthers)
        
        // Table View
        self.incomeTable.dataSource = self
        self.incomeTable.delegate = self
        self.incomeTable.separatorStyle = .none
        let xib = UINib(nibName: "OthersIncomeCell", bundle: nil)
        self.incomeTable.register(xib, forCellReuseIdentifier: "cell")
        
        // Load Others Incomes values
        let incomeDB = OthersIncomeDB()
        othersIncomes = incomeDB.getIncomesBySymbol(symbol)
        incomeDB.close()
        
        // Load Others Data
        let dataDB = OthersDataDB()
        let othersData = dataDB.getDataBySymbol(symbol)
        dataDB.close()
        let locale = Locale(identifier: "pt_BR")
        let grossIncome = othersData.liquidIncome + othersData.incomeTax
        let netIncome = othersData.liquidIncome
        let grossPercent = "(" + String(format: "%.2f", locale: locale, arguments: [grossIncome/othersData.buyTotal*100]) + "%)"
        let taxPercent = "(" + String(format: "%.2f", locale: locale, arguments: [othersData.incomeTax/othersData.buyTotal*100]) + "%)"
        let netPercent = "(" + String(format: "%.2f", locale: locale, arguments: [netIncome/othersData.buyTotal*100]) + "%)"
        grossPercentLabel.textColor = UIColor(red: 139/255, green: 195/255, blue: 74/255, alpha: 1)
        taxPercentLabel.textColor = UIColor(red: 244/255, green: 67/255, blue: 54/255, alpha: 1)
        netPercentLabel.textColor = UIColor(red: 139/255, green: 195/255, blue: 74/255, alpha: 1)
        grossLabel.textColor = UIColor(red: 139/255, green: 195/255, blue: 74/255, alpha: 1)
        taxLabel.textColor = UIColor(red: 244/255, green: 67/255, blue: 54/255, alpha: 1)
        liquidLabel.textColor = UIColor(red: 139/255, green: 195/255, blue: 74/255, alpha: 1)
        grossPercentLabel.text = grossPercent
        taxPercentLabel.text = taxPercent
        netPercentLabel.text = netPercent
        boughtLabel.text = Utils.doubleToRealCurrency(value: othersData.buyTotal)
        grossLabel.text = Utils.doubleToRealCurrency(value: othersData.incomeTotal + othersData.incomeTax)
        taxLabel.text = Utils.doubleToRealCurrency(value: othersData.incomeTax)
        liquidLabel.text = Utils.doubleToRealCurrency(value: othersData.incomeTotal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Load all Others Incomes of a symbol to show on this list
        let incomeDB = OthersIncomeDB()
        othersIncomes = incomeDB.getIncomesBySymbol(symbol)
        if (othersIncomes.isEmpty){
            self.incomeTable.isHidden = true
        } else {
            self.incomeTable.isHidden = false
        }
        incomeDB.close()
        
        // Load Others Data
        let dataDB = OthersDataDB()
        let othersData = dataDB.getDataBySymbol(symbol)
        dataDB.close()
        let locale = Locale(identifier: "pt_BR")
        let grossIncome = othersData.liquidIncome + othersData.incomeTax
        let netIncome = othersData.liquidIncome
        let grossPercent = "(" + String(format: "%.2f", locale: locale, arguments: [grossIncome/othersData.buyTotal*100]) + "%)"
        let taxPercent = "(" + String(format: "%.2f", locale: locale, arguments: [othersData.incomeTax/othersData.buyTotal*100]) + "%)"
        let netPercent = "(" + String(format: "%.2f", locale: locale, arguments: [netIncome/othersData.buyTotal*100]) + "%)"
        grossPercentLabel.text = grossPercent
        taxPercentLabel.text = taxPercent
        netPercentLabel.text = netPercent
        boughtLabel.text = Utils.doubleToRealCurrency(value: othersData.buyTotal)
        grossLabel.text = Utils.doubleToRealCurrency(value: othersData.liquidIncome + othersData.incomeTax)
        taxLabel.text = Utils.doubleToRealCurrency(value: othersData.incomeTax)
        liquidLabel.text = Utils.doubleToRealCurrency(value: othersData.liquidIncome)
        // Reload data every time OthersDataView is shown
        self.incomeTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (othersIncomes.isEmpty){
            return 0
        } else {
            // +1 to leave a empty field for Floating Button to scroll
            return othersIncomes.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let linha = indexPath.row
        let cell = self.incomeTable.dequeueReusableCell(withIdentifier: "cell") as! OthersIncomeCell
        // Do not show highlight when selected
        cell.selectionStyle = .none
        
        if(linha < (othersIncomes.count)){
            // Get Transaction and populat table
            let income = othersIncomes[linha]
            if(income.type == Constants.IncomeType.OTHERS){
                cell.type.text = "Rendimento"
            }
            
            //Get Date
            let timestamp = income.exdividendTimestamp
            let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            formatter.dateFormat = "dd/MM/yyyy"
            let dateString = formatter.string(from: date)
            cell.date.text = dateString
            
            cell.symbol.text = income.symbol
            
            cell.total.text = Utils.doubleToRealCurrency(value: income.liquidIncome)
        } else {
            cell.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // When a others income is selected in the table view, it will show menu asking for action
        // Edit, Delete
        let linha = indexPath.row
        let income = othersIncomes[linha]
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
        if(linha < (othersIncomes.count)){
            let detailsAction = UIAlertAction(title: NSLocalizedString("Mais Detalhes", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                self.detailsIncome(income)
            })
            let editAction = UIAlertAction(title: NSLocalizedString("Editar", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                self.editIncome(income)
            })
            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancelar", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                
            })
            let deleteAction = UIAlertAction(title: NSLocalizedString("Deletar", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                let deleteAlertController = UIAlertController(title: "Deletar esse provento do seu portfolio?", message: "Tem certeza que deseja deletar esse provento do seu portfolio? ", preferredStyle: .alert)
                let okAction = UIAlertAction(title: NSLocalizedString("Deletar", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
                    self.deleteIncome(income)
                })
                
                deleteAlertController.addAction(cancelAction)
                deleteAlertController.addAction(okAction)
                self.present(deleteAlertController, animated: false, completion: nil)
                
            })
            alertController.addAction(detailsAction)
            alertController.addAction(editAction)
            alertController.addAction(deleteAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: false, completion: nil)
        }
    }
    
    func editIncome(_ income: OthersIncome){
        // Sets id of already existing transaction to be edited in BuyForm
        let dividendForm = OthersDividendForm()
        dividendForm.symbol = income.symbol
        dividendForm.id = income.id
        dividendForm.incomeType = income.type
        self.navigationController?.pushViewController(dividendForm, animated: true)
    }
    
    // Delete Transaction and update OthersData
    func deleteIncome(_ income: OthersIncome){
        let othersGeneral = OthersGeneral()
        othersGeneral.deleteOthersIncome(String(income.id), symbol: income.symbol)
        
        let incomeDB = OthersIncomeDB()
        othersIncomes = incomeDB.getIncomesBySymbol(symbol)
        if (othersIncomes.isEmpty){
            self.incomeTable.isHidden = true
        } else {
            self.incomeTable.isHidden = false
        }
        incomeDB.close()
        
        // Load Others Data
        let dataDB = OthersDataDB()
        let othersData = dataDB.getDataBySymbol(symbol)
        dataDB.close()
        boughtLabel.text = Utils.doubleToRealCurrency(value: othersData.buyTotal)
        grossLabel.text = Utils.doubleToRealCurrency(value: othersData.liquidIncome + othersData.incomeTax)
        taxLabel.text = Utils.doubleToRealCurrency(value: othersData.incomeTax)
        liquidLabel.text = Utils.doubleToRealCurrency(value: othersData.liquidIncome)
        
        self.incomeTable.reloadData()
    }
    
    // Show income details
    func detailsIncome(_ income: OthersIncome){
        let incomeDetails = OthersIncomeDetailsView()
        incomeDetails.income = income
        self.navigationController?.pushViewController(incomeDetails, animated: true)
    }
    
    //Shows alert yo choose income type
    @IBAction func incomeMenu(){
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
        let dividendAction = UIAlertAction(title: NSLocalizedString("Rendimento", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
            self.addIncome(Constants.IncomeType.OTHERS)
        })
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancelar", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
            
        })
        
        alertController.addAction(dividendAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: false, completion: nil)
    }
    
    func addIncome(_ type: Int){
        switch (type) {
        case Constants.IncomeType.OTHERS:
            let dividendForm = OthersDividendForm()
            dividendForm.symbol = symbol
            dividendForm.incomeType = type
            self.navigationController?.pushViewController(dividendForm, animated: true)
            break
        default:
            break
        }
    }
}
