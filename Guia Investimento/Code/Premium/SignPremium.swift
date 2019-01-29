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
    @IBOutlet var terms: UITextView!
    @IBOutlet var privacy: UITextView!
    
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
        
        let attributedTerms = NSMutableAttributedString(string: "Terms of Use")
        let attributedPrivacy = NSMutableAttributedString(string: "Privacy Policy")
        let urlTerms = URL(string: "http://www.guiainvestimento.com.br/terms_use.html")
        let urlPrivacy = URL(string: "http://www.guiainvestimento.com.br/privacy_policy.html")
        
        attributedTerms.setAttributes([.link: urlTerms], range: NSMakeRange(0, 12))
        attributedPrivacy.setAttributes([.link: urlPrivacy], range: NSMakeRange(0, 14))
        
        self.terms.attributedText = attributedTerms
        self.terms.isUserInteractionEnabled = true
        self.terms.isEditable = false
        self.privacy.attributedText = attributedPrivacy
        self.privacy.isUserInteractionEnabled = true
        self.privacy.isEditable = false
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
