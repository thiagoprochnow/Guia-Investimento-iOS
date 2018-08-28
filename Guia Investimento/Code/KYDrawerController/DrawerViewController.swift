/*
Copyright (c) 2015 Kyohei Yamaguchi. All rights reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

import UIKit

class DrawerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var mainMenu: UITableView!
    var nav: UINavigationController!
    var stockRefresh = false
    var fiiRefresh = false
    var treasuryRefresh = false
    var currencyRefresh = false
    var fixedRefresh = false
    
    var stocks:Array<StockData> = []
    var stocksIncomes:Array<StockIncome> = []
    var fiis:Array<FiiData> = []
    var fiisIncomes:Array<FiiIncome> = []
    var treasuries:Array<TreasuryData> = []
    var currencies:Array<CurrencyData> = []
    var fixeds:Array<FixedData> = []
    var cdis:Array<Cdi> = []
    var ipcas:Array<Ipca> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.mainMenu.dataSource = self
        self.mainMenu.delegate = self
        self.mainMenu.rowHeight = 65
        self.mainMenu.register(UITableViewCell.self, forCellReuseIdentifier: "mainMenu")
        self.mainMenu.separatorStyle = UITableViewCellSeparatorStyle.none
    }
    
    // Number of Table View cells, number of Main Menu itens
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    // Creates the Main Menu itens
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let linha = indexPath.row
        let cell = self.mainMenu.dequeueReusableCell(withIdentifier: "mainMenu")!
        // Main Menu Structure
        switch linha {
        case 0:
            cell.textLabel!.text = "Tesouro"
            cell.textLabel?.textAlignment = .left
            return cell
        case 1:
            cell.textLabel!.text = "Renda Fixa"
            cell.textLabel?.textAlignment = .left
            return cell
        case 2:
            cell.textLabel!.text = "Ações"
            cell.textLabel?.textAlignment = .left
            return cell
        case 3:
            cell.textLabel!.text = "Fundos Imobiliários"
            cell.textLabel?.textAlignment = .left
            return cell
        case 4:
            cell.textLabel!.text = "Moedas"
            cell.textLabel?.textAlignment = .left
            return cell
        case 5:
            cell.textLabel!.text = "Outros"
            cell.textLabel?.textAlignment = .left
            return cell
        case 6:
            cell.textLabel!.text = "Versão Premium"
            cell.textLabel?.textAlignment = .left
            return cell
        case 7:
            cell.textLabel!.text = "Copia e Restauração"
            cell.textLabel?.textAlignment = .left
            return cell
        case 8:
            cell.textLabel!.text = "Sobre"
            cell.textLabel?.textAlignment = .left
            return cell
        default:
            return cell
        }
    }
    
    // When clicking in option of Navigation Drawer
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let linha = indexPath.row
        openViewAndCloseDrawer(linha)
    }
    
    // Open the correct UIViewController when option selected and closes Navigation Drawer
    @objc func openViewAndCloseDrawer(_ linha: Int) {
        var view: UITabBarController
        view = TabController()
        
        // Create custom Back Button
        let backButton = UIBarButtonItem(title: "Voltar", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        view.navigationItem.backBarButtonItem = backButton
        view.navigationItem.backBarButtonItem?.tintColor = UIColor.white
        
        // Update portfolio button
        let updateBtn = UIBarButtonItem(title: "Atualizar", style: UIBarButtonItemStyle.plain, target: self, action: #selector(DrawerViewController.updateQuotes))
        view.navigationItem.rightBarButtonItem = updateBtn
        view.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        
        if let drawerController = parent as? KYDrawerController {
            drawerController.setDrawerState(.closed, animated: true)
            switch linha{
            case 0:
                let portfolio = TreasuryPortfolioView()
                let data = TreasuryDataView()
                let soldData = SoldTreasuryDataView()
                let income = TreasuryMainIncomesView()
                portfolio.tabBarItem.title = ""
                portfolio.tabBarItem.image =  Utils.makeThumbnailFromText(text: "Visão Geral")
                data.tabBarItem.title = ""
                data.tabBarItem.image = Utils.makeThumbnailFromText(text: "Carteira")
                soldData.tabBarItem.title = ""
                soldData.tabBarItem.image = Utils.makeThumbnailFromText(text: "Histórico")
                income.tabBarItem.title = ""
                income.tabBarItem.image = Utils.makeThumbnailFromText(text: "Rendimentos")
                
                view.title = "Tesouro"
                view.viewControllers = [portfolio, data, soldData, income]
                break
            case 1:
                let portfolio = FixedPortfolioView()
                let data = FixedDataView()
                portfolio.tabBarItem.title = ""
                portfolio.tabBarItem.image =  Utils.makeThumbnailFromText(text: "Visão Geral")
                data.tabBarItem.title = ""
                data.tabBarItem.image = Utils.makeThumbnailFromText(text: "Carteira")
                
                view.title = "Renda Fixa"
                view.viewControllers = [portfolio, data]
                break
            case 2:
                let portfolio = StockPortfolioView()
                let data = StockDataView()
                let soldData = SoldStockDataView()
                let income = StockMainIncomesView()
                portfolio.tabBarItem.title = ""
                portfolio.tabBarItem.image =  Utils.makeThumbnailFromText(text: "Visão Geral")
                data.tabBarItem.title = ""
                data.tabBarItem.image = Utils.makeThumbnailFromText(text: "Carteira")
                soldData.tabBarItem.title = ""
                soldData.tabBarItem.image = Utils.makeThumbnailFromText(text: "Histórico")
                income.tabBarItem.title = ""
                income.tabBarItem.image = Utils.makeThumbnailFromText(text: "Rendimentos")
                
                view.title = "Ações"
                view.viewControllers = [portfolio, data, soldData, income]
                break
            case 3:
                let portfolio = FiiPortfolioView()
                let data = FiiDataView()
                let soldData = SoldFiiDataView()
                let income = FiiMainIncomesView()
                portfolio.tabBarItem.title = ""
                portfolio.tabBarItem.image =  Utils.makeThumbnailFromText(text: "Visão Geral")
                data.tabBarItem.title = ""
                data.tabBarItem.image = Utils.makeThumbnailFromText(text: "Carteira")
                soldData.tabBarItem.title = ""
                soldData.tabBarItem.image = Utils.makeThumbnailFromText(text: "Histórico")
                income.tabBarItem.title = ""
                income.tabBarItem.image = Utils.makeThumbnailFromText(text: "Rendimentos")
                
                view.title = "Fundos Imobiliários"
                view.viewControllers = [portfolio, data, soldData, income]
                break
            case 4:
                let portfolio = CurrencyPortfolioView()
                let data = CurrencyDataView()
                let soldData = SoldCurrencyDataView()
                portfolio.tabBarItem.title = ""
                portfolio.tabBarItem.image =  Utils.makeThumbnailFromText(text: "Visão Geral")
                data.tabBarItem.title = ""
                data.tabBarItem.image = Utils.makeThumbnailFromText(text: "Carteira")
                soldData.tabBarItem.title = ""
                soldData.tabBarItem.image = Utils.makeThumbnailFromText(text: "Histórico")
                
                view.title = "Moedas"
                view.viewControllers = [portfolio, data, soldData]
                break
            case 5:
                let portfolio = OthersPortfolioView()
                let data = OthersDataView()
                let income = OthersMainIncomesView()
                portfolio.tabBarItem.title = ""
                portfolio.tabBarItem.image =  Utils.makeThumbnailFromText(text: "Visão Geral")
                data.tabBarItem.title = ""
                data.tabBarItem.image = Utils.makeThumbnailFromText(text: "Carteira")
                income.tabBarItem.title = ""
                income.tabBarItem.image = Utils.makeThumbnailFromText(text: "Rendimentos")
                
                view.title = "Outros"
                view.viewControllers = [portfolio, data, income]
                break
            default:
                view.title = "Carteira Completa"
            }
            
            nav = drawerController.mainViewController as! UINavigationController
            nav.pushViewController(view, animated: true)
        }
    }
    
    @IBAction func updateQuotes(){
        // Place Loading indication on place of refresh button
        let activity = UIActivityIndicatorView()
        activity.startAnimating()
        let button = UIBarButtonItem.init(customView: activity)
        nav.topViewController?.navigationItem.rightBarButtonItem = button
        let fixedDB = FixedDataDB()
        let fixeds = fixedDB.getData()
        fixedDB.close()
        
        // Stocks
        StockService.updateStockIncomes({(_ stockIncomes:Array<StockIncome>,error:Bool) -> Void in
            self.stocksIncomes = stockIncomes
            StockService.updateStockQuotes({(_ stocks:Array<StockData>,error:Bool) -> Void in
                self.stockRefresh = true
                self.stocks = stocks
                DispatchQueue.main.async {
                    self.updateView()
                }
            })
        })
        
        // FII
        FiiService.updateFiiIncomes({(_ fiiIncomes:Array<FiiIncome>,error:Bool) -> Void in
            self.fiisIncomes = fiiIncomes
            FiiService.updateFiiQuotes({(_ fiis:Array<FiiData>,error:Bool) -> Void in
                self.fiiRefresh = true
                self.fiis = fiis
                DispatchQueue.main.async {
                    self.updateView()
                }
            })
        })
        
        // TREASURY
        TreasuryService.updateTreasuryQuotes({(_ treasuries:Array<TreasuryData>,error:Bool) -> Void in
            self.treasuryRefresh = true
            self.treasuries = treasuries
            DispatchQueue.main.async {
                self.updateView()
            }
        })
        
        // CURRENCY
        CurrencyService.updateCurrencyQuotes({(_ currencies:Array<CurrencyData>,error:Bool) -> Void in
            self.currencyRefresh = true
            self.currencies = currencies
            DispatchQueue.main.async {
                self.updateView()
            }
        })
        
        // FIXED
        FixedService.updateFixedQuotes({(_ cdis:Array<Cdi>,ipcas:Array<Ipca>,error:Bool) -> Void in
            self.fixedRefresh = true
            self.cdis = cdis
            self.ipcas = ipcas
            DispatchQueue.main.async {
                self.updateView()
            }
        })
    }
    
    func updateView(){
        if(self.stockRefresh && self.fiiRefresh && self.treasuryRefresh && self.currencyRefresh && self.fixedRefresh){
            // Update and save values
            
            //Stocks
            let stockDB = StockDataDB()
            stocks.forEach{ stock in
                let currentTotal = Double(stock.quantity) * stock.currentPrice
                let variation = currentTotal - stock.buyValue
                let totalGain = currentTotal + stock.netIncome - stock.buyValue - stock.brokerage
                stock.currentTotal = currentTotal
                stock.variation = variation
                stock.totalGain = totalGain
                stockDB.save(stock)
            }
            stockDB.close()
            Utils.updateStockPortfolio()
            
            // Stocks Incomes
            let incomeDB = StockIncomeDB()
            let stockGeneral = StockGeneral()
            stocksIncomes.forEach{ stockIncome in
                let isInserted = incomeDB.isIncomeInserted(stockIncome)
                // Check if it not already inserted
                if(!isInserted){
                    incomeDB.save(stockIncome)
                    if(stockIncome.affectedQuantity > 0){
                        stockGeneral.updateStockDataIncome(stockIncome.symbol, valueReceived: stockIncome.liquidIncome, tax: stockIncome.tax)
                    }
                }
            }
            incomeDB.close()
            
            // Fii
            let fiiDB = FiiDataDB()
            fiis.forEach{ fii in
                let currentTotal = Double(fii.quantity) * fii.currentPrice
                let variation = currentTotal - fii.buyValue
                let totalGain = currentTotal + fii.netIncome - fii.buyValue - fii.brokerage
                fii.currentTotal = currentTotal
                fii.variation = variation
                fii.totalGain = totalGain
                fiiDB.save(fii)
            }
            fiiDB.close()
            Utils.updateFiiPortfolio()
            
            // Fii Incomes
            let fiiIncomeDB = FiiIncomeDB()
            let fiiGeneral = FiiGeneral()
            fiisIncomes.forEach{ fiiIncome in
                let isInserted = fiiIncomeDB.isIncomeInserted(fiiIncome)
                // Check if it not already inserted
                if(!isInserted){
                    fiiIncomeDB.save(fiiIncome)
                    if(fiiIncome.affectedQuantity > 0){
                        fiiGeneral.updateFiiDataIncome(fiiIncome.symbol, valueReceived: fiiIncome.liquidIncome, tax: fiiIncome.tax)
                    }
                }
            }
            fiiIncomeDB.close()
          
            // Treasury
            let treasuryDB = TreasuryDataDB()
            treasuries.forEach{ treasury in
                let currentTotal = treasury.quantity * treasury.currentPrice
                let variation = currentTotal - treasury.buyValue
                let totalGain = currentTotal + treasury.netIncome - treasury.buyValue - treasury.brokerage
                treasury.currentTotal = currentTotal
                treasury.variation = variation
                treasury.totalGain = totalGain
                treasuryDB.save(treasury)
            }
            treasuryDB.close()
            Utils.updateTreasuryPortfolio()
            
            // Currency
            let currencyDB = CurrencyDataDB()
            currencies.forEach{ currency in
                let currentTotal = currency.quantity * currency.currentPrice
                let variation = currentTotal - currency.buyValue
                let totalGain = currentTotal - currency.buyValue
                currency.currentTotal = currentTotal
                currency.variation = variation
                currency.totalGain = totalGain
                currencyDB.save(currency)
            }
            currencyDB.close()
            Utils.updateCurrencyPortfolio()
            
            // Fixed
            // CDI
            let cdiDB = CdiDB()
            cdis.forEach{ cdi in
                cdiDB.save(cdi)
            }
            cdiDB.close()
            //IPCA
            let ipcaDB = IpcaDB()
            ipcas.forEach{ ipca in
                ipcaDB.save(ipca)
            }
            ipcaDB.close()
            // Fixed Income
            let general = FixedGeneral()
            let fixedDB = FixedDataDB()
            let fixeds = fixedDB.getData()
            var returnFixeds:Array<FixedData> = []
            fixeds.forEach{ fixed in
                let fixed = general.updateFixedQuote(fixed)
                returnFixeds.append(fixed)
            }
            returnFixeds.forEach{ fixed in
                let currentTotal = fixed.currentTotal
                let totalGain = currentTotal - fixed.buyTotal
                fixed.currentTotal = currentTotal
                fixed.totalGain = totalGain
                fixedDB.save(fixed)
            }
            fixedDB.close()
            Utils.updateFixedPortfolio()
            
            // OTHERS
            Utils.updateOthersPortfolio()
            
            nav.navigationController?.visibleViewController?.viewWillAppear(false)
            nav.topViewController?.viewWillAppear(false)
            nav.navigationController?.topViewController?.viewWillAppear(false)
            nav.visibleViewController?.viewWillAppear(false)
            
            // Place Button back after finish loading in place of loading view
            let updateBtn = UIBarButtonItem(title: "Atualizar", style: UIBarButtonItemStyle.plain, target: self, action: #selector(DrawerViewController.updateQuotes))
            nav.topViewController?.navigationItem.rightBarButtonItem = updateBtn
            nav.topViewController?.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
            
            let alert = UIAlertView()
            alert.delegate = self
            alert.addButton(withTitle: "OK")
            // Show Alert
            alert.title = ""
            alert.message = "Atualização feita com sucesso"
            alert.show()
            
            // Reset refresh status
            self.stockRefresh = false
            self.fiiRefresh = false
            self.treasuryRefresh = false
            self.currencyRefresh = false
            self.stocks = []
            self.fiis = []
            self.treasuries = []
            self.currencies = []
        }
    }
}
