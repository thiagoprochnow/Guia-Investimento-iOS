//
//  FiiDataDB.swift
//  Guia Investimento
//
//  Created by Felipe on 24/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
class FiiDataDB{
    var db:SQLiteHelper
    init(){
        self.db = SQLiteHelper(database: "Portfolio.db")
    }
    
    // Create FiiData tables if it does not exists
    func createTable(){
        let sql = "create table if not exists fii_data (_id integer primary key autoincrement"
            + ", symbol text not null"
            + ", quantity_total integer"
            + ", value_total real"
            + ", income_total real"
            + ", income_tax real"
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
            + ", closing_price real"
            + ", UNIQUE (symbol) ON CONFLICT REPLACE);"
        _ = db.execSql(sql)
    }
    
    // Load FiiData of a specific Fii Symbol
    func getDataBySymbol(_ symbol: String) -> FiiData {
        let data = FiiData()
        let stmt = db.query("SELECT * FROM fii_data where symbol = ?",params: [symbol])
        if (db.nextRow(stmt)){
            data.id = db.getInt(stmt, index: 0)
            data.symbol = db.getString(stmt, index: 1)
            data.quantity = db.getInt(stmt, index: 2)
            data.buyValue = db.getDouble(stmt, index: 3)
            data.netIncome = db.getDouble(stmt, index: 4)
            data.incomeTax = db.getDouble(stmt, index: 5)
            data.variation = db.getDouble(stmt, index: 6)
            data.totalGain = db.getDouble(stmt, index: 7)
            data.objectivePercent = db.getDouble(stmt, index: 8)
            data.currentPercent = db.getDouble(stmt, index: 9)
            data.mediumPrice = db.getDouble(stmt, index: 10)
            data.currentPrice = db.getDouble(stmt, index: 11)
            data.currentTotal = db.getDouble(stmt, index: 12)
            data.status = db.getInt(stmt, index: 13)
            data.tax = db.getDouble(stmt, index: 14)
            data.brokerage = db.getDouble(stmt, index: 15)
            data.lastUpdate = db.getInt(stmt, index: 16)
            data.updateStatus = db.getInt(stmt, index: 17)
            data.closingPrice = db.getDouble(stmt, index: 18)
        }
        db.closeStatement(stmt)
        return data
    }
    
    // Load Active FiiData ordered by percent
    func getDataPercent() -> Array<FiiData> {
        var fiiDatas : Array<FiiData> = []
        let stmt = db.query("SELECT _id,symbol,current_percent FROM fii_data where status = ? ORDER BY current_percent DESC",params: [Constants.Status.ACTIVE])
        while (db.nextRow(stmt)){
            let data = FiiData()
            data.id = db.getInt(stmt, index: 0)
            data.symbol = db.getString(stmt, index: 1)
            data.currentPercent = db.getDouble(stmt, index: 2)
            fiiDatas.append(data)
        }
        db.closeStatement(stmt)
        return fiiDatas
    }
    
    // Load FiiData of a specific Fii Symbol
    func getDataById(_ id: Int) -> FiiData {
        let data = FiiData()
        let stmt = db.query("SELECT * FROM fii_data where _id = ?",params: [id])
        if (db.nextRow(stmt)){
            data.id = db.getInt(stmt, index: 0)
            data.symbol = db.getString(stmt, index: 1)
            data.quantity = db.getInt(stmt, index: 2)
            data.buyValue = db.getDouble(stmt, index: 3)
            data.netIncome = db.getDouble(stmt, index: 4)
            data.incomeTax = db.getDouble(stmt, index: 5)
            data.variation = db.getDouble(stmt, index: 6)
            data.totalGain = db.getDouble(stmt, index: 7)
            data.objectivePercent = db.getDouble(stmt, index: 8)
            data.currentPercent = db.getDouble(stmt, index: 9)
            data.mediumPrice = db.getDouble(stmt, index: 10)
            data.currentPrice = db.getDouble(stmt, index: 11)
            data.currentTotal = db.getDouble(stmt, index: 12)
            data.status = db.getInt(stmt, index: 13)
            data.tax = db.getDouble(stmt, index: 14)
            data.brokerage = db.getDouble(stmt, index: 15)
            data.lastUpdate = db.getInt(stmt, index: 16)
            data.updateStatus = db.getInt(stmt, index: 17)
            data.closingPrice = db.getDouble(stmt, index: 18)
        }
        db.closeStatement(stmt)
        return data
    }
    
