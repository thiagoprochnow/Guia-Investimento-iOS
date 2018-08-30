//
//  PortfolioDB.swift
//  Guia Investimento
//
//  Created by Felipe on 12/07/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
class PortfolioDB{
    var db:SQLiteHelper
    init(){
        self.db = SQLiteHelper(database: "Portfolio.db")
    }
    
    // Create StockPortfolio tables if it does not exists
    func createTable(){
        let sql = "create table if not exists portfolio (_id integer primary key autoincrement"
            + ", buy_total real"
            + ", sold_total real"
            + ", current_total real"
            + ", variation_total real"
            + ", income_total real"
            + ", total_gain real"
            + ", treasury_percent real"
            + ", fixed_percent real"
            + ", others_percent real"
            + ", stock_percent real"
            + ", fii_percent real"
            + ", currency_percent real"
            + ", fund_percent real"
            + ", tax real"
            + ", brokerage real"
            + ", last_update long"
            + ", UNIQUE (_id) ON CONFLICT REPLACE);"
        _ = db.execSql(sql)
    }
    
    // Save or update a StockPortfolio
    func save(_ portfolio: Portfolio){
        if(portfolio.id == 0){
            // Insert
            let sql = "insert or replace into portfolio (buy_total,sold_total,current_total,variation_total,income_total,total_gain,treasury_percent,fixed_percent,others_percent,stock_percent,fii_percent,currency_percent,fund_percent,tax,brokerage,last_update) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);"
            let params = [portfolio.buyTotal,portfolio.soldTotal,portfolio.currentTotal,portfolio.variationTotal,portfolio.incomeTotal,portfolio.totalGain,portfolio.treasuryPercent,portfolio.fixedPercent,portfolio.othersPercent,portfolio.stockPercent,portfolio.fiiPercent,portfolio.currencyPercent,portfolio.fundPercent,portfolio.tax,portfolio.brokerage,portfolio.lastUpdate] as [Any]
            _ = db.execSql(sql, params: params as Array<AnyObject>)
        } else {
            // Update
            let sql = "update portfolio set buy_total=?,sold_total=?,current_total=?,variation_total=?,income_total=?,total_gain=?,treasury_percent=?,fixed_percent=?,others_percent=?,stock_percent=?,fii_percent=?,currency_percent=?,fund_percent=?,tax=?,brokerage=?,last_update=? where _id=?;"
            let params = [portfolio.buyTotal,portfolio.soldTotal,portfolio.currentTotal,portfolio.variationTotal,portfolio.incomeTotal,portfolio.totalGain,portfolio.treasuryPercent,portfolio.fixedPercent,portfolio.othersPercent,portfolio.stockPercent,portfolio.fiiPercent,portfolio.currencyPercent,portfolio.fundPercent,portfolio.tax,portfolio.brokerage,portfolio.lastUpdate,portfolio.id] as [Any]
            _ = db.execSql(sql,params: params as Array<AnyObject>)
        }
    }
    
    // Load Portfolio
    func getPortfolio() -> Portfolio {
        let portfolio = Portfolio()
        let stmt = db.query("SELECT * FROM portfolio")
        if (db.nextRow(stmt)){
            portfolio.id = db.getInt(stmt, index: 0)
            portfolio.buyTotal = db.getDouble(stmt, index: 1)
            portfolio.soldTotal = db.getDouble(stmt, index: 2)
            portfolio.currentTotal = db.getDouble(stmt, index: 3)
            portfolio.variationTotal = db.getDouble(stmt, index: 4)
            portfolio.incomeTotal = db.getDouble(stmt, index: 5)
            portfolio.totalGain = db.getDouble(stmt, index: 6)
            portfolio.treasuryPercent = db.getDouble(stmt, index: 7)
            portfolio.fixedPercent = db.getDouble(stmt, index: 8)
            portfolio.othersPercent = db.getDouble(stmt, index: 9)
            portfolio.stockPercent = db.getDouble(stmt, index: 10)
            portfolio.fiiPercent = db.getDouble(stmt, index: 11)
            portfolio.currencyPercent = db.getDouble(stmt, index: 12)
            portfolio.fundPercent = db.getDouble(stmt, index: 13)
            portfolio.tax = db.getDouble(stmt, index: 14)
            portfolio.brokerage = db.getDouble(stmt, index: 15)
            portfolio.lastUpdate = db.getInt(stmt, index: 16)
        }
        db.closeStatement(stmt)
        return portfolio
    }
    
    func deleteById(_ id: Int){
        let sql = "delete from portfolio where _id = ?"
        _ = db.execSql(sql,params: [id])
    }
    
    func close(){
        // Close database
        self.db.close()
    }
}
