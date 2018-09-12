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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Background Color
        
        let versionString = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        version.text = "Versão: " + versionString
    }
}
