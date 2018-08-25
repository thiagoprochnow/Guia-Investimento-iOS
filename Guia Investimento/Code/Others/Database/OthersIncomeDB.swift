//
//  OthersIncomeDB.swift
//  Guia Investimento
//
//  Created by Felipe on 07/07/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
class OthersIncomeDB{
    var db:SQLiteHelper
    init(){
        self.db = SQLiteHelper(database: "Portfolio.db")
    }
    
    // Create OthersIncome tables if it does not exists
    func createTable(){
        let sql = "create table if not exists others_incomes (_id integer primary key autoincrement"
            + ", symbol text not null"
            + ", income_type integer"
            + ", timestamp long"
            + ", receive_total real"
            + ", tax real"
            + ", receive_liquid real"
            + ", brokerage real"
            + ", last_update long"
            + ", foreign key (symbol) references others_data (_id));"
        _ = db.execSql(sql)
    }
    
    // Load all Incomes of a specific Others Symbol
    func getIncomesBySymbol(_ symbol: String) -> Array<OthersIncome> {
        var othersIncomes : Array<OthersIncome> = []
        let stmt = db.query("SELECT * FROM others_incomes where symbol = ?",params: [symbol])
        while (db.nextRow(stmt)){
            let income = OthersIncome()
            income.id = db.getInt(stmt, index: 0)
            income.symbol = db.getString(stmt, index: 1)
            income.type = db.getInt(stmt, index: 2)
            income.exdividendTimestamp = db.getInt(stmt, index: 3)
            income.grossIncome = db.getDouble(stmt, index: 4)
            income.tax = db.getDouble(stmt, index: 5)
            income.liquidIncome = db.getDouble(stmt, index: 6)
            income.brokerage = db.getDouble(stmt, index: 7)
            income.lastUpdate = db.getInt(stmt, index: 8)
            othersIncomes.append(income)
        }
        db.closeStatement(stmt)
        return othersIncomes
    }
    
    // Load all Incomes with a bigger Timestamp then
    func getIncomesByTimestamp(_ symbol: String, timestamp: Int) -> Array<OthersIncome> {
        var othersIncomes : Array<OthersIncome> = []
        let stmt = db.query("SELECT * FROM others_incomes where symbol = ? AND timestamp > ?",params: [symbol,timestamp])
        while (db.nextRow(stmt)){
            let income = OthersIncome()
            income.id = db.getInt(stmt, index: 0)
            income.symbol = db.getString(stmt, index: 1)
            income.type = db.getInt(stmt, index: 2)
            income.exdividendTimestamp = db.getInt(stmt, index: 3)
            income.grossIncome = db.getDouble(stmt, index: 4)
            income.tax = db.getDouble(stmt, index: 5)
            income.liquidIncome = db.getDouble(stmt, index: 6)
            income.brokerage = db.getDouble(stmt, index: 7)
            income.lastUpdate = db.getInt(stmt, index: 8)
            othersIncomes.append(income)
        }
        db.closeStatement(stmt)
        return othersIncomes
    }
    
    func getLastIncome(_ symbol: String) -> OthersIncome{
        var income = OthersIncome()
        let stmt = db.query("SELECT * FROM others_incomes where symbol = ? ORDER BY timestamp DESC",params: [symbol])
        if(db.nextRow(stmt)){
            income.id = db.getInt(stmt, index: 0)
            income.symbol = db.getString(stmt, index: 1)
            income.type = db.getInt(stmt, index: 2)
            income.exdividendTimestamp = db.getInt(stmt, index: 3)
            income.grossIncome = db.getDouble(stmt, index: 4)
            income.tax = db.getDouble(stmt, index: 5)
            income.liquidIncome = db.getDouble(stmt, index: 6)
            income.brokerage = db.getDouble(stmt, index: 7)
            income.lastUpdate = db.getInt(stmt, index: 8)
        }
        db.closeStatement(stmt)
        return income
    }
    
    // Load OthersIncome with a specific id
    func getIncomesById(_ id: Int) -> OthersIncome {
            let income = OthersIncome()
        let stmt = db.query("SELECT * FROM others_incomes where _id = ?",params: [id])
        if(db.nextRow(stmt)){
            income.id = db.getInt(stmt, index: 0)
            income.symbol = db.getString(stmt, index: 1)
            income.type = db.getInt(stmt, index: 2)
            income.exdividendTimestamp = db.getInt(stmt, index: 3)
            income.grossIncome = db.getDouble(stmt, index: 4)
            income.tax = db.getDouble(stmt, index: 5)
            income.liquidIncome = db.getDouble(stmt, index: 6)
            income.brokerage = db.getDouble(stmt, index: 7)
            income.lastUpdate = db.getInt(stmt, index: 8)
        }
        db.closeStatement(stmt)
        return income
    }
    
    // Load all Incomes of a specific Others Symbol
    func getIncomes() -> Array<OthersIncome> {
        var othersIncomes : Array<OthersIncome> = []
        let stmt = db.query("SELECT * FROM others_incomes")
        while (db.nextRow(stmt)){
            let income = OthersIncome()
            income.id = db.getInt(stmt, index: 0)
            income.symbol = db.getString(stmt, index: 1)
            income.type = db.getInt(stmt, index: 2)
            income.exdividendTimestamp = db.getInt(stmt, index: 3)
            income.grossIncome = db.getDouble(stmt, index: 4)
            income.tax = db.getDouble(stmt, index: 5)
            income.liquidIncome = db.getDouble(stmt, index: 6)
            income.brokerage = db.getDouble(stmt, index: 7)
            income.lastUpdate = db.getInt(stmt, index: 8)
            othersIncomes.append(income)
        }
        db.closeStatement(stmt)
        return othersIncomes
    }
    
    // Save or update a OthersIncome
    func save(_ income: OthersIncome){
        if(income.id == 0){
            // Insert
            let sql = "insert or replace into others_incomes (symbol,income_type,timestamp,receive_total,tax,receive_liquid,brokerage,last_update) VALUES (?,?,?,?,?,?,?,?);"
            let params = [income.symbol,income.type,income.exdividendTimestamp,income.grossIncome,income.tax,income.liquidIncome,income.brokerage,income.lastUpdate] as [Any]
            _ = db.execSql(sql, params: params as Array<AnyObject>)
        } else {
            // Update
            let sql = "update others_incomes set symbol=?,income_type=?,timestamp=?,receive_total=?,tax=?,receive_liquid=?,brokerage=?,last_update=? where _id=?;"
            let params = [income.symbol,income.type,income.exdividendTimestamp,income.grossIncome,income.tax,income.liquidIncome,income.brokerage,income.lastUpdate,income.id] as [Any]
            _ = db.execSql(sql,params: params as Array<AnyObject>)
        }
    }
    
    func delete(_ income: OthersIncome){
        let sql = "delete from others_incomes where _id = ?"
        _ = db.execSql(sql,params: [income.id])
    }
    
    func deleteById(_ id: Int){
        let sql = "delete from others_incomes where _id = ?"
        _ = db.execSql(sql,params: [id])
    }
    
    func deleteBySymbol(_ symbol: String){
        let sql = "delete from others_incomes where symbol = ?"
        _ = db.execSql(sql,params: [symbol])
    }
    
    func close(){
        // Close database
        self.db.close()
    }
    
}
