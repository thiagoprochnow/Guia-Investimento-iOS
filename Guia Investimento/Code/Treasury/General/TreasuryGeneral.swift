//
//  TreasuryGeneral.swift
//  Guia Investimento
//
//  Created by Felipe on 25/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
class TreasuryGeneral {
    
    // update TreasuryData according to all transactions already occured. Similar to Android app version of
    // this function.
    func updateTreasuryData(_ symbol: String, type: Int) -> Bool{
        let dataDB = TreasuryDataDB()
        let transactionDB = TreasuryTransactionDB()
        let treasuryTransactions = transactionDB.getTransactionsBySymbol(symbol)
        transactionDB.close()

        if(treasuryTransactions.count > 0 ){
            // Final value to be inserted in TreasuryData
            var quantityTotal = 0.0
            var buyValue = 0.0
            // Buy quantity and total is to calculate correct medium buy price
            // Medium price is only for buys
            var buyQuantity = 0.0
            var buyTotal = 0.0
            var receiveIncome = 0.0
            var taxIncome = 0.0
            var mediumPrice = 0.0
            var currentType = -1
            // Used for brokerage calculation for buy and sell
            // See file calculo brokerage.txt for math in Android version github
            var buyBrokerage = 0.0
            var buyQuantityBrokerage = 0.0
            var sellBrokerage = 0.0
            var soldBuyValue = 0.0
        
            treasuryTransactions.forEach{ transaction in
                currentType = transaction.type
                
                switch(currentType){
                case Constants.TypeOp.BUY:
                    buyQuantity += Double(transaction.quantity)
                    buyTotal += Double(transaction.quantity) * transaction.price
                    quantityTotal += Double(transaction.quantity)
                    buyValue += Double(transaction.quantity) * transaction.price
                    mediumPrice = buyValue/quantityTotal
                    // Brokerage
                    buyBrokerage += transaction.brokerage
                    buyQuantityBrokerage += Double(transaction.quantity)
                    break
                case Constants.TypeOp.SELL:
                    quantityTotal -= Double(transaction.quantity)
                    buyValue -= Double(transaction.quantity) * mediumPrice
                    // Add the value sold times the current medium buy price
                    soldBuyValue += Double(transaction.quantity) * mediumPrice
                    // Brokerage
                    var partialSell = 0.0;
                    partialSell = buyBrokerage/buyQuantityBrokerage * Double(transaction.quantity)
                    buyBrokerage -= partialSell
                    sellBrokerage += partialSell + transaction.brokerage
                    break
                default: break
                }
            }
            let treasuryData = dataDB.getDataBySymbol(symbol)
            
            // In case it is Delete Transaction or Sell which does not update values
            var currentTotal = 0.0
            var variation = 0.0
            if(treasuryData.id != 0){
                let currentPrice = treasuryData.currentPrice
                currentTotal = currentPrice * quantityTotal
                variation = currentTotal - buyTotal
            }
            
            let incomeDB = TreasuryIncomeDB()
            let incomes = incomeDB.getIncomesBySymbol(symbol)
            incomes.forEach{ income in
                receiveIncome += income.liquidIncome
                taxIncome += income.tax
            }
            
            treasuryData.symbol = symbol
            treasuryData.quantity = quantityTotal
            treasuryData.buyValue = buyValue
            if((type == Constants.TypeOp.DELETE_TRANSACTION || type == Constants.TypeOp.SELL) && treasuryData.id != 0){
                treasuryData.currentTotal = currentTotal
                treasuryData.variation = variation
            }
            treasuryData.netIncome = receiveIncome
            treasuryData.incomeTax = taxIncome
            treasuryData.mediumPrice = mediumPrice
            treasuryData.brokerage = buyBrokerage
            
            if(quantityTotal > 0){
                // Set treasury as active
                treasuryData.status = Constants.Status.ACTIVE
            } else {
                // Set treasury as sold
                treasuryData.status = Constants.Status.SOLD
            }
            
            dataDB.save(treasuryData)
            dataDB.close()
            updateSoldTreasuryData(symbol, soldBuyValue: soldBuyValue, sellBrokerage: sellBrokerage)
            return true
        } else {
            dataDB.close()
            return false
        }
    }
    
