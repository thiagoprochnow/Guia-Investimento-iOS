//
//  PortfolioMainView.swift
//  Guia Investimento
//
//  Created by Felipe on 27/05/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import UIKit

class PortfolioMainController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var emptyListView: UILabel!
    var portfolio: Portfolio!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Titulo
        self.title = "Carteira Completa"
        self.view.backgroundColor = UIColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1)
        Utils.changeStatusBar()
        
        // Table View
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.separatorStyle = .none
        let xibPortfolio = UINib(nibName: "PortfolioCell", bundle: nil)
        let xibPie = UINib(nibName: "PortfolioPieChartCell", bundle: nil)
        self.tableView.register(xibPortfolio, forCellReuseIdentifier: "cellPortfolio")
        self.tableView.register(xibPie, forCellReuseIdentifier: "cellPie")
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Menu",
            style: UIBarButtonItemStyle.plain,
            target: self,
            action: #selector(didTapOpenButton)
        )
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        
        // Create custom Back Button
        let backButton = UIBarButtonItem(title: "Voltar", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButton
        navigationItem.backBarButtonItem?.tintColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let portfolioDB = PortfolioDB()
        portfolio = portfolioDB.getPortfolio()
        if (portfolio.buyTotal == 0.0){
            self.tableView.isHidden = true
            self.emptyListView.isHidden = false
        } else {
            self.tableView.isHidden = false
            self.emptyListView.isHidden = true
        }
        portfolioDB.close()
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let linha = indexPath.row
        
        if(linha == 0){
            // Load Portfolio information on cell
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "cellPortfolio") as! PortfolioCell
            // Do not show highlight when selected
            cell.selectionStyle = .none
            let locale = Locale(identifier: "pt_BR")
            let buyTotal = portfolio.buyTotal
            let portfolioAppreciationPercent = "(" + String(format: "%.2f", locale: locale, arguments: [portfolio.variationTotal/buyTotal * 100]) + "%)"
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
            cell.variationPercent.text = portfolioAppreciationPercent
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
        } else if(linha == 1){
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "cellPie") as! PortfolioPieChartCell
            // Do not show highlight when selected
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = UITableViewCell()
            cell.isHidden = true
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (portfolio.buyTotal == 0.0){
            return 0
        } else {
            return 2
        }
    }
    
    @objc func didTapOpenButton(_ sender: UIBarButtonItem) {
        if let drawerController = navigationController?.parent as? KYDrawerController {
            drawerController.setDrawerState(.opened, animated: true)
        }
    }
}
