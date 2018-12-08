//
//  Utils.swift
//  Guia Investimento
//
//  Created by Felipe on 31/05/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import UIKit
import Foundation

class Utils {
    // Change Navigation Bar Color
    class func changeStatusBar(){
        let navigationBarAppearace = UINavigationBar.appearance()
        let navigationBar = UINavigationBar()
        
        navigationBarAppearace.tintColor = UIColor(red: 63/255, green: 81/255, blue: 181/255, alpha: 1)
        navigationBarAppearace.barTintColor = UIColor(red: 63/255, green: 81/255, blue: 181/255, alpha: 1)
        navigationBarAppearace.titleTextAttributes =  [NSAttributedStringKey.foregroundColor: UIColor.white,NSAttributedStringKey.font: UIFont.init(name: "Arial", size: 15)]
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
    }
    
    // Check if text matches regex formula
    class func matches(regex: String, text:String) -> Bool{
        if text.range(of: regex, options: .regularExpression) != nil {
            return true
        } else {
            return false
        }
    }
    
    // Check if inputted symbol is correct Stock symbol
    class func isValidStockSymbol(symbol: String) -> Bool{
        let regex = "^[A-Z0-9]{4}([0-9]|[0-9][0-9])$"
        return matches(regex: regex, text: symbol)
    }
    
    // Check if inputted symbol is correct FII symbol
    class func isValidFiiSymbol(symbol: String) -> Bool{
        let regex = "^[A-Z0-9]{4}([0-9][0-9][A-Z]|[0-9][0-9])$"
        return matches(regex: regex, text: symbol)
    }
    
    // Check if inputted symbol is correct Treasury symbol
    class func isValidTreasurySymbol(symbol: String) -> Bool{
        let regex = "[a-zA-Z\\s0-9]*"
        return matches(regex: regex, text: symbol)
    }
    
    // Check if inputted symbol is correct Fixed symbol
    class func isValidFixedSymbol(symbol: String) -> Bool{
        let regex = "[a-zA-Z\\s0-9]*"
        return matches(regex: regex, text: symbol)
    }

    // Check if inputted symbol is correct Others symbol
    class func isValidOthersSymbol(symbol: String) -> Bool{
        let regex = "[a-zA-Z\\s0-9]*"
        return matches(regex: regex, text: symbol)
    }
    
    // Check if inputed text is a double
    class func isValidDouble(text: String) -> Bool{
        let regex = "^[0-9]+\\.?[0-9]*$"
        return matches(regex: regex, text: text)
    }
    
    // Check if inputed text is only Int values
    class func isValidInt(text: String) -> Bool{
        let regex = "^[0-9]+$"
        return matches(regex: regex, text: text)
    }
    
    // Check if inputted selling quantity is valid and there was enough buy, so it will not generate negative quantity value
    class func isValidSellStock(quantity:Int, symbol:String) -> Bool{
        let dataDB = StockDataDB()
        let quantityBought = dataDB.getDataBySymbol(symbol)
        if(quantityBought.quantity >= quantity){
            return true
        } else {
            return false
        }
    }
    
    // Check if inputted selling quantity is valid and there was enough buy, so it will not generate negative quantity value
    class func isValidSellFii(quantity:Int, symbol:String) -> Bool{
        let dataDB = FiiDataDB()
        let quantityBought = dataDB.getDataBySymbol(symbol)
        if(quantityBought.quantity >= quantity){
            return true
        } else {
            return false
        }
    }
    
    // Check if inputted selling quantity is valid and there was enough buy, so it will not generate negative quantity value
    class func isValidSellTreasury(quantity:Double, symbol:String) -> Bool{
        let dataDB = TreasuryDataDB()
        let quantityBought = dataDB.getDataBySymbol(symbol)
        if(quantityBought.quantity >= quantity){
            return true
        } else {
            return false
        }
    }
    
    // Check if inputted selling quantity is valid and there was enough buy, so it will not generate negative quantity value
    class func isValidSellFixed(total:Double, symbol:String) -> Bool{
        let dataDB = FixedDataDB()
        let quantityBought = dataDB.getDataBySymbol(symbol)
        if(quantityBought.currentTotal >= total){
            return true
        } else {
            return false
        }
    }
    
    // Check if inputted selling quantity is valid and there was enough buy, so it will not generate negative quantity value
    class func isValidSellOthers(total:Double, symbol:String) -> Bool{
        let dataDB = OthersDataDB()
        let quantityBought = dataDB.getDataBySymbol(symbol)
        if(quantityBought.currentTotal >= total){
            return true
        } else {
            return false
        }
    }
    
