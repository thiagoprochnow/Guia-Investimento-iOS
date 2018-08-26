//
//  OthersDataDB.swift
//  Guia Investimento
//
//  Created by Felipe on 24/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
class OthersDataDB{
    var db:SQLiteHelper
    init(){
        self.db = SQLiteHelper(database: "Portfolio.db")
    }
    
    // Create OthersData tables if it does not exists
    func createTable(){
        let sql = "create table if not exists others_data (_id integer primary key autoincrement"
            + ", symbol text not null"
            + ", buy_value_total real"
            + ", sell_value_total real"
            + ", net_gain real"
            + ", tax real"
            + ", variation real"
            + ", total_gain real"
            + ", objective_percent real"
            + ", current_percent real"
            + ", current_total real"
            + ", status integer"
            + ", brokerage real"
            + ", income_total real"
            + ", income_tax real"
            + ", liquid_income real"
            + ", last_update long"
            + ", UNIQUE (symbol) ON CONFLICT REPLACE);"
        _ = db.execSql(sql)
    }
    
    // Load OthersData of a specific Others Symbol
    func getDataBySymbol(_ symbol: String) -> OthersData {
        let data = OthersData()
        let stmt = db.query("SELECT * FROM others_data where symbol = ?",params: [symbol])
        if (db.nextRow(stmt)){
            data.id = db.getInt(stmt, index: 0)
            data.symbol = db.getString(stmt, index: 1)
            data.buyTotal = db.getDouble(stmt, index: 2)
            data.sellTotal = db.getDouble(stmt, index: 3)
            data.netGain = db.getDouble(stmt, index: 4)
            data.tax = db.getDouble(stmt, index: 5)
            data.variation = db.getDouble(stmt, index: 6)
            data.totalGain = db.getDouble(stmt, index: 7)
            data.objectivePercent = db.getDouble(stmt, index: 8)
            data.currentPercent = db.getDouble(stmt, index: 9)
            data.currentTotal = db.getDouble(stmt, index: 10)
            data.status = db.getInt(stmt, index: 11)
            data.brokerage = db.getDouble(stmt, index: 12)
            data.incomeTotal = db.getDouble(stmt, index: 13)
            data.incomeTax = db.getDouble(stmt, index: 14)
            data.liquidIncome = db.getDouble(stmt, index: 15)
            data.lastUpdate = db.getInt(stmt, index: 16)
        }
        db.closeStatement(stmt)
        return data
    }
    
    // Load Active Others ordered by percent
    func getDataPercent() -> Array<OthersData> {
        var othersDatas : Array<OthersData> = []
        let stmt = db.query("SELECT _id,symbol,current_percent FROM others_data where status = ? ORDER BY current_percent DESC",params: [Constants.Status.ACTIVE])
        while (db.nextRow(stmt)){
            let data = OthersData()
            data.id = db.getInt(stmt, index: 0)
            data.symbol = db.getString(stmt, index: 1)
            data.currentPercent = db.getDouble(stmt, index: 2)
            othersDatas.append(data)
        }
        db.closeStatement(stmt)
        return othersDatas
    }
    
    // Load Others of a specific Others Symbol
    func getDataById(_ id: Int) -> OthersData {
        let data = OthersData()
        let stmt = db.query("SELECT * FROM others_data where _id = ?",params: [id])
        if (db.nextRow(stmt)){
            data.id = db.getInt(stmt, index: 0)
            data.symbol = db.getString(stmt, index: 1)
            data.buyTotal = db.getDouble(stmt, index: 2)
            data.sellTotal = db.getDouble(stmt, index: 3)
            data.netGain = db.getDouble(stmt, index: 4)
            data.tax = db.getDouble(stmt, index: 5)
            data.variation = db.getDouble(stmt, index: 6)
            data.totalGain = db.getDouble(stmt, index: 7)
            data.objectivePercent = db.getDouble(stmt, index: 8)
            data.currentPercent = db.getDouble(stmt, index: 9)
            data.currentTotal = db.getDouble(stmt, index: 10)
            data.status = db.getInt(stmt, index: 11)
            data.brokerage = db.getDouble(stmt, index: 12)
            data.incomeTotal = db.getDouble(stmt, index: 13)
            data.incomeTax = db.getDouble(stmt, index: 14)
            data.liquidIncome = db.getDouble(stmt, index: 15)
            data.lastUpdate = db.getInt(stmt, index: 16)
        }
        db.closeStatement(stmt)
        return data
    }
    
