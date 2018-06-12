//
//  StockData.swift
//  Guia Investimento
//
//  Created by Felipe on 01/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
import UIKit

class StockData: UIViewController, UITableViewDataSource{
    @IBOutlet var stockTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Background Color
        self.view.backgroundColor = UIColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1)
        
        // Table View
        self.stockTable.dataSource = self
        let xib = UINib(nibName: "StockDataCell", bundle: nil)
        self.stockTable.register(xib, forCellReuseIdentifier: "cell")
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.stockTable.dequeueReusableCell(withIdentifier: "cell")
        let linha = indexPath.row
        return cell!
    }
}
