//
//  Constants.swift
//  Guia Investimento
//
//  Created by Felipe on 24/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
struct Constants {
    
    struct TypeOp {
        static let INVALID = -1
        static let BUY = 0
        static let SELL = 1
        static let BONIFICATION = 2
        static let GROUPING = 3
        static let SPLIT = 4
        static let EDIT = 5
        static let DELETE_TRANSACTION = 6
        static let EDIT_TRANSACTION = 7
        static let EDIT_INCOME = 8
    }
    
    struct Status {
        static let INVALID = -1
        static let ACTIVE = 0
        static let SOLD = 1
    }
    
    struct ProductType {
        static let INVALID = -1
        static let STOCK = 0
        static let FII = 1
        static let CURRENCY = 2
        static let FIXED = 3
        static let TREASURY = 4
        static let OTHERS = 5
        static let PORTFOLIO = 6
    }
    
    struct IncomeType {
        static let INVALID = -1
        static let DIVIDEND = 0
        static let JCP = 1
        static let BONIFICATION = 2
        static let GROUPING = 3
        static let SPLIT = 4
        static let FII = 5
        static let FIXED = 6
        static let TREASURY = 7
        static let OTHERS = 8
        static let FII_SPLIT = 9
    }
    
    struct UpdateStatus {
        static let INVALID = -1
        static let UPDATED = 0
        static let NOT_UPDATED = 1
    }
    
    struct FixedType {
        static let INVALID = -1
        static let CDI = 0
        static let IPCA = 1
        static let PRE = 2
    }
}
