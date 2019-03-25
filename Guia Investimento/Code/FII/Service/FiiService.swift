//
//  FiiService.swift
//  Guia Investimento
//
//  Created by Felipe on 24/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
import UIKit
class FiiService{
    class func updateFiiQuotes(_ updateFiis:Array<FiiData>, callback: @escaping(_ fiisCallback:Array<FiiData>,_ error:String) -> Void){
        let fiiDataDB = FiiDataDB()
        var fiis:Array<FiiData> = []
        
        let apiKey = "XT5MYEQ27BZ6LXYC";
        let function = "TIME_SERIES_DAILY";
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        var subscription = appDelegate.subscription
        
        if(updateFiis.count == 0){
            fiis = fiiDataDB.getDataByStatus(Constants.Status.ACTIVE)
        } else {
            fiis = updateFiis
        }
        fiiDataDB.close()
        var returnFiis: Array<FiiData> = []
        var success: Bool = true
        var result = "true"
        
        var limit = 0
        var size = 0
        var count = 0
        
        if(fiis.count > 0){
            // Prepare http request to webservice
            let http = URLSession.shared
            
            for (index, fii) in fiis.enumerated() {
                if(limit < 3){
                    let getURL = URL(string: "http://www.alphavantage.co/query?function="+function+"&symbol="+fii.symbol+".SA&apikey="+apiKey)
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
                                        
                                        fii.currentPrice = Double(lastTrade)!
                                        fii.closingPrice = Double(previousTrade)!
                                        fii.updateStatus = Constants.UpdateStatus.UPDATED
                                        
                                    } else {
                                        fii.closingPrice = 0.0
                                        fii.updateStatus = Constants.UpdateStatus.NOT_UPDATED
                                    }
                                } else {
                                    fii.updateStatus = Constants.UpdateStatus.NOT_UPDATED
                                }
                                returnFiis.append(fii)
                            }catch {
                                print(error)
                                fii.updateStatus = Constants.UpdateStatus.NOT_UPDATED
                                returnFiis.append(fii)
                                result = "false"
                            }
                        }
                        if let getError = getError {
                            success = false
                        }
                        
                        // only calls callback for last item
                        if(count == (fiis.count)){
                            callback(returnFiis,result)
                        }
                    }.resume()
                    
                    if(subscription!.isPremium == false){
                        limit = limit + 1
                    }
                } else {
                    fii.updateStatus = Constants.UpdateStatus.NOT_UPDATED
                    returnFiis.append(fii)
                    result = "limit"
                    count = count + 1
                    // only calls callback for last item
                    if(count == (fiis.count)){
                        callback(returnFiis,result)
                    }
                }
            }
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
        var count = 0
        
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
                            //print(String(data: data, encoding: String.Encoding.utf8))
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
                    count = count + 1
                    // only calls callback for last item
                    if(count == (fiis.count)){
                        callback(returnIncomes,result)
                    }
                }.resume()
            }
        } else {
            callback(returnIncomes,true)
        }
    }
}
