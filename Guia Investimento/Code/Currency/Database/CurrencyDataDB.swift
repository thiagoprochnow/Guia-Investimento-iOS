//
//  CurrencyDataDB.swift
//  Guia Investimento
//
//  Created by Felipe on 24/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
class CurrencyDataDB{
    var db:SQLiteHelper
    init(){
        self.db = SQLiteHelper(database: "Portfolio.db")
    }
    
    // Create CurrencyData tables if it does not exists
    func createTable(){
        let sql = "create table if not exists currency_data (_id integer primary key autoincrement"
            + ", symbol text not null"
            + ", quantity_total real"
            + ", value_total real"
            + ", variation real"
            + ", total_gain real"
            + ", objective_percent real"
            + ", current_percent real"
            + ", medium_price real"
            + ", current_price real"
            + ", current_total real"
            + ", status integer"
            + ", tax real"
            + ", brokerage real"
            + ", last_update long"
            + ", update_status integer"
            + ", UNIQUE (symbol) ON CONFLICT REPLACE);"
        _ = db.execSql(sql)
    }
    
    // Load CurrencyData of a specific Currency Symbol
    func getDataBySymbol(_ symbol: String) -> CurrencyData {
        let data = CurrencyData()
        let stmt = db.query("SELECT * FROM currency_data where symbol = ?",params: [symbol])
        if (db.nextRow(stmt)){
            data.id = db.getInt(stmt, index: 0)
            data.symbol = db.getString(stmt, index: 1)
            data.quantity = db.getDouble(stmt, index: 2)
            data.buyValue = db.getDouble(stmt, index: 3)
            data.variation = db.getDouble(stmt, index: 4)
            data.totalGain = db.getDouble(stmt, index: 5)
            data.objectivePercent = db.getDouble(stmt, index: 6)
            data.currentPercent = db.getDouble(stmt, index: 7)
            data.mediumPrice = db.getDouble(stmt, index: 8)
            data.currentPrice = db.getDouble(stmt, index: 9)
            data.currentTotal = db.getDouble(stmt, index: 10)
            data.status = db.getInt(stmt, index: 11)
            data.tax = db.getDouble(stmt, index: 12)
            data.brokerage = db.getDouble(stmt, index: 13)
            data.lastUpdate = db.getInt(stmt, index: 14)
            data.updateStatus = db.getInt(stmt, index: 15)
        }
        db.closeStatement(stmt)
        return data
    }
    
    // Load Active Currency ordered by percent
    func getDataPercent() -> Array<CurrencyData> {
        var currencyDatas : Array<CurrencyData> = []
        let stmt = db.query("SELECT _id,symbol,current_percent FROM currency_data where status = ? ORDER BY current_percent DESC",params: [Constants.Status.ACTIVE])
        while (db.nextRow(stmt)){
            let data = CurrencyData()
            data.id = db.getInt(stmt, index: 0)
            data.symbol = db.getString(stmt, index: 1)
            data.currentPercent = db.getDouble(stmt, index: 2)
            currencyDatas.append(data)
        }
        db.closeStatement(stmt)
        return currencyDatas
    }
    
    // Load Currency of a specific Currency Symbol
    func getDataById(_ id: Int) -> CurrencyData {
        let data = CurrencyData()
        let stmt = db.query("SELECT * FROM currency_data where _id = ?",params: [id])
        if (db.nextRow(stmt)){
            data.id = db.getInt(stmt, index: 0)
            data.symbol = db.getString(stmt, index: 1)
            data.quantity = db.getDouble(stmt, index: 2)
            data.buyValue = db.getDouble(stmt, index: 3)
            data.variation = db.getDouble(stmt, index: 4)
            data.totalGain = db.getDouble(stmt, index: 5)
            data.objectivePercent = db.getDouble(stmt, index: 6)
            data.currentPercent = db.getDouble(stmt, index: 7)
            data.mediumPrice = db.getDouble(stmt, index: 8)
            data.currentPrice = db.getDouble(stmt, index: 9)
            data.currentTotal = db.getDouble(stmt, index: 10)
            data.status = db.getInt(stmt, index: 11)
            data.tax = db.getDouble(stmt, index: 12)
            data.brokerage = db.getDouble(stmt, index: 13)
            data.lastUpdate = db.getInt(stmt, index: 14)
            data.updateStatus = db.getInt(stmt, index: 15)
        }
        db.closeStatement(stmt)
        return data
    }
    
