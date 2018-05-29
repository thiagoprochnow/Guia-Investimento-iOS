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

class DrawerViewController: UIViewController, UITableViewDataSource {
    @IBOutlet var mainMenu: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.mainMenu.dataSource = self
        self.mainMenu.rowHeight = 65
        self.mainMenu.register(UITableViewCell.self, forCellReuseIdentifier: "mainMenu")
        self.mainMenu.separatorStyle = UITableViewCellSeparatorStyle.none
        // Do any additional setup after loading the view.
        /*
        let closeButton    = UIButton()
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setTitle("Carteira Completa", for: UIControlState())
        closeButton.addTarget(self,
            action: #selector(didTapCloseButton),
            for: .touchUpInside
       )
        closeButton.sizeToFit()
        closeButton.setTitleColor(UIColor.black, for: UIControlState())
        view.addSubview(closeButton)
        view.addConstraint(
            NSLayoutConstraint(
                item: closeButton,
                attribute: .centerX,
                relatedBy: .equal,
                toItem: view,
                attribute: .centerX,
                multiplier: 1,
                constant: 0
            )
        )
        view.addConstraint(
            NSLayoutConstraint(
                item: closeButton,
                attribute: .centerY,
                relatedBy: .equal,
                toItem: view,
                attribute: .centerY,
                multiplier: 1,
                constant: 0
            )
        )
        view.backgroundColor = UIColor.white
         */
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
            cell.textLabel?.textAlignment = .left
            return cell
        case 1:
            cell.textLabel!.text = "Tesouro"
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
            cell.textLabel!.text = "Cópia e Restauração"
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
    
    @objc func didTapCloseButton(_ sender: UIButton) {
        if let drawerController = parent as? KYDrawerController {
            drawerController.setDrawerState(.closed, animated: true)
            let portfolioMain = PortfolioMainController()
            drawerController.mainViewController = UINavigationController(
                rootViewController: portfolioMain
            )
        }
    }

}
