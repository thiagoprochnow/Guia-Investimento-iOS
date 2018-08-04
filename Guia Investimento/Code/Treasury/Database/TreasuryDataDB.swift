//
//  TreasuryDataDB.swift
//  Guia Investimento
//
//  Created by Felipe on 24/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
class TreasuryDataDB{
    var db:SQLiteHelper
    init(){
        self.db = SQLiteHelper(database: "Portfolio.db")
    }
    
    // Create TreasuryData tables if it does not exists
    func createTable(){
        let sql = "create table if not exists treasury_data (_id integer primary key autoincrement"
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
            + ", UNIQUE (symbol) ON CONFLICT REPLACE);"
        _ = db.execSql(sql)
    }
    
    // Load TreasuryData of a specific Treasury Symbol
    func getDataBySymbol(_ symbol: String) -> TreasuryData {
        let data = TreasuryData()
        let stmt = db.query("SELECT * FROM treasury_data where symbol = ?",params: [symbol])
        if (db.nextRow(stmt)){
            data.id = db.getInt(stmt, index: 0)
            data.symbol = db.getString(stmt, index: 1)
            data.quantity = db.getDouble(stmt, index: 2)
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
        }
        db.closeStatement(stmt)
        return data
    }
    
    // Load Active Treasury ordered by percent
    func getDataPercent() -> Array<TreasuryData> {
        var treasuryDatas : Array<TreasuryData> = []
        let stmt = db.query("SELECT _id,symbol,current_percent FROM treasury_data where status = ? ORDER BY current_percent DESC",params: [Constants.Status.ACTIVE])
        while (db.nextRow(stmt)){
            let data = TreasuryData()
            data.id = db.getInt(stmt, index: 0)
            data.symbol = db.getString(stmt, index: 1)
            data.currentPercent = db.getDouble(stmt, index: 2)
            treasuryDatas.append(data)
        }
        db.closeStatement(stmt)
        return treasuryDatas
    }
    
    // Load Treasury of a specific Treasury Symbol
    func getDataById(_ id: Int) -> TreasuryData {
        let data = TreasuryData()
        let stmt = db.query("SELECT * FROM treasury_data where _id = ?",params: [id])
        if (db.nextRow(stmt)){
            data.id = db.getInt(stmt, index: 0)
            data.symbol = db.getString(stmt, index: 1)
            data.quantity = db.getDouble(stmt, index: 2)
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
        }
        db.closeStatement(stmt)
        return data
    }
    
    // Load TreasuryData by its status
    // Used to get all TreasuryData as Active or Sold
    func getDataByStatus(_ status: Int) -> Array<TreasuryData> {
        var treasuryDatas : Array<TreasuryData> = []
        let stmt = db.query("SELECT * FROM treasury_data where status = ?",params: [status])
        while (db.nextRow(stmt)){
            let data = TreasuryData()
            data.id = db.getInt(stmt, index: 0)
            data.symbol = db.getString(stmt, index: 1)
            data.quantity = db.getDouble(stmt, index: 2)
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
            treasuryDatas.append(data)
        }
        db.closeStatement(stmt)
        return treasuryDatas
    }
    
    // Load All TreasuryData
    func getData() -> Array<TreasuryData> {
        var treasuryDatas : Array<TreasuryData> = []
        let stmt = db.query("SELECT * FROM treasury_data")
        while (db.nextRow(stmt)){
            let data = TreasuryData()
            data.id = db.getInt(stmt, index: 0)
            data.symbol = db.getString(stmt, index: 1)
            data.quantity = db.getDouble(stmt, index: 2)
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
            treasuryDatas.append(data)
        }
        db.closeStatement(stmt)
        return treasuryDatas
    }
    
    // Save or update a TreasuryData
    func save(_ data: TreasuryData){
        if(data.id == 0){
            // Insert
            let sql = "insert or replace into treasury_data (symbol,quantity_total,value_total,income_total,income_tax,variation,total_gain,objective_percent,current_percent,medium_price,current_price,current_total,status,tax,brokerage,last_update,update_status) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);"
            
            let params = [data.symbol,data.quantity,data.buyValue,data.netIncome,data.incomeTax,data.variation,data.totalGain,data.objectivePercent,data.currentPercent,data.mediumPrice,data.currentPrice,data.currentTotal,data.status,data.tax,data.brokerage,data.lastUpdate,data.updateStatus] as [Any]
            _ = db.execSql(sql, params: params as Array<AnyObject>)
        } else {
            // Update
            let sql = "update treasury_data set symbol=?,quantity_total=?,value_total=?,income_total=?,income_tax=?,variation=?,total_gain=?,objective_percent=?,current_percent=?,medium_price=?,current_price=?,current_total=?,status=?,tax=?,brokerage=?,last_update=?,update_status=? where _id=?;"
            let params = [data.symbol,data.quantity,data.buyValue,data.netIncome,data.incomeTax,data.variation,data.totalGain,data.objectivePercent,data.currentPercent,data.mediumPrice,data.currentPrice,data.currentTotal,data.status,data.tax,data.brokerage,data.lastUpdate,data.updateStatus,data.id] as [Any]
            _ = db.execSql(sql,params: params as Array<AnyObject>)
        }
    }
    
    func bulkSave(_ treasuries: Array<TreasuryData>){
        treasuries.forEach{ treasury in
            save(treasury)
        }
    }
    
    func delete(_ data: TreasuryData){
        let sql = "delete from treasury_data where _id = ?"
        _ = db.execSql(sql,params: [data.id])
    }
    
    func deleteById(_ id: Int){
        let sql = "delete from treasury_data where _id = ?"
        _ = db.execSql(sql,params: [id])
    }
    
    func deleteBySymbol(_ symbol: String){
        let sql = "delete from treasury_data where symbol = ?"
        _ = db.execSql(sql,params: [symbol])
    }
    
    func close(){
        // Close database
        self.db.close()
    }
}
