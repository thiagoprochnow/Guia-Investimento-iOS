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
