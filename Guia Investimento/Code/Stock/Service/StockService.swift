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
        }
    }
}
