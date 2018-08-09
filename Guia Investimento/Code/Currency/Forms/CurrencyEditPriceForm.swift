//
//  CurrencyEditPriceForm.swift
//  Guia Investimento
//
//  Created by Felipe on 13/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
import UIKit
class CurrencyEditPriceForm: UIViewController, UITextFieldDelegate{
    @IBOutlet var priceField: UITextField!
    var prealodedData: CurrencyData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add Dividend button added on the right side of the bar menu
        let btInsert = UIBarButtonItem(title: "Inserir", style: UIBarButtonItemStyle.plain, target: self, action: #selector(CurrencyEditPriceForm.editPrice))
        self.navigationItem.rightBarButtonItem = btInsert
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        
        // Delegade UITextFieldDelagate to self
        priceField.delegate = self
        priceField.keyboardType = UIKeyboardType.decimalPad
        
        priceField.text = String(prealodedData.currentPrice)
    }
    
    @IBAction func editPrice(){
        let currencyDB = CurrencyDataDB()
        prealodedData.currentPrice = Double(priceField.text!)!
        let currentTotal = Double(prealodedData.quantity) * prealodedData.currentPrice
        let variation = currentTotal - prealodedData.buyValue
        let totalGain = currentTotal - prealodedData.buyValue - prealodedData.brokerage
        prealodedData.currentTotal = currentTotal
        prealodedData.variation = variation
        prealodedData.totalGain = totalGain
        currencyDB.save(prealodedData)
        currencyDB.close()
        Utils.updateCurrencyPortfolio()
        
        self.navigationController?.popViewController(animated: true)
        // Create alert saying the currency information is invalid
        let alert = UIAlertView()
        alert.title = ""
        alert.delegate = self
        alert.addButton(withTitle: "OK")
        // Show Alert
        alert.message = "Preço da moeda atualizado com sucesso"
        alert.show()
    }
    
    // Gives first responder back to view and closes keyboard when clicking outside of text field
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        priceField.resignFirstResponder()
    }
}
