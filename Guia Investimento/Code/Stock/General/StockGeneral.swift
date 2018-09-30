//
//  StockGeneral.swift
//  Guia Investimento
//
//  Created by Felipe on 25/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
class StockGeneral {
    
    // update StockData according to all transactions already occured. Similar to Android app version of
    // this function.
    func updateStockData(_ symbol: String, type: Int) -> Bool{
        let dataDB = StockDataDB()
        let transactionDB = StockTransactionDB()
        let stockTransactions = transactionDB.getTransactionsBySymbol(symbol)
        transactionDB.close()

        if(stockTransactions.count > 0 ){
            // Final value to be inserted in StockData
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
        
            stockTransactions.forEach{ transaction in
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
            let stockData = dataDB.getDataBySymbol(symbol)
            
            // In case it is Delete Transaction, Bonification or Sell which does not update values
            var currentTotal = 0.0
            var variation = 0.0
            if(stockData.id != 0){
                let currentPrice = stockData.currentPrice
                currentTotal = currentPrice * quantityTotal
                variation = currentTotal - buyTotal
            }
            
            let incomeDB = StockIncomeDB()
            let incomes = incomeDB.getIncomesBySymbol(symbol)
            incomes.forEach{ income in
                receiveIncome += income.liquidIncome
                taxIncome += income.tax
            }
            
            stockData.symbol = symbol
            stockData.quantity = Int(quantityTotal)
            stockData.buyValue = buyValue
            if((type == Constants.TypeOp.DELETE_TRANSACTION || type == Constants.TypeOp.BONIFICATION || type == Constants.TypeOp.SELL) && stockData.id != 0){
                stockData.currentTotal = currentTotal
                stockData.variation = variation
            }
            stockData.netIncome = receiveIncome
            stockData.incomeTax = taxIncome
            stockData.mediumPrice = mediumPrice
            stockData.brokerage = buyBrokerage
            
            if(quantityTotal > 0){
                // Set stock as active
                stockData.status = Constants.Status.ACTIVE
            } else {
                // Set stock as sold
                stockData.status = Constants.Status.SOLD
            }
            
            dataDB.save(stockData)
            dataDB.close()
            updateSoldStockData(symbol, soldBuyValue: soldBuyValue, sellBrokerage: sellBrokerage)
            return true
        } else {
            dataDB.close()
            return false
        }
    }
    
    // Reads the StockTransaction entries and calculates value for SoldStockData for this symbol
    func updateSoldStockData(_ symbol:String, soldBuyValue: Double, sellBrokerage: Double){
        let soldDataDB = SoldStockDataDB()
        let transactionDB = StockTransactionDB()
        let stockTransactions = transactionDB.getTransactionsBySymbol(symbol)
        transactionDB.close()
        
        if(stockTransactions.count > 0){
            var quantityTotal: Double = 0.0
            var soldTotal: Double = 0.0
            var sellMediumPrice: Double = 0.0
            
            stockTransactions.forEach{ transaction in
                let currentyType = transaction.type
                
                if(currentyType == Constants.TypeOp.SELL){
                    quantityTotal += Double(transaction.quantity)
                    soldTotal += Double(transaction.quantity) * transaction.price
                    sellMediumPrice = soldTotal/Double(quantityTotal)
                }
            }
            
            // If there is any sold stock
            if (quantityTotal > 0){
                let soldStockData = soldDataDB.getDataBySymbol(symbol)
                let sellGain = soldTotal - soldBuyValue - sellBrokerage
                
                soldStockData.symbol = symbol
                soldStockData.quantity = Int(quantityTotal)
                soldStockData.buyValue = soldBuyValue
                soldStockData.mediumPrice = sellMediumPrice
                soldStockData.currentTotal = soldTotal
                soldStockData.sellGain = sellGain
                soldStockData.brokerage = sellBrokerage
                soldDataDB.save(soldStockData)
            }
        }
        soldDataDB.close()
    }
    
    // Get stock quantity that will receive the dividend per stock
    // symbol is to query by specific symbol only
    // income timestamp is to query only the quantity of stocks transactions before the timestamp
    func getStockQuantity(symbol: String, incomeTimestamp: Int) -> Double {
        let stockTransactionDB = StockTransactionDB()
        let stockTransactions = stockTransactionDB.getTransactionsByTimestamp(symbol, timestamp: incomeTimestamp)
        stockTransactionDB.close()
        
        if(stockTransactions.count > 0 ){
            var quantityTotal: Double = 0.0
            stockTransactions.forEach{ transaction in
                let currentType = transaction.type
                switch(currentType){
                    case Constants.TypeOp.BUY:
                        quantityTotal += Double(transaction.quantity)
                        break
                    case Constants.TypeOp.SELL:
                        quantityTotal -= Double(transaction.quantity)
                        break
                    case Constants.TypeOp.BONIFICATION:
                        quantityTotal += Double(transaction.quantity)
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
    
    // Update Total Income on Stock Data by new income added
    func updateStockDataIncome(_ symbol: String, valueReceived: Double, tax: Double){
        let dataDB = StockDataDB()
        let stockData = dataDB.getDataBySymbol(symbol)
        let dbIncome = stockData.netIncome
        let dbTax = stockData.incomeTax
        let totalIncome = dbIncome + valueReceived
        let totalTax = dbTax + tax
        let totalGain = totalIncome + stockData.variation
        
        stockData.netIncome = totalIncome
        stockData.incomeTax = totalTax
        stockData.totalGain = totalGain
        
        dataDB.save(stockData)
        
        dataDB.close()
    }
    
    // By using the timestamp of bought/sold stock, function will check if any added income
    // is affected by this buy/sell stock
    // If any income if affected, it will update income line with new value by using
    // getStockQuantity function for each affected line
    func updateStockIncomes(_ symbol:String, timestamp:Int){
        let incomeDB = StockIncomeDB()
        let stockIncomes = incomeDB.getIncomesByTimestamp(symbol, timestamp: timestamp)
        incomeDB.close()
        
        stockIncomes.forEach{ income in
            let incomeTimestamp = income.exdividendTimestamp
            let quantity = getStockQuantity(symbol: symbol, incomeTimestamp: incomeTimestamp)
            let perStock = income.perStock
            let incomeType = income.type
            let receiveTotal = Double(quantity) * perStock
            
            income.affectedQuantity = Int(quantity)
            income.grossIncome = receiveTotal
            if(incomeType == Constants.IncomeType.DIVIDEND){
                income.liquidIncome = receiveTotal
            } else {
                let tax = receiveTotal * 0.15
                let receiveLiquid = receiveTotal - tax
                income.tax = tax
                income.liquidIncome = receiveLiquid
            }
            let incomeDB = StockIncomeDB()
            incomeDB.save(income)
            incomeDB.close()
        }
    }
    
    // Delete stock income from table by using its id
    // symbol is used to update Stock Data table
    func deleteStockIncome(_ id:String, symbol:String){
        let incomeDB = StockIncomeDB()
        incomeDB.deleteById(Int(id)!)
        incomeDB.close()
        _ = updateStockData(symbol, type: -1)
    }
    
    // Delete stock data, all its transactions and incomes
    func deleteStock(_ symbol: String){
        let dataDB = StockDataDB()
        let transactionDB = StockTransactionDB()
        let soldDataDB = SoldStockDataDB()
        let incomeDB = StockIncomeDB()
        
        dataDB.deleteBySymbol(symbol)
        transactionDB.deleteBySymbol(symbol)
        soldDataDB.deleteBySymbol(symbol)
        incomeDB.deleteBySymbol(symbol)
        Utils.updateStockPortfolio()
        dataDB.close()
        transactionDB.close()
        soldDataDB.close()
        incomeDB.close()
    }
    
    // Get last inserted income timestamp
    func getLastIncomeTime(_ symbol:String) -> String {
        let incomeDB = StockIncomeDB()
        let income = incomeDB.getLastIncome(symbol)
        return String(income.exdividendTimestamp)
    }
}
