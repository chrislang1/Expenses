//
//  Expense+Helper.swift
//  Expenses
//
//  Created by Andy Kim on 17/6/18.
//  Copyright © 2018 Chris Lang. All rights reserved.
//

import Foundation

extension Expense {
    enum PeriodType: Int, CustomStringConvertible {
        case day
        case week
        case fortnight
        case month
        case year
        
        init?(typeString: String) {
            switch typeString.lowercased() {
            case "day":
                self.init(rawValue: 0)
            case "week":
                self.init(rawValue: 1)
            case "fortnight":
                self.init(rawValue: 2)
            case "month":
                self.init(rawValue: 3)
            case "year":
                self.init(rawValue: 4)
            default:
                return nil
            }
        }
        
        var description: String {
            switch self {
            case .day: return "Day(s)"
            case .week: return "Week(s)"
            case .fortnight: return "Fortnight(s)"
            case .month: return "Month(s)"
            case .year: return "Year(s)"
            }
        }
        
        var countPerYear: Double {
            switch self {
            case .day: return 365
            case .week: return 52
            case .fortnight: return 26
            case .month: return 12
            case .year: return 1
            }
        }
    }
    
}
