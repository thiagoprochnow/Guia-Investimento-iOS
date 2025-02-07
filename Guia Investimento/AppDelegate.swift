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
    var portfolioMain: PortfolioMainController!
    var subscription: SubscriptionService!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        Utils.changeStatusBar()
        
        // Load PortfolioMain Controller as initial view
        portfolioMain = PortfolioMainController(nibName: "PortfolioMainController", bundle: nil)
        
        // Load Navigation Drawer as Navigation Controller
        let drawerViewController = DrawerViewController()
        
        let drawerController     = KYDrawerController(drawerDirection: .left, drawerWidth: 200)
        drawerController.mainViewController = UINavigationController(
            rootViewController: portfolioMain
        )
        drawerViewController.nav = drawerController.mainViewController as! UINavigationController
        drawerController.drawerViewController = drawerViewController
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = drawerController
        window?.makeKeyAndVisible()
        
        // Update portfolio button
        let updateBtn = UIBarButtonItem(title: "Atualizar", style: UIBarButtonItemStyle.plain, target: self, action: #selector(AppDelegate.updateQuotes))
        
        let font = UIFont.init(name: "Arial", size: 14)
        updateBtn.setTitleTextAttributes([NSAttributedStringKey.font: font], for: .normal)
        
        portfolioMain.navigationItem.rightBarButtonItem = updateBtn
        portfolioMain.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        
        // Initialize Database
        initializeDB()
        
        subscription = SubscriptionService()
        subscription.fetchAvailableProducts()
        subscription.receiptValidation()
        
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        subscription.receiptValidation()
    }
    
    @objc func updateQuotes(){
        let drawerController = window?.rootViewController as! KYDrawerController
        let drawerViewController = drawerController.drawerViewController as! DrawerViewController
        drawerViewController.updateQuotes()
    }
    
    func initializeDB(){
        // Portfolio
        let portfolioDB = PortfolioDB()
        portfolioDB.createTable()
        portfolioDB.close()
        
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
        
        // TREASURY
        
        // TREASURY Portfolio
        let treasuryPortfolioDB = TreasuryPortfolioDB()
        treasuryPortfolioDB.createTable()
        treasuryPortfolioDB.close()
        // TREASURY Transaction
        let treasuryTransactionDB = TreasuryTransactionDB()
        treasuryTransactionDB.createTable()
        treasuryTransactionDB.close()
        // TREASURY Data
        let treasuryDataDB = TreasuryDataDB()
        treasuryDataDB.createTable()
        treasuryDataDB.close()
        // Sold TREASURY Data
        let soldTreasuryDataDB = SoldTreasuryDataDB()
        soldTreasuryDataDB.createTable()
        soldTreasuryDataDB.close()
        // TREASURY Incomes
        let treasuryIncomesDB = TreasuryIncomeDB()
        treasuryIncomesDB.createTable()
        treasuryIncomesDB.close()
        
        // CURRENCY
        
        // CURRENCY Portfolio
        let currencyPortfolioDB = CurrencyPortfolioDB()
        currencyPortfolioDB.createTable()
        currencyPortfolioDB.close()
        // CURRENCY Transaction
        let currencyTransactionDB = CurrencyTransactionDB()
        currencyTransactionDB.createTable()
        currencyTransactionDB.close()
        // CURRENCY Data
        let currencyDataDB = CurrencyDataDB()
        currencyDataDB.createTable()
        currencyDataDB.close()
        // Sold CURRENCY Data
        let soldCurrencyDataDB = SoldCurrencyDataDB()
        soldCurrencyDataDB.createTable()
        soldCurrencyDataDB.close()
        
        // FIXED
        
        // FIXED Portfolio
        let fixedPortfolioDB = FixedPortfolioDB()
        fixedPortfolioDB.createTable()
        fixedPortfolioDB.close()
        // FIXED Transaction
        let fixedTransactionDB = FixedTransactionDB()
        fixedTransactionDB.createTable()
        fixedTransactionDB.close()
        // FIXED Data
        let fixedDataDB = FixedDataDB()
        fixedDataDB.createTable()
        fixedDataDB.close()
        // CDI Table
        let cdiDB = CdiDB()
        cdiDB.createTable()
        cdiDB.close()
        // IPCA Table
        let ipcaDB = IpcaDB()
        ipcaDB.createTable()
        ipcaDB.close()
        
        // OTHERS
        
        // OTHERS Portfolio
        let othersPortfolioDB = OthersPortfolioDB()
        othersPortfolioDB.createTable()
        othersPortfolioDB.close()
        // OTHERS Transaction
        let othersTransactionDB = OthersTransactionDB()
        othersTransactionDB.createTable()
        othersTransactionDB.close()
        // OTHERS Data
        let othersDataDB = OthersDataDB()
        othersDataDB.createTable()
        othersDataDB.close()
        // OTHERS Incomes
        let othersIncomesDB = OthersIncomeDB()
        othersIncomesDB.createTable()
        othersIncomesDB.close()
    }
}
