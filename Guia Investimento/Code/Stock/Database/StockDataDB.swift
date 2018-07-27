//
//  StockDataDB.swift
//  Guia Investimento
//
//  Created by Felipe on 24/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
class StockDataDB{
    var db:SQLiteHelper
    init(){
        self.db = SQLiteHelper(database: "Portfolio.db")
    }
    
    // Create StockData tables if it does not exists
    func createTable(){
        let sql = "create table if not exists stock_data (_id integer primary key autoincrement"
            + ", symbol text not null"
            + ", quantity_total integer"
            + ", value_total real"
            + ", income_total real"
            + ", income_tax real"
            + ", variation real"
            + ", total_gain real"
            + ", objective_percent real"
            + ", current_percent real"
            + ", medium_price real"
            + ", current_price real"
            + ", current_total real"
            + ", status integer"
            + ", tax real"
            + ", brokerage real"
            + ", last_update long"
            + ", update_status integer"
            + ", closing_price real"
            + ", UNIQUE (symbol) ON CONFLICT REPLACE);"
        _ = db.execSql(sql)
    }
    
    // Load StockData of a specific Stock Symbol
    func getDataBySymbol(_ symbol: String) -> StockData {
        let data = StockData()
        let stmt = db.query("SELECT * FROM stock_data where symbol = ?",params: [symbol])
        if (db.nextRow(stmt)){
            data.id = db.getInt(stmt, index: 0)
            data.symbol = db.getString(stmt, index: 1)
            data.quantity = db.getInt(stmt, index: 2)
            data.buyValue = db.getDouble(stmt, index: 3)
            data.netIncome = db.getDouble(stmt, index: 4)
            data.incomeTax = db.getDouble(stmt, index: 5)
            data.variation = db.getDouble(stmt, index: 6)
            data.totalGain = db.getDouble(stmt, index: 7)
            data.objectivePercent = db.getDouble(stmt, index: 8)
            data.currentPercent = db.getDouble(stmt, index: 9)
            data.mediumPrice = db.getDouble(stmt, index: 10)
            data.currentPrice = db.getDouble(stmt, index: 11)
            data.currentTotal = db.getDouble(stmt, index: 12)
            data.status = db.getInt(stmt, index: 13)
            data.tax = db.getDouble(stmt, index: 14)
            data.brokerage = db.getDouble(stmt, index: 15)
            data.lastUpdate = db.getInt(stmt, index: 16)
            data.updateStatus = db.getInt(stmt, index: 17)
            data.closingPrice = db.getDouble(stmt, index: 18)
        }
        db.closeStatement(stmt)
        return data
    }
    
    // Load Active StockData ordered by percent
    func getDataPercent() -> Array<StockData> {
        var stockDatas : Array<StockData> = []
        let stmt = db.query("SELECT _id,symbol,current_percent FROM stock_data where status = ? ORDER BY current_percent DESC",params: [Constants.Status.ACTIVE])
        while (db.nextRow(stmt)){
            let data = StockData()
            data.id = db.getInt(stmt, index: 0)
            data.symbol = db.getString(stmt, index: 1)
            data.currentPercent = db.getDouble(stmt, index: 2)
            stockDatas.append(data)
        }
        db.closeStatement(stmt)
        return stockDatas
    }
    
    // Load StockData of a specific Stock Symbol
    func getDataById(_ id: Int) -> StockData {
        let data = StockData()
        let stmt = db.query("SELECT * FROM stock_data where _id = ?",params: [id])
        if (db.nextRow(stmt)){
            data.id = db.getInt(stmt, index: 0)
            data.symbol = db.getString(stmt, index: 1)
            data.quantity = db.getInt(stmt, index: 2)
            data.buyValue = db.getDouble(stmt, index: 3)
            data.netIncome = db.getDouble(stmt, index: 4)
            data.incomeTax = db.getDouble(stmt, index: 5)
            data.variation = db.getDouble(stmt, index: 6)
            data.totalGain = db.getDouble(stmt, index: 7)
            data.objectivePercent = db.getDouble(stmt, index: 8)
            data.currentPercent = db.getDouble(stmt, index: 9)
            data.mediumPrice = db.getDouble(stmt, index: 10)
            data.currentPrice = db.getDouble(stmt, index: 11)
            data.currentTotal = db.getDouble(stmt, index: 12)
            data.status = db.getInt(stmt, index: 13)
            data.tax = db.getDouble(stmt, index: 14)
            data.brokerage = db.getDouble(stmt, index: 15)
            data.lastUpdate = db.getInt(stmt, index: 16)
            data.updateStatus = db.getInt(stmt, index: 17)
            data.closingPrice = db.getDouble(stmt, index: 18)
        }
        db.closeStatement(stmt)
        return data
    }
    