    // Check if inputted selling quantity us valid and there was enough buy, so it will not generate negative quantity value
    class func isValidSellCurrency(quantity:Double, symbol:String) -> Bool{
        let dataDB = CurrencyDataDB()
        let quantityBought = dataDB.getDataBySymbol(symbol)
        if(quantityBought.quantity >= quantity){
            return true
        } else {
            return false
        }
    }
    
    // Check if selected date is a date in future from current time
    class func isFutureDate(timestamp: Int) -> Bool {
        let current = Date().timeIntervalSince1970
        if(Int(current) < timestamp){
            return true
        }
        return false
    }
    
    // Convert from Double to string as real currency
    class func doubleToRealCurrency(value: Double) -> String {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        // localize to Brazil
        currencyFormatter.locale = Locale(identifier: "pt_BR")
        let currency = currencyFormatter.string(from: NSNumber(value: value))
        return currency!
    }
    
    // Get row index for a currency symbol to select in picker
    class func getCurrencyPickerIndex(symbol: String) -> Int {
        if(symbol == "USD"){
            return 0
        } else if(symbol == "EUR"){
            return 1
        } else if(symbol == "BTC"){
            return 2
        } else if(symbol == "LTC"){
            return 3
        }
        //Default
        return 0
    }
    
    // Get row index for a currency symbol to select in picker
    class func getCurrencyLabel(symbol: String) -> String {
        if(symbol == "USD"){
            return "Dolar"
        } else if(symbol == "EUR"){
            return "Euro"
        } else if(symbol == "BTC"){
            return "Bitcoin"
        } else if(symbol == "LTC"){
            return "Litecoin"
        }
        //Default
        return "Dolar"
    }
    
    // Updates stock portfolio after stock data quotes have been updated
    class func updateStockPortfolio(){
        // Sold Stock Data
        let soldStockDB = SoldStockDataDB()
        let soldStocks = soldStockDB.getSoldData()
        soldStockDB.close()

        var buyTotal: Double = 0.0
        var totalGain: Double = 0.0
        var variationTotal: Double = 0.0
        var sellTotal: Double = 0.0
        var brokerage: Double = 0.0
        var mCurrentTotal: Double = 0.0
        var incomeTotal: Double = 0.0
        
        soldStocks.forEach{ soldStock in
            buyTotal += soldStock.buyValue
            sellTotal += soldStock.currentTotal
            brokerage += soldStock.brokerage
            variationTotal += soldStock.brokerage + soldStock.sellGain
            totalGain += soldStock.sellGain
        }
        
        // Stock Data
        let stockDB = StockDataDB()
        let stocks = stockDB.getData()
        
        stocks.forEach{ stock in
            if(stock.status == Constants.Status.ACTIVE){
                variationTotal += stock.variation
                buyTotal += stock.buyValue
                incomeTotal += stock.netIncome
                mCurrentTotal += stock.currentTotal
                brokerage += stock.brokerage
                totalGain += stock.totalGain
            }
        }
        
        // Updates current percent of each stock data
        stocks.forEach{stock in
            stock.currentPercent = stock.currentTotal/mCurrentTotal*100
            stockDB.save(stock)
        }
        
        stockDB.close()
        
        let portfolioDB = StockPortfolioDB()
        var portfolio = portfolioDB.getPortfolio()
        portfolio.variationTotal = variationTotal
        portfolio.buyTotal = buyTotal
        portfolio.soldTotal = sellTotal
        portfolio.incomeTotal = incomeTotal
        portfolio.brokerage = brokerage
        portfolio.totalGain = totalGain
        portfolio.currentTotal = mCurrentTotal
        
        portfolioDB.save(portfolio)
        portfolioDB.close()
    }
    
    // Updates fii portfolio after fii data quotes have been updated
    class func updateFiiPortfolio(){
        // Sold Fii Data
        let soldFiiDB = SoldFiiDataDB()
        let soldFiis = soldFiiDB.getSoldData()
        soldFiiDB.close()
        
        var buyTotal: Double = 0.0
        var totalGain: Double = 0.0
        var variationTotal: Double = 0.0
        var sellTotal: Double = 0.0
        var brokerage: Double = 0.0
        var mCurrentTotal: Double = 0.0
        var incomeTotal: Double = 0.0
        
