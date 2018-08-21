//
//  FixedTransactionDB.swift
//  Guia Investimento
//
//  Created by Felipe on 24/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
class FixedTransactionDB{
    var db:SQLiteHelper
    init(){
        self.db = SQLiteHelper(database: "Portfolio.db")
    }
    
    // Create FixedTransaction tables if it does not exists
    func createTable(){
        let sql = "create table if not exists fixed_transaction (_id integer primary key autoincrement"
            + ", symbol text not null"
            + ", bought_total real"
            + ", timestamp long"
            + ", type integer"
            + ", tax real"
            + ", brokerage real"
            + ", gain_rate real"
            + ", gain_type integer"
            + ", last_update long"
            + ", foreign key (symbol) references fixed_data (_id));"
        _ = db.execSql(sql)
    }
    
    // Load all Transaction of a specific Fixed Symbol
    func getTransactionsBySymbol(_ symbol: String) -> Array<FixedTransaction> {
        var fixedTransactions : Array<FixedTransaction> = []
        let stmt = db.query("SELECT * FROM fixed_transaction where symbol = ?",params: [symbol])
        while (db.nextRow(stmt)){
            let transaction = FixedTransaction()
            transaction.id = db.getInt(stmt, index: 0)
            transaction.symbol = db.getString(stmt, index: 1)
            transaction.boughtTotal = db.getDouble(stmt, index: 2)
            transaction.timestamp = db.getInt(stmt, index: 3)
            transaction.type = db.getInt(stmt, index: 4)
            transaction.tax = db.getDouble(stmt, index: 5)
            transaction.brokerage = db.getDouble(stmt, index: 6)
            transaction.gainRate = db.getDouble(stmt, index: 7)
            transaction.gainType = db.getInt(stmt, index: 8)
            transaction.lastUpdate = db.getInt(stmt, index: 9)
            fixedTransactions.append(transaction)
        }
        db.closeStatement(stmt)
        return fixedTransactions
    }
    
    // Load all Transaction of a specific Fixed Symbol
    func getTransactionsByTimestamp(_ symbol: String, timestamp: Int) -> Array<FixedTransaction> {
        var fixedTransactions : Array<FixedTransaction> = []
        let stmt = db.query("SELECT * FROM fixed_transaction where symbol = ? AND timestamp < ?  ORDER BY timestamp ASC",params: [symbol, timestamp])
        while (db.nextRow(stmt)){
            let transaction = FixedTransaction()
            transaction.id = db.getInt(stmt, index: 0)
            transaction.symbol = db.getString(stmt, index: 1)
            transaction.boughtTotal = db.getDouble(stmt, index: 2)
            transaction.timestamp = db.getInt(stmt, index: 3)
            transaction.type = db.getInt(stmt, index: 4)
            transaction.tax = db.getDouble(stmt, index: 5)
            transaction.brokerage = db.getDouble(stmt, index: 6)
            transaction.gainRate = db.getDouble(stmt, index: 7)
            transaction.gainType = db.getInt(stmt, index: 8)
            transaction.lastUpdate = db.getInt(stmt, index: 9)
            fixedTransactions.append(transaction)
        }
        db.closeStatement(stmt)
        return fixedTransactions
    }
    
    // Load FixedTransaction with a specific id
    func getTransactionById(_ id: Int) -> FixedTransaction {
        let transaction = FixedTransaction()
        let stmt = db.query("SELECT * FROM fixed_transaction where _id = ?",params: [id])
        if(db.nextRow(stmt)){
            transaction.id = db.getInt(stmt, index: 0)
            transaction.symbol = db.getString(stmt, index: 1)
            transaction.boughtTotal = db.getDouble(stmt, index: 2)
            transaction.timestamp = db.getInt(stmt, index: 3)
            transaction.type = db.getInt(stmt, index: 4)
            transaction.tax = db.getDouble(stmt, index: 5)
            transaction.brokerage = db.getDouble(stmt, index: 6)
            transaction.gainRate = db.getDouble(stmt, index: 7)
            transaction.gainType = db.getInt(stmt, index: 8)
            transaction.lastUpdate = db.getInt(stmt, index: 9)
        }
        db.closeStatement(stmt)
        return transaction
    }
    
    // Save or update a FixedTransaction
    func save(_ transaction: FixedTransaction){
        if(transaction.id == 0){
            // Insert
            let sql = "insert or replace into fixed_transaction (symbol,bought_total,timestamp,type,tax,brokerage,gain_rate,gain_type,last_update) VALUES (?,?,?,?,?,?,?,?,?);"
            let params = [transaction.symbol,transaction.boughtTotal,transaction.timestamp,transaction.type,transaction.tax,transaction.brokerage,transaction.gainRate,transaction.gainType,transaction.lastUpdate] as [Any]
            _ = db.execSql(sql, params: params as Array<AnyObject>)
        } else {
            // Update
            let sql = "update fixed_transaction set symbol=?,bought_total=?,timestamp=?,type=?,tax=?,brokerage=?,gain_rate=?,gain_type=?,last_update=? where _id=?;"
            let params = [transaction.symbol,transaction.boughtTotal,transaction.timestamp,transaction.type,transaction.tax,transaction.brokerage,transaction.gainRate,transaction.gainType,transaction.lastUpdate, transaction.id] as [Any]
            _ = db.execSql(sql,params: params as Array<AnyObject>)
        }
    }
    
    func delete(_ transaction: FixedTransaction){
        let sql = "delete from fixed_transaction where _id = ?"
        _ = db.execSql(sql,params: [transaction.id])
    }
    
    func deleteById(_ id: Int){
        let sql = "delete from fixed_transaction where _id = ?"
        _ = db.execSql(sql,params: [id])
    }
    
    func deleteBySymbol(_ symbol: String){
        let sql = "delete from fixed_transaction where symbol = ?"
        _ = db.execSql(sql,params: [symbol])
    }
    
    func close(){
        // Close database
        self.db.close()
    }
}