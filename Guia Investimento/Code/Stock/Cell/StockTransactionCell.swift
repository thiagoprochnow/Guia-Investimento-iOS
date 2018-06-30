//
//  StockTransactionCell.swift
//  Guia Investimento
//
//  Created by Felipe on 29/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
import UIKit

class StockTransactionCell: UITableViewCell {
    @IBOutlet var quantity: UILabel!
    @IBOutlet var price: UILabel!
    @IBOutlet var date: UILabel!
    @IBOutlet var total: UILabel!
    @IBOutlet var type: UILabel!
    
    // Customize the Cell
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
