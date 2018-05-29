//
//  MainMenu.swift
//  Guia Investimento
//
//  Created by Felipe on 27/05/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import UIKit

class MainMenu: UIViewController, UITableViewDataSource {
    @IBOutlet var mainMenu: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Titulo
        self.title = "Guia Investimento"
        self.view.backgroundColor = UIColor.white
        self.mainMenu.dataSource = self
        self.mainMenu.rowHeight = 65
        self.mainMenu.register(UITableViewCell.self, forCellReuseIdentifier: "mainMenu")
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Menu",
            style: UIBarButtonItemStyle.plain,
            target: self,
            action: #selector(didTapOpenButton)
        )
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
    }
    
    // Number of Table View cells, number of Main Menu itens
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 9
    }
    
    // Creates the Main Menu itens
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let linha = indexPath.row
        let cell = self.mainMenu.dequeueReusableCell(withIdentifier: "mainMenu")!
        // Main Menu Structure
        switch linha {
        case 0:
            cell.textLabel!.text = "Carteira Completa"
            cell.textLabel?.textAlignment = .center
            return cell
        case 1:
            cell.textLabel!.text = "Tesouro"
            cell.textLabel?.textAlignment = .center
            return cell
        case 2:
            cell.textLabel!.text = "Ações"
            cell.textLabel?.textAlignment = .center
            return cell
        case 3:
            cell.textLabel!.text = "Fundos Imobiliários"
            cell.textLabel?.textAlignment = .center
            return cell
        case 4:
            cell.textLabel!.text = "Moedas"
            cell.textLabel?.textAlignment = .center
            return cell
        case 5:
            cell.textLabel!.text = "Outros"
            cell.textLabel?.textAlignment = .center
            return cell
        case 6:
            cell.textLabel!.text = "Versão Premium"
            cell.textLabel?.textAlignment = .center
            return cell
        case 7:
            cell.textLabel!.text = "Cópia e Restauração"
            cell.textLabel?.textAlignment = .center
            return cell
        case 8:
            cell.textLabel!.text = "Sobre"
            cell.textLabel?.textAlignment = .center
            return cell
        default:
            return cell
        }
    }
    
    @objc func didTapOpenButton(_ sender: UIBarButtonItem) {
        if let drawerController = navigationController?.parent as? KYDrawerController {
            drawerController.setDrawerState(.opened, animated: true)
        }
    }
}