    // Load StockData by its status
    // Used to get all StockData as Active or Sold
    func getDataByStatus(_ status: Int) -> Array<StockData> {
        var stockDatas : Array<StockData> = []
        let stmt = db.query("SELECT * FROM stock_data where status = ?",params: [status])
        while (db.nextRow(stmt)){
            let data = StockData()
            data.id = db.getInt(stmt, index: 0)
            data.symbol = db.getString(stmt, index: 1)
            data.quantity = db.getInt(stmt, index: 2)
            data.buyValue = db.getDouble(stmt, index: 3)
            data.netIncome = db.getDouble(stmt, index: 4)
            data.incomeTax = db.getDouble(stmt, index: 5)
            data.variation = db.getDouble(stmt, index: 6)
            data.totalGain = db.getDouble(stmt, index: 7)
            data.objectivePercent = db.getDouble(stmt, index: 8)
            data.currentPercent = db.getDouble(stmt, index: 9)
            data.mediumPrice = db.getDouble(stmt, index: 10)
            data.currentPrice = db.getDouble(stmt, index: 11)
            data.currentTotal = db.getDouble(stmt, index: 12)
            data.status = db.getInt(stmt, index: 13)
            data.tax = db.getDouble(stmt, index: 14)
            data.brokerage = db.getDouble(stmt, index: 15)
            data.lastUpdate = db.getInt(stmt, index: 16)
            data.updateStatus = db.getInt(stmt, index: 17)
            data.closingPrice = db.getDouble(stmt, index: 18)
            stockDatas.append(data)
        }
        db.closeStatement(stmt)
        return stockDatas
    }
    
    // Load All StockData
    func getData() -> Array<StockData> {
        var stockDatas : Array<StockData> = []
        let stmt = db.query("SELECT * FROM stock_data")
        while (db.nextRow(stmt)){
            let data = StockData()
            data.id = db.getInt(stmt, index: 0)
            data.symbol = db.getString(stmt, index: 1)
            data.quantity = db.getInt(stmt, index: 2)
            data.buyValue = db.getDouble(stmt, index: 3)
            data.netIncome = db.getDouble(stmt, index: 4)
            data.incomeTax = db.getDouble(stmt, index: 5)
            data.variation = db.getDouble(stmt, index: 6)
            data.totalGain = db.getDouble(stmt, index: 7)
            data.objectivePercent = db.getDouble(stmt, index: 8)
            data.currentPercent = db.getDouble(stmt, index: 9)
            data.mediumPrice = db.getDouble(stmt, index: 10)
            data.currentPrice = db.getDouble(stmt, index: 11)
            data.currentTotal = db.getDouble(stmt, index: 12)
            data.status = db.getInt(stmt, index: 13)
            data.tax = db.getDouble(stmt, index: 14)
            data.brokerage = db.getDouble(stmt, index: 15)
            data.lastUpdate = db.getInt(stmt, index: 16)
            data.updateStatus = db.getInt(stmt, index: 17)
            data.closingPrice = db.getDouble(stmt, index: 18)
            stockDatas.append(data)
        }
        db.closeStatement(stmt)
        return stockDatas
    }
    
    // Save or update a StockData
    func save(_ data: StockData){
        if(data.id == 0){
            // Insert
            let sql = "insert or replace into stock_data (symbol,quantity_total,value_total,income_total,income_tax,variation,total_gain,objective_percent,current_percent,medium_price,current_price,current_total,status,tax,brokerage,last_update,update_status,closing_price) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);"
            
            let params = [data.symbol,data.quantity,data.buyValue,data.netIncome,data.incomeTax,data.variation,data.totalGain,data.objectivePercent,data.currentPercent,data.mediumPrice,data.currentPrice,data.currentTotal,data.status,data.tax,data.brokerage,data.lastUpdate,data.updateStatus,data.closingPrice] as [Any]
            _ = db.execSql(sql, params: params as Array<AnyObject>)
        } else {
            // Update
            let sql = "update stock_data set symbol=?,quantity_total=?,value_total=?,income_total=?,income_tax=?,variation=?,total_gain=?,objective_percent=?,current_percent=?,medium_price=?,current_price=?,current_total=?,status=?,tax=?,brokerage=?,last_update=?,update_status=?,closing_price=? where _id=?;"
            let params = [data.symbol,data.quantity,data.buyValue,data.netIncome,data.incomeTax,data.variation,data.totalGain,data.objectivePercent,data.currentPercent,data.mediumPrice,data.currentPrice,data.currentTotal,data.status,data.tax,data.brokerage,data.lastUpdate,data.updateStatus,data.closingPrice,data.id] as [Any]
            _ = db.execSql(sql,params: params as Array<AnyObject>)
        }
    }
    
    func bulkSave(_ stocks: Array<StockData>){
        stocks.forEach{ stock in
            save(stock)
        }
    }
    
    func delete(_ data: StockData){
        let sql = "delete from stock_data where _id = ?"
        _ = db.execSql(sql,params: [data.id])
    }
    
    func deleteById(_ id: Int){
        let sql = "delete from stock_data where _id = ?"
        _ = db.execSql(sql,params: [id])
    }
    
    func deleteBySymbol(_ symbol: String){
        let sql = "delete from stock_data where symbol = ?"
        _ = db.execSql(sql,params: [symbol])
    }
    
    func close(){
        // Close database
        self.db.close()
    }
}
