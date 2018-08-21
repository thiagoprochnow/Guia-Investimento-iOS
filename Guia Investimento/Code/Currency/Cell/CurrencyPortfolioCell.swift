//
//  TreasuryPortfolioCell.swift
//  Guia Investimento
//
//  Created by Felipe on 20/07/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
import UIKit

class CurrencyPortfolioCell: UITableViewCell {
    @IBOutlet var bgView: UIView!
    @IBOutlet var currentTotal: UILabel!
    @IBOutlet var soldTotal: UILabel!
    @IBOutlet var buyTotal: UILabel!
    @IBOutlet var totalGain: UILabel!
    @IBOutlet var totalPercent: UILabel!
    
    // Customize the Cell
    override func layoutSubviews() {
        super.layoutSubviews()
        bgView.layer.masksToBounds = false
        
        bgView.layer.cornerRadius = 6
        bgView.layer.shadowColor = UIColor.black.cgColor
        bgView.layer.shadowOpacity = 0.5
        bgView.layer.shadowOffset = CGSize(width: -1, height: 1)
        bgView.layer.shadowRadius = 5
    }
}