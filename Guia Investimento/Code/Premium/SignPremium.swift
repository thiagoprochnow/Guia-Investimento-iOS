//
//  SignPremium.swift
//  Guia Investimento
//
//  Created by Felipe on 11/09/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
import UIKit

class SignPremium: UIViewController {
    var subscription = SubscriptionService()
    @IBOutlet var mensalButton: UIView!
    @IBOutlet var semestralButton: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subscription.fetchAvailableProducts()
        
        mensalButton.isUserInteractionEnabled = true
        semestralButton.isUserInteractionEnabled = true
        let mensalGesture = UITapGestureRecognizer(target: self, action: #selector(SignPremium.assinarMensal))
        let semestralGesture = UITapGestureRecognizer(target: self, action: #selector(SignPremium.assinarSemestral))
        mensalButton.addGestureRecognizer(mensalGesture)
        semestralButton.addGestureRecognizer(semestralGesture)
    }
    
    @IBAction func assinarMensal(){
        print("mensal")
    }
    
    @IBAction func assinarSemestral(){
        print("semestral")
    }
}
