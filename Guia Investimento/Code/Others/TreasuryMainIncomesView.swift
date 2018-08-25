//
//  TreasuryIncomesView.swift
//  Guia Investimento
//
//  Created by Felipe on 29/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
import UIKit
class TreasuryMainIncomesView: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var bgView: UIView!
    @IBOutlet var boughtLabel: UILabel!
    @IBOutlet var grossLabel: UILabel!
    @IBOutlet var taxLabel: UILabel!
    @IBOutlet var liquidLabel: UILabel!
    @IBOutlet var fab: UIImageView!
    @IBOutlet var incomeTable: UITableView!
    @IBOutlet var grossPercentLabel: UILabel!
    @IBOutlet var taxPercentLabel: UILabel!
    @IBOutlet var liquidPercentLabel: UILabel!
    @IBOutlet var emptyListView: UILabel!
    
    var treasuryIncomes: Array<TreasuryIncome> = []
    
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
        let tapBuyTreasury = UITapGestureRecognizer(target: self, action: #selector(TreasuryDetailsView.incomeMenu))
        fab.addGestureRecognizer(tapBuyTreasury)
        
        // Table View
        self.incomeTable.dataSource = self
        self.incomeTable.delegate = self
        self.incomeTable.separatorStyle = .none
        let xib = UINib(nibName: "TreasuryIncomeCell", bundle: nil)
        self.incomeTable.register(xib, forCellReuseIdentifier: "cell")
        
        // Load Treasury Incomes values
        let incomeDB = TreasuryIncomeDB()
        treasuryIncomes = incomeDB.getIncomes()
        incomeDB.close()
        
        // Load Treasury Data
        let dataDB = TreasuryDataDB()
        let treasuryDatas = dataDB.getData()
        dataDB.close()
        var tax = 0.0
        
        treasuryDatas.forEach{treasury in
            tax += treasury.incomeTax
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Load all Treasury Incomes of a symbol to show on this list
        let incomeDB = TreasuryIncomeDB()
        treasuryIncomes = incomeDB.getIncomes()
        if (treasuryIncomes.isEmpty){
            self.incomeTable.isHidden = true
            self.bgView.isHidden = true
            self.emptyListView.isHidden = false
        } else {
            self.incomeTable.isHidden = false
            self.bgView.isHidden = false
            self.emptyListView.isHidden = true
        }
        incomeDB.close()
        
        // Load Treasury Data
        let dataDB = TreasuryDataDB()
        let treasuryDatas = dataDB.getData()
        dataDB.close()
        var tax = 0.0
        
        treasuryDatas.forEach{treasury in
            tax += treasury.incomeTax
        }
        
        // Load Treasury Portfolio
        let portfolioDB = TreasuryPortfolioDB()
        let treasuryPortfolio = portfolioDB.getPortfolio()
        portfolioDB.close()
        let locale = Locale(identifier: "pt_BR")
        let grossIncome = treasuryPortfolio.incomeTotal + tax
        let netIncome = treasuryPortfolio.incomeTotal
        let grossPercent = "(" + String(format: "%.2f", locale: locale, arguments: [grossIncome/treasuryPortfolio.buyTotal*100]) + "%)"
        let taxPercent = "(" + String(format: "%.2f", locale: locale, arguments: [tax/treasuryPortfolio.buyTotal*100]) + "%)"
        let netPercent = "(" + String(format: "%.2f", locale: locale, arguments: [netIncome/treasuryPortfolio.buyTotal*100]) + "%)"
        grossPercentLabel.textColor = UIColor(red: 139/255, green: 195/255, blue: 74/255, alpha: 1)
        taxPercentLabel.textColor = UIColor(red: 244/255, green: 67/255, blue: 54/255, alpha: 1)
        liquidPercentLabel.textColor = UIColor(red: 139/255, green: 195/255, blue: 74/255, alpha: 1)
        grossLabel.textColor = UIColor(red: 139/255, green: 195/255, blue: 74/255, alpha: 1)
        taxLabel.textColor = UIColor(red: 244/255, green: 67/255, blue: 54/255, alpha: 1)
        liquidLabel.textColor = UIColor(red: 139/255, green: 195/255, blue: 74/255, alpha: 1)
        grossPercentLabel.text = grossPercent
        taxPercentLabel.text = taxPercent
        liquidPercentLabel.text = netPercent
        boughtLabel.text = Utils.doubleToRealCurrency(value: treasuryPortfolio.buyTotal)
        grossLabel.text = Utils.doubleToRealCurrency(value: treasuryPortfolio.incomeTotal + tax)
        taxLabel.text = Utils.doubleToRealCurrency(value: tax)
        liquidLabel.text = Utils.doubleToRealCurrency(value: treasuryPortfolio.incomeTotal)
        
        // Load Treasury Portfolio
        // Reload data every time TreasuryDataView is shown
        self.incomeTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (treasuryIncomes.isEmpty){
            return 0
        } else {
            // +1 to leave a empty field for Floating Button to scroll
            return treasuryIncomes.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let linha = indexPath.row
        let cell = self.incomeTable.dequeueReusableCell(withIdentifier: "cell") as! TreasuryIncomeCell
        // Do not show highlight when selected
        cell.selectionStyle = .none
        
        if(linha < (treasuryIncomes.count)){
            // Get Transaction and populat table
            let income = treasuryIncomes[linha]
            if(income.type == Constants.IncomeType.TREASURY){
                cell.type.text = "Cupom Semestral"
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
        // When a treasury income is selected in the table view, it will show menu asking for action
        // Edit, Delete
        let linha = indexPath.row
        let income = treasuryIncomes[linha]
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
        if(linha < (treasuryIncomes.count)){
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
    
    func editIncome(_ income: TreasuryIncome){
        // Sets id of already existing transaction to be edited in BuyForm
        let dividendForm = TreasuryDividendForm()
        dividendForm.symbol = income.symbol
        dividendForm.id = income.id
        dividendForm.incomeType = income.type
        self.navigationController?.pushViewController(dividendForm, animated: true)
    }
    
    // Delete Transaction and update TreasuryData
    func deleteIncome(_ income: TreasuryIncome){
        let treasuryGeneral = TreasuryGeneral()
        treasuryGeneral.deleteTreasuryIncome(String(income.id), symbol: income.symbol)
        
        let incomeDB = TreasuryIncomeDB()
        treasuryIncomes = incomeDB.getIncomes()
        if (treasuryIncomes.isEmpty){
            self.incomeTable.isHidden = true
        } else {
            self.incomeTable.isHidden = false
        }
        incomeDB.close()
        
        // Load Treasury Portfolio
        self.incomeTable.reloadData()
    }
    
    // Show income details
    func detailsIncome(_ income: TreasuryIncome){
        let incomeDetails = TreasuryIncomeDetailsView()
        incomeDetails.income = income
        self.navigationController?.pushViewController(incomeDetails, animated: true)
    }
    
    //Shows alert yo choose income type
    @IBAction func incomeMenu(){
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
        let dividendAction = UIAlertAction(title: NSLocalizedString("Cupom Semestral", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
            self.addIncome(Constants.IncomeType.TREASURY)
        })
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancelar", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
            
        })
        
        alertController.addAction(dividendAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: false, completion: nil)
    }
    
    func addIncome(_ type: Int){
        switch (type) {
        case Constants.IncomeType.TREASURY:
            let dividendForm = TreasuryDividendForm()
            dividendForm.incomeType = type
            self.navigationController?.pushViewController(dividendForm, animated: true)
            break
        default:
            break
        }
    }
}