    // Load FiiData by its status
    // Used to get all FiiData as Active or Sold
    func getDataByStatus(_ status: Int) -> Array<FiiData> {
        var fiiDatas : Array<FiiData> = []
        let stmt = db.query("SELECT * FROM fii_data where status = ?",params: [status])
        while (db.nextRow(stmt)){
            let data = FiiData()
            data.id = db.getInt(stmt, index: 0)
            data.symbol = db.getString(stmt, index: 1)
            data.quantity = db.getInt(stmt, index: 2)
            data.buyValue = db.getDouble(stmt, index: 3)
            data.netIncome = db.getDouble(stmt, index: 4)
            data.incomeTax = db.getDouble(stmt, index: 5)
            data.variation = db.getDouble(stmt, index: 6)
            data.totalGain = db.getDouble(stmt, index: 7)
            data.objectivePercent = db.getDouble(stmt, index: 8)
            data.currentPercent = db.getDouble(stmt, index: 9)
            data.mediumPrice = db.getDouble(stmt, index: 10)
            data.currentPrice = db.getDouble(stmt, index: 11)
            data.currentTotal = db.getDouble(stmt, index: 12)
            data.status = db.getInt(stmt, index: 13)
            data.tax = db.getDouble(stmt, index: 14)
            data.brokerage = db.getDouble(stmt, index: 15)
            data.lastUpdate = db.getInt(stmt, index: 16)
            data.updateStatus = db.getInt(stmt, index: 17)
            data.closingPrice = db.getDouble(stmt, index: 18)
            fiiDatas.append(data)
        }
        db.closeStatement(stmt)
        return fiiDatas
    }
    
    // Load All FiiData
    func getData() -> Array<FiiData> {
        var fiiDatas : Array<FiiData> = []
        let stmt = db.query("SELECT * FROM fii_data")
        while (db.nextRow(stmt)){
            let data = FiiData()
            data.id = db.getInt(stmt, index: 0)
            data.symbol = db.getString(stmt, index: 1)
            data.quantity = db.getInt(stmt, index: 2)
            data.buyValue = db.getDouble(stmt, index: 3)
            data.netIncome = db.getDouble(stmt, index: 4)
            data.incomeTax = db.getDouble(stmt, index: 5)
            data.variation = db.getDouble(stmt, index: 6)
            data.totalGain = db.getDouble(stmt, index: 7)
            data.objectivePercent = db.getDouble(stmt, index: 8)
            data.currentPercent = db.getDouble(stmt, index: 9)
            data.mediumPrice = db.getDouble(stmt, index: 10)
            data.currentPrice = db.getDouble(stmt, index: 11)
            data.currentTotal = db.getDouble(stmt, index: 12)
            data.status = db.getInt(stmt, index: 13)
            data.tax = db.getDouble(stmt, index: 14)
            data.brokerage = db.getDouble(stmt, index: 15)
            data.lastUpdate = db.getInt(stmt, index: 16)
            data.updateStatus = db.getInt(stmt, index: 17)
            data.closingPrice = db.getDouble(stmt, index: 18)
            fiiDatas.append(data)
        }
        db.closeStatement(stmt)
        return fiiDatas
    }
    
    // Save or update a FiiData
    func save(_ data: FiiData){
        if(data.id == 0){
            // Insert
            let sql = "insert or replace into fii_data (symbol,quantity_total,value_total,income_total,income_tax,variation,total_gain,objective_percent,current_percent,medium_price,current_price,current_total,status,tax,brokerage,last_update,update_status,closing_price) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);"
            
            let params = [data.symbol,data.quantity,data.buyValue,data.netIncome,data.incomeTax,data.variation,data.totalGain,data.objectivePercent,data.currentPercent,data.mediumPrice,data.currentPrice,data.currentTotal,data.status,data.tax,data.brokerage,data.lastUpdate,data.updateStatus,data.closingPrice] as [Any]
            _ = db.execSql(sql, params: params as Array<AnyObject>)
        } else {
            // Update
            let sql = "update fii_data set symbol=?,quantity_total=?,value_total=?,income_total=?,income_tax=?,variation=?,total_gain=?,objective_percent=?,current_percent=?,medium_price=?,current_price=?,current_total=?,status=?,tax=?,brokerage=?,last_update=?,update_status=?,closing_price=? where _id=?;"
            let params = [data.symbol,data.quantity,data.buyValue,data.netIncome,data.incomeTax,data.variation,data.totalGain,data.objectivePercent,data.currentPercent,data.mediumPrice,data.currentPrice,data.currentTotal,data.status,data.tax,data.brokerage,data.lastUpdate,data.updateStatus,data.closingPrice,data.id] as [Any]
            _ = db.execSql(sql,params: params as Array<AnyObject>)
        }
    }
    
    func bulkSave(_ fiis: Array<FiiData>){
        fiis.forEach{ fii in
            save(fii)
        }
    }
    
    func delete(_ data: FiiData){
        let sql = "delete from fii_data where _id = ?"
        _ = db.execSql(sql,params: [data.id])
    }
    
    func deleteById(_ id: Int){
        let sql = "delete from fii_data where _id = ?"
        _ = db.execSql(sql,params: [id])
    }
    
    func deleteBySymbol(_ symbol: String){
        let sql = "delete from fii_data where symbol = ?"
        _ = db.execSql(sql,params: [symbol])
    }
    
    func close(){
        // Close database
        self.db.close()
    }
}
