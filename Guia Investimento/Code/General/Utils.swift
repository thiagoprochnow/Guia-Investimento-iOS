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
        navigationBarAppearace.titleTextAttributes =  [NSAttributedStringKey.foregroundColor: UIColor.white]
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
        let regex = "^[A-Z0-9]{4}([0-9]|[0-9][A-Z]|[0-9][0-9])$"
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
    
    // Check if inputted selling quantity us valid and there was enough buy, so it will not generate negative quantity value
    class func isValidSellStock(quantity:Int, symbol:String) -> Bool{
        let dataDB = StockDataDB()
        let quantityBought = dataDB.getDataBySymbol(symbol)
        if(quantityBought.quantity >= quantity){
            return true
        } else {
            return false
        }
    }
    
    // Check if inputted selling quantity us valid and there was enough buy, so it will not generate negative quantity value
    class func isValidSellFii(quantity:Int, symbol:String) -> Bool{
        let dataDB = FiiDataDB()
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
            variationTotal += stock.variation
            buyTotal += stock.buyValue
            incomeTotal += stock.netIncome
            mCurrentTotal += stock.currentTotal
            brokerage += stock.brokerage
            totalGain += stock.totalGain
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
    
    // Updates fii portfolio after stock data quotes have been updated
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
            variationTotal += fii.variation
            buyTotal += fii.buyValue
            incomeTotal += fii.netIncome
            mCurrentTotal += fii.currentTotal
            brokerage += fii.brokerage
            totalGain += fii.totalGain
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
