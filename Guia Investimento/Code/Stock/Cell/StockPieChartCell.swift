//
//  StockPortfolioCell.swift
//  Guia Investimento
//
//  Created by Felipe on 20/07/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
import UIKit

class StockPieChartCell: UITableViewCell {
    @IBOutlet var chart: PieChartView!
    
    // Customize the Cell
    override func layoutSubviews() {
        super.layoutSubviews()
        chart.layer.masksToBounds = false
        
        chart.layer.cornerRadius = 6
        chart.layer.shadowColor = UIColor.black.cgColor
        chart.layer.shadowOpacity = 0.5
        chart.layer.shadowOffset = CGSize(width: -1, height: 1)
        chart.layer.shadowRadius = 5
        
        // Sample data
        let values: [Double] = [11, 33, 81, 52, 97, 101, 75]
        
        var entries: [PieChartDataEntry] = Array()
        
        for value in values
        {
            entries.append(PieChartDataEntry(value: value, icon: UIImage(named: "icon", in: Bundle(for: self.classForCoder), compatibleWith: nil)))
        }
        
        let dataSet = PieChartDataSet(values: entries, label: "First unit test data")
        dataSet.iconsOffset = CGPoint(x: 0, y: 20.0)
        
        chart.backgroundColor = UIColor.white
        chart.centerText = "PieChart Unit Test"
        chart.data = PieChartData(dataSet: dataSet)
    }
}
