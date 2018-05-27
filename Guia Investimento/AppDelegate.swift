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
        
        // Change Navigation Bar Color
        let navigationBarAppearace = UINavigationBar.appearance()
        
        navigationBarAppearace.tintColor = UIColor(red: 63/255, green: 81/255, blue: 181/255, alpha: 1)
        navigationBarAppearace.barTintColor = UIColor(red: 63/255, green: 81/255, blue: 181/255, alpha: 1)
        navigationBarAppearace.titleTextAttributes =  [NSAttributedStringKey.foregroundColor: UIColor.white]
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        
        // PortfolioMain Controller
        let portfolioController = PortfolioMainController(nibName: "PortfolioMainController", bundle: nil)
        // Navigation Controller
        let nav = NavigationController()
        
        nav.pushViewController(portfolioController, animated: false)
        self.window!.rootViewController = nav
        self.window!.makeKeyAndVisible()
        
        return true
    }
}

