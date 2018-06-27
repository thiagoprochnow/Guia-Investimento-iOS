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
            cell.textLabel!.text = "Carteira Completa"
            cell.textLabel?.textAlignment = .left
            return cell
        case 1:
            cell.textLabel!.text = "Tesouro"
            cell.textLabel?.textAlignment = .left
            return cell
        case 2:
            cell.textLabel!.text = "Renda Fixa"
            cell.textLabel?.textAlignment = .left
            return cell
        case 3:
            cell.textLabel!.text = "Ações"
            cell.textLabel?.textAlignment = .left
            return cell
        case 4:
            cell.textLabel!.text = "Fundos Imobiliários"
            cell.textLabel?.textAlignment = .left
            return cell
        case 5:
            cell.textLabel!.text = "Moedas"
            cell.textLabel?.textAlignment = .left
            return cell
        case 6:
            cell.textLabel!.text = "Outros"
            cell.textLabel?.textAlignment = .left
            return cell
        case 7:
            cell.textLabel!.text = "Versão Premium"
            cell.textLabel?.textAlignment = .left
            return cell
        case 8:
            cell.textLabel!.text = "Copia e Restauração"
            cell.textLabel?.textAlignment = .left
            return cell
        case 9:
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
        
        if let drawerController = parent as? KYDrawerController {
            drawerController.setDrawerState(.closed, animated: true)
            switch linha{
            case 3:
                let portfolio = StockPortfolioView()
                let data = StockDataView()
                let soldData = SoldStockDataView()
                let income = StockDataView()
                portfolio.tabBarItem.title = ""
                portfolio.tabBarItem.image =  makeThumbnailFromText(text: "Visão Geral")
                data.tabBarItem.title = ""
                data.tabBarItem.image = makeThumbnailFromText(text: "Carteira")
                soldData.tabBarItem.title = ""
                soldData.tabBarItem.image = makeThumbnailFromText(text: "Histórico")
                income.tabBarItem.title = ""
                income.tabBarItem.image = makeThumbnailFromText(text: "Rendimentos")
                
                view.title = "Ações"
                // Create custom Back Button
                let backButton = UIBarButtonItem(title: "Voltar", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
                view.navigationItem.backBarButtonItem = backButton
                view.navigationItem.backBarButtonItem?.tintColor = UIColor.white
                view.viewControllers = [portfolio, data, soldData, income]
                break
            default:
                view.title = "Carteira Completa"
            }
            
            let nav = drawerController.mainViewController as! UINavigationController
            nav.pushViewController(view, animated: true)
        }
    }

    func makeThumbnailFromText(text: String) -> UIImage {
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
