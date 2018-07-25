//
//  StockPortfolio.swift
//  Guia Investimento
//
//  Created by Felipe on 31/05/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import UIKit

class StockPortfolioView: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var fab: UIImageView!
    @IBOutlet var bgView: UIView!
    @IBOutlet var tableView: UITableView!
    var portfolio: StockPortfolio!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Background Color
        self.view.backgroundColor = UIColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1)
        
        // Table View
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.separatorStyle = .none
        let xib = UINib(nibName: "StockPortfolioCell", bundle: nil)
        self.tableView.register(xib, forCellReuseIdentifier: "cell")
        
        // Load fab (Floating action button)
        // Set images for each icon
        let fabImg = UIImage(named: "fab")
        fab.image = fabImg
        // Add action to open buy form when tapped
        fab.isUserInteractionEnabled = true
        let tapBuyStock = UITapGestureRecognizer(target: self, action: #selector(StockDataView.buyStock))
        fab.addGestureRecognizer(tapBuyStock)
        
        let portfolioDB = StockPortfolioDB()
        portfolio = portfolioDB.getPortfolio()
        if (portfolio.buyTotal == 0.0){
            self.tableView.isHidden = true
        } else {
            self.tableView.isHidden = false
        }
        portfolioDB.close()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let portfolioDB = StockPortfolioDB()
        portfolio = portfolioDB.getPortfolio()
        if (portfolio.buyTotal == 0.0){
            self.tableView.isHidden = true
        } else {
            self.tableView.isHidden = false
        }
        portfolioDB.close()
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let linha = indexPath.row
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! StockPortfolioCell
        // Do not show highlight when selected
        cell.selectionStyle = .none
        
        if(linha == 0){
            // Load Stock Portfolio information on cell
            let locale = Locale(identifier: "pt_BR")
            let buyTotal = portfolio.buyTotal
            let stockAppreciationPercent = "(" + String(format: "%.2f", locale: locale, arguments: [portfolio.variationTotal/buyTotal * 100]) + "%)"
            let incomePercent = "(" + String(format: "%.2f", locale: locale, arguments: [portfolio.incomeTotal/buyTotal * 100]) + "%)"
            let brokeragePercent = "(" + String(format: "%.2f", locale: locale, arguments: [portfolio.brokerage/buyTotal * 100]) + "%)"
            let totalGainPercent = "(" + String(format: "%.2f", locale: locale, arguments: [portfolio.totalGain/buyTotal * 100]) + "%)"
            cell.currentTotal.text = Utils.doubleToRealCurrency(value: portfolio.currentTotal)
            cell.soldTotal.text = Utils.doubleToRealCurrency(value: portfolio.soldTotal)
            cell.buyTotal.text = Utils.doubleToRealCurrency(value: portfolio.buyTotal)
            cell.variationTotal.text = Utils.doubleToRealCurrency(value: portfolio.variationTotal)
            cell.incomeTotal.text = Utils.doubleToRealCurrency(value: portfolio.incomeTotal)
            cell.brokerageTotal.text = Utils.doubleToRealCurrency(value: portfolio.brokerage)
            cell.totalGain.text = Utils.doubleToRealCurrency(value: portfolio.totalGain)
            cell.variationPercent.text = stockAppreciationPercent
            cell.incomePercent.text = incomePercent
            cell.brokeragePercent.text = brokeragePercent
            cell.totalPercent.text = totalGainPercent
            
            if(portfolio.variationTotal >= 0){
                cell.variationTotal.textColor = UIColor(red: 139/255, green: 195/255, blue: 74/255, alpha: 1)
                cell.variationPercent.textColor = UIColor(red: 139/255, green: 195/255, blue: 74/255, alpha: 1)
            } else {
                cell.variationTotal.textColor = UIColor(red: 244/255, green: 67/255, blue: 54/255, alpha: 1)
                cell.variationPercent.textColor = UIColor(red: 244/255, green: 67/255, blue: 54/255, alpha: 1)
            }
            
            cell.incomeTotal.textColor = UIColor(red: 139/255, green: 195/255, blue: 74/255, alpha: 1)
            cell.incomePercent.textColor = UIColor(red: 139/255, green: 195/255, blue: 74/255, alpha: 1)
            
            cell.brokerageTotal.textColor = UIColor(red: 244/255, green: 67/255, blue: 54/255, alpha: 1)
            cell.brokeragePercent.textColor = UIColor(red: 244/255, green: 67/255, blue: 54/255, alpha: 1)
            
            if(portfolio.totalGain >= 0){
                cell.totalGain.textColor = UIColor(red: 139/255, green: 195/255, blue: 74/255, alpha: 1)
                cell.totalPercent.textColor = UIColor(red: 139/255, green: 195/255, blue: 74/255, alpha: 1)
            } else {
                cell.totalGain.textColor = UIColor(red: 244/255, green: 67/255, blue: 54/255, alpha: 1)
                cell.totalPercent.textColor = UIColor(red: 244/255, green: 67/255, blue: 54/255, alpha: 1)
            }
            
            return cell
        } else {
            cell.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (portfolio.buyTotal == 0.0){
            return 0
        } else {
            return 1
        }
    }
    
    // Open form to buy stocks
    @IBAction func buyStock(){
        let buyStockForm = BuyStockForm()
        self.navigationController?.pushViewController(buyStockForm, animated: true)
    }
}
