//
//  IpcaDB.swift
//  Guia Investimento
//
//  Created by Felipe on 24/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
class IpcaDB{
    var db:SQLiteHelper
    init(){
        self.db = SQLiteHelper(database: "Portfolio.db")
    }
    
    // Create IpcaDB tables if it does not exists
    func createTable(){
        let sql = "create table if not exists ipca (_id integer primary key autoincrement"
            + ", ano integer"
            + ", mes integer"
            + ", valor real"
            + ", last_update text"
            + ", UNIQUE (_id) ON CONFLICT REPLACE);"
        _ = db.execSql(sql)
    }
    
    // Load ipca by id
    func getDataById(_ id: Int) -> Ipca {
        let ipca = Ipca()
        let stmt = db.query("SELECT * FROM ipca where _id = ?",params: [id])
        if (db.nextRow(stmt)){
            ipca.id = db.getInt(stmt, index: 0)
            ipca.ano = db.getInt(stmt, index: 1)
            ipca.mes = db.getInt(stmt, index: 2)
            ipca.valor = db.getDouble(stmt, index: 3)
            ipca.lastUpdate = db.getString(stmt, index: 4)
        }
        db.closeStatement(stmt)
        return ipca
    }
    
    // Load All Ipca
    func getData() -> Array<Ipca> {
        var ipcas : Array<Ipca> = []
        let stmt = db.query("SELECT * FROM ipca")
        while (db.nextRow(stmt)){
            let ipca = Ipca()
            ipca.id = db.getInt(stmt, index: 0)
            ipca.ano = db.getInt(stmt, index: 1)
            ipca.mes = db.getInt(stmt, index: 2)
            ipca.valor = db.getDouble(stmt, index: 3)
            ipca.lastUpdate = db.getString(stmt, index: 4)
            ipcas.append(ipca)
        }
        db.closeStatement(stmt)
        return ipcas
    }
    
    // Save or update a Ipca
    func save(_ ipca: Ipca){
        // Insert
        let sql = "insert or replace into ipca (id,ano,mes,valor,last_update) VALUES (?,?,?,?,?);"
            
        let params = [ipca.id,ipca.ano,ipca.mes,ipca.valor,ipca.lastUpdate] as [Any]
        _ = db.execSql(sql, params: params as Array<AnyObject>)
    }
    
    func bulkSave(_ ipcas: Array<Ipca>){
        ipcas.forEach{ ipca in
            save(ipca)
        }
    }
    
    func delete(_ ipca: Ipca){
        let sql = "delete from ipca where _id = ?"
        _ = db.execSql(sql,params: [ipca.id])
    }
    
    func deleteById(_ id: Int){
        let sql = "delete from ipca where _id = ?"
        _ = db.execSql(sql,params: [id])
    }
    
    func close(){
        // Close database
        self.db.close()
    }
}
