//
//  StockData.swift
//  Guia Investimento
//
//  Created by Felipe on 13/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation

class StockData {
    var id = 0
    var symbol = ""
    var quantity = 0
    var buyValue = 0.0
    var netIncome = 0.0
    var incomeTax = 0.0
    var variation = 0.0
    var totalGain = 0.0
    var objectivePercent = 0.0
    var currentPercent = 0.0
    var mediumPrice = 0.0
    var currentPrice = 0.0
    var currentTotal = 0.0
    var status = Constants.UpdateStatus.NOT_UPDATED
    var tax = 0.0
    var brokerage = 0.0
    var lastUpdate = 0
    var updateStatus = 0
    var closingPrice = 0.0
}
