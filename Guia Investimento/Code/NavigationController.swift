//
//  NavigationController.swift
//  Guia Investimento
//
//  Created by Thiago on 27/05/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import UIKit
class NavigationController: UINavigationController {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return self.topViewController!.supportedInterfaceOrientations
    }
}
