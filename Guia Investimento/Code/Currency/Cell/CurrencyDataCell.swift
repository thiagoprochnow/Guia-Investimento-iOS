//
//  TreasuryDataCell.swift
//  Guia Investimento
//
//  Created by Felipe on 03/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
import UIKit

class CurrencyDataCell: UITableViewCell {
    @IBOutlet var bgView: UIView!
    @IBOutlet var bgHeader: UIView!
    @IBOutlet var alocationImg: UIImageView!
    @IBOutlet var symbolLabel : UILabel!
    @IBOutlet var quantityLabel: UILabel!
    @IBOutlet var currentLabel: UILabel!
    @IBOutlet var boughtLabel: UILabel!
    @IBOutlet var gainLabel: UILabel!
    @IBOutlet var errorIconView: UIImageView!
    @IBOutlet var gainPercent: UILabel!
    @IBOutlet var currentPercent: UILabel!
    
    // Customize the Cell
    override func layoutSubviews() {
        super.layoutSubviews()
        bgView.layer.masksToBounds = false
        
        bgView.layer.cornerRadius = 6
        bgView.layer.shadowColor = UIColor.black.cgColor
        bgView.layer.shadowOpacity = 0.5
        bgView.layer.shadowOffset = CGSize(width: -1, height: 1)
        bgView.layer.shadowRadius = 5
        
        // Set images for each icon
        let alocationIcon = UIImage(named: "current_small")
        alocationImg.image = alocationIcon
        let errorIcon = UIImage(named: "error_icon")
        errorIconView.image = errorIcon
    }
}
