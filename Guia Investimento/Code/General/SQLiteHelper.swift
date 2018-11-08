//
//  SQLiteHelper.swift
//  Carros
//
//  Created by Ricardo Lecheta on 7/1/14.
//  Copyright (c) 2014 Ricardo Lecheta. All rights reserved.
//

import Foundation

class SQLiteHelper :NSObject {
    
    // sqlite3 *db;
    var db: OpaquePointer? = nil;
    
    // Construtor
    init(database: String) {
        super.init()
        
        self.db = open(database)
    }
    
    // Caminho do banco de dados
    func getFilePath(_ nome: String) -> String {
        // Caminho com o arquivo
        let path = NSHomeDirectory() + "/Documents/" + nome
        return path
    }
    
    // Abre o banco de dados
    func open(_ database: String) -> OpaquePointer? {
        
        var db: OpaquePointer? = nil;
        
        let path = getFilePath(database)
        let cPath = StringUtils.toCString(path)
        let result = sqlite3_open(path, &db);
        if(result != SQLITE_OK) {
            //print("Não foi possível abrir o banco de dados SQLite \(result)")
            return nil
        } else {
            //println("SQLite OK")
        }
        
        return db
    }
    
    // Executa o SQL
    func execSql(_ sql: String) -> CInt {
        return self.execSql(sql, params: nil)
    }
    
    func execSql(_ sql: String, params: Array<Any>!) -> CInt {
        var result:CInt = 0
        
        //let cSql = StringUtils.toCString(sql)
        
        // Statement
        let stmt = query(sql, params: params)
        
        // Step
        result = sqlite3_step(stmt)
        if (result != SQLITE_OK && result != SQLITE_DONE) {
            sqlite3_finalize(stmt)
            let msg = "Erro ao executar SQL\n\(sql)\nError: \(lastSQLError())"
            //print(msg)
            return -1
        } else {
            //println("SQL [\(sql)]")
        }
        
        // Se for insert recupera o id
        if (sql.uppercased().hasPrefix("INSERT")) {
            // http://www.sqlite.org/c3ref/last_insert_rowid.html
            let rid = sqlite3_last_insert_rowid(self.db)
            result = CInt(rid)
        } else {
            result = 1
        }
        
        // Fecha o statement
        sqlite3_finalize(stmt)
        
        return result
    }
    
    // Faz o bind dos parametros (?,?,?) de um SQL
    func bindParams(_ stmt:OpaquePointer, params: Array<Any>!) {
        if(params != nil) {
            let size = params.count
            //            println("Bind \(size) values")
            for i:Int in 1...size {
                let value = params[i-1]
                if(value is Int) {
                    let number:CInt = toCInt(value as! Int)
                    
                    sqlite3_bind_int(stmt, toCInt(i), number)
                    
                    // println("bind int \(i) -> \(value)")
                } else if(value is Double){
                    let number:Double = value as! Double
                    
                    sqlite3_bind_double(stmt, Int32(i), number)
                } else {
                    
                    let text: String = value as! String
                    let ns = text as NSString
                    sqlite3_bind_text(stmt,Int32(i),ns.utf8String, -1, nil)
                    
                    //println("bind tetxt \(i) -> \(value)")
                }
            }
        }
    }
    
    // Executa o SQL e retorna o statement
    func query(_ sql:String) -> OpaquePointer {
        return query(sql, params: nil)
    }
    
    // Executa o SQL e retorna o statement
    func query(_ sql:String, params: Array<Any>!) -> OpaquePointer {
        var stmt:OpaquePointer? = nil
        
        //let cSql = StringUtils.toCString(sql)
        
        // Prepare
        let result = sqlite3_prepare_v2(self.db, sql, -1, &stmt, nil)
        
        if (result != SQLITE_OK) {
            sqlite3_finalize(stmt)
            let msg = "Erro ao preparar SQL\n\(sql)\nError: \(lastSQLError())"
            //print("SQLite ERROR \(msg)")
        } else {
            //print("SQL [\(sql)], params: \(params)")
        }
        
        // Bind Values (?,?,?)
        if(params != nil) {
            bindParams(stmt!, params:params)
        }
        
        return stmt!
    }
    
    // Retorna true se existe a próxima linha da consulta
    func nextRow(_ stmt:OpaquePointer) -> Bool {
        let result = sqlite3_step(stmt)
        let next: Bool = result == SQLITE_ROW
        return next
    }
    
    // Fecha o banco de dados
    func close() {
        sqlite3_close(self.db)
    }
    
    func closeStatement(_ stmt:OpaquePointer) {
        // Fecha o statement
        sqlite3_finalize(stmt)
    }
    
    // Retorna o último erro de SQL
    func lastSQLError() -> String {
        var err:UnsafePointer<Int8>? = nil
        err = sqlite3_errmsg(self.db)
        
        if(err != nil) {
            let s = NSString(utf8String: err!)
            return s! as String
        }
        
        return ""
    }
    
    // Lê uma coluna do tipo Int
    func getInt(_ stmt:OpaquePointer, index:CInt) -> Int {
        let val = sqlite3_column_int(stmt, index)
        return Int(val)
    }
    
    // Lê uma coluna do tipo Double
    func getDouble(_ stmt:OpaquePointer, index:CInt) -> Double {
        let val = sqlite3_column_double(stmt, index)
        return Double(val)
    }
    
    // Lê uma coluna do tipo Float
    func getFloat(_ stmt:OpaquePointer, index:CInt) -> Float {
        let val = sqlite3_column_double(stmt, index)
        return Float(val)
    }
    
    // Lê uma coluna do tipo String
    func getString(_ stmt:OpaquePointer, index:CInt) -> String {
        
        let s = sqlite3_column_text(stmt, index)
        if let s = s {
            return String(cString: s)
        }
        return ""
    }
    
    // Converte Int (swift) para CInt(C)
    func toCInt(_ swiftInt : Int) -> CInt {
        let number : NSNumber = swiftInt as NSNumber
        let pos: CInt = number.int32Value
        return pos
    }
}
