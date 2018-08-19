//
//  FixedPortfolioCell.swift
//  Guia Investimento
//
//  Created by Felipe on 20/07/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
import UIKit

class FixedPieChartCell: UITableViewCell {
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
        
        // Get FixedData
        let fixedDB = FixedDataDB()
        let fixeds = fixedDB.getDataPercent()
        fixedDB.close()
        
        var entries: [PieChartDataEntry] = Array()
        
        var otherPercent = 0.0
        for (index,fixed) in fixeds.enumerated()
        {
            if(index < 6){
                entries.append(PieChartDataEntry(value: fixed.currentPercent/100, label: fixed.symbol))
            } else {
                // Check if it is last fixed
                otherPercent += fixed.currentPercent
                if(index == (fixeds.count - 1)){
                    entries.append(PieChartDataEntry(value: otherPercent/100, label: "OUTROS"))
                }
            }
        }

        let dataSet = PieChartDataSet(values: entries, label: "")
        dataSet.iconsOffset = CGPoint(x: 0, y: 20.0)
        dataSet.setColors(
             UIColor.init(red: 121/255, green: 128/255, blue: 50/255, alpha: 1)
            ,UIColor.init(red: 100/255, green: 181/255, blue: 246/255, alpha: 1)
            ,UIColor.init(red: 244/255, green: 67/255, blue: 54/255, alpha: 1)
            ,UIColor.init(red: 171/255, green: 171/255, blue: 15/255, alpha: 1)
            ,UIColor.init(red: 63/255, green: 81/255, blue: 181/255, alpha: 1)
            ,UIColor.init(red: 155/255, green: 163/255, blue: 163/255, alpha: 1)
            ,UIColor.init(red: 236/255, green: 64/255, blue: 122/255, alpha: 1)
            ,UIColor.init(red: 67/255, green: 160/255, blue: 71/255, alpha: 1)
            ,UIColor.init(red: 138/255, green: 139/255, blue: 139/255, alpha: 1)
        )
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 1
        dataSet.valueFormatter = DefaultValueFormatter(formatter: formatter)
        
        let legend = chart.legend
        legend.verticalAlignment = Legend.VerticalAlignment.top
        legend.horizontalAlignment = Legend.HorizontalAlignment.center
        legend.yOffset = 12
        legend.yEntrySpace = 5
        legend.xEntrySpace = 7
        let font = UIFont.systemFont(ofSize: 13)
        legend.font = font
        
        chart.chartDescription?.text = ""
        chart.backgroundColor = UIColor.white
        let data = PieChartData(dataSet: dataSet)
        data.setValueFormatter(DefaultValueFormatter(formatter: formatter))
        chart.data = PieChartData(dataSet: dataSet)
    }
}
