//
//  TreasuryIncomeDB.swift
//  Guia Investimento
//
//  Created by Felipe on 07/07/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
class TreasuryIncomeDB{
    var db:SQLiteHelper
    init(){
        self.db = SQLiteHelper(database: "Portfolio.db")
    }
    
    // Create TreasuryIncome tables if it does not exists
    func createTable(){
        let sql = "create table if not exists treasury_incomes (_id integer primary key autoincrement"
            + ", symbol text not null"
            + ", income_type integer"
            + ", timestamp long"
            + ", receive_total real"
            + ", tax real"
            + ", receive_liquid real"
            + ", brokerage real"
            + ", last_update long"
            + ", foreign key (symbol) references treasury_data (_id));"
        _ = db.execSql(sql)
    }
    
    // Load all Incomes of a specific Treasury Symbol
    func getIncomesBySymbol(_ symbol: String) -> Array<TreasuryIncome> {
        var treasuryIncomes : Array<TreasuryIncome> = []
        let stmt = db.query("SELECT * FROM treasury_incomes where symbol = ?",params: [symbol])
        while (db.nextRow(stmt)){
            let income = TreasuryIncome()
            income.id = db.getInt(stmt, index: 0)
            income.symbol = db.getString(stmt, index: 1)
            income.type = db.getInt(stmt, index: 2)
            income.exdividendTimestamp = db.getInt(stmt, index: 3)
            income.grossIncome = db.getDouble(stmt, index: 4)
            income.tax = db.getDouble(stmt, index: 5)
            income.liquidIncome = db.getDouble(stmt, index: 6)
            income.brokerage = db.getDouble(stmt, index: 7)
            income.lastUpdate = db.getInt(stmt, index: 8)
            treasuryIncomes.append(income)
        }
        db.closeStatement(stmt)
        return treasuryIncomes
    }
    
    // Load all Incomes with a bigger Timestamp then
    func getIncomesByTimestamp(_ symbol: String, timestamp: Int) -> Array<TreasuryIncome> {
        var treasuryIncomes : Array<TreasuryIncome> = []
        let stmt = db.query("SELECT * FROM treasury_incomes where symbol = ? AND timestamp > ?",params: [symbol,timestamp])
        while (db.nextRow(stmt)){
            let income = TreasuryIncome()
            income.id = db.getInt(stmt, index: 0)
            income.symbol = db.getString(stmt, index: 1)
            income.type = db.getInt(stmt, index: 2)
            income.exdividendTimestamp = db.getInt(stmt, index: 3)
            income.grossIncome = db.getDouble(stmt, index: 4)
            income.tax = db.getDouble(stmt, index: 5)
            income.liquidIncome = db.getDouble(stmt, index: 6)
            income.brokerage = db.getDouble(stmt, index: 7)
            income.lastUpdate = db.getInt(stmt, index: 8)
            treasuryIncomes.append(income)
        }
        db.closeStatement(stmt)
        return treasuryIncomes
    }
    
    func getLastIncome(_ symbol: String) -> TreasuryIncome{
        var income = TreasuryIncome()
        let stmt = db.query("SELECT * FROM treasury_incomes where symbol = ? ORDER BY timestamp DESC",params: [symbol])
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
    
    // Load TreasuryIncome with a specific id
    func getIncomesById(_ id: Int) -> TreasuryIncome {
            let income = TreasuryIncome()
        let stmt = db.query("SELECT * FROM treasury_incomes where _id = ?",params: [id])
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
    
    // Load all Incomes of a specific Treasury Symbol
    func getIncomes() -> Array<TreasuryIncome> {
        var treasuryIncomes : Array<TreasuryIncome> = []
        let stmt = db.query("SELECT * FROM treasury_incomes")
        while (db.nextRow(stmt)){
            let income = TreasuryIncome()
            income.id = db.getInt(stmt, index: 0)
            income.symbol = db.getString(stmt, index: 1)
            income.type = db.getInt(stmt, index: 2)
            income.exdividendTimestamp = db.getInt(stmt, index: 3)
            income.grossIncome = db.getDouble(stmt, index: 4)
            income.tax = db.getDouble(stmt, index: 5)
            income.liquidIncome = db.getDouble(stmt, index: 6)
            income.brokerage = db.getDouble(stmt, index: 7)
            income.lastUpdate = db.getInt(stmt, index: 8)
            treasuryIncomes.append(income)
        }
        db.closeStatement(stmt)
        return treasuryIncomes
    }
    
    // Save or update a TreasuryIncome
    func save(_ income: TreasuryIncome){
        if(income.id == 0){
            // Insert
            let sql = "insert or replace into treasury_incomes (symbol,income_type,timestamp,receive_total,tax,receive_liquid,brokerage,last_update) VALUES (?,?,?,?,?,?,?,?);"
            let params = [income.symbol,income.type,income.exdividendTimestamp,income.grossIncome,income.tax,income.liquidIncome,income.brokerage,income.lastUpdate] as [Any]
            _ = db.execSql(sql, params: params as Array<AnyObject>)
        } else {
            // Update
            let sql = "update treasury_incomes set symbol=?,income_type=?,timestamp=?,receive_total=?,tax=?,receive_liquid=?,brokerage=?,last_update=? where _id=?;"
            let params = [income.symbol,income.type,income.exdividendTimestamp,income.grossIncome,income.tax,income.liquidIncome,income.brokerage,income.lastUpdate,income.id] as [Any]
            _ = db.execSql(sql,params: params as Array<AnyObject>)
        }
    }
    
    func delete(_ income: TreasuryIncome){
        let sql = "delete from treasury_incomes where _id = ?"
        _ = db.execSql(sql,params: [income.id])
    }
    
    func deleteById(_ id: Int){
        let sql = "delete from treasury_incomes where _id = ?"
        _ = db.execSql(sql,params: [id])
    }
    
    func deleteBySymbol(_ symbol: String){
        let sql = "delete from treasury_incomes where symbol = ?"
        _ = db.execSql(sql,params: [symbol])
    }
    
    func close(){
        // Close database
        self.db.close()
    }
    
}
