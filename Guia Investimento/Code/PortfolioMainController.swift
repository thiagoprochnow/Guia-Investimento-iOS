//
//  PortfolioMainView.swift
//  Guia Investimento
//
//  Created by Felipe on 27/05/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import UIKit

class PortfolioMainController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Titulo
        self.title = "Carteira Completa"
        self.view.backgroundColor = UIColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1)
        Utils.changeStatusBar()
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Menu",
            style: UIBarButtonItemStyle.plain,
            target: self,
            action: #selector(didTapOpenButton)
        )
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        
        // Create custom Back Button
        let backButton = UIBarButtonItem(title: "Voltar", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButton
        navigationItem.backBarButtonItem?.tintColor = UIColor.white
    }
    
    @objc func didTapOpenButton(_ sender: UIBarButtonItem) {
        if let drawerController = navigationController?.parent as? KYDrawerController {
            drawerController.setDrawerState(.opened, animated: true)
        }
    }
}