    // Load OthersData by its status
    // Used to get all OthersData as Active or Sold
    func getDataByStatus(_ status: Int) -> Array<OthersData> {
        var othersDatas : Array<OthersData> = []
        let stmt = db.query("SELECT * FROM others_data where status = ?",params: [status])
        while (db.nextRow(stmt)){
            let data = OthersData()
            data.id = db.getInt(stmt, index: 0)
            data.symbol = db.getString(stmt, index: 1)
            data.buyTotal = db.getDouble(stmt, index: 2)
            data.sellTotal = db.getDouble(stmt, index: 3)
            data.netGain = db.getDouble(stmt, index: 4)
            data.tax = db.getDouble(stmt, index: 5)
            data.variation = db.getDouble(stmt, index: 6)
            data.totalGain = db.getDouble(stmt, index: 7)
            data.objectivePercent = db.getDouble(stmt, index: 8)
            data.currentPercent = db.getDouble(stmt, index: 9)
            data.currentTotal = db.getDouble(stmt, index: 10)
            data.status = db.getInt(stmt, index: 11)
            data.brokerage = db.getDouble(stmt, index: 12)
            data.incomeTotal = db.getDouble(stmt, index: 13)
            data.incomeTax = db.getDouble(stmt, index: 14)
            data.liquidIncome = db.getDouble(stmt, index: 15)
            data.lastUpdate = db.getInt(stmt, index: 16)
            othersDatas.append(data)
        }
        db.closeStatement(stmt)
        return othersDatas
    }
    
    // Load All OthersDatas
    func getData() -> Array<OthersData> {
        var othersDatas : Array<OthersData> = []
        let stmt = db.query("SELECT * FROM others_data")
        while (db.nextRow(stmt)){
            let data = OthersData()
            data.id = db.getInt(stmt, index: 0)
            data.symbol = db.getString(stmt, index: 1)
            data.buyTotal = db.getDouble(stmt, index: 2)
            data.sellTotal = db.getDouble(stmt, index: 3)
            data.netGain = db.getDouble(stmt, index: 4)
            data.tax = db.getDouble(stmt, index: 5)
            data.variation = db.getDouble(stmt, index: 6)
            data.totalGain = db.getDouble(stmt, index: 7)
            data.objectivePercent = db.getDouble(stmt, index: 8)
            data.currentPercent = db.getDouble(stmt, index: 9)
            data.currentTotal = db.getDouble(stmt, index: 10)
            data.status = db.getInt(stmt, index: 11)
            data.brokerage = db.getDouble(stmt, index: 12)
            data.incomeTotal = db.getDouble(stmt, index: 13)
            data.incomeTax = db.getDouble(stmt, index: 14)
            data.liquidIncome = db.getDouble(stmt, index: 15)
            data.lastUpdate = db.getInt(stmt, index: 16)
            othersDatas.append(data)
        }
        db.closeStatement(stmt)
        return othersDatas
    }
    
    
    // Save or update a OthersData
    func save(_ data: OthersData){
        if(data.id == 0){
            // Insert
            let sql = "insert or replace into others_data (symbol,buy_value_total,sell_value_total,net_gain,tax,variation,total_gain,objective_percent,current_percent,current_total,status,brokerage,income_total,income_tax,liquid_income,last_update) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);"
            
            let params = [data.symbol,data.buyTotal,data.sellTotal,data.netGain,data.tax,data.variation,data.totalGain,data.objectivePercent,data.currentPercent,data.currentTotal,data.status,data.brokerage,data.incomeTotal,data.incomeTax,data.liquidIncome,data.lastUpdate] as [Any]
            _ = db.execSql(sql, params: params as Array<AnyObject>)
        } else {
            // Update
            let sql = "update others_data set symbol=?,buy_value_total=?,sell_value_total=?,net_gain=?,tax=?,variation=?,total_gain=?,objective_percent=?,current_percent=?,current_total=?,status=?,brokerage=?,income_total=?,income_tax=?,liquid_income=?,last_update=? where _id=?;"
            let params = [data.symbol,data.buyTotal,data.sellTotal,data.netGain,data.tax,data.variation,data.totalGain,data.objectivePercent,data.currentPercent,data.currentTotal,data.status,data.brokerage,data.incomeTotal,data.incomeTax,data.liquidIncome,data.lastUpdate,data.id] as [Any]
            _ = db.execSql(sql,params: params as Array<AnyObject>)
        }
    }
    
    func bulkSave(_ others: Array<OthersData>){
        others.forEach{ other in
            save(other)
        }
    }
    
    func delete(_ data: OthersData){
        let sql = "delete from others_data where _id = ?"
        _ = db.execSql(sql,params: [data.id])
    }
    
    func deleteById(_ id: Int){
        let sql = "delete from others_data where _id = ?"
        _ = db.execSql(sql,params: [id])
    }
    
    func deleteBySymbol(_ symbol: String){
        let sql = "delete from others_data where symbol = ?"
        _ = db.execSql(sql,params: [symbol])
    }
    
    func close(){
        // Close database
        self.db.close()
    }
}
