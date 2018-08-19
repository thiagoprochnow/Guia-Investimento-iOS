//
//  FixedService.swift
//  Guia Investimento
//
//  Created by Felipe on 24/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
class FixedService{
    class func updateFixedQuotes(_ callback: @escaping(_ error:Bool) -> Void){
        var success: Bool = true
        var resultCDI = false
        var resultIPCA = false
        
            let http = URLSession.shared
            let username = "mainuser"
            let password = "user1133"
            let loginData = String(format: "%@:%@", username, password).data(using: String.Encoding.utf8)!
            let base64LoginData = loginData.base64EncodedString()
            var count = 0
            
            // Gets and Loads CDI and IPCA table first
            let general = FixedGeneral()
            let lastCdi = general.getLastCdi()
            let lastTimestamp = lastCdi.timestamp
            
            let url = URL(string: "http://35.199.123.90/getcdi/" + String(lastTimestamp))!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Basic \(base64LoginData)", forHTTPHeaderField: "Authorization")
            // CDI Table
            http.dataTask(with: request){(data, response, error) in
                count = count + 1
                if let data = data {
                    do{
                        var cdis: Array<NSDictionary> = []
                        print(String(data: data, encoding: String.Encoding.utf8))
                        cdis = try JSONSerialization.jsonObject(with: data, options: [JSONSerialization.ReadingOptions.mutableContainers,.allowFragments]) as! Array<NSDictionary>
                        
                        let cdiDB = CdiDB()
                        cdis.forEach{ cdiValue in
                            let cdi = Cdi()
                            cdi.id = cdiValue["id"] as! Int
                            cdi.data = cdiValue["data_string"] as! String
                            cdi.timestamp = cdiValue["data"] as! Int
                            cdi.value = cdiValue["valor"] as! Double
                            cdi.lastUpdate = cdiValue["atualizado"] as! String
                            cdiDB.save(cdi)
                        }
                        cdiDB.close()
                        resultCDI = true
                        if(resultIPCA == true){
                            callback(true)
                        }
                    } catch {
                        print(error)
                    }
                }
                if let error = error {
                    callback(false)
                }
            }.resume()
            
            let urlIpca = URL(string: "http://35.199.123.90/getipca/")!
            var requestIpca = URLRequest(url: url)
            requestIpca.httpMethod = "GET"
            requestIpca.setValue("Basic \(base64LoginData)", forHTTPHeaderField: "Authorization")
            // IPCA table
            http.dataTask(with: request){(dataIpca, response, errorIpca) in
                    if let dataIpca = dataIpca {
                        do{
                            var ipcas: Array<NSDictionary> = []
                            print(String(data: dataIpca, encoding: String.Encoding.utf8))
                            ipcas = try JSONSerialization.jsonObject(with: dataIpca, options: [JSONSerialization.ReadingOptions.mutableContainers,.allowFragments]) as! Array<NSDictionary>
                            
                            let ipcaDB = IpcaDB()
                            ipcas.forEach{ ipcaValue in
                                let ipca = Ipca()
                                ipca.id = ipcaValue["id"] as! Int
                                ipca.ano = ipcaValue["ano"] as! Int
                                ipca.mes = ipcaValue["mes"] as! Int
                                ipca.valor = ipcaValue["valor"] as! Double
                                ipca.lastUpdate = ipcaValue["atualizado"] as! String
                                ipcaDB.save(ipca)
                            }
                            ipcaDB.close()
                            
                            resultIPCA = true
                            if(resultCDI == true){
                                callback(true)
                            }
                        } catch {
                            print(error)
                        }
                    }
                
                    if let errorIpca = errorIpca {
                        callback(false)
                    }
                }.resume()
    }
}
