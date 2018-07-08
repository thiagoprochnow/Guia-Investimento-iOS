//
//  StockIncomesView.swift
//  Guia Investimento
//
//  Created by Felipe on 29/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
import UIKit
class StockIncomesView: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var bgView: UIView!
    @IBOutlet var boughtLabel: UILabel!
    @IBOutlet var grossLabel: UILabel!
    @IBOutlet var taxLabel: UILabel!
    @IBOutlet var liquidLabel: UILabel!
    @IBOutlet var fab: UIImageView!
    @IBOutlet var incomeTable: UITableView!
    var stockIncomes: Array<StockIncome> = []
    
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
        //let tapBuyStock = UITapGestureRecognizer(target: self, action: #selector(StockDetailsView.incomeMenu))
        //fab.addGestureRecognizer(tapBuyStock)
        
        // Table View
        self.incomeTable.dataSource = self
        self.incomeTable.delegate = self
        self.incomeTable.separatorStyle = .none
        let xib = UINib(nibName: "StockIncomeCell", bundle: nil)
        self.incomeTable.register(xib, forCellReuseIdentifier: "cell")
        
        // Load Stock Incomes values
        let incomeDB = StockIncomeDB()
        stockIncomes = incomeDB.getIncomesBySymbol(symbol)
        incomeDB.close()
        
        // Load Stock Data
        let dataDB = StockDataDB()
        let stockData = dataDB.getDataBySymbol(symbol)
        dataDB.close()
        boughtLabel.text = Utils.doubleToRealCurrency(value: stockData.buyValue)
        grossLabel.text = Utils.doubleToRealCurrency(value: stockData.netIncome + stockData.tax)
        taxLabel.text = Utils.doubleToRealCurrency(value: stockData.tax)
        liquidLabel.text = Utils.doubleToRealCurrency(value: stockData.netIncome)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Load all Stock Incomes of a symbol to show on this list
        let incomeDB = StockIncomeDB()
        stockIncomes = incomeDB.getIncomesBySymbol(symbol)
        if (stockIncomes.isEmpty){
            self.incomeTable.isHidden = true
        } else {
            self.incomeTable.isHidden = false
        }
        incomeDB.close()
        // Reload data every time StockDataView is shown
        self.incomeTable.reloadData()
        
        // Load Stock Data
        let dataDB = StockDataDB()
        let stockData = dataDB.getDataBySymbol(symbol)
        dataDB.close()
        boughtLabel.text = Utils.doubleToRealCurrency(value: stockData.buyValue)
        grossLabel.text = Utils.doubleToRealCurrency(value: stockData.netIncome + stockData.tax)
        taxLabel.text = Utils.doubleToRealCurrency(value: stockData.tax)
        liquidLabel.text = Utils.doubleToRealCurrency(value: stockData.netIncome)
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
            formatter.timeZone = TimeZone(identifier: "UTC")
            formatter.dateFormat = "dd/MM/yyyy"
            let dateString = formatter.string(from: date)
            cell.date.text = dateString
            
            cell.total.text = Utils.doubleToRealCurrency(value: income.perStock * Double(income.affectedQuantity))
        } else {
            cell.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
}
