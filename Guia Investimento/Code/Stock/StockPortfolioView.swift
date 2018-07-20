//
//  StockPortfolio.swift
//  Guia Investimento
//
//  Created by Felipe on 31/05/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import UIKit

class StockPortfolioView: UIViewController {
    @IBOutlet var fab: UIImageView!
    @IBOutlet var bgView: UIView!
    @IBOutlet var currentTotal: UILabel!
    @IBOutlet var soldTotal: UILabel!
    @IBOutlet var buyTotal: UILabel!
    @IBOutlet var variationTotal: UILabel!
    @IBOutlet var incomeTotal: UILabel!
    @IBOutlet var brokerageTotal: UILabel!
    @IBOutlet var totalGain: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Background Color
        self.view.backgroundColor = UIColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1)
        
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
        let tapBuyStock = UITapGestureRecognizer(target: self, action: #selector(StockDataView.buyStock))
        fab.addGestureRecognizer(tapBuyStock)
        
        let portfolioDB = StockPortfolioDB()
        let portfolio = portfolioDB.getPortfolio()
        portfolioDB.close()
        
        self.currentTotal.text = Utils.doubleToRealCurrency(value: portfolio.currentTotal)
        self.soldTotal.text = Utils.doubleToRealCurrency(value: portfolio.soldTotal)
        self.buyTotal.text = Utils.doubleToRealCurrency(value: portfolio.buyTotal)
        self.variationTotal.text = Utils.doubleToRealCurrency(value: portfolio.variationTotal)
        self.incomeTotal.text = Utils.doubleToRealCurrency(value: portfolio.incomeTotal)
        self.brokerageTotal.text = Utils.doubleToRealCurrency(value: portfolio.brokerage)
        self.totalGain.text = Utils.doubleToRealCurrency(value: portfolio.totalGain)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let portfolioDB = StockPortfolioDB()
        let portfolio = portfolioDB.getPortfolio()
        portfolioDB.close()
        
        self.currentTotal.text = Utils.doubleToRealCurrency(value: portfolio.currentTotal)
        self.soldTotal.text = Utils.doubleToRealCurrency(value: portfolio.soldTotal)
        self.buyTotal.text = Utils.doubleToRealCurrency(value: portfolio.buyTotal)
        self.variationTotal.text = Utils.doubleToRealCurrency(value: portfolio.variationTotal)
        self.incomeTotal.text = Utils.doubleToRealCurrency(value: portfolio.incomeTotal)
        self.brokerageTotal.text = Utils.doubleToRealCurrency(value: portfolio.brokerage)
        self.totalGain.text = Utils.doubleToRealCurrency(value: portfolio.totalGain)
    }
    
    // Open form to buy stocks
    @IBAction func buyStock(){
        let buyStockForm = BuyStockForm()
        self.navigationController?.pushViewController(buyStockForm, animated: true)
    }
}
