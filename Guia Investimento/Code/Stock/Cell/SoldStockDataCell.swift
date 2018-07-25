//
//  StockDataCell.swift
//  Guia Investimento
//
//  Created by Felipe on 03/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
import UIKit

class SoldStockDataCell: UITableViewCell {
    @IBOutlet var bgView: UIView!
    @IBOutlet var bgHeader: UIView!
    @IBOutlet var symbolLabel : UILabel!
    @IBOutlet var quantityLabel: UILabel!
    @IBOutlet var soldLabel: UILabel!
    @IBOutlet var boughtLabel: UILabel!
    @IBOutlet var brokerageLabel: UILabel!
    @IBOutlet var gainLabel: UILabel!
    @IBOutlet var gainPercent: UILabel!
    
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
