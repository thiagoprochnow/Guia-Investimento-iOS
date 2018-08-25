//
//  FixedData.swift
//  Guia Investimento
//
//  Created by Felipe on 13/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation

class OthersData {
    var id = 0
    var symbol = ""
    var buyTotal = 0.0
    var sellTotal = 0.0
    var netGain = 0.0
    var tax = 0.0
    var variation = 0.0
    var totalGain = 0.0
    var objectivePercent = 0.0
    var currentPercent = 0.0
    var currentTotal = 0.0
    var status = 0
    var brokerage = 0.0
    var incomeTotal = 0.0
    var incomeTax = 0.0
    var lastUpdate = 0
    var updateStatus = Constants.UpdateStatus.UPDATED
}