    // Load CurrencyData by its status
    // Used to get all CurrencyData as Active or Sold
    func getDataByStatus(_ status: Int) -> Array<CurrencyData> {
        var currencyDatas : Array<CurrencyData> = []
        let stmt = db.query("SELECT * FROM currency_data where status = ?",params: [status])
        while (db.nextRow(stmt)){
            let data = CurrencyData()
            data.id = db.getInt(stmt, index: 0)
            data.symbol = db.getString(stmt, index: 1)
            data.quantity = db.getDouble(stmt, index: 2)
            data.buyValue = db.getDouble(stmt, index: 3)
            data.variation = db.getDouble(stmt, index: 4)
            data.totalGain = db.getDouble(stmt, index: 5)
            data.objectivePercent = db.getDouble(stmt, index: 6)
            data.currentPercent = db.getDouble(stmt, index: 7)
            data.mediumPrice = db.getDouble(stmt, index: 8)
            data.currentPrice = db.getDouble(stmt, index: 9)
            data.currentTotal = db.getDouble(stmt, index: 10)
            data.status = db.getInt(stmt, index: 11)
            data.tax = db.getDouble(stmt, index: 12)
            data.brokerage = db.getDouble(stmt, index: 13)
            data.lastUpdate = db.getInt(stmt, index: 14)
            data.updateStatus = db.getInt(stmt, index: 15)
            currencyDatas.append(data)
        }
        db.closeStatement(stmt)
        return currencyDatas
    }
    
    // Load All CurrencyData
    func getData() -> Array<CurrencyData> {
        var currencyDatas : Array<CurrencyData> = []
        let stmt = db.query("SELECT * FROM currency_data")
        while (db.nextRow(stmt)){
            let data = CurrencyData()
            data.id = db.getInt(stmt, index: 0)
            data.symbol = db.getString(stmt, index: 1)
            data.quantity = db.getDouble(stmt, index: 2)
            data.buyValue = db.getDouble(stmt, index: 3)
            data.variation = db.getDouble(stmt, index: 4)
            data.totalGain = db.getDouble(stmt, index: 5)
            data.objectivePercent = db.getDouble(stmt, index: 6)
            data.currentPercent = db.getDouble(stmt, index: 7)
            data.mediumPrice = db.getDouble(stmt, index: 8)
            data.currentPrice = db.getDouble(stmt, index: 9)
            data.currentTotal = db.getDouble(stmt, index: 10)
            data.status = db.getInt(stmt, index: 11)
            data.tax = db.getDouble(stmt, index: 12)
            data.brokerage = db.getDouble(stmt, index: 13)
            data.lastUpdate = db.getInt(stmt, index: 14)
            data.updateStatus = db.getInt(stmt, index: 15)
            currencyDatas.append(data)
        }
        db.closeStatement(stmt)
        return currencyDatas
    }
    
    // Save or update a CurrencyData
    func save(_ data: CurrencyData){
        if(data.id == 0){
            // Insert
            let sql = "insert or replace into currency_data (symbol,quantity_total,value_total,variation,total_gain,objective_percent,current_percent,medium_price,current_price,current_total,status,tax,brokerage,last_update,update_status) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);"
            
            let params = [data.symbol,data.quantity,data.buyValue,data.variation,data.totalGain,data.objectivePercent,data.currentPercent,data.mediumPrice,data.currentPrice,data.currentTotal,data.status,data.tax,data.brokerage,data.lastUpdate,data.updateStatus] as [Any]
            _ = db.execSql(sql, params: params as Array<AnyObject>)
        } else {
            // Update
            let sql = "update currency_data set symbol=?,quantity_total=?,value_total=?,variation=?,total_gain=?,objective_percent=?,current_percent=?,medium_price=?,current_price=?,current_total=?,status=?,tax=?,brokerage=?,last_update=?,update_status=? where _id=?;"
            let params = [data.symbol,data.quantity,data.buyValue,data.variation,data.totalGain,data.objectivePercent,data.currentPercent,data.mediumPrice,data.currentPrice,data.currentTotal,data.status,data.tax,data.brokerage,data.lastUpdate,data.updateStatus,data.id] as [Any]
            _ = db.execSql(sql,params: params as Array<AnyObject>)
        }
    }
    
    func bulkSave(_ currencies: Array<CurrencyData>){
        currencies.forEach{ currency in
            save(currency)
        }
    }
    
    func delete(_ data: CurrencyData){
        let sql = "delete from currency_data where _id = ?"
        _ = db.execSql(sql,params: [data.id])
    }
    
    func deleteById(_ id: Int){
        let sql = "delete from currency_data where _id = ?"
        _ = db.execSql(sql,params: [id])
    }
    
    func deleteBySymbol(_ symbol: String){
        let sql = "delete from currency_data where symbol = ?"
        _ = db.execSql(sql,params: [symbol])
    }
    
    func close(){
        // Close database
        self.db.close()
    }
}
