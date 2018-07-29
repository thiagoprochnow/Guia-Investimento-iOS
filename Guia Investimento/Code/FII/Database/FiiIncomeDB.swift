//
//  FiiIncomeDB.swift
//  Guia Investimento
//
//  Created by Felipe on 07/07/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
class FiiIncomeDB{
    var db:SQLiteHelper
    init(){
        self.db = SQLiteHelper(database: "Portfolio.db")
    }
    
    // Create FiiIncome tables if it does not exists
    func createTable(){
        let sql = "create table if not exists fii_incomes (_id integer primary key autoincrement"
            + ", symbol text not null"
            + ", income_type integer"
            + ", per_fii real"
            + ", timestamp long"
            + ", receive_total real"
            + ", tax real"
            + ", receive_liquid real"
            + ", affected_quantity integer"
            + ", brokerage real"
            + ", last_update long"
            + ", foreign key (symbol) references fii_data (_id));"
        _ = db.execSql(sql)
    }
    
    // Load all Incomes of a specific Fii Symbol
    func getIncomesBySymbol(_ symbol: String) -> Array<FiiIncome> {
        var fiiIncomes : Array<FiiIncome> = []
        let stmt = db.query("SELECT * FROM fii_incomes where symbol = ? AND affected_quantity > 0",params: [symbol])
        while (db.nextRow(stmt)){
            let income = FiiIncome()
            income.id = db.getInt(stmt, index: 0)
            income.symbol = db.getString(stmt, index: 1)
            income.type = db.getInt(stmt, index: 2)
            income.perFii = db.getDouble(stmt, index: 3)
            income.exdividendTimestamp = db.getInt(stmt, index: 4)
            income.grossIncome = db.getDouble(stmt, index: 5)
            income.tax = db.getDouble(stmt, index: 6)
            income.liquidIncome = db.getDouble(stmt, index: 7)
            income.affectedQuantity = db.getInt(stmt, index: 8)
            income.brokerage = db.getDouble(stmt, index: 9)
            income.lastUpdate = db.getInt(stmt, index: 10)
            fiiIncomes.append(income)
        }
        db.closeStatement(stmt)
        return fiiIncomes
    }
    
    // Load all Incomes with a bigger Timestamp then
    func getIncomesByTimestamp(_ symbol: String, timestamp: Int) -> Array<FiiIncome> {
        var fiiIncomes : Array<FiiIncome> = []
        let stmt = db.query("SELECT * FROM fii_incomes where symbol = ? AND timestamp > ?",params: [symbol,timestamp])
        while (db.nextRow(stmt)){
            let income = FiiIncome()
            income.id = db.getInt(stmt, index: 0)
            income.symbol = db.getString(stmt, index: 1)
            income.type = db.getInt(stmt, index: 2)
            income.perFii = db.getDouble(stmt, index: 3)
            income.exdividendTimestamp = db.getInt(stmt, index: 4)
            income.grossIncome = db.getDouble(stmt, index: 5)
            income.tax = db.getDouble(stmt, index: 6)
            income.liquidIncome = db.getDouble(stmt, index: 7)
            income.affectedQuantity = db.getInt(stmt, index: 8)
            income.brokerage = db.getDouble(stmt, index: 9)
            income.lastUpdate = db.getInt(stmt, index: 10)
            fiiIncomes.append(income)
        }
        db.closeStatement(stmt)
        return fiiIncomes
    }
    
    func getLastIncome(_ symbol: String) -> FiiIncome{
        var income = FiiIncome()
        let stmt = db.query("SELECT * FROM fii_incomes where symbol = ? ORDER BY timestamp DESC",params: [symbol])
        if(db.nextRow(stmt)){
            income.id = db.getInt(stmt, index: 0)
            income.symbol = db.getString(stmt, index: 1)
            income.type = db.getInt(stmt, index: 2)
            income.perFii = db.getDouble(stmt, index: 3)
            income.exdividendTimestamp = db.getInt(stmt, index: 4)
            income.grossIncome = db.getDouble(stmt, index: 5)
            income.tax = db.getDouble(stmt, index: 6)
            income.liquidIncome = db.getDouble(stmt, index: 7)
            income.affectedQuantity = db.getInt(stmt, index: 8)
            income.brokerage = db.getDouble(stmt, index: 9)
            income.lastUpdate = db.getInt(stmt, index: 10)
        }
        db.closeStatement(stmt)
        return income
    }
    
