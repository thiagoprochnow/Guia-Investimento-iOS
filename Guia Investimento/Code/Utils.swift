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
}
