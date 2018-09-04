//
//  FiiService.swift
//  Guia Investimento
//
//  Created by Felipe on 24/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
class FiiService{
    class func updateFiiQuotes(_ updateFiis:Array<FiiData>, callback: @escaping(_ fiisCallback:Array<FiiData>,_ error:Bool) -> Void){
        let fiiDataDB = FiiDataDB()
        var fiis:Array<FiiData> = []
        if(updateFiis.count == 0){
            fiis = fiiDataDB.getDataByStatus(Constants.Status.ACTIVE)
        } else {
            fiis = updateFiis
        }
        fiiDataDB.close()
        var returnFiis: Array<FiiData> = []
        var success: Bool = true
        
        if(fiis.count > 0){
            // Prepare http request to webservice
            let http = URLSession.shared
            let postURL = URL(string: "http://webfeeder.cedrofinances.com.br/SignIn?login=thiprochnow&password=4schGOS")
            var postRequest = URLRequest(url: postURL!)
            
            var symbolsURL:String = ""
            fiis.forEach{ fii in
                symbolsURL += "/" + fii.symbol.lowercased()
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
                                        var fiiQuotes: Array<NSDictionary> = []
                                        
                                        // Needed because the return is different in case of one fii or many fiis
                                        if(fiis.count > 1){
                                        fiiQuotes = try JSONSerialization.jsonObject(with: getData, options: [JSONSerialization.ReadingOptions.mutableContainers,.allowFragments]) as! Array<NSDictionary>
                                        } else {
                                            let quote = try JSONSerialization.jsonObject(with: getData, options: [JSONSerialization.ReadingOptions.mutableContainers,.allowFragments]) as! NSDictionary
                                            fiiQuotes.append(quote)
                                        }
                                        fiis.forEach{ fii in
                                            let symbol = fii.symbol.lowercased()
                                            var found:Bool = false
                                            fiiQuotes.forEach{ quote in
                                                var quoteSymbol:String = quote["symbol"] as! String
                                                quoteSymbol = quoteSymbol.lowercased()
                                                
                                                // Matching symbols
                                                if(symbol == quoteSymbol){
                                                    if(quote["lastTrade"] != nil){
                                                        let lastTrade = quote["lastTrade"] as! Double
                                                        fii.currentPrice = lastTrade
                                                        fii.closingPrice = quote["previous"] as! Double
                                                        fii.updateStatus = Constants.UpdateStatus.UPDATED
                                                        found = true
                                                    } else {
                                                        fii.closingPrice = 0.0
                                                        fii.updateStatus = Constants.UpdateStatus.NOT_UPDATED
                                                    }
                                                }
                                            }
                                            if(found == false){
                                                fii.closingPrice = 0.0
                                                fii.updateStatus = Constants.UpdateStatus.NOT_UPDATED
                                            }
                                            returnFiis.append(fii)
                                        }
                                        callback(returnFiis, true)
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
                            callback(returnFiis,false)
                        }
                    }
                    if let error = error {
                        // Return fail to main thread
                        callback(returnFiis,false)
                    }
                }.resume()
        } else {
            callback(returnFiis,false)
        }
    }
    
    class func updateFiiIncomes(_ callback: @escaping(_ fiiIncomes:Array<FiiIncome>, _ error:Bool) -> Void){
        let fiiDataDB = FiiDataDB()
        let fiis = fiiDataDB.getDataByStatus(Constants.Status.ACTIVE)
        fiiDataDB.close()
        var returnIncomes: Array<FiiIncome> = []
        var success: Bool = true
        var result = false
        
        let http = URLSession.shared
        let username = "mainuser"
        let password = "user1133"
        let loginData = String(format: "%@:%@", username, password).data(using: String.Encoding.utf8)!
        let base64LoginData = loginData.base64EncodedString()
        
        if(fiis.count > 0){
            let general = FiiGeneral()
            for (index, fii) in fiis.enumerated() {
                let lastTimestamp = general.getLastIncomeTime(fii.symbol)
                let url = URL(string: "http://35.199.123.90/getprovento/"+fii.symbol.uppercased()+"/"+lastTimestamp)!
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.setValue("Basic \(base64LoginData)", forHTTPHeaderField: "Authorization")
                http.dataTask(with: request){(data, response, error) in
                    if let data = data {
                        var fiiIncomes: Array<NSDictionary> = []
                        do{
                            print(String(data: data, encoding: String.Encoding.utf8))
                            fiiIncomes = try JSONSerialization.jsonObject(with: data, options: [JSONSerialization.ReadingOptions.mutableContainers,.allowFragments]) as! Array<NSDictionary>
                            
                            fiiIncomes.forEach{ income in
                                var fiiIncome = FiiIncome()
                                let perFii = income["valor"] as! Double
                                let exdividend = Int(income["timestamp"] as! Int64)
                                let affected = general.getFiiQuantity(symbol: fii.symbol, incomeTimestamp: exdividend)
                                let receivedValue = affected * perFii
                                var liquidValue = receivedValue
                                var tax = 0.0
                                
                                fiiIncome.type = Constants.IncomeType.FII
                                
                                fiiIncome.symbol = fii.symbol
                                fiiIncome.perFii = perFii
                                fiiIncome.exdividendTimestamp = exdividend
                                fiiIncome.affectedQuantity = Int(affected)
                                fiiIncome.grossIncome = receivedValue
                                fiiIncome.tax = tax
                                fiiIncome.liquidIncome = liquidValue
                                
                                returnIncomes.append(fiiIncome)
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
                    // only calls callback for last item
                    if(index == (fiis.count - 1)){
                        callback(returnIncomes,result)
                    }
                }.resume()
            }
        } else {
            callback(returnIncomes,true)
        }
    }
}
