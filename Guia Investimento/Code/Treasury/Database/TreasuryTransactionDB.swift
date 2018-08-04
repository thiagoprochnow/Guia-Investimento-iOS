//
//  TreasuryTransactionDB.swift
//  Guia Investimento
//
//  Created by Felipe on 24/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
class TreasuryTransactionDB{
    var db:SQLiteHelper
    init(){
        self.db = SQLiteHelper(database: "Portfolio.db")
    }
    
    // Create TreasuryTransaction tables if it does not exists
    func createTable(){
        let sql = "create table if not exists treasury_transaction (_id integer primary key autoincrement"
            + ", symbol text not null"
            + ", quantity integer"
            + ", bought_price real"
            + ", timestamp long"
            + ", type integer"
            + ", tax real"
            + ", brokerage real"
            + ", last_update long"
            + ", foreign key (symbol) references treasury_data (_id));"
        _ = db.execSql(sql)
    }
    
    // Load all Transaction of a specific Treasury Symbol
    func getTransactionsBySymbol(_ symbol: String) -> Array<TreasuryTransaction> {
        var treasuryTransactions : Array<TreasuryTransaction> = []
        let stmt = db.query("SELECT * FROM treasury_transaction where symbol = ?",params: [symbol])
        while (db.nextRow(stmt)){
            let transaction = TreasuryTransaction()
            transaction.id = db.getInt(stmt, index: 0)
            transaction.symbol = db.getString(stmt, index: 1)
            transaction.quantity = db.getDouble(stmt, index: 2)
            transaction.price = db.getDouble(stmt, index: 3)
            transaction.timestamp = db.getInt(stmt, index: 4)
            transaction.type = db.getInt(stmt, index: 5)
            transaction.tax = db.getDouble(stmt, index: 6)
            transaction.brokerage = db.getDouble(stmt, index: 7)
            transaction.lastUpdate = db.getInt(stmt, index: 8)
            treasuryTransactions.append(transaction)
        }
        db.closeStatement(stmt)
        return treasuryTransactions
    }
    
    // Load all Transaction of a specific Treasury Symbol
    func getTransactionsByTimestamp(_ symbol: String, timestamp: Int) -> Array<TreasuryTransaction> {
        var treasuryTransactions : Array<TreasuryTransaction> = []
        let stmt = db.query("SELECT * FROM treasury_transaction where symbol = ? AND timestamp < ?  ORDER BY timestamp ASC",params: [symbol, timestamp])
        while (db.nextRow(stmt)){
            let transaction = TreasuryTransaction()
            transaction.id = db.getInt(stmt, index: 0)
            transaction.symbol = db.getString(stmt, index: 1)
            transaction.quantity = db.getDouble(stmt, index: 2)
            transaction.price = db.getDouble(stmt, index: 3)
            transaction.timestamp = db.getInt(stmt, index: 4)
            transaction.type = db.getInt(stmt, index: 5)
            transaction.tax = db.getDouble(stmt, index: 6)
            transaction.brokerage = db.getDouble(stmt, index: 7)
            transaction.lastUpdate = db.getInt(stmt, index: 8)
            treasuryTransactions.append(transaction)
        }
        db.closeStatement(stmt)
        return treasuryTransactions
    }
    
    // Load TreasuryTransaction with a specific id
    func getTransactionById(_ id: Int) -> TreasuryTransaction {
        let transaction = TreasuryTransaction()
        let stmt = db.query("SELECT * FROM treasury_transaction where _id = ?",params: [id])
        if(db.nextRow(stmt)){
            transaction.id = db.getInt(stmt, index: 0)
            transaction.symbol = db.getString(stmt, index: 1)
            transaction.quantity = db.getDouble(stmt, index: 2)
            transaction.price = db.getDouble(stmt, index: 3)
            transaction.timestamp = db.getInt(stmt, index: 4)
            transaction.type = db.getInt(stmt, index: 5)
            transaction.tax = db.getDouble(stmt, index: 6)
            transaction.brokerage = db.getDouble(stmt, index: 7)
            transaction.lastUpdate = db.getInt(stmt, index: 8)
        }
        db.closeStatement(stmt)
        return transaction
    }
    
    // Save or update a TreasuryTransaction
    func save(_ transaction: TreasuryTransaction){
        if(transaction.id == 0){
            // Insert
            let sql = "insert or replace into treasury_transaction (symbol,quantity,bought_price,timestamp,type,tax,brokerage,last_update) VALUES (?,?,?,?,?,?,?,?);"
            let params = [transaction.symbol,transaction.quantity,transaction.price,transaction.timestamp,transaction.type,transaction.tax,transaction.brokerage,transaction.lastUpdate] as [Any]
            _ = db.execSql(sql, params: params as Array<AnyObject>)
        } else {
            // Update
            let sql = "update treasury_transaction set symbol=?,quantity=?,bought_price=?,timestamp=?,type=?,tax=?,brokerage=?,last_update=? where _id=?;"
            let params = [transaction.symbol,transaction.quantity,transaction.price,transaction.timestamp,transaction.type,transaction.tax,transaction.brokerage,transaction.lastUpdate, transaction.id] as [Any]
            _ = db.execSql(sql,params: params as Array<AnyObject>)
        }
    }
    
    func delete(_ transaction: TreasuryTransaction){
        let sql = "delete from treasury_transaction where _id = ?"
        _ = db.execSql(sql,params: [transaction.id])
    }
    
    func deleteById(_ id: Int){
        let sql = "delete from treasury_transaction where _id = ?"
        _ = db.execSql(sql,params: [id])
    }
    
    func deleteBySymbol(_ symbol: String){
        let sql = "delete from treasury_transaction where symbol = ?"
        _ = db.execSql(sql,params: [symbol])
    }
    
    func close(){
        // Close database
        self.db.close()
    }
}
