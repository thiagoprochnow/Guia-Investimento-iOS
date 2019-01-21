//
//  About.swift
//  Guia Investimento
//
//  Created by Felipe on 11/09/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
import UIKit

class About: UIViewController {
    @IBOutlet var version: UILabel!
    @IBOutlet var terms: UITextView!
    @IBOutlet var privacy: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Background Color
        
        let versionString = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        version.text = "Versão: " + versionString
        
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
}