    // Load FiiIncome with a specific id
    func getIncomesById(_ id: Int) -> FiiIncome {
            let income = FiiIncome()
        let stmt = db.query("SELECT * FROM fii_incomes where _id = ?",params: [id])
        if(db.nextRow(stmt)){
            income.id = db.getInt(stmt, index: 0)
            income.symbol = db.getString(stmt, index: 1)
            income.type = db.getInt(stmt, index: 2)
            income.perFii = db.getDouble(stmt, index: 3)
            income.exdividendTimestamp = db.getInt(stmt, index: 4)
            income.grossIncome = db.getDouble(stmt, index: 5)
            income.tax = db.getDouble(stmt, index: 6)
            income.liquidIncome = db.getDouble(stmt, index: 7)
            income.affectedQuantity = db.getInt(stmt, index: 8)
            income.brokerage = db.getDouble(stmt, index: 9)
            income.lastUpdate = db.getInt(stmt, index: 10)
        }
        db.closeStatement(stmt)
        return income
    }
    
    // Load all Incomes of a specific Fii Symbol
    func getIncomes() -> Array<FiiIncome> {
        var fiiIncomes : Array<FiiIncome> = []
        let stmt = db.query("SELECT * FROM fii_incomes WHERE affected_quantity > 0")
        while (db.nextRow(stmt)){
            let income = FiiIncome()
            income.id = db.getInt(stmt, index: 0)
            income.symbol = db.getString(stmt, index: 1)
            income.type = db.getInt(stmt, index: 2)
            income.perFii = db.getDouble(stmt, index: 3)
            income.exdividendTimestamp = db.getInt(stmt, index: 4)
            income.grossIncome = db.getDouble(stmt, index: 5)
            income.tax = db.getDouble(stmt, index: 6)
            income.liquidIncome = db.getDouble(stmt, index: 7)
            income.affectedQuantity = db.getInt(stmt, index: 8)
            income.brokerage = db.getDouble(stmt, index: 9)
            income.lastUpdate = db.getInt(stmt, index: 10)
            fiiIncomes.append(income)
        }
        db.closeStatement(stmt)
        return fiiIncomes
    }
    
    // Checks if this income is already inserted so it will not generate duplicate
    func isIncomeInserted(_ income:FiiIncome) -> Bool {
        let stmt = db.query("SELECT * FROM fii_incomes WHERE symbol=? AND income_type =? AND per_fii =? AND timestamp=?",params: [income.symbol,income.type,income.perFii,income.exdividendTimestamp])
        if(db.nextRow(stmt)){
            db.closeStatement(stmt)
            return true
        } else {
            db.closeStatement(stmt)
            return false
        }
    }
    
    // Save or update a FiiIncome
    func save(_ income: FiiIncome){
        if(income.id == 0){
            // Insert
            let sql = "insert or replace into fii_incomes (symbol,income_type,per_fii,timestamp,receive_total,tax,receive_liquid,affected_quantity,brokerage,last_update) VALUES (?,?,?,?,?,?,?,?,?,?);"
            let params = [income.symbol,income.type,income.perFii,income.exdividendTimestamp,income.grossIncome,income.tax,income.liquidIncome,income.affectedQuantity,income.brokerage,income.lastUpdate] as [Any]
            _ = db.execSql(sql, params: params as Array<AnyObject>)
        } else {
            // Update
            let sql = "update fii_incomes set symbol=?,income_type=?,per_fii=?,timestamp=?,receive_total=?,tax=?,receive_liquid=?,affected_quantity=?,brokerage=?,last_update=? where _id=?;"
            let params = [income.symbol,income.type,income.perFii,income.exdividendTimestamp,income.grossIncome,income.tax,income.liquidIncome,income.affectedQuantity,income.brokerage,income.lastUpdate,income.id] as [Any]
            _ = db.execSql(sql,params: params as Array<AnyObject>)
        }
    }
    
    func delete(_ income: FiiIncome){
        let sql = "delete from fii_incomes where _id = ?"
        _ = db.execSql(sql,params: [income.id])
    }
    
    func deleteById(_ id: Int){
        let sql = "delete from fii_incomes where _id = ?"
        _ = db.execSql(sql,params: [id])
    }
    
    func deleteBySymbol(_ symbol: String){
        let sql = "delete from fii_incomes where symbol = ?"
        _ = db.execSql(sql,params: [symbol])
    }
    
    func close(){
        // Close database
        self.db.close()
    }
    
}
