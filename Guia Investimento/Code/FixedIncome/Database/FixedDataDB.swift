//
//  FixedDataDB.swift
//  Guia Investimento
//
//  Created by Felipe on 24/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
class FixedDataDB{
    var db:SQLiteHelper
    init(){
        self.db = SQLiteHelper(database: "Portfolio.db")
    }
    
    // Create FixedData tables if it does not exists
    func createTable(){
        let sql = "create table if not exists fixed_data (_id integer primary key autoincrement"
            + ", symbol text not null"
            + ", buy_value_total real"
            + ", sell_value_total real"
            + ", net_gain real"
            + ", tax real"
            + ", total_gain real"
            + ", objective_percent real"
            + ", current_percent real"
            + ", current_total real"
            + ", status integer"
            + ", brokerage real"
            + ", update_status integer"
            + ", last_update long"
            + ", UNIQUE (symbol) ON CONFLICT REPLACE);"
        _ = db.execSql(sql)
    }
    
    // Load FixedData of a specific Fixed Symbol
    func getDataBySymbol(_ symbol: String) -> FixedData {
        let data = FixedData()
        let stmt = db.query("SELECT * FROM fixed_data where symbol = ?",params: [symbol])
        if (db.nextRow(stmt)){
            data.id = db.getInt(stmt, index: 0)
            data.symbol = db.getString(stmt, index: 1)
            data.buyTotal = db.getDouble(stmt, index: 2)
            data.sellTotal = db.getDouble(stmt, index: 3)
            data.netGain = db.getDouble(stmt, index: 4)
            data.tax = db.getDouble(stmt, index: 5)
            data.totalGain = db.getDouble(stmt, index: 6)
            data.objectivePercent = db.getDouble(stmt, index: 7)
            data.currentPercent = db.getDouble(stmt, index: 8)
            data.currentTotal = db.getDouble(stmt, index: 9)
            data.status = db.getInt(stmt, index: 10)
            data.brokerage = db.getDouble(stmt, index: 11)
            data.updateStatus = db.getInt(stmt, index: 12)
            data.lastUpdate = db.getInt(stmt, index: 13)
        }
        db.closeStatement(stmt)
        return data
    }
    
    // Load Active Fixed ordered by percent
    func getDataPercent() -> Array<FixedData> {
        var fixedDatas : Array<FixedData> = []
        let stmt = db.query("SELECT _id,symbol,current_percent FROM fixed_data where status = ? ORDER BY current_percent DESC",params: [Constants.Status.ACTIVE])
        while (db.nextRow(stmt)){
            let data = FixedData()
            data.id = db.getInt(stmt, index: 0)
            data.symbol = db.getString(stmt, index: 1)
            data.currentPercent = db.getDouble(stmt, index: 2)
            fixedDatas.append(data)
        }
        db.closeStatement(stmt)
        return fixedDatas
    }
    
    // Load Fixed of a specific Fixed Symbol
    func getDataById(_ id: Int) -> FixedData {
        let data = FixedData()
        let stmt = db.query("SELECT * FROM fixed_data where _id = ?",params: [id])
        if (db.nextRow(stmt)){
            data.id = db.getInt(stmt, index: 0)
            data.symbol = db.getString(stmt, index: 1)
            data.buyTotal = db.getDouble(stmt, index: 2)
            data.sellTotal = db.getDouble(stmt, index: 3)
            data.netGain = db.getDouble(stmt, index: 4)
            data.tax = db.getDouble(stmt, index: 5)
            data.totalGain = db.getDouble(stmt, index: 6)
            data.objectivePercent = db.getDouble(stmt, index: 7)
            data.currentPercent = db.getDouble(stmt, index: 8)
            data.currentTotal = db.getDouble(stmt, index: 9)
            data.status = db.getInt(stmt, index: 10)
            data.brokerage = db.getDouble(stmt, index: 11)
            data.updateStatus = db.getInt(stmt, index: 12)
            data.lastUpdate = db.getInt(stmt, index: 13)
        }
        db.closeStatement(stmt)
        return data
    }
    
