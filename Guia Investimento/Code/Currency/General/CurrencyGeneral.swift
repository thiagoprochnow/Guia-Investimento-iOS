//
//  CurrencyGeneral.swift
//  Guia Investimento
//
//  Created by Felipe on 25/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
class CurrencyGeneral {
    
    // update CurrencyData according to all transactions already occured. Similar to Android app version of
    // this function.
    func updateCurrencyData(_ symbol: String, type: Int) -> Bool{
        let dataDB = CurrencyDataDB()
        let transactionDB = CurrencyTransactionDB()
        let currencyTransactions = transactionDB.getTransactionsBySymbol(symbol)
        transactionDB.close()

        if(currencyTransactions.count > 0 ){
            // Final value to be inserted in CurrencyData
            var quantityTotal = 0.0
            var buyValue = 0.0
            // Buy quantity and total is to calculate correct medium buy price
            // Medium price is only for buys
            var buyQuantity = 0.0
            var buyTotal = 0.0
            var mediumPrice = 0.0
            var currentType = -1
            // Used for brokerage calculation for buy and sell
            // See file calculo brokerage.txt for math in Android version github
            var buyBrokerage = 0.0
            var buyQuantityBrokerage = 0.0
            var sellBrokerage = 0.0
            var soldBuyValue = 0.0
        
            currencyTransactions.forEach{ transaction in
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
            let currencyData = dataDB.getDataBySymbol(symbol)
            
            // In case it is Delete Transaction or Sell which does not update values
            var currentTotal = 0.0
            var variation = 0.0
            if(currencyData.id != 0){
                let currentPrice = currencyData.currentPrice
                currentTotal = currentPrice * quantityTotal
                variation = currentTotal - buyTotal
            }
            
            currencyData.symbol = symbol
            currencyData.quantity = quantityTotal
            currencyData.buyValue = buyValue
            if((type == Constants.TypeOp.DELETE_TRANSACTION || type == Constants.TypeOp.SELL) && currencyData.id != 0){
                currencyData.currentTotal = currentTotal
                currencyData.variation = variation
            }
            currencyData.mediumPrice = mediumPrice
            currencyData.brokerage = buyBrokerage
            
            if(quantityTotal > 0){
                // Set currency as active
                currencyData.status = Constants.Status.ACTIVE
            } else {
                // Set currency as sold
                currencyData.status = Constants.Status.SOLD
            }
            
            dataDB.save(currencyData)
            dataDB.close()
            updateSoldCurrencyData(symbol, soldBuyValue: soldBuyValue, sellBrokerage: sellBrokerage)
            return true
        } else {
            dataDB.close()
            return false
        }
    }
    
    // Reads the CurrencyTransaction entries and calculates value for SoldCurrencyData for this symbol
    func updateSoldCurrencyData(_ symbol:String, soldBuyValue: Double, sellBrokerage: Double){
        let soldDataDB = SoldCurrencyDataDB()
        let transactionDB = CurrencyTransactionDB()
        let currencyTransactions = transactionDB.getTransactionsBySymbol(symbol)
        transactionDB.close()
        
        if(currencyTransactions.count > 0){
            var quantityTotal: Double = 0.0
            var soldTotal: Double = 0.0
            var sellMediumPrice: Double = 0.0
            
            currencyTransactions.forEach{ transaction in
                let currentyType = transaction.type
                
                if(currentyType == Constants.TypeOp.SELL){
                    quantityTotal += Double(transaction.quantity)
                    soldTotal += Double(transaction.quantity) * transaction.price
                    sellMediumPrice = soldTotal/Double(quantityTotal)
                }
            }
            
            // If there is any sold currency
            if (quantityTotal > 0){
                let soldCurrencyData = soldDataDB.getDataBySymbol(symbol)
                let sellGain = soldTotal - soldBuyValue - sellBrokerage
                
                soldCurrencyData.symbol = symbol
                soldCurrencyData.quantity = quantityTotal
                soldCurrencyData.buyValue = soldBuyValue
                soldCurrencyData.mediumPrice = sellMediumPrice
                soldCurrencyData.currentTotal = soldTotal
                soldCurrencyData.sellGain = sellGain
                soldCurrencyData.brokerage = sellBrokerage
                soldDataDB.save(soldCurrencyData)
            }
        }
        soldDataDB.close()
    }
    
    // Delete currency data, all its transactions
    func deleteCurrency(_ symbol: String){
        let dataDB = CurrencyDataDB()
        let transactionDB = CurrencyTransactionDB()
        let soldDataDB = SoldCurrencyDataDB()
        
        dataDB.deleteBySymbol(symbol)
        transactionDB.deleteBySymbol(symbol)
        soldDataDB.deleteBySymbol(symbol)
        Utils.updateCurrencyPortfolio()
        dataDB.close()
        transactionDB.close()
        soldDataDB.close()
    }
}
