//
//  FiiGeneral.swift
//  Guia Investimento
//
//  Created by Felipe on 25/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
class FiiGeneral {
    
    // update FiiData according to all transactions already occured. Similar to Android app version of
    // this function.
    func updateFiiData(_ symbol: String, type: Int) -> Bool{
        let dataDB = FiiDataDB()
        let transactionDB = FiiTransactionDB()
        let fiiTransactions = transactionDB.getTransactionsBySymbol(symbol)
        transactionDB.close()

        if(fiiTransactions.count > 0 ){
            // Final value to be inserted in FiiData
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
            var bonificationQuantity = 0.0
            // Used for brokerage calculation for buy and sell
            // See file calculo brokerage.txt for math in Android version github
            var buyBrokerage = 0.0
            var buyQuantityBrokerage = 0.0
            var sellBrokerage = 0.0
            var soldBuyValue = 0.0
        
            fiiTransactions.forEach{ transaction in
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
                case Constants.TypeOp.BONIFICATION:
                    bonificationQuantity += Double(transaction.quantity)
                    break
                case Constants.TypeOp.SPLIT:
                    buyQuantity = Double(transaction.quantity)
                    quantityTotal = quantityTotal * Double(transaction.quantity)
                    bonificationQuantity = bonificationQuantity * Double(transaction.quantity)
                    mediumPrice = mediumPrice/Double(transaction.quantity)
                    break
                case Constants.TypeOp.GROUPING:
                    buyQuantity = buyQuantity/Double(transaction.quantity)
                    quantityTotal = quantityTotal/Double(transaction.quantity)
                    bonificationQuantity = bonificationQuantity/Double(transaction.quantity)
                    mediumPrice = mediumPrice*Double(transaction.quantity)
                    break
                default: break
                }
            }
            // Adds the bonification after the buyValue is totally calculated
            // Bonification cannot influence on the buy value
            quantityTotal += bonificationQuantity
            let fiiData = dataDB.getDataBySymbol(symbol)
            
            // In case it is Delete Transaction, Bonification or Sell which does not update values
            var currentTotal = 0.0
            var variation = 0.0
            if(fiiData.id != 0){
                let currentPrice = fiiData.currentPrice
                currentTotal = currentPrice * quantityTotal
                variation = currentTotal - buyTotal
            }
            
            let incomeDB = FiiIncomeDB()
            let incomes = incomeDB.getIncomesBySymbol(symbol)
            incomes.forEach{ income in
                receiveIncome += income.liquidIncome
                taxIncome += income.tax
            }
            
            fiiData.symbol = symbol
            fiiData.quantity = Int(quantityTotal)
            fiiData.buyValue = buyValue
            if((type == Constants.TypeOp.DELETE_TRANSACTION || type == Constants.TypeOp.BONIFICATION || type == Constants.TypeOp.SELL) && fiiData.id != 0){
                fiiData.currentTotal = currentTotal
                fiiData.variation = variation
            }
            fiiData.netIncome = receiveIncome
            fiiData.incomeTax = taxIncome
            fiiData.mediumPrice = mediumPrice
            fiiData.brokerage = buyBrokerage
            
            if(quantityTotal > 0){
                // Set fii as active
                fiiData.status = Constants.Status.ACTIVE
            } else {
                // Set fii as sold
                fiiData.status = Constants.Status.SOLD
            }
            
            dataDB.save(fiiData)
            dataDB.close()
            updateSoldFiiData(symbol, soldBuyValue: soldBuyValue, sellBrokerage: sellBrokerage)
            return true
        } else {
            dataDB.close()
            return false
        }
    }
    
    // Reads the FiiTransaction entries and calculates value for SoldFiiData for this symbol
    func updateSoldFiiData(_ symbol:String, soldBuyValue: Double, sellBrokerage: Double){
        let soldDataDB = SoldFiiDataDB()
        let transactionDB = FiiTransactionDB()
        let fiiTransactions = transactionDB.getTransactionsBySymbol(symbol)
        transactionDB.close()
        
        if(fiiTransactions.count > 0){
            var quantityTotal: Double = 0.0
            var soldTotal: Double = 0.0
            var sellMediumPrice: Double = 0.0
            
            fiiTransactions.forEach{ transaction in
                let currentyType = transaction.type
                
                if(currentyType == Constants.TypeOp.SELL){
                    quantityTotal += Double(transaction.quantity)
                    soldTotal += Double(transaction.quantity) * transaction.price
                    sellMediumPrice = soldTotal/Double(quantityTotal)
                }
            }
            
            // If there is any sold fii
            if (quantityTotal > 0){
                let soldFiiData = soldDataDB.getDataBySymbol(symbol)
                let sellGain = soldTotal - soldBuyValue - sellBrokerage
                
                soldFiiData.symbol = symbol
                soldFiiData.quantity = Int(quantityTotal)
                soldFiiData.buyValue = soldBuyValue
                soldFiiData.mediumPrice = sellMediumPrice
                soldFiiData.currentTotal = soldTotal
                soldFiiData.sellGain = sellGain
                soldFiiData.brokerage = sellBrokerage
                soldDataDB.save(soldFiiData)
            }
        }
        soldDataDB.close()
    }
    
    // Get fii quantity that will receive the dividend per fii
    // symbol is to query by specific symbol only
    // income timestamp is to query only the quantity of fii transactions before the timestamp
    func getFiiQuantity(symbol: String, incomeTimestamp: Int) -> Double {
        let fiiTransactionDB = FiiTransactionDB()
        let fiiTransactions = fiiTransactionDB.getTransactionsByTimestamp(symbol, timestamp: incomeTimestamp)
        fiiTransactionDB.close()
        
        if(fiiTransactions.count > 0 ){
            var quantityTotal: Double = 0.0
            fiiTransactions.forEach{ transaction in
                let currentType = transaction.type
                switch(currentType){
                    case Constants.TypeOp.BUY:
                        quantityTotal += Double(transaction.quantity)
                        break
                    case Constants.TypeOp.SELL:
                        quantityTotal -= Double(transaction.quantity)
                        break
                    case Constants.TypeOp.SPLIT:
                        quantityTotal = quantityTotal*Double(transaction.quantity)
                        break
                    case Constants.TypeOp.GROUPING:
                        quantityTotal = quantityTotal/Double(transaction.quantity)
                        break
                    default: break
                }
            }
            return quantityTotal
        } else {
            return 0.0
        }
        return 0.0
    }
    
    // Update Total Income on Fii Data by new income added
    func updateFiiDataIncome(_ symbol: String, valueReceived: Double, tax: Double){
        let dataDB = FiiDataDB()
        let fiiData = dataDB.getDataBySymbol(symbol)
        let dbIncome = fiiData.netIncome
        let dbTax = fiiData.incomeTax
        let totalIncome = dbIncome + valueReceived
        let totalTax = dbTax + tax
        let totalGain = totalIncome + fiiData.variation
        
        fiiData.netIncome = totalIncome
        fiiData.incomeTax = totalTax
        fiiData.totalGain = totalGain
        
        dataDB.save(fiiData)
        
        dataDB.close()
    }
    
    // By using the timestamp of bought/sold fii, function will check if any added income
    // is affected by this buy/sell fii
    // If any income if affected, it will update income line with new value by using
    // getFiiQuantity function for each affected line
    func updateFiiIncomes(_ symbol:String, timestamp:Int){
        let incomeDB = FiiIncomeDB()
        let fiiIncomes = incomeDB.getIncomesByTimestamp(symbol, timestamp: timestamp)
        
        fiiIncomes.forEach{ income in
            let incomeTimestamp = income.exdividendTimestamp
            let quantity = getFiiQuantity(symbol: symbol, incomeTimestamp: incomeTimestamp)
            let perFii = income.perFii
            let incomeType = income.type
            let receiveTotal = Double(quantity) * perFii
            
            income.affectedQuantity = Int(quantity)
            income.grossIncome = receiveTotal
            income.liquidIncome = receiveTotal
            incomeDB.save(income)
        }
        incomeDB.close()
    }
    
    // Delete fii income from table by using its id
    // symbol is used to update Fii Data table
    func deleteFiiIncome(_ id:String, symbol:String){
        let incomeDB = FiiIncomeDB()
        incomeDB.deleteById(Int(id)!)
        incomeDB.close()
        _ = updateFiiData(symbol, type: -1)
    }
    
    // Delete fii data, all its transactions and incomes
    func deleteFii(_ symbol: String){
        let dataDB = FiiDataDB()
        let transactionDB = FiiTransactionDB()
        let soldDataDB = SoldFiiDataDB()
        let incomeDB = FiiIncomeDB()
        
        dataDB.deleteBySymbol(symbol)
        transactionDB.deleteBySymbol(symbol)
        soldDataDB.deleteBySymbol(symbol)
        incomeDB.deleteBySymbol(symbol)
        Utils.updateFiiPortfolio()
        dataDB.close()
        transactionDB.close()
        soldDataDB.close()
        incomeDB.close()
    }
    
    // Get last inserted income timestamp
    func getLastIncomeTime(_ symbol:String) -> String {
        let incomeDB = FiiIncomeDB()
        let income = incomeDB.getLastIncome(symbol)
        return String(income.exdividendTimestamp)
    }
}
