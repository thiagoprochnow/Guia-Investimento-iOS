//
//  StockService.swift
//  Guia Investimento
//
//  Created by Felipe on 24/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
class StockService{
    class func updateStockQuotes(_ callback: @escaping(_ stocksCallback:Array<StockData>,_ error:Bool) -> Void){
        let stockDataDB = StockDataDB()
        let stocks = stockDataDB.getDataByStatus(Constants.Status.ACTIVE)
        stockDataDB.close()
        var returnStocks: Array<StockData> = []
        var success: Bool = true
        
        if(stocks.count > 0){
            // Prepare http request to webservice
            let http = URLSession.shared
            let postURL = URL(string: "http://webfeeder.cedrofinances.com.br/SignIn?login=thiprochnow&password=4schGOS")
            var postRequest = URLRequest(url: postURL!)
            
            var symbolsURL:String = ""
            stocks.forEach{ stock in
                symbolsURL += "/" + stock.symbol.lowercased()
            }
            
            postRequest.httpMethod = "POST"
            http.dataTask(with: postRequest) { (data, response, error) in
                    // Return from POST
                    if let data = data {
                        let postResult = String(data: data, encoding: String.Encoding.utf8)!
                        // Success on authentication
                        if(postResult == "true"){
                            // Success on authentication
                            let getURL = URL(string: "http://webfeeder.cedrofinances.com.br/services/quotes/quote"+symbolsURL)
                            // Get quotes
                            var getRequest = URLRequest(url: getURL!)
                            getRequest.httpMethod = "GET"
                            http.dataTask(with: getRequest) { (getData, getResponse, getError) in
                                // Return from GET
                                if let getData = getData {
                                    do {
                                        var stockQuotes: Array<NSDictionary> = []
                                        
                                        // Needed because the return is different in case of one stock or many stocks
                                        if(stocks.count > 1){
                                        stockQuotes = try JSONSerialization.jsonObject(with: getData, options: [JSONSerialization.ReadingOptions.mutableContainers,.allowFragments]) as! Array<NSDictionary>
                                        } else {
                                            let quote = try JSONSerialization.jsonObject(with: getData, options: [JSONSerialization.ReadingOptions.mutableContainers,.allowFragments]) as! NSDictionary
                                            stockQuotes.append(quote)
                                        }
                                        stocks.forEach{ stock in
                                            let symbol = stock.symbol.lowercased()
                                            var found:Bool = false
                                            stockQuotes.forEach{ quote in
                                                var quoteSymbol:String = quote["symbol"] as! String
                                                quoteSymbol = quoteSymbol.lowercased()
                                                
                                                // Matching symbols
                                                if(symbol == quoteSymbol){
                                                    if(quote["lastTrade"] != nil){
                                                        let lastTrade = quote["lastTrade"] as! Double
                                                        stock.currentPrice = lastTrade
                                                        stock.closingPrice = quote["previous"] as! Double
                                                        stock.updateStatus = Constants.UpdateStatus.UPDATED
                                                        found = true
                                                    } else {
                                                        stock.closingPrice = 0.0
                                                        stock.updateStatus = Constants.UpdateStatus.NOT_UPDATED
                                                    }
                                                }
                                            }
                                            if(found == false){
                                                stock.closingPrice = 0.0
                                                stock.updateStatus = Constants.UpdateStatus.NOT_UPDATED
                                            }
                                            returnStocks.append(stock)
                                        }
                                        callback(returnStocks, true)
                                    }catch {
                                        print(error)
                                    }
                                }
                                if let getError = getError {
                                    success = false
                                }
                            }.resume()
                        } else {
                            // Return fail to main thread
                            callback(returnStocks,false)
                        }
                    }
                    if let error = error {
                        // Return fail to main thread
                        callback(returnStocks,false)
                    }
                }.resume()
        } else {
            callback(returnStocks,false)
        }
    }
    
    class func updateStockIncomes(_ callback: @escaping(_ error:Bool) -> Void){
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
                            print(String(data: data, encoding: String.Encoding.utf8))
                            stockIncomes = try JSONSerialization.jsonObject(with: data, options: [JSONSerialization.ReadingOptions.mutableContainers,.allowFragments]) as! Array<NSDictionary>
                            
                            let incomeDB = StockIncomeDB()
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
                                
                                let isInserted = incomeDB.isIncomeInserted(stockIncome)
                                // Check if it not already inserted
                                if(!isInserted){
                                    incomeDB.save(stockIncome)
                                    if(stockIncome.affectedQuantity > 0){
                                    general.updateStockDataIncome(stockIncome.symbol, valueReceived: stockIncome.liquidIncome, tax: stockIncome.tax)
                                    }
                                }
                            }
                            incomeDB.close()
                            result = true
                        } catch {
                            print(error)
                        }
                    } 
                    if let error = error {
                        // Return fail to main thread
                        result = false
                    }
                    // only calls callback for last item
                    if(index == (stocks.count - 1)){
                        callback(result)
                    }
                }.resume()
            }
        } else {
            callback(true)
        }
    }
}