        soldFiis.forEach{ soldFii in
            buyTotal += soldFii.buyValue
            sellTotal += soldFii.currentTotal
            brokerage += soldFii.brokerage
            variationTotal += soldFii.brokerage + soldFii.sellGain
            totalGain += soldFii.sellGain
        }
        
        // Fii Data
        let fiiDB = FiiDataDB()
        let fiis = fiiDB.getData()
        
        fiis.forEach{ fii in
            if(fii.status == Constants.Status.ACTIVE){
                variationTotal += fii.variation
                buyTotal += fii.buyValue
                incomeTotal += fii.netIncome
                mCurrentTotal += fii.currentTotal
                brokerage += fii.brokerage
                totalGain += fii.totalGain
            }
        }
        
        // Updates current percent of each fii data
        fiis.forEach{fii in
            fii.currentPercent = fii.currentTotal/mCurrentTotal*100
            fiiDB.save(fii)
        }
        
        fiiDB.close()
        
        let portfolioDB = FiiPortfolioDB()
        var portfolio = portfolioDB.getPortfolio()
        portfolio.variationTotal = variationTotal
        portfolio.buyTotal = buyTotal
        portfolio.soldTotal = sellTotal
        portfolio.incomeTotal = incomeTotal
        portfolio.brokerage = brokerage
        portfolio.totalGain = totalGain
        portfolio.currentTotal = mCurrentTotal
        
        portfolioDB.save(portfolio)
        portfolioDB.close()
    }
    
    // Updates treasury portfolio after treasury data quotes have been updated
    class func updateTreasuryPortfolio(){
        // Sold Treasury Data
        let soldTreasuryDB = SoldTreasuryDataDB()
        let soldTreasuries = soldTreasuryDB.getSoldData()
        soldTreasuryDB.close()
        
        var buyTotal: Double = 0.0
        var totalGain: Double = 0.0
        var variationTotal: Double = 0.0
        var sellTotal: Double = 0.0
        var brokerage: Double = 0.0
        var mCurrentTotal: Double = 0.0
        var incomeTotal: Double = 0.0
        
        soldTreasuries.forEach{ soldTreasury in
            buyTotal += soldTreasury.buyValue
            sellTotal += soldTreasury.currentTotal
            brokerage += soldTreasury.brokerage
            variationTotal += soldTreasury.brokerage + soldTreasury.sellGain
            totalGain += soldTreasury.sellGain
        }
        
        // Treasury Data
        let treasuryDB = TreasuryDataDB()
        let treasuries = treasuryDB.getData()
        
        treasuries.forEach{ treasury in
            if(treasury.status == Constants.Status.ACTIVE){
                variationTotal += treasury.variation
                buyTotal += treasury.buyValue
                incomeTotal += treasury.netIncome
                mCurrentTotal += treasury.currentTotal
                brokerage += treasury.brokerage
                totalGain += treasury.totalGain
            }
        }
        
        // Updates current percent of each treasury data
        treasuries.forEach{treasury in
            treasury.currentPercent = treasury.currentTotal/mCurrentTotal*100
            treasuryDB.save(treasury)
        }
        
        treasuryDB.close()
        
        let portfolioDB = TreasuryPortfolioDB()
        var portfolio = portfolioDB.getPortfolio()
        portfolio.variationTotal = variationTotal
        portfolio.buyTotal = buyTotal
        portfolio.soldTotal = sellTotal
        portfolio.incomeTotal = incomeTotal
        portfolio.brokerage = brokerage
        portfolio.totalGain = totalGain
        portfolio.currentTotal = mCurrentTotal
        
        portfolioDB.save(portfolio)
        portfolioDB.close()
    }
    
    // Updates currency portfolio after currency data quotes have been updated
    class func updateCurrencyPortfolio(){
        // Sold Currency Data
        let soldCurrencyDB = SoldCurrencyDataDB()
        let soldCurrencies = soldCurrencyDB.getSoldData()
        soldCurrencyDB.close()
        
        var buyTotal: Double = 0.0
        var totalGain: Double = 0.0
        var variationTotal: Double = 0.0
        var sellTotal: Double = 0.0
        var brokerage: Double = 0.0
        var mCurrentTotal: Double = 0.0
        
        soldCurrencies.forEach{ soldCurrency in
            buyTotal += soldCurrency.buyValue
            sellTotal += soldCurrency.currentTotal
            brokerage += soldCurrency.brokerage
            variationTotal += soldCurrency.brokerage + soldCurrency.sellGain
            totalGain += soldCurrency.sellGain
        }
        
        // Currency Data
        let currencyDB = CurrencyDataDB()
        let currencies = currencyDB.getData()
        
