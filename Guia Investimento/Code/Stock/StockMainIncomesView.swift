//
//  StockIncomesView.swift
//  Guia Investimento
//
//  Created by Felipe on 29/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
import UIKit
class StockMainIncomesView: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var bgView: UIView!
    @IBOutlet var boughtLabel: UILabel!
    @IBOutlet var grossLabel: UILabel!
    @IBOutlet var taxLabel: UILabel!
    @IBOutlet var liquidLabel: UILabel!
    @IBOutlet var fab: UIImageView!
    @IBOutlet var incomeTable: UITableView!
    var stockIncomes: Array<StockIncome> = []
    
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
        let tapBuyStock = UITapGestureRecognizer(target: self, action: #selector(StockDetailsView.incomeMenu))
        fab.addGestureRecognizer(tapBuyStock)
        
        // Table View
        self.incomeTable.dataSource = self
        self.incomeTable.delegate = self
        self.incomeTable.separatorStyle = .none
        let xib = UINib(nibName: "StockIncomeCell", bundle: nil)
        self.incomeTable.register(xib, forCellReuseIdentifier: "cell")
        
        // Load Stock Incomes values
        let incomeDB = StockIncomeDB()
        stockIncomes = incomeDB.getIncomes()
        incomeDB.close()
        
        // Load Stock Portfolio
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Load all Stock Incomes of a symbol to show on this list
        let incomeDB = StockIncomeDB()
        stockIncomes = incomeDB.getIncomes()
        if (stockIncomes.isEmpty){
            self.incomeTable.isHidden = true
        } else {
            self.incomeTable.isHidden = false
        }
        incomeDB.close()
        
        // Load Stock Portfolio
        // Reload data every time StockDataView is shown
        self.incomeTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (stockIncomes.isEmpty){
            return 0
        } else {
            // +1 to leave a empty field for Floating Button to scroll
            return stockIncomes.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let linha = indexPath.row
        let cell = self.incomeTable.dequeueReusableCell(withIdentifier: "cell") as! StockIncomeCell
        // Do not show highlight when selected
        cell.selectionStyle = .none
        
        if(linha < (stockIncomes.count)){
            // Get Transaction and populat table
            let income = stockIncomes[linha]
            if(income.type == Constants.IncomeType.DIVIDEND){
                cell.type.text = "Dividendo"
            } else if (income.type == Constants.IncomeType.JCP){
                cell.type.text = "Juros S/ Capital"
            }
            
            //Get Date
            let timestamp = income.exdividendTimestamp
            let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            let dateString = formatter.string(from: date)
            cell.date.text = dateString
            
            cell.symbol.text = income.symbol
            
            cell.total.text = Utils.doubleToRealCurrency(value: income.perStock * Double(income.affectedQuantity) - income.tax)
        } else {
            cell.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // When a stock income is selected in the table view, it will show menu asking for action
        // Edit, Delete
        let linha = indexPath.row
        let income = stockIncomes[linha]
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
        if(linha < (stockIncomes.count)){
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
    
    func editIncome(_ income: StockIncome){
        // Sets id of already existing transaction to be edited in BuyForm
        let dividendForm = StockDividendForm()
        dividendForm.symbol = income.symbol
        dividendForm.id = income.id
        dividendForm.incomeType = income.type
        self.navigationController?.pushViewController(dividendForm, animated: true)
    }
    
    // Delete Transaction and update StockData
    func deleteIncome(_ income: StockIncome){
        let stockGeneral = StockGeneral()
        stockGeneral.deleteStockIncome(String(income.id), symbol: income.symbol)
        
        let incomeDB = StockIncomeDB()
        stockIncomes = incomeDB.getIncomes()
        if (stockIncomes.isEmpty){
            self.incomeTable.isHidden = true
        } else {
            self.incomeTable.isHidden = false
        }
        incomeDB.close()
        
        // Load Stock Portfolio
        self.incomeTable.reloadData()
    }
    
    // Show income details
    func detailsIncome(_ income: StockIncome){
        let incomeDetails = StockIncomeDetailsView()
        incomeDetails.income = income
        self.navigationController?.pushViewController(incomeDetails, animated: true)
    }
    
    //Shows alert yo choose income type
    @IBAction func incomeMenu(){
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
        let dividendAction = UIAlertAction(title: NSLocalizedString("Dividendo", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
            self.addIncome(Constants.IncomeType.DIVIDEND)
        })
        let jcpAction = UIAlertAction(title: NSLocalizedString("Juros sobre Capital", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
            self.addIncome(Constants.IncomeType.JCP)
        })
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancelar", comment: ""), style: .default, handler: {(action: UIAlertAction) -> Void in
            
        })
        
        alertController.addAction(dividendAction)
        alertController.addAction(jcpAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: false, completion: nil)
    }
    
    func addIncome(_ type: Int){
        switch (type) {
        case Constants.IncomeType.DIVIDEND:
            let dividendForm = StockDividendForm()
            dividendForm.incomeType = type
            self.navigationController?.pushViewController(dividendForm, animated: true)
            break
        case Constants.IncomeType.JCP:
            let dividendForm = StockDividendForm()
            dividendForm.incomeType = type
            self.navigationController?.pushViewController(dividendForm, animated: true)
            break
        default:
            break
        }
    }
}