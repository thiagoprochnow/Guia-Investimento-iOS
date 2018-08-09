//
//  CurrencyTransactionDB.swift
//  Guia Investimento
//
//  Created by Felipe on 24/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
class CurrencyTransactionDB{
    var db:SQLiteHelper
    init(){
        self.db = SQLiteHelper(database: "Portfolio.db")
    }
    
    // Create CurrencyTransaction tables if it does not exists
    func createTable(){
        let sql = "create table if not exists currency_transaction (_id integer primary key autoincrement"
            + ", symbol text not null"
            + ", quantity integer"
            + ", bought_price real"
            + ", timestamp long"
            + ", type integer"
            + ", tax real"
            + ", brokerage real"
            + ", last_update long"
            + ", foreign key (symbol) references currency_data (_id));"
        _ = db.execSql(sql)
    }
    
    // Load all Transaction of a specific Currency Symbol
    func getTransactionsBySymbol(_ symbol: String) -> Array<CurrencyTransaction> {
        var currencyTransactions : Array<CurrencyTransaction> = []
        let stmt = db.query("SELECT * FROM currency_transaction where symbol = ?",params: [symbol])
        while (db.nextRow(stmt)){
            let transaction = CurrencyTransaction()
            transaction.id = db.getInt(stmt, index: 0)
            transaction.symbol = db.getString(stmt, index: 1)
            transaction.quantity = db.getDouble(stmt, index: 2)
            transaction.price = db.getDouble(stmt, index: 3)
            transaction.timestamp = db.getInt(stmt, index: 4)
            transaction.type = db.getInt(stmt, index: 5)
            transaction.tax = db.getDouble(stmt, index: 6)
            transaction.brokerage = db.getDouble(stmt, index: 7)
            transaction.lastUpdate = db.getInt(stmt, index: 8)
            currencyTransactions.append(transaction)
        }
        db.closeStatement(stmt)
        return currencyTransactions
    }
    
    // Load all Transaction of a specific Currency Symbol
    func getTransactionsByTimestamp(_ symbol: String, timestamp: Int) -> Array<CurrencyTransaction> {
        var currencyTransactions : Array<CurrencyTransaction> = []
        let stmt = db.query("SELECT * FROM currency_transaction where symbol = ? AND timestamp < ?  ORDER BY timestamp ASC",params: [symbol, timestamp])
        while (db.nextRow(stmt)){
            let transaction = CurrencyTransaction()
            transaction.id = db.getInt(stmt, index: 0)
            transaction.symbol = db.getString(stmt, index: 1)
            transaction.quantity = db.getDouble(stmt, index: 2)
            transaction.price = db.getDouble(stmt, index: 3)
            transaction.timestamp = db.getInt(stmt, index: 4)
            transaction.type = db.getInt(stmt, index: 5)
            transaction.tax = db.getDouble(stmt, index: 6)
            transaction.brokerage = db.getDouble(stmt, index: 7)
            transaction.lastUpdate = db.getInt(stmt, index: 8)
            currencyTransactions.append(transaction)
        }
        db.closeStatement(stmt)
        return currencyTransactions
    }
    
    // Load CurrencyTransaction with a specific id
    func getTransactionById(_ id: Int) -> CurrencyTransaction {
        let transaction = CurrencyTransaction()
        let stmt = db.query("SELECT * FROM currency_transaction where _id = ?",params: [id])
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
    
    // Save or update a CurrencyTransaction
    func save(_ transaction: CurrencyTransaction){
        if(transaction.id == 0){
            // Insert
            let sql = "insert or replace into currency_transaction (symbol,quantity,bought_price,timestamp,type,tax,brokerage,last_update) VALUES (?,?,?,?,?,?,?,?);"
            let params = [transaction.symbol,transaction.quantity,transaction.price,transaction.timestamp,transaction.type,transaction.tax,transaction.brokerage,transaction.lastUpdate] as [Any]
            _ = db.execSql(sql, params: params as Array<AnyObject>)
        } else {
            // Update
            let sql = "update currency_transaction set symbol=?,quantity=?,bought_price=?,timestamp=?,type=?,tax=?,brokerage=?,last_update=? where _id=?;"
            let params = [transaction.symbol,transaction.quantity,transaction.price,transaction.timestamp,transaction.type,transaction.tax,transaction.brokerage,transaction.lastUpdate, transaction.id] as [Any]
            _ = db.execSql(sql,params: params as Array<AnyObject>)
        }
    }
    
    func delete(_ transaction: CurrencyTransaction){
        let sql = "delete from currency_transaction where _id = ?"
        _ = db.execSql(sql,params: [transaction.id])
    }
    
    func deleteById(_ id: Int){
        let sql = "delete from currency_transaction where _id = ?"
        _ = db.execSql(sql,params: [id])
    }
    
    func deleteBySymbol(_ symbol: String){
        let sql = "delete from currency_transaction where symbol = ?"
        _ = db.execSql(sql,params: [symbol])
    }
    
    func close(){
        // Close database
        self.db.close()
    }
}
