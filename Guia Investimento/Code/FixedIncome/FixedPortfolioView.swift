//
//  FixedPortfolio.swift
//  Guia Investimento
//
//  Created by Felipe on 31/05/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import UIKit

class FixedPortfolioView: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var fab: UIImageView!
    @IBOutlet var bgView: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var emptyListView: UILabel!
    var portfolio: FixedPortfolio!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Background Color
        self.view.backgroundColor = UIColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1)
        
        // Table View
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.separatorStyle = .none
        let xibPortfolio = UINib(nibName: "FixedPortfolioCell", bundle: nil)
        let xibPie = UINib(nibName: "FixedPieChartCell", bundle: nil)
        self.tableView.register(xibPortfolio, forCellReuseIdentifier: "cellPortfolio")
        self.tableView.register(xibPie, forCellReuseIdentifier: "cellPie")
        
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
        let portfolioDB = FixedPortfolioDB()
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
            // Load Fixed Portfolio information on cell
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "cellPortfolio") as! FixedPortfolioCell
            // Do not show highlight when selected
            cell.selectionStyle = .none
            let locale = Locale(identifier: "pt_BR")
            let buyTotal = portfolio.buyTotal
            let totalGainPercent = "(" + String(format: "%.2f", locale: locale, arguments: [portfolio.totalGain/buyTotal * 100]) + "%)"
            cell.currentTotal.text = Utils.doubleToRealCurrency(value: portfolio.currentTotal)
            cell.soldTotal.text = Utils.doubleToRealCurrency(value: portfolio.soldTotal)
            cell.buyTotal.text = Utils.doubleToRealCurrency(value: portfolio.buyTotal)
            cell.totalGain.text = Utils.doubleToRealCurrency(value: portfolio.totalGain)
            cell.totalPercent.text = totalGainPercent
            
            if(portfolio.totalGain >= 0){
                cell.totalGain.textColor = UIColor(red: 139/255, green: 195/255, blue: 74/255, alpha: 1)
                cell.totalPercent.textColor = UIColor(red: 139/255, green: 195/255, blue: 74/255, alpha: 1)
            } else {
                cell.totalGain.textColor = UIColor(red: 244/255, green: 67/255, blue: 54/255, alpha: 1)
                cell.totalPercent.textColor = UIColor(red: 244/255, green: 67/255, blue: 54/255, alpha: 1)
            }
            
            return cell
        } else if(linha == 1){
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "cellPie") as! FixedPieChartCell
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
    
    // Open form to buy curencies
    @IBAction func buyFixed(){
        let buyFixedForm = BuyFixedForm()
        self.navigationController?.pushViewController(buyFixedForm, animated: true)
    }
}
