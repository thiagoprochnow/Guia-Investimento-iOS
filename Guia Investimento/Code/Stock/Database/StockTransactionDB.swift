//
//  StockTransactionDB.swift
//  Guia Investimento
//
//  Created by Felipe on 24/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
class StockTransactionDB{
    var db:SQLiteHelper
    init(){
        self.db = SQLiteHelper(database: "Portfolio.db")
    }
    
    // Create StockTransaction tables if it does not exists
    func createTable(){
        let sql = "create table if not exists stock_transaction (_id integer primary key autoincrement"
            + ", symbol text not null"
            + ", quantity integer"
            + ", bought_price real"
            + ", timestamp long"
            + ", type integer"
            + ", tax real"
            + ", brokerage real"
            + ", last_update long"
            + ", foreign key (symbol) references stock_data (_id));"
        _ = db.execSql(sql)
    }
    
    // Load all Transaction of a specific Stock Symbol
    func getTransactionsBySymbol(_ symbol: String) -> Array<StockTransaction> {
        var stockTransactions : Array<StockTransaction> = []
        let stmt = db.query("SELECT * FROM stock_transaction where symbol = ?",params: [symbol])
        while (db.nextRow(stmt)){
            let transaction = StockTransaction()
            transaction.id = db.getInt(stmt, index: 0)
            transaction.symbol = db.getString(stmt, index: 1)
            transaction.quantity = db.getInt(stmt, index: 2)
            transaction.price = db.getDouble(stmt, index: 3)
            transaction.timestamp = db.getInt(stmt, index: 4)
            transaction.type = db.getInt(stmt, index: 5)
            transaction.tax = db.getDouble(stmt, index: 6)
            transaction.brokerage = db.getDouble(stmt, index: 7)
            transaction.lastUpdate = db.getInt(stmt, index: 8)
            stockTransactions.append(transaction)
        }
        db.closeStatement(stmt)
        return stockTransactions
    }
    
    // Load StockTransaction with a specific id
    func getTransactionById(_ id: Int) -> StockTransaction {
        let transaction = StockTransaction()
        let stmt = db.query("SELECT * FROM stock_transaction where _id = ?",params: [id])
        if(db.nextRow(stmt)){
            transaction.id = db.getInt(stmt, index: 0)
            transaction.symbol = db.getString(stmt, index: 1)
            transaction.quantity = db.getInt(stmt, index: 2)
            transaction.price = db.getDouble(stmt, index: 3)
            transaction.timestamp = db.getInt(stmt, index: 4)
            transaction.type = db.getInt(stmt, index: 5)
            transaction.tax = db.getDouble(stmt, index: 6)
            transaction.brokerage = db.getDouble(stmt, index: 7)
            transaction.lastUpdate = db.getInt(stmt, index: 8)
        }
        return transaction
    }
    
    // Save or update a StockTransaction
    func save(_ transaction: StockTransaction){
        if(transaction.id == 0){
            // Insert
            let sql = "insert or replace into stock_transaction (symbol,quantity,bought_price,timestamp,type,tax,brokerage,last_update) VALUES (?,?,?,?,?,?,?,?);"
            let params = [transaction.symbol,transaction.quantity,transaction.price,transaction.timestamp,transaction.type,transaction.tax,transaction.brokerage,transaction.lastUpdate] as [Any]
            _ = db.execSql(sql, params: params as Array<AnyObject>)
        } else {
            // Update
            let sql = "update stock_transaction set symbol=?,quantity=?,bought_price=?,timestamp=?,type=?,tax=?,brokerage=?,last_update=? where _id=?;"
            let params = [transaction.symbol,transaction.quantity,transaction.price,transaction.timestamp,transaction.type,transaction.tax,transaction.brokerage,transaction.lastUpdate, transaction.id] as [Any]
            _ = db.execSql(sql,params: params as Array<AnyObject>)
        }
    }
    
    func delete(_ transaction: StockTransaction){
        let sql = "delete from stock_transaction where _id = ?"
        _ = db.execSql(sql,params: [transaction.id])
    }
    
    func deleteById(_ id: Int){
        let sql = "delete from stock_transaction where _id = ?"
        _ = db.execSql(sql,params: [id])
    }
    
    func deleteBySymbol(_ symbol: String){
        let sql = "delete from stock_transaction where symbol = ?"
        _ = db.execSql(sql,params: [symbol])
    }
    
    func close(){
        // Close database
        self.db.close()
    }
}
