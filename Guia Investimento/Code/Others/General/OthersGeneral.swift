//
//  OthersGeneral.swift
//  Guia Investimento
//
//  Created by Felipe on 25/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
class OthersGeneral {
    
    // update OthersData according to all transactions already occured. Similar to Android app version of
    // this function.
    func updateOthersData(_ symbol: String, type: Int) -> Bool{
        let dataDB = OthersDataDB()
        let transactionDB = OthersTransactionDB()
        let othersTransactions = transactionDB.getTransactionsBySymbol(symbol)
        transactionDB.close()

        if(othersTransactions.count > 0 ){
            var buyTotal = 0.0
            var lastSell = 0.0
            var currentType = -1
            var soldTotal = 0.0
            var receiveIncome = 0.0
            var taxIncome = 0.0
            var liquidIncome = 0.0
            
            othersTransactions.forEach{ transaction in
                currentType = transaction.type
                
                switch(currentType){
                case Constants.TypeOp.BUY:
                    buyTotal += transaction.boughtTotal
                    break
                case Constants.TypeOp.SELL:
                    soldTotal += transaction.boughtTotal
                    lastSell = transaction.boughtTotal
                    break
                default: break
                }
            }
            let othersData = dataDB.getDataBySymbol(symbol)
            othersData.symbol = symbol
            
            // In case it is Delete Transaction or Sell which does not update values
            var currentTotal = 0.0
            if(othersData.id != 0){
                currentTotal = othersData.currentTotal
            } else {
                currentTotal = buyTotal
                othersData.currentTotal = currentTotal
            }
            
            if((type == Constants.TypeOp.SELL) && othersData.id != 0){
                currentTotal -= lastSell
                othersData.currentTotal = currentTotal
            }
            
            let incomeDB = OthersIncomeDB()
            let incomes = incomeDB.getIncomesBySymbol(symbol)
            incomes.forEach{ income in
                receiveIncome += income.grossIncome
                taxIncome += income.tax
            }
            liquidIncome = receiveIncome - taxIncome
            
            let variation = currentTotal + soldTotal - buyTotal
            let totalGain = currentTotal + soldTotal + liquidIncome - buyTotal
            
            // Set others as active
            othersData.buyTotal = buyTotal
            othersData.sellTotal = soldTotal
            othersData.totalGain = totalGain
            othersData.status = Constants.Status.ACTIVE
            othersData.variation = variation
            othersData.incomeTax = taxIncome
            othersData.incomeTotal = receiveIncome
            othersData.liquidIncome = liquidIncome
            
            dataDB.save(othersData)
            dataDB.close()
            return true
        } else {
            dataDB.close()
            return false
        }
    }
    
    // Update Total Income on Others Data by new income added
    func updateOthersDataIncome(_ symbol: String, valueReceived: Double, tax: Double){
        let dataDB = OthersDataDB()
        let othersData = dataDB.getDataBySymbol(symbol)
        let dbIncome = othersData.liquidIncome
        let dbTax = othersData.incomeTax
        let totalIncome = dbIncome + valueReceived
        let totalTax = dbTax + tax
        
        othersData.liquidIncome = totalIncome
        othersData.incomeTax = totalTax
        othersData.incomeTotal = totalIncome + totalTax
        
        dataDB.save(othersData)
        
        dataDB.close()
    }
    
    // Delete others data, all its transactions and incomes
    func deleteOthers(_ symbol: String){
        let dataDB = OthersDataDB()
        let transactionDB = OthersTransactionDB()
        
        dataDB.deleteBySymbol(symbol)
        transactionDB.deleteBySymbol(symbol)
        Utils.updateOthersPortfolio()
        dataDB.close()
        transactionDB.close()
    }
}
