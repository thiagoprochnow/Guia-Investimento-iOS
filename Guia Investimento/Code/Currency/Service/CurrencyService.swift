//
//  CurrencyService.swift
//  Guia Investimento
//
//  Created by Felipe on 24/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
class CurrencyService{
    class func updateCurrencyQuotes(_ updateCurrencies:Array<CurrencyData>, callback: @escaping(_ currenciesCallback:Array<CurrencyData>,_ error:String) -> Void){
        let currencyDataDB = CurrencyDataDB()
        var currencies: Array<CurrencyData> = []
        if(updateCurrencies.count == 0){
            currencies = currencyDataDB.getDataByStatus(Constants.Status.ACTIVE)
        } else {
            currencies = updateCurrencies
        }
        currencyDataDB.close()
        var success: Bool = true
        var result = "false"
        var returnCurrencies: Array<CurrencyData> = []
        var alphaKey = "FXVK1K9EYIJHIOEX"
        
        let http = URLSession.shared
        var count = 0
        if(currencies.count > 0){
            let general = CurrencyGeneral()
            for (index, currency) in currencies.enumerated() {
                let symbol = currency.symbol
                // Dolar e Euro
                if(symbol == "USD" || symbol == "EUR"){
                    let url = URL(string: "https://www.alphavantage.co/query?function=CURRENCY_EXCHANGE_RATE&from_currency=" + symbol + "&to_currency=BRL&apikey=" + alphaKey)!
                    var request = URLRequest(url: url)
                    request.httpMethod = "GET"
                    http.dataTask(with: request){(data, response, error) in
                        count = count + 1
                        if let data = data {
                            do{
                                //print(String(data: data, encoding: String.Encoding.utf8))
                                let currencyQuote = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) as! NSDictionary
                                let note = currencyQuote["Note"] as! String!
                                if(note == nil){
                                    let valores = currencyQuote["Realtime Currency Exchange Rate"] as! NSDictionary!
                                    let valor = valores?["5. Exchange Rate"] as! String
                                    currency.currentPrice = Double(valor) ?? 0
                                    currency.updateStatus = Constants.UpdateStatus.UPDATED
                                    returnCurrencies.append(currency)
                                    result = "true"
                                } else {
                                    currency.updateStatus = Constants.UpdateStatus.NOT_UPDATED
                                    returnCurrencies.append(currency)
                                    result = "false"
                                }
                            } catch {
                                currency.updateStatus = Constants.UpdateStatus.NOT_UPDATED
                                returnCurrencies.append(currency)
                                print(error)
                            }
                        }
                        if let response = response{
                            //print(response)
                        }
                        if let error = error {
                            // Return fail to main thread
                            currency.updateStatus = Constants.UpdateStatus.NOT_UPDATED
                            returnCurrencies.append(currency)
                            result = "false"
                        }
                        // only calls callback for last item
                        if(count == (currencies.count)){
                            callback(returnCurrencies,result)
                        }
                    }.resume()
                } else{
                    // Bitcoin or Litecoin
                    let url = URL(string: "https://www.mercadobitcoin.net/api/" + symbol+"/ticker/")!
                    var request = URLRequest(url: url)
                    request.httpMethod = "GET"
                    http.dataTask(with: request){(data, response, error) in
                        count = count + 1
                        if let data = data {
                            do{
                                //print(String(data: data, encoding: String.Encoding.utf8))
                                let currencyQuote = try JSONSerialization.jsonObject(with: data, options: [JSONSerialization.ReadingOptions.mutableContainers,.allowFragments]) as! NSDictionary
                                let ticker = currencyQuote["ticker"] as! NSDictionary
                                let last = ticker["last"] as! String
                                currency.currentPrice = Double(last)!
                                currency.updateStatus = Constants.UpdateStatus.UPDATED
                                returnCurrencies.append(currency)
                                result = "true"
                            } catch {
                                currency.updateStatus = Constants.UpdateStatus.NOT_UPDATED
                                returnCurrencies.append(currency)
                                print(error)
                            }
                        }
                        if let response = response{
                            //print(response)
                        }
                        if let error = error {
                            // Return fail to main thread
                            currency.updateStatus = Constants.UpdateStatus.NOT_UPDATED
                            returnCurrencies.append(currency)
                            result = "false"
                        }
                        // only calls callback for last item
                        if(count == (currencies.count)){
                            callback(returnCurrencies,result)
                        }
                        }.resume()
                }
            }
        } else {
            callback(returnCurrencies,"")
        }
    }
}
