//
//  OthersPortfolioDB.swift
//  Guia Investimento
//
//  Created by Felipe on 12/07/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
class OthersPortfolioDB{
    var db:SQLiteHelper
    init(){
        self.db = SQLiteHelper(database: "Portfolio.db")
    }
    
    // Create OthersPortfolio tables if it does not exists
    func createTable(){
        let sql = "create table if not exists others_portfolio (_id integer primary key autoincrement"
            + ", value_total real"
            + ", sold_total real"
            + ", variation_total real"
            + ", income_total real"
            + ", value_gain real"
            + ", objective_percent real"
            + ", portfolio_percent real"
            + ", current_total real"
            + ", tax real"
            + ", brokerage real"
            + ", last_update long"
            + ", UNIQUE (_id) ON CONFLICT REPLACE);"
        _ = db.execSql(sql)
    }
    
    // Save or update a OthersPortfolio
    func save(_ portfolio: OthersPortfolio){
        if(portfolio.id == 0){
            // Insert
            let sql = "insert or replace into others_portfolio (value_total,sold_total,variation_total,income_total,value_gain,objective_percent,portfolio_percent,current_total,tax,brokerage,last_update) VALUES (?,?,?,?,?,?,?,?,?,?,?);"
            let params = [portfolio.buyTotal,portfolio.soldTotal,portfolio.variationTotal,portfolio.incomeTotal,portfolio.totalGain,portfolio.objectivePercent,portfolio.portfolioPercent,portfolio.currentTotal,portfolio.tax,portfolio.brokerage,portfolio.lastUpdate] as [Any]
            _ = db.execSql(sql, params: params as Array<AnyObject>)
        } else {
            // Update
            let sql = "update others_portfolio set value_total=?,sold_total=?,variation_total=?,income_total=?,value_gain=?,objective_percent=?,portfolio_percent=?,current_total=?,tax=?,brokerage=?,last_update=? where _id=?;"
            let params = [portfolio.buyTotal,portfolio.soldTotal,portfolio.variationTotal,portfolio.incomeTotal,portfolio.totalGain,portfolio.objectivePercent,portfolio.portfolioPercent,portfolio.currentTotal,portfolio.tax,portfolio.brokerage,portfolio.lastUpdate,portfolio.id] as [Any]
            _ = db.execSql(sql,params: params as Array<AnyObject>)
        }
    }
    
    // Load OthersPortfolio
    func getPortfolio() -> OthersPortfolio {
        let portfolio = OthersPortfolio()
        let stmt = db.query("SELECT * FROM others_portfolio")
        if (db.nextRow(stmt)){
            portfolio.id = db.getInt(stmt, index: 0)
            portfolio.buyTotal = db.getDouble(stmt, index: 1)
            portfolio.soldTotal = db.getDouble(stmt, index: 2)
            portfolio.variationTotal = db.getDouble(stmt, index: 3)
            portfolio.incomeTotal = db.getDouble(stmt, index: 4)
            portfolio.totalGain = db.getDouble(stmt, index: 5)
            portfolio.objectivePercent = db.getDouble(stmt, index: 6)
            portfolio.portfolioPercent = db.getDouble(stmt, index: 7)
            portfolio.currentTotal = db.getDouble(stmt, index: 8)
            portfolio.tax = db.getDouble(stmt, index: 9)
            portfolio.brokerage = db.getDouble(stmt, index: 10)
            portfolio.lastUpdate = db.getInt(stmt, index: 11)
        }
        db.closeStatement(stmt)
        return portfolio
    }
    
    func deleteById(_ id: Int){
        let sql = "delete from others_portfolio where _id = ?"
        _ = db.execSql(sql,params: [id])
    }
    
    func close(){
        // Close database
        self.db.close()
    }
}
