//
//  OthersEditPriceForm.swift
//  Guia Investimento
//
//  Created by Felipe on 13/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
import UIKit
class OthersEditPriceForm: UIViewController, UITextFieldDelegate{
    @IBOutlet var totalField: UITextField!
    var prealodedData: OthersData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add Dividend button added on the right side of the bar menu
        let btInsert = UIBarButtonItem(title: "Inserir", style: UIBarButtonItemStyle.plain, target: self, action: #selector(OthersEditPriceForm.editTotal))
        let font = UIFont.init(name: "Arial", size: 14)
        btInsert.setTitleTextAttributes([NSAttributedStringKey.font: font], for: .normal)
        self.navigationItem.rightBarButtonItem = btInsert
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        
        // Delegade UITextFieldDelagate to self
        totalField.delegate = self
        totalField.keyboardType = UIKeyboardType.numbersAndPunctuation
        
        totalField.text = String(prealodedData.currentTotal)
    }
    
    @IBAction func editTotal(){
        let othersDB = OthersDataDB()
        let currentTotal = Double(totalField.text!)!
        let totalBuy = prealodedData.buyTotal
        let sellTotal = prealodedData.sellTotal
        let totalGain = currentTotal + prealodedData.liquidIncome + sellTotal - totalBuy
        prealodedData.currentTotal = currentTotal
        prealodedData.totalGain = totalGain
        othersDB.save(prealodedData)
        othersDB.close()
        Utils.updateOthersPortfolio()
        
        self.navigationController?.popViewController(animated: true)
        // Create alert saying the others information is invalid
        let alert = UIAlertView()
        alert.title = ""
        alert.delegate = self
        alert.addButton(withTitle: "OK")
        // Show Alert
        alert.message = "Total da Renda Fixa atualizada com sucesso"
        alert.show()
    }
    
    // Gives first responder back to view and closes keyboard when clicking outside of text field
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        totalField.resignFirstResponder()
    }
}
