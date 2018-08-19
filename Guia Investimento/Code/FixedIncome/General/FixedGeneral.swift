//
//  FixedGeneral.swift
//  Guia Investimento
//
//  Created by Felipe on 25/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
class FixedGeneral {
    
    // update FixedData according to all transactions already occured. Similar to Android app version of
    // this function.
    func updateFixedData(_ symbol: String, type: Int) -> Bool{
        let dataDB = FixedDataDB()
        let transactionDB = FixedTransactionDB()
        let fixedTransactions = transactionDB.getTransactionsBySymbol(symbol)
        transactionDB.close()

        if(fixedTransactions.count > 0 ){
            var buyTotal = 0.0
            var lastSell = 0.0
            var currentType = -1
            var soldTotal = 0.0
            
            fixedTransactions.forEach{ transaction in
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
            let fixedData = dataDB.getDataBySymbol(symbol)
            fixedData.symbol = symbol
            
            // In case it is Delete Transaction or Sell which does not update values
            var currentTotal = 0.0
            if(fixedData.id != 0){
                currentTotal = fixedData.currentTotal
            }
            
            if((type == Constants.TypeOp.SELL) && fixedData.id != 0){
                currentTotal -= lastSell
                fixedData.currentTotal = currentTotal
            }
            
            let totalGain = currentTotal + soldTotal - buyTotal
            
            // Set fixed as active
            fixedData.status = Constants.Status.ACTIVE
            fixedData.buyTotal = buyTotal
            fixedData.sellTotal = soldTotal
            fixedData.totalGain = totalGain
            
            dataDB.save(fixedData)
            dataDB.close()
            return true
        } else {
            dataDB.close()
            return false
        }
    }
    
    // Delete fixed data, all its transactions and incomes
    func deleteFixed(_ symbol: String){
        let dataDB = FixedDataDB()
        let transactionDB = FixedTransactionDB()
        
        dataDB.deleteBySymbol(symbol)
        transactionDB.deleteBySymbol(symbol)
        Utils.updateFixedPortfolio()
        dataDB.close()
        transactionDB.close()
    }
    
    func getLastCdi() -> Cdi {
        let cdiDB = CdiDB()
        let lastCdi = cdiDB.getLastCdi()
        cdiDB.close()
        return lastCdi
    }
    
    // Updates the FixedData using the CDI and IPCA table
    func updateFixedQuote(_ fixed: FixedData) -> FixedData {
        var currentFixedValue: Double = 0.0
        var gainRate: Double = 1
        let symbol = fixed.symbol
        
        let transactionDB = FixedTransactionDB()
        let transactions = transactionDB.getTransactionsBySymbol(symbol)
        transactionDB.close()
        
        for (index, transaction) in transactions.enumerated() {
            let cdiDB = CdiDB()
            let cdis = cdiDB.getCdiByTimestamp(transaction.timestamp)
            cdiDB.close()
            var cdiIndex = 0
            // CDI
            if(transaction.gainType == Constants.FixedType.CDI){
                if (transaction.type == Constants.TypeOp.BUY){
                    currentFixedValue += transaction.boughtTotal
                    gainRate = transaction.gainRate
                } else {
                    // SELL
                    currentFixedValue -= transaction.boughtTotal
                }
                
                if(gainRate == 0){
                    continue
                }
                
                if(cdis.count == 0){
                    // No CDI for after this transaction timestamp
                    continue
                }
                
                if(index < transactions.count - 1){
                    // Need to check if next transaction is reached because total value is then another
                    let nextTransaction = transactions[index + 1]
                    var cdiTimestamp = 0
                    
                    repeat{
                        let cdi = cdis[cdiIndex]
                        let cdiDaily = getCdiDaily(cdi.value,gainRate: gainRate)
                        
                        currentFixedValue = currentFixedValue * cdiDaily
                        
                        // Get next cdi
                        cdiIndex = cdiIndex + 1
                        if(cdiIndex >= cdis.count){
                            // Transaction timestamp is bigger then last cdi timestamp
                            break
                        } else {
                            cdiTimestamp = cdi.timestamp
                        }
                    } while (cdiTimestamp < nextTransaction.timestamp)
                    
                } else {
                    // Last one, only needs to sum or subtract and update until end of CDI
                    // Last Transaction
                    repeat{
                        let cdi = cdis[cdiIndex]
                        let cdiDaily = getCdiDaily(cdi.value, gainRate: gainRate)
                        
                        currentFixedValue = currentFixedValue * cdiDaily
                        
                        cdiIndex = cdiIndex + 1
                    } while (cdiIndex < cdis.count)
                }
                
            } else if (transaction.gainType == Constants.FixedType.IPCA){
                
            } else if (transaction.gainType == Constants.FixedType.PRE){
                
            }
        }
        
        fixed.currentTotal = currentFixedValue
        
        return fixed
    }
    
    // Return the calculated Daily CDI for this cdi yearly value multiplied by the investiment cdi rate
    func getCdiDaily(_ value:Double, gainRate:Double) -> Double{
        let cdiDaily = ((pow((1 + value/100), 1/252))-1)*gainRate + 1
        return cdiDaily
    }
}
