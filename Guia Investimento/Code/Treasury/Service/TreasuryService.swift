//
//  TreasuryService.swift
//  Guia Investimento
//
//  Created by Felipe on 24/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
import UIKit
class TreasuryService{
    class func updateTreasuryQuotes(_ updateTreasury:Array<TreasuryData>, callback: @escaping(_ treasuriesCallback:Array<TreasuryData>,_ error:String) -> Void){
        let treasuryDataDB = TreasuryDataDB()
        var treasuries:Array<TreasuryData> = []
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        var subscription = appDelegate.subscription
        
        if(updateTreasury.count == 0){
            treasuries = treasuryDataDB.getDataByStatus(Constants.Status.ACTIVE)
        } else {
            treasuries = updateTreasury
        }
        treasuryDataDB.close()
        var success: Bool = true
        var result = "true"
        var returnTreasuries: Array<TreasuryData> = []
        
        var limit = 0
        var size = 0
        
        let http = URLSession.shared
        let username = "mainuser"
        let password = "user1133"
        let loginData = String(format: "%@:%@", username, password).data(using: String.Encoding.utf8)!
        let base64LoginData = loginData.base64EncodedString()
        var count = 0
        if(treasuries.count > 0){
            let general = TreasuryGeneral()
            for (index, treasury) in treasuries.enumerated() {
                if(limit < 2){
                    let lastTimestamp = general.getLastIncomeTime(treasury.symbol)
                    let symbol = treasury.symbol
                    let symbols = Constants.Symbols.TREASURY
                    var symbolIndex = symbols.index(of: symbol)
                    if(symbolIndex != nil){
                        let symbolsID = Constants.Symbols.TREASURY_ID
                        let symbolID = symbolsID[symbolIndex!]
                        let url = URL(string: "http://35.199.123.90/gettesouro/" + String(symbolID))!
                        var request = URLRequest(url: url)
                        request.httpMethod = "GET"
                        request.setValue("Basic \(base64LoginData)", forHTTPHeaderField: "Authorization")
                        http.dataTask(with: request){(data, response, error) in
                            count = count + 1
                            if let data = data {
                                var treasuryIncomes: Array<NSDictionary> = []
                                do{
                                    print(String(data: data, encoding: String.Encoding.utf8))
                                    let treasuryQuote = try JSONSerialization.jsonObject(with: data, options: [JSONSerialization.ReadingOptions.mutableContainers,.allowFragments]) as! NSDictionary
                                    treasury.currentPrice = treasuryQuote["valor"] as! Double
                                    treasury.updateStatus = Constants.UpdateStatus.UPDATED
                                    returnTreasuries.append(treasury)
                                    // count for free version
                                    if(subscription!.isPremium == false){
                                        limit = limit + 1
                                    }
                                } catch {
                                    print(error)
                                }
                            }
                            if let error = error {
                                // Return fail to main thread
                                treasury.updateStatus = Constants.UpdateStatus.NOT_UPDATED
                                returnTreasuries.append(treasury)
                                result = "false"
                            }
                            // only calls callback for last item
                            if(count == (treasuries.count)){
                                callback(returnTreasuries,result)
                            }
                        }.resume()
                    } else {
                        count = count + 1
                        treasury.updateStatus = Constants.UpdateStatus.NOT_UPDATED
                        returnTreasuries.append(treasury)
                        result = "false"
                    }
                    
                } else {
                    treasury.updateStatus = Constants.UpdateStatus.NOT_UPDATED
                    returnTreasuries.append(treasury)
                    result = "limit"
                }
            }
            callback(returnTreasuries,result)
        } else {
            callback(returnTreasuries,"")
        }
    }
}
