//
//  AppDelegate.swift
//  Guia Investimento
//
//  Created by Felipe on 27/05/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        Utils.changeStatusBar()
        
        // Load PortfolioMain Controller as initial view
        let portfolioMain = PortfolioMainController(nibName: "PortfolioMainController", bundle: nil)
        
        // Load Navigation Drawer as Navigation Controller
        let drawerViewController = DrawerViewController()
        let drawerController     = KYDrawerController(drawerDirection: .left, drawerWidth: 300)
        drawerController.mainViewController = UINavigationController(
            rootViewController: portfolioMain
        )
        drawerController.drawerViewController = drawerViewController
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = drawerController
        window?.makeKeyAndVisible()
        
        // Initialize Database
        initializeDB()
        
        return true
    }
    
    func initializeDB(){
        // Stock
        
        // Stock Portfolio
        let stockPortfolioDB = StockPortfolioDB()
        stockPortfolioDB.createTable()
        stockPortfolioDB.close()
        // Stock Transaction
        let stockTransactionDB = StockTransactionDB()
        stockTransactionDB.createTable()
        stockTransactionDB.close()
        // Stock Data
        let stockDataDB = StockDataDB()
        stockDataDB.createTable()
        stockDataDB.close()
        // Sold Stock Data
        let soldStockDataDB = SoldStockDataDB()
        soldStockDataDB.createTable()
        soldStockDataDB.close()
        // Stock Incomes
        let stockIncomesDB = StockIncomeDB()
        stockIncomesDB.createTable()
        stockIncomesDB.close()
        
        // FII
        
        // FII Portfolio
        let fiiPortfolioDB = FiiPortfolioDB()
        fiiPortfolioDB.createTable()
        fiiPortfolioDB.close()
        // Fii Transaction
        let fiiTransactionDB = FiiTransactionDB()
        fiiTransactionDB.createTable()
        fiiTransactionDB.close()
        // Fii Data
        let fiiDataDB = FiiDataDB()
        fiiDataDB.createTable()
        fiiDataDB.close()
        // Sold Fii Data
        let soldFiiDataDB = SoldFiiDataDB()
        soldFiiDataDB.createTable()
        soldFiiDataDB.close()
        // Fii Incomes
        let fiiIncomesDB = FiiIncomeDB()
        fiiIncomesDB.createTable()
        fiiIncomesDB.close()
    }
}
