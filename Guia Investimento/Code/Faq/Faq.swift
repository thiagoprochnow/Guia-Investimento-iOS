//
//  Faq.swift
//  Guia Investimento
//
//  Created by Felipe on 11/09/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
import UIKit

class Faq: UIViewController, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Table View
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        let xib = UINib(nibName: "FaqCell", bundle: nil)
        self.tableView.register(xib, forCellReuseIdentifier: "cell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let linha = indexPath.row
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! FaqCell
        // Do not show highlight when selected
        cell.selectionStyle = .none
        
        return cell
    }
}
