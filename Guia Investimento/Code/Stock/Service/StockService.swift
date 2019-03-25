//
//  StockService.swift
//  Guia Investimento
//
//  Created by Felipe on 24/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import UIKit
import Foundation
class StockService{
    class func updateStockQuotes(_ updateStocks:Array<StockData>, callback: @escaping(_ stocksCallback:Array<StockData>,_ error:String) -> Void){
        let stockDataDB = StockDataDB()
        var stocks:Array<StockData> = []
        
        let apiKey = "XT5MYEQ27BZ6LXYC";
        let function = "TIME_SERIES_DAILY";
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        var subscription = appDelegate.subscription
        
        if(updateStocks.count == 0){
            stocks = stockDataDB.getDataByStatus(Constants.Status.ACTIVE)
        } else{
            stocks = updateStocks
        }
        stockDataDB.close()
        var returnStocks: Array<StockData> = []
        var success: Bool = true
        var result = "true"
        
        var limit = 0
        var size = 0
        var count = 0
        
        if(stocks.count > 0){
            // Prepare http request to webservice
            let http = URLSession.shared
            
            for (index, stock) in stocks.enumerated() {
                if(limit < 5){
                    let getURL = URL(string: "http://www.alphavantage.co/query?function="+function+"&symbol="+stock.symbol+".SA&apikey="+apiKey)
                    // Get quotes
                    var getRequest = URLRequest(url: getURL!)
                    getRequest.httpMethod = "GET"
                    http.dataTask(with: getRequest) { (getData, getResponse, getError) in
                        // Return from GET
                        count = count + 1
                        if let getData = getData {
                            do {
                                // Needed because the return is different in case of one stock or many stocks
                                let responseObj = try JSONSerialization.jsonObject(with: getData, options: [JSONSerialization.ReadingOptions.mutableContainers,.allowFragments]) as! NSDictionary
                                if(responseObj.count > 1){
                                    let quotes = responseObj["Time Series (Daily)"] as! [String:NSDictionary]
                                    let sortedQuotes = quotes.sorted(by: {$0.key > $1.key})
                                    let firstQuote = sortedQuotes[0].value
                                    let previousQuote = sortedQuotes[1].value
                                    
                                    if(firstQuote["4. close"] != nil){
                                        let lastTrade = firstQuote["4. close"] as! String
                                        let previousTrade = previousQuote["4. close"] as! String
                                        
                                        stock.currentPrice = Double(lastTrade)!
                                        stock.closingPrice = Double(previousTrade)!
                                        stock.updateStatus = Constants.UpdateStatus.UPDATED
                                        
                                    } else {
                                        stock.closingPrice = 0.0
                                        stock.updateStatus = Constants.UpdateStatus.NOT_UPDATED
                                    }
                                } else {
                                    stock.updateStatus = Constants.UpdateStatus.NOT_UPDATED
                                }
                                returnStocks.append(stock)
                            }catch {
                                print(error)
                                stock.updateStatus = Constants.UpdateStatus.NOT_UPDATED
                                returnStocks.append(stock)
                                result = "false"
                            }
                        }
                        if let getError = getError {
                            success = false
                        }
                        
                        // only calls callback for last item
                        if(count == (stocks.count)){
                            callback(returnStocks,result)
                        }
                    }.resume()
                    
                    if(subscription!.isPremium == false){
                        limit = limit + 1
                    }
                } else {
                    stock.updateStatus = Constants.UpdateStatus.NOT_UPDATED
                    returnStocks.append(stock)
                    result = "limit"
                    count = count + 1
                    // only calls callback for last item
                    if(count == (stocks.count)){
                        callback(returnStocks,result)
                    }
                }
            }
        }
    }
    
    class func updateStockIncomes(_ callback: @escaping(_ incomesCallback:Array<StockIncome>,_ error:Bool) -> Void){
        let stockDataDB = StockDataDB()
        let stocks = stockDataDB.getDataByStatus(Constants.Status.ACTIVE)
        stockDataDB.close()
        var returnIncomes: Array<StockIncome> = []
        var success: Bool = true
        var result = false
        
        let http = URLSession.shared
        let username = "mainuser"
        let password = "user1133"
        let loginData = String(format: "%@:%@", username, password).data(using: String.Encoding.utf8)!
        let base64LoginData = loginData.base64EncodedString()
        var count = 0
        
        if(stocks.count > 0){
            let general = StockGeneral()
            for (index, stock) in stocks.enumerated() {
                let lastTimestamp = general.getLastIncomeTime(stock.symbol)
                let url = URL(string: "http://35.199.123.90/getprovento/"+stock.symbol.uppercased()+"/"+lastTimestamp)!
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.setValue("Basic \(base64LoginData)", forHTTPHeaderField: "Authorization")
                http.dataTask(with: request){(data, response, error) in
                    if let data = data {
                        var stockIncomes: Array<NSDictionary> = []
                        do{
                            //print(String(data: data, encoding: String.Encoding.utf8))
                            stockIncomes = try JSONSerialization.jsonObject(with: data, options: [JSONSerialization.ReadingOptions.mutableContainers,.allowFragments]) as! Array<NSDictionary>
                            
                            stockIncomes.forEach{ income in
                                var stockIncome = StockIncome()
                                let perStock = income["valor"] as! Double
                                let exdividend = Int(income["timestamp"] as! Int64)
                                let affected = general.getStockQuantity(symbol: stock.symbol, incomeTimestamp: exdividend)
                                let receivedValue = affected * perStock
                                var liquidValue = receivedValue
                                var tax = 0.0
                                
                                if(income["tipo"] as! String == "JCP"){
                                    stockIncome.type = Constants.IncomeType.JCP
                                    tax = receivedValue*0.15
                                    liquidValue = receivedValue - tax
                                } else {
                                    stockIncome.type = Constants.IncomeType.DIVIDEND
                                }
                                
                                stockIncome.symbol = stock.symbol
                                stockIncome.perStock = perStock
                                stockIncome.exdividendTimestamp = exdividend
                                stockIncome.affectedQuantity = Int(affected)
                                stockIncome.grossIncome = receivedValue
                                stockIncome.tax = tax
                                stockIncome.liquidIncome = liquidValue
                                
                                returnIncomes.append(stockIncome)
                            }
                            result = true
                        } catch {
                            print(error)
                        }
                    } 
                    if let error = error {
                        // Return fail to main thread
                        result = false
                    }
                    count = count + 1
                    // only calls callback for last item
                    if(count == (stocks.count)){
                        callback(returnIncomes, result)
                    }
                    }.resume()
            }
        } else {
            callback(returnIncomes, true)
        }
    }
}