    // Load FixedData by its status
    // Used to get all FixedData as Active or Sold
    func getDataByStatus(_ status: Int) -> Array<FixedData> {
        var fixedDatas : Array<FixedData> = []
        let stmt = db.query("SELECT * FROM fixed_data where status = ?",params: [status])
        while (db.nextRow(stmt)){
            let data = FixedData()
            data.id = db.getInt(stmt, index: 0)
            data.symbol = db.getString(stmt, index: 1)
            data.buyTotal = db.getDouble(stmt, index: 2)
            data.sellTotal = db.getDouble(stmt, index: 3)
            data.netGain = db.getDouble(stmt, index: 4)
            data.tax = db.getDouble(stmt, index: 5)
            data.totalGain = db.getDouble(stmt, index: 6)
            data.objectivePercent = db.getDouble(stmt, index: 7)
            data.currentPercent = db.getDouble(stmt, index: 8)
            data.currentTotal = db.getDouble(stmt, index: 9)
            data.status = db.getInt(stmt, index: 10)
            data.brokerage = db.getDouble(stmt, index: 11)
            data.updateStatus = db.getInt(stmt, index: 12)
            data.lastUpdate = db.getInt(stmt, index: 13)
            fixedDatas.append(data)
        }
        db.closeStatement(stmt)
        return fixedDatas
    }
    
    // Load All FixedData
    func getData() -> Array<FixedData> {
        var fixedDatas : Array<FixedData> = []
        let stmt = db.query("SELECT * FROM fixed_data")
        while (db.nextRow(stmt)){
            let data = FixedData()
            data.id = db.getInt(stmt, index: 0)
            data.symbol = db.getString(stmt, index: 1)
            data.buyTotal = db.getDouble(stmt, index: 2)
            data.sellTotal = db.getDouble(stmt, index: 3)
            data.netGain = db.getDouble(stmt, index: 4)
            data.tax = db.getDouble(stmt, index: 5)
            data.totalGain = db.getDouble(stmt, index: 6)
            data.objectivePercent = db.getDouble(stmt, index: 7)
            data.currentPercent = db.getDouble(stmt, index: 8)
            data.currentTotal = db.getDouble(stmt, index: 9)
            data.status = db.getInt(stmt, index: 10)
            data.brokerage = db.getDouble(stmt, index: 11)
            data.updateStatus = db.getInt(stmt, index: 12)
            data.lastUpdate = db.getInt(stmt, index: 13)
            fixedDatas.append(data)
        }
        db.closeStatement(stmt)
        return fixedDatas
    }
    
    
    // Save or update a FixedData
    func save(_ data: FixedData){
        if(data.id == 0){
            // Insert
            let sql = "insert or replace into fixed_data (symbol,buy_value_total,sell_value_total,net_gain,tax,total_gain,objective_percent,current_percent,current_total,status,brokerage,update_status,last_update) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?);"
            
            let params = [data.symbol,data.buyTotal,data.sellTotal,data.netGain,data.tax,data.totalGain,data.objectivePercent,data.currentPercent,data.currentTotal,data.status,data.brokerage,data.updateStatus,data.lastUpdate] as [Any]
            _ = db.execSql(sql, params: params as Array<AnyObject>)
        } else {
            // Update
            let sql = "update fixed_data set symbol=?,buy_value_total=?,sell_value_total=?,net_gain=?,tax=?,total_gain=?,objective_percent=?,current_percent=?,current_total=?,status=?,brokerage=?,update_status=?,last_update=? where _id=?;"
            let params = [data.symbol,data.buyTotal,data.sellTotal,data.netGain,data.tax,data.totalGain,data.objectivePercent,data.currentPercent,data.currentTotal,data.status,data.brokerage,data.updateStatus,data.lastUpdate,data.id] as [Any]
            _ = db.execSql(sql,params: params as Array<AnyObject>)
        }
    }
    
    func bulkSave(_ fixeds: Array<FixedData>){
        fixeds.forEach{ fixed in
            save(fixed)
        }
    }
    
    func delete(_ data: FixedData){
        let sql = "delete from fixed_data where _id = ?"
        _ = db.execSql(sql,params: [data.id])
    }
    
    func deleteById(_ id: Int){
        let sql = "delete from fixed_data where _id = ?"
        _ = db.execSql(sql,params: [id])
    }
    
    func deleteBySymbol(_ symbol: String){
        let sql = "delete from fixed_data where symbol = ?"
        _ = db.execSql(sql,params: [symbol])
    }
    
    func close(){
        // Close database
        self.db.close()
    }
}