        currencies.forEach{ currency in
            if(currency.status == Constants.Status.ACTIVE){
                variationTotal += currency.variation
                buyTotal += currency.buyValue
                mCurrentTotal += currency.currentTotal
                brokerage += currency.brokerage
                totalGain += currency.totalGain
            }
        }
        
        // Updates current percent of each currency data
        currencies.forEach{currency in
            currency.currentPercent = currency.currentTotal/mCurrentTotal*100
            currencyDB.save(currency)
        }
        
        currencyDB.close()
        
        let portfolioDB = CurrencyPortfolioDB()
        var portfolio = portfolioDB.getPortfolio()
        portfolio.variationTotal = variationTotal
        portfolio.buyTotal = buyTotal
        portfolio.soldTotal = sellTotal
        portfolio.brokerage = brokerage
        portfolio.totalGain = totalGain
        portfolio.currentTotal = mCurrentTotal
        
        portfolioDB.save(portfolio)
        portfolioDB.close()
    }
    
    // Updates others portfolio after treasury data quotes have been updated
    class func updateOthersPortfolio(){
        
        var buyTotal: Double = 0.0
        var totalGain: Double = 0.0
        var variationTotal: Double = 0.0
        var sellTotal: Double = 0.0
        var brokerage: Double = 0.0
        var mCurrentTotal: Double = 0.0
        var incomeTotal: Double = 0.0
        
        // Treasury Data
        let othersDB = OthersDataDB()
        let others = othersDB.getData()
        
        others.forEach{ other in
            variationTotal += other.variation
            buyTotal += other.buyTotal
            sellTotal += other.sellTotal
            incomeTotal += other.liquidIncome
            mCurrentTotal += other.currentTotal
            brokerage += other.brokerage
            totalGain += other.totalGain
        }
        
        // Updates current percent of each treasury data
        others.forEach{ other in
            other.currentPercent = other.currentTotal/mCurrentTotal*100
            othersDB.save(other)
        }
        
        othersDB.close()
        
        let portfolioDB = OthersPortfolioDB()
        let portfolio = portfolioDB.getPortfolio()
        portfolio.variationTotal = variationTotal
        portfolio.buyTotal = buyTotal
        portfolio.soldTotal = sellTotal
        portfolio.incomeTotal = incomeTotal
        portfolio.brokerage = brokerage
        portfolio.totalGain = totalGain
        portfolio.currentTotal = mCurrentTotal
        
        portfolioDB.save(portfolio)
        portfolioDB.close()
    }
    
    // Updates fixed income portfolio after fixed data current total has been updated
    class func updateFixedPortfolio(){
        var buyTotal: Double = 0.0
        var totalGain: Double = 0.0
        var sellTotal: Double = 0.0
        var mCurrentTotal: Double = 0.0
        
        // Fixed Data
        let fixedDB = FixedDataDB()
        let fixeds = fixedDB.getData()
        
        fixeds.forEach{ fixed in
            buyTotal += fixed.buyTotal
            mCurrentTotal += fixed.currentTotal
            totalGain += fixed.totalGain
            sellTotal += fixed.sellTotal
        }
        
        // Updates current percent of each fixed data
        fixeds.forEach{fixed in
            fixed.currentPercent = fixed.currentTotal/mCurrentTotal*100
            fixedDB.save(fixed)
        }
        
        fixedDB.close()
        
        let portfolioDB = FixedPortfolioDB()
        let portfolio = portfolioDB.getPortfolio()
        portfolio.buyTotal = buyTotal
        portfolio.soldTotal = sellTotal
        portfolio.totalGain = totalGain
        portfolio.currentTotal = mCurrentTotal
        
        portfolioDB.save(portfolio)
        portfolioDB.close()
    }
    
    // Updates portfolio after all other portfolios have been updated
    class func updatePortfolio(){
        // Treasury
        let treasuryDB = TreasuryPortfolioDB()
        let treasury = treasuryDB.getPortfolio()
        treasuryDB.close()
        
        // Fixed
        let fixedDB = FixedPortfolioDB()
        let fixed = fixedDB.getPortfolio()
        fixedDB.close()
        
        // Others
        let othersDB = OthersPortfolioDB()
        let others = othersDB.getPortfolio()
        othersDB.close()
        
        // Stock
        let stockDB = StockPortfolioDB()
        let stock = stockDB.getPortfolio()
        stockDB.close()
        
        // Fii
        let fiiDB = FiiPortfolioDB()
        let fii = fiiDB.getPortfolio()
        fiiDB.close()
        
