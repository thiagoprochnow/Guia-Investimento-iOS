//
//  OthersTransactionDB.swift
//  Guia Investimento
//
//  Created by Felipe on 24/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
class OthersTransactionDB{
    var db:SQLiteHelper
    init(){
        self.db = SQLiteHelper(database: "Portfolio.db")
    }
    
    // Create OthersTransaction tables if it does not exists
    func createTable(){
        let sql = "create table if not exists others_transaction (_id integer primary key autoincrement"
            + ", symbol text not null"
            + ", bought_total real"
            + ", timestamp long"
            + ", type integer"
            + ", tax real"
            + ", brokerage real"
            + ", last_update long"
            + ", foreign key (symbol) references others_data (_id));"
        _ = db.execSql(sql)
    }
    
    // Load all Transaction of a specific Others Symbol
    func getTransactionsBySymbol(_ symbol: String) -> Array<OthersTransaction> {
        var othersTransactions : Array<OthersTransaction> = []
        let stmt = db.query("SELECT * FROM others_transaction where symbol = ?",params: [symbol])
        while (db.nextRow(stmt)){
            let transaction = OthersTransaction()
            transaction.id = db.getInt(stmt, index: 0)
            transaction.symbol = db.getString(stmt, index: 1)
            transaction.boughtTotal = db.getDouble(stmt, index: 2)
            transaction.timestamp = db.getInt(stmt, index: 3)
            transaction.type = db.getInt(stmt, index: 4)
            transaction.tax = db.getDouble(stmt, index: 5)
            transaction.brokerage = db.getDouble(stmt, index: 6)
            transaction.lastUpdate = db.getInt(stmt, index: 7)
            othersTransactions.append(transaction)
        }
        db.closeStatement(stmt)
        return othersTransactions
    }
    
    // Load all Transaction of a specific Others Symbol
    func getTransactionsByTimestamp(_ symbol: String, timestamp: Int) -> Array<OthersTransaction> {
        var othersTransactions : Array<OthersTransaction> = []
        let stmt = db.query("SELECT * FROM others_transaction where symbol = ? AND timestamp < ?  ORDER BY timestamp ASC",params: [symbol, timestamp])
        while (db.nextRow(stmt)){
            let transaction = OthersTransaction()
            transaction.id = db.getInt(stmt, index: 0)
            transaction.symbol = db.getString(stmt, index: 1)
            transaction.boughtTotal = db.getDouble(stmt, index: 2)
            transaction.timestamp = db.getInt(stmt, index: 3)
            transaction.type = db.getInt(stmt, index: 4)
            transaction.tax = db.getDouble(stmt, index: 5)
            transaction.brokerage = db.getDouble(stmt, index: 6)
            transaction.lastUpdate = db.getInt(stmt, index: 7)
            othersTransactions.append(transaction)
        }
        db.closeStatement(stmt)
        return othersTransactions
    }
    
    // Load OthersTransaction with a specific id
    func getTransactionById(_ id: Int) -> OthersTransaction {
        let transaction = OthersTransaction()
        let stmt = db.query("SELECT * FROM others_transaction where _id = ?",params: [id])
        if(db.nextRow(stmt)){
            transaction.id = db.getInt(stmt, index: 0)
            transaction.symbol = db.getString(stmt, index: 1)
            transaction.boughtTotal = db.getDouble(stmt, index: 2)
            transaction.timestamp = db.getInt(stmt, index: 3)
            transaction.type = db.getInt(stmt, index: 4)
            transaction.tax = db.getDouble(stmt, index: 5)
            transaction.brokerage = db.getDouble(stmt, index: 6)
            transaction.lastUpdate = db.getInt(stmt, index: 7)
        }
        db.closeStatement(stmt)
        return transaction
    }
    
    // Save or update a OthersTransaction
    func save(_ transaction: OthersTransaction){
        if(transaction.id == 0){
            // Insert
            let sql = "insert or replace into others_transaction (symbol,bought_total,timestamp,type,tax,brokerage,last_update) VALUES (?,?,?,?,?,?,?);"
            let params = [transaction.symbol,transaction.boughtTotal,transaction.timestamp,transaction.type,transaction.tax,transaction.brokerage,transaction.lastUpdate] as [Any]
            _ = db.execSql(sql, params: params as Array<AnyObject>)
        } else {
            // Update
            let sql = "update others_transaction set symbol=?,bought_total=?,timestamp=?,type=?,tax=?,brokerage=?,last_update=? where _id=?;"
            let params = [transaction.symbol,transaction.boughtTotal,transaction.timestamp,transaction.type,transaction.tax,transaction.brokerage,transaction.lastUpdate, transaction.id] as [Any]
            _ = db.execSql(sql,params: params as Array<AnyObject>)
        }
    }
    
    func delete(_ transaction: OthersTransaction){
        let sql = "delete from others_transaction where _id = ?"
        _ = db.execSql(sql,params: [transaction.id])
    }
    
    func deleteById(_ id: Int){
        let sql = "delete from others_transaction where _id = ?"
        _ = db.execSql(sql,params: [id])
    }
    
    func deleteBySymbol(_ symbol: String){
        let sql = "delete from others_transaction where symbol = ?"
        _ = db.execSql(sql,params: [symbol])
    }
    
    func close(){
        // Close database
        self.db.close()
    }
}
