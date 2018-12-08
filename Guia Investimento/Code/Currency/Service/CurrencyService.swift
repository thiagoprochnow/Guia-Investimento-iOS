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
        
        let http = URLSession.shared
        var count = 0
        if(currencies.count > 0){
            let general = CurrencyGeneral()
            for (index, currency) in currencies.enumerated() {
                let symbol = currency.symbol
                // Dolar e Euro
                if(symbol == "USD" || symbol == "EUR"){
                    let url = URL(string: "http://api.promasters.net.br/cotacao/v1/valores?moedas=" + symbol+"&alt=json")!
                    var request = URLRequest(url: url)
                    request.httpMethod = "GET"
                    http.dataTask(with: request){(data, response, error) in
                        count = count + 1
                        if let data = data {
                            do{
                                //print(String(data: data, encoding: String.Encoding.utf8))
                                let currencyQuote = try JSONSerialization.jsonObject(with: data, options: [JSONSerialization.ReadingOptions.mutableContainers,.allowFragments]) as! NSDictionary
                                let valores = currencyQuote["valores"] as! NSDictionary
                                let moeda = valores[symbol] as! NSDictionary
                                let valor = moeda["valor"]
                                currency.currentPrice = valor as! Double
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
                            print(response)
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
                            print(response)
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
