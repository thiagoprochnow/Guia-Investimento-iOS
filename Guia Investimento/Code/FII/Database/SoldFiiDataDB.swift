//
//  SoldFiiDataDB.swift
//  Guia Investimento
//
//  Created by Thiago on 01/07/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
class SoldFiiDataDB{
    var db:SQLiteHelper
    init(){
        self.db = SQLiteHelper(database: "Portfolio.db")
    }
    
    // Create SoldFiiData tables if it does not exists
    func createTable(){
        let sql = "create table if not exists sold_fii_data (_id integer primary key autoincrement"
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
    
    // Load SoldFiiData of a specific Fii Symbol
    func getDataBySymbol(_ symbol: String) -> SoldFiiData {
        let data = SoldFiiData()
        let stmt = db.query("SELECT * FROM sold_fii_data where symbol = ?",params: [symbol])
        if (db.nextRow(stmt)){
            data.id = db.getInt(stmt, index: 0)
            data.symbol = db.getString(stmt, index: 1)
            data.quantity = db.getInt(stmt, index: 2)
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
    
    // Load SoldFiiData of a specific Fii Symbol
    func getDataById(_ id: Int) -> SoldFiiData {
        let data = SoldFiiData()
        let stmt = db.query("SELECT * FROM sold_fii_data where _id = ?",params: [id])
        if (db.nextRow(stmt)){
            data.id = db.getInt(stmt, index: 0)
            data.symbol = db.getString(stmt, index: 1)
            data.quantity = db.getInt(stmt, index: 2)
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
    
    // Used to get all SoldFiiData
    func getSoldData() -> Array<SoldFiiData> {
        var soldFiiDatas : Array<SoldFiiData> = []
        let stmt = db.query("SELECT * FROM sold_fii_data")
        while (db.nextRow(stmt)){
            let data = SoldFiiData()
            data.id = db.getInt(stmt, index: 0)
            data.symbol = db.getString(stmt, index: 1)
            data.quantity = db.getInt(stmt, index: 2)
            data.buyValue = db.getDouble(stmt, index: 3)
            data.sellGain = db.getDouble(stmt, index: 4)
            data.mediumPrice = db.getDouble(stmt, index: 5)
            data.currentTotal = db.getDouble(stmt, index: 6)
            data.tax = db.getDouble(stmt, index: 7)
            data.brokerage = db.getDouble(stmt, index: 8)
            data.lastUpdate = db.getInt(stmt, index: 9)
            soldFiiDatas.append(data)
        }
        db.closeStatement(stmt)
        return soldFiiDatas
    }
    
    // Save or update a SoldFiiData
    func save(_ data: SoldFiiData){
        if(data.id == 0){
            // Insert
            let sql = "insert or replace into sold_fii_data (symbol,quantity_total,value_total,sell_gain,current_price,current_total,tax,brokerage,last_update) VALUES (?,?,?,?,?,?,?,?,?);"
            
            let params = [data.symbol,data.quantity,data.buyValue,data.sellGain,data.mediumPrice,data.currentTotal,data.tax,data.brokerage,data.lastUpdate] as [Any]
            _ = db.execSql(sql, params: params as Array<AnyObject>)
        } else {
            // Update
            let sql = "update sold_fii_data set symbol=?,quantity_total=?,value_total=?,sell_gain=?,current_price=?,current_total=?,tax=?,brokerage=?,last_update=? where _id=?;"
            let params = [data.symbol,data.quantity,data.buyValue,data.sellGain,data.mediumPrice,data.currentTotal,data.tax,data.brokerage,data.lastUpdate,data.id] as [Any]
            _ = db.execSql(sql,params: params as Array<AnyObject>)
        }
    }
    
    func delete(_ data: SoldFiiData){
        let sql = "delete from sold_fii_data where _id = ?"
        _ = db.execSql(sql,params: [data.id])
    }
    
    func deleteById(_ id: Int){
        let sql = "delete from sold_fii_data where _id = ?"
        _ = db.execSql(sql,params: [id])
    }
    
    func deleteBySymbol(_ symbol: String){
        let sql = "delete from sold_fii_data where symbol = ?"
        _ = db.execSql(sql,params: [symbol])
    }
    
    func close(){
        // Close database
        self.db.close()
    }
}
