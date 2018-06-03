//
//  Expense.swift
//  Subscriptions
//
//  Created by Chris Lang on 3/6/18.
//  Copyright © 2018 Chris Lang. All rights reserved.
//

import Foundation
import CoreData

class Expense: NSManagedObject {
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        
        var periodTypePerYear: Double?
        
        switch periodType {
        case "Day(s)":
            periodTypePerYear = 365;
        case "Weeks(s)":
            periodTypePerYear = 52;
        case "Fortnight(s)":
            periodTypePerYear = 26;
        case "Month(s)":
            periodTypePerYear = 12;
        case "Year(s)":
            periodTypePerYear = 1;
        default:
            periodTypePerYear = nil
        }
        
        yearPrice = price * periodTypePerYear!
    }
}
