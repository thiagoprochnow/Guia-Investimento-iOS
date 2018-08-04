//
//  SoldTreasuryDataDB.swift
//  Guia Investimento
//
//  Created by Thiago on 01/07/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
class SoldTreasuryDataDB{
    var db:SQLiteHelper
    init(){
        self.db = SQLiteHelper(database: "Portfolio.db")
    }
    
    // Create SoldTreasuryData tables if it does not exists
    func createTable(){
        let sql = "create table if not exists sold_treasury_data (_id integer primary key autoincrement"
            + ", symbol text not null"
            + ", quantity_total integer"
            + ", value_total real"
            + ", sell_gain real"
            + ", current_price real"
            + ", current_total"
            + ", tax real"
            + ", brokerage real"
            + ", last_update long"
            + ", UNIQUE (symbol) ON CONFLICT REPLACE);"
        _ = db.execSql(sql)
    }
    
    // Load SoldTreasuryData of a specific Treasury Symbol
    func getDataBySymbol(_ symbol: String) -> SoldTreasuryData {
        let data = SoldTreasuryData()
        let stmt = db.query("SELECT * FROM sold_treasury_data where symbol = ?",params: [symbol])
        if (db.nextRow(stmt)){
            data.id = db.getInt(stmt, index: 0)
            data.symbol = db.getString(stmt, index: 1)
            data.quantity = db.getDouble(stmt, index: 2)
            data.buyValue = db.getDouble(stmt, index: 3)
            data.sellGain = db.getDouble(stmt, index: 4)
            data.mediumPrice = db.getDouble(stmt, index: 5)
            data.currentTotal = db.getDouble(stmt, index: 6)
            data.tax = db.getDouble(stmt, index: 7)
            data.brokerage = db.getDouble(stmt, index: 8)
            data.lastUpdate = db.getInt(stmt, index: 9)
        }
        db.closeStatement(stmt)
        return data
    }
    
    // Load SoldTreasuryData of a specific Treasury Symbol
    func getDataById(_ id: Int) -> SoldTreasuryData {
        let data = SoldTreasuryData()
        let stmt = db.query("SELECT * FROM sold_treasury_data where _id = ?",params: [id])
        if (db.nextRow(stmt)){
            data.id = db.getInt(stmt, index: 0)
            data.symbol = db.getString(stmt, index: 1)
            data.quantity = db.getDouble(stmt, index: 2)
            data.buyValue = db.getDouble(stmt, index: 3)
            data.sellGain = db.getDouble(stmt, index: 4)
            data.mediumPrice = db.getDouble(stmt, index: 5)
            data.currentTotal = db.getDouble(stmt, index: 6)
            data.tax = db.getDouble(stmt, index: 7)
            data.brokerage = db.getDouble(stmt, index: 8)
            data.lastUpdate = db.getInt(stmt, index: 9)
        }
        db.closeStatement(stmt)
        return data
    }
    
    // Used to get all SoldTreasuryData
    func getSoldData() -> Array<SoldTreasuryData> {
        var soldTreasuriesDatas : Array<SoldTreasuryData> = []
        let stmt = db.query("SELECT * FROM sold_treasury_data")
        while (db.nextRow(stmt)){
            let data = SoldTreasuryData()
            data.id = db.getInt(stmt, index: 0)
            data.symbol = db.getString(stmt, index: 1)
            data.quantity = db.getDouble(stmt, index: 2)
            data.buyValue = db.getDouble(stmt, index: 3)
            data.sellGain = db.getDouble(stmt, index: 4)
            data.mediumPrice = db.getDouble(stmt, index: 5)
            data.currentTotal = db.getDouble(stmt, index: 6)
            data.tax = db.getDouble(stmt, index: 7)
            data.brokerage = db.getDouble(stmt, index: 8)
            data.lastUpdate = db.getInt(stmt, index: 9)
            soldTreasuriesDatas.append(data)
        }
        db.closeStatement(stmt)
        return soldTreasuriesDatas
    }
    
    // Save or update a SoldTreasuryData
    func save(_ data: SoldTreasuryData){
        if(data.id == 0){
            // Insert
            let sql = "insert or replace into sold_treasury_data (symbol,quantity_total,value_total,sell_gain,current_price,current_total,tax,brokerage,last_update) VALUES (?,?,?,?,?,?,?,?,?);"
            
            let params = [data.symbol,data.quantity,data.buyValue,data.sellGain,data.mediumPrice,data.currentTotal,data.tax,data.brokerage,data.lastUpdate] as [Any]
            _ = db.execSql(sql, params: params as Array<AnyObject>)
        } else {
            // Update
            let sql = "update sold_treasury_data set symbol=?,quantity_total=?,value_total=?,sell_gain=?,current_price=?,current_total=?,tax=?,brokerage=?,last_update=? where _id=?;"
            let params = [data.symbol,data.quantity,data.buyValue,data.sellGain,data.mediumPrice,data.currentTotal,data.tax,data.brokerage,data.lastUpdate,data.id] as [Any]
            _ = db.execSql(sql,params: params as Array<AnyObject>)
        }
    }
    
    func delete(_ data: SoldTreasuryData){
        let sql = "delete from sold_treasury_data where _id = ?"
        _ = db.execSql(sql,params: [data.id])
    }
    
    func deleteById(_ id: Int){
        let sql = "delete from sold_treasury_data where _id = ?"
        _ = db.execSql(sql,params: [id])
    }
    
    func deleteBySymbol(_ symbol: String){
        let sql = "delete from sold_treasury_data where symbol = ?"
        _ = db.execSql(sql,params: [symbol])
    }
    
    func close(){
        // Close database
        self.db.close()
    }
}