        // Currency
        let currencyDB = CurrencyPortfolioDB()
        let currency = currencyDB.getPortfolio()
        currencyDB.close()
        
        let portfolioBuy = treasury.buyTotal + fixed.buyTotal + stock.buyTotal + fii.buyTotal + currency.buyTotal + others.buyTotal
        let portfolioSold = treasury.soldTotal + fixed.soldTotal + stock.soldTotal + fii.soldTotal + currency.soldTotal + others.soldTotal
        let portfolioCurrent = treasury.currentTotal + fixed.currentTotal + stock.currentTotal + fii.currentTotal + currency.currentTotal + others.currentTotal
        let portfolioVariation = treasury.variationTotal + fixed.totalGain + stock.variationTotal + fii.variationTotal + currency.variationTotal + others.variationTotal
        let portfolioIncome = treasury.incomeTotal + stock.incomeTotal + fii.incomeTotal + others.incomeTotal
        let portfolioBrokerage = stock.brokerage + fii.brokerage
        let portfolioGain = treasury.totalGain + fixed.totalGain + stock.totalGain + fii.totalGain + currency.totalGain + others.totalGain
        let treasuryPercent = treasury.currentTotal/portfolioCurrent*100
        let fixedPercent = fixed.currentTotal/portfolioCurrent*100
        let stockPercent = stock.currentTotal/portfolioCurrent*100
        let fiiPercent = fii.currentTotal/portfolioCurrent*100
        let currencyPercent = currency.currentTotal/portfolioCurrent*100
        let othersPercent = others.currentTotal/portfolioCurrent*100
        
        let portfolioDB = PortfolioDB()
        let portfolio = portfolioDB.getPortfolio()
        portfolio.buyTotal = portfolioBuy
        portfolio.soldTotal = portfolioSold
        portfolio.currentTotal = portfolioCurrent
        portfolio.variationTotal = portfolioVariation
        portfolio.incomeTotal = portfolioIncome
        portfolio.brokerage = portfolioBrokerage
        portfolio.totalGain = portfolioGain
        portfolio.treasuryPercent = treasuryPercent
        portfolio.fixedPercent = fixedPercent
        portfolio.stockPercent = stockPercent
        portfolio.fiiPercent = fiiPercent
        portfolio.currencyPercent = currencyPercent
        portfolio.othersPercent = othersPercent
        
        portfolioDB.save(portfolio)
        portfolioDB.close()
    }
    
    class func makeThumbnailFromText(text: String) -> UIImage {
        // some variables that control the size of the image we create, what font to use, etc.
        
        struct LineOfText {
            var string: String
            var size: CGSize
        }
        
        let imageSize = CGSize(width: 100, height: 80)
        let fontSize: CGFloat = 13.0
        let fontName = "Helvetica-Bold"
        let font = UIFont(name: fontName, size: fontSize)!
        let lineSpacing = fontSize * 1.2
        
        // set up the context and the font
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        let attributes = [kCTFontAttributeName: font]
        
        // some variables we use for figuring out the words in the string and how to arrange them on lines of text
        
        let words = text.components(separatedBy: " ")
        var lines = [LineOfText]()
        var lineThusFar: LineOfText?
        
        // let's figure out the lines by examining the size of the rendered text and seeing whether it fits or not and
        // figure out where we should break our lines (as well as using that to figure out how to center the text)
        
        for word in words {
            let currentLine = lineThusFar?.string == nil ? word : "\(lineThusFar!.string) \(word)"
            let size = currentLine.size(withAttributes: attributes as [NSAttributedStringKey : Any])
            if size.width > imageSize.width && lineThusFar != nil {
                lines.append(lineThusFar!)
                lineThusFar = LineOfText(string: word, size: word.size(withAttributes: attributes as [NSAttributedStringKey : Any]))
            } else {
                lineThusFar = LineOfText(string: currentLine, size: size)
            }
        }
        if lineThusFar != nil { lines.append(lineThusFar!) }
        
        // now write the lines of text we figured out above
        
        let totalSize = CGFloat(lines.count - 1) * lineSpacing + fontSize
        let topMargin = (imageSize.height - totalSize) / 2.0
        
        for (index, line) in lines.enumerated() {
            let x = (imageSize.width - line.size.width) / 2.0
            let y = topMargin + CGFloat(index) * lineSpacing
            line.string.draw(at: CGPoint(x: x, y: y), withAttributes: attributes as [NSAttributedStringKey : Any])
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}
