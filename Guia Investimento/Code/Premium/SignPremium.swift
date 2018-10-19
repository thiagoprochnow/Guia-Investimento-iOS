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
    var subscription: SubscriptionService!
    @IBOutlet var mensalButton: UIView!
    @IBOutlet var semestralButton: UIView!
    @IBOutlet var restoreButton: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        subscription = appDelegate.subscription
        
        mensalButton.isUserInteractionEnabled = true
        semestralButton.isUserInteractionEnabled = true
        restoreButton.isUserInteractionEnabled = true
        let mensalGesture = UITapGestureRecognizer(target: self, action: #selector(SignPremium.assinarMensal))
        let semestralGesture = UITapGestureRecognizer(target: self, action: #selector(SignPremium.assinarSemestral))
        let restoreGesture = UITapGestureRecognizer(target: self, action: #selector(SignPremium.restaurarAssinatura))
        mensalButton.addGestureRecognizer(mensalGesture)
        semestralButton.addGestureRecognizer(semestralGesture)
        restoreButton.addGestureRecognizer(restoreGesture)
    }
    
    @IBAction func assinarMensal(){
        let mensal = subscription.mensal
        subscription.purchaseProduct(product: mensal)
    }
    
    @IBAction func assinarSemestral(){
        let semestral = subscription.semestral
        subscription.purchaseProduct(product: semestral)
    }
    
    @IBAction func restaurarAssinatura(){
        subscription.restorePurchases()
    }
}
