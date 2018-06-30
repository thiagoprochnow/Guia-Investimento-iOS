//
//  StockIncomesView.swift
//  Guia Investimento
//
//  Created by Felipe on 29/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
import UIKit
class StockIncomesView: UIViewController {
    var symbol: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Income: " + symbol)
    }
}
