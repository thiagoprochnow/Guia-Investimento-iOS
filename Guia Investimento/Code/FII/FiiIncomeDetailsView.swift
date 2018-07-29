//
//  FiiIncomeDetailsView.swift
//  Guia Investimento
//
//  Created by Felipe on 11/07/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
import UIKit

class FiiIncomeDetailsView: UIViewController{
    @IBOutlet var bgView: UIView!
    @IBOutlet var symbolLabel: UILabel!
    @IBOutlet var quantityLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var perLabel: UILabel!
    @IBOutlet var grossLabel: UILabel!
    @IBOutlet var taxLabel: UILabel!
    @IBOutlet var liquidLabel: UILabel!
    
    var income: FiiIncome!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set rounded border and shadow to Details Overview
        bgView.layer.masksToBounds = false
        bgView.layer.cornerRadius = 6
        bgView.layer.shadowColor = UIColor.black.cgColor
        bgView.layer.shadowOpacity = 0.5
        bgView.layer.shadowOffset = CGSize(width: -1, height: 1)
        bgView.layer.shadowRadius = 5
        
        symbolLabel.text = income.symbol
        quantityLabel.text = String(income.affectedQuantity)
        
        //Get Date
        let timestamp = income.exdividendTimestamp
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = "dd/MM/yyyy"
        let dateString = formatter.string(from: date)
        dateLabel.text = dateString
        
        perLabel.text = Utils.doubleToRealCurrency(value: income.perFii)
        grossLabel.text = Utils.doubleToRealCurrency(value: income.grossIncome)
        taxLabel.text = Utils.doubleToRealCurrency(value: income.tax)
        liquidLabel.text = Utils.doubleToRealCurrency(value: income.liquidIncome)
    }
}
