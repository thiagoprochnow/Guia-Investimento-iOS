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
            
            
            
            // INCOME CODE HERE
            
            
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
            var quantityTotal: Int = 0
            var soldTotal: Double = 0.0
            var sellMediumPrice: Double = 0.0
            
            stockTransactions.forEach{ transaction in
                let currentyType = transaction.type
                
                if(currentyType == Constants.TypeOp.SELL){
                    quantityTotal += transaction.quantity
                    soldTotal += Double(transaction.quantity) * transaction.price
                    sellMediumPrice = soldTotal/Double(quantityTotal)
                }
            }
            
            // If there is any sold stock
            if (quantityTotal > 0){
                let soldStockData = soldDataDB.getDataBySymbol(symbol)
                let sellGain = soldTotal - soldBuyValue - sellBrokerage
                
                soldStockData.symbol = symbol
                soldStockData.quantity = quantityTotal
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
}
