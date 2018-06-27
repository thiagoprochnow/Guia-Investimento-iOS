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
    
    // Check if selected date is a date in future from current time
    class func isFutureDate(timestamp: Int) -> Bool {
        let current = Date().timeIntervalSince1970
        if(Int(current) < timestamp){
            return true
        }
        return false
    }
}
