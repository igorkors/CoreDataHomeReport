//
//  Double+Extension.swift
//  CoreDataHomeReport
//
//  Created by Igor Korshunov on 27/12/2019.
//  Copyright © 2019 Igor Korshunov. All rights reserved.
//

import Foundation

extension Double {
    var currencyFormatter: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: NSNumber(value: self))!
    }
}
