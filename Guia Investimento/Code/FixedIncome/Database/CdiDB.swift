//
//  CdiDB.swift
//  Guia Investimento
//
//  Created by Felipe on 24/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
class CdiDB{
    var db:SQLiteHelper
    init(){
        self.db = SQLiteHelper(database: "Portfolio.db")
    }
    
    // Create Cdi tables if it does not exists
    func createTable(){
        let sql = "create table if not exists cdi (_id integer primary key autoincrement"
            + ", value real"
            + ", timestamp long"
            + ", data text not null"
            + ", last_update text"
            + ", UNIQUE (_id) ON CONFLICT REPLACE);"
        _ = db.execSql(sql)
    }
    
    // Load Cdi by its Id
    func getCdiById(_ id: Int) -> Cdi {
        let cdi = Cdi()
        let stmt = db.query("SELECT * FROM cdi where _id = ?",params: [id])
        if (db.nextRow(stmt)){
            cdi.id = db.getInt(stmt, index: 0)
            cdi.value = db.getDouble(stmt, index: 1)
            cdi.timestamp = db.getInt(stmt, index: 2)
            cdi.data = db.getString(stmt, index: 3)
            cdi.lastUpdate = db.getString(stmt, index: 4)
        }
        db.closeStatement(stmt)
        return cdi
    }
    
    // Load All Cdis
    func getData() -> Array<Cdi> {
        var cdis : Array<Cdi> = []
        let stmt = db.query("SELECT * FROM cdi")
        while (db.nextRow(stmt)){
            let cdi = Cdi()
            cdi.id = db.getInt(stmt, index: 0)
            cdi.value = db.getDouble(stmt, index: 1)
            cdi.timestamp = db.getInt(stmt, index: 2)
            cdi.data = db.getString(stmt, index: 3)
            cdi.lastUpdate = db.getString(stmt, index: 4)
            cdis.append(cdi)
        }
        db.closeStatement(stmt)
        return cdis
    }
    
    // Load All Cdis after a timestamp
    func getCdiByTimestamp(_ timestamp: Int) -> Array<Cdi> {
        var cdis : Array<Cdi> = []
        let stmt = db.query("SELECT * FROM cdi where timestamp > ?",params: [timestamp])
        while (db.nextRow(stmt)){
            let cdi = Cdi()
            cdi.id = db.getInt(stmt, index: 0)
            cdi.value = db.getDouble(stmt, index: 1)
            cdi.timestamp = db.getInt(stmt, index: 2)
            cdi.data = db.getString(stmt, index: 3)
            cdi.lastUpdate = db.getString(stmt, index: 4)
            cdis.append(cdi)
        }
        db.closeStatement(stmt)
        return cdis
    }
    
    // Load Cdi by its Id
    func getLastCdi() -> Cdi {
        let cdi = Cdi()
        let stmt = db.query("SELECT * FROM cdi order by timestamp desc limit 1")
        if (db.nextRow(stmt)){
            cdi.id = db.getInt(stmt, index: 0)
            cdi.value = db.getDouble(stmt, index: 1)
            cdi.timestamp = db.getInt(stmt, index: 2)
            cdi.data = db.getString(stmt, index: 3)
            cdi.lastUpdate = db.getString(stmt, index: 4)
        }
        db.closeStatement(stmt)
        return cdi
    }
    
    // Save or update a Cdi
    func save(_ cdi: Cdi){
        // Insert
        let sql = "insert or replace into cdi (_id,value,timestamp,data,last_update) VALUES (?,?,?,?,?);"
            
        let params = [cdi.id,cdi.value,cdi.timestamp,cdi.data,cdi.lastUpdate] as [Any]
        _ = db.execSql(sql, params: params as Array<AnyObject>)
    }
    
    func bulkSave(_ cdis: Array<Cdi>){
        cdis.forEach{ cdi in
            save(cdi)
        }
    }
    
    func delete(_ cdi: Cdi){
        let sql = "delete from cdi where _id = ?"
        _ = db.execSql(sql,params: [cdi.id])
    }
    
    func deleteById(_ id: Int){
        let sql = "delete from cdi where _id = ?"
        _ = db.execSql(sql,params: [id])
    }
    
    func close(){
        // Close database
        self.db.close()
    }
}