    // Reads the TreasuryTransaction entries and calculates value for SoldTreasuryData for this symbol
    func updateSoldTreasuryData(_ symbol:String, soldBuyValue: Double, sellBrokerage: Double){
        let soldDataDB = SoldTreasuryDataDB()
        let transactionDB = TreasuryTransactionDB()
        let treasuryTransactions = transactionDB.getTransactionsBySymbol(symbol)
        transactionDB.close()
        
        if(treasuryTransactions.count > 0){
            var quantityTotal: Double = 0.0
            var soldTotal: Double = 0.0
            var sellMediumPrice: Double = 0.0
            
            treasuryTransactions.forEach{ transaction in
                let currentyType = transaction.type
                
                if(currentyType == Constants.TypeOp.SELL){
                    quantityTotal += Double(transaction.quantity)
                    soldTotal += Double(transaction.quantity) * transaction.price
                    sellMediumPrice = soldTotal/Double(quantityTotal)
                }
            }
            
            // If there is any sold treasury
            if (quantityTotal > 0){
                let soldTreasuryData = soldDataDB.getDataBySymbol(symbol)
                let sellGain = soldTotal - soldBuyValue - sellBrokerage
                
                soldTreasuryData.symbol = symbol
                soldTreasuryData.quantity = quantityTotal
                soldTreasuryData.buyValue = soldBuyValue
                soldTreasuryData.mediumPrice = sellMediumPrice
                soldTreasuryData.currentTotal = soldTotal
                soldTreasuryData.sellGain = sellGain
                soldTreasuryData.brokerage = sellBrokerage
                soldDataDB.save(soldTreasuryData)
            }
        }
        soldDataDB.close()
    }
    
    // Update Total Income on Treasury Data by new income added
    func updateTreasuryDataIncome(_ symbol: String, valueReceived: Double, tax: Double){
        let dataDB = TreasuryDataDB()
        let treasuryData = dataDB.getDataBySymbol(symbol)
        let dbIncome = treasuryData.netIncome
        let dbTax = treasuryData.incomeTax
        let totalIncome = dbIncome + valueReceived
        let totalTax = dbTax + tax
        
        treasuryData.netIncome = totalIncome
        treasuryData.incomeTax = totalTax
        
        dataDB.save(treasuryData)
        
        dataDB.close()
    }
    
    // Delete treasury income from table by using its id
    // symbol is used to update Treasury Data table
    func deleteTreasuryIncome(_ id:String, symbol:String){
        let incomeDB = TreasuryIncomeDB()
        incomeDB.deleteById(Int(id)!)
        incomeDB.close()
        _ = updateTreasuryData(symbol, type: -1)
    }
    
    // Delete treasury data, all its transactions and incomes
    func deleteTreasury(_ symbol: String){
        let dataDB = TreasuryDataDB()
        let transactionDB = TreasuryTransactionDB()
        let soldDataDB = SoldTreasuryDataDB()
        let incomeDB = TreasuryIncomeDB()
        
        dataDB.deleteBySymbol(symbol)
        transactionDB.deleteBySymbol(symbol)
        soldDataDB.deleteBySymbol(symbol)
        incomeDB.deleteBySymbol(symbol)
        Utils.updateTreasuryPortfolio()
        dataDB.close()
        transactionDB.close()
        soldDataDB.close()
        incomeDB.close()
    }
    
    // Get last inserted income timestamp
    func getLastIncomeTime(_ symbol:String) -> String {
        let incomeDB = TreasuryIncomeDB()
        let income = incomeDB.getLastIncome(symbol)
        return String(income.exdividendTimestamp)
    }
}
