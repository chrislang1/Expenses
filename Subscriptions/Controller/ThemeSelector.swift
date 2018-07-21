//
//  ThemeSelector.swift
//  Expenses
//
//  Created by Chris Lang on 20/7/18.
//  Copyright © 2018 Chris Lang. All rights reserved.
//

import Foundation
import UIKit

enum Theme: Int, CustomStringConvertible {
    case light
    case dark
    
    init?(typeString: String) {
        switch typeString.lowercased() {
        case "light":
            self.init(rawValue: 0)
        case "dark":
            self.init(rawValue: 1)
        default:
            return nil
        }
    }
    
    var applicationBackgroundColor: CGColor {
        switch self {
        case .light: return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        case .dark: return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
    }
    
    var expensesFontColor: UIColor {
        switch self {
        case .light: return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        case .dark: return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }
    
    var selectedButtonColor: UIColor {
        switch self {
        case .light: return #colorLiteral(red: 0.46, green: 0.29, blue: 0.96, alpha: 0.2)
        case .dark: return #colorLiteral(red: 0.46, green: 0.29, blue: 0.96, alpha: 1)
        }
    }
    
    var selectedButtonTextColor: UIColor {
        switch self {
        case .light: return #colorLiteral(red: 0.46, green: 0.29, blue: 0.96, alpha: 1)
        case .dark: return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }
    
    var buttonColor: UIColor {
        switch self {
        case .light: return #colorLiteral(red: 0.95, green: 0.96, blue: 0.96, alpha: 1)
        case .dark: return #colorLiteral(red: 0.17, green: 0.17, blue: 0.17, alpha: 1)
        }
    }
    
    var totalCostViewColor: CGColor {
        switch self {
        case .light: return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        case .dark: return #colorLiteral(red: 0.12, green: 0.12, blue: 0.12, alpha: 1)
        }
    }
    
    var doneToolBarColor: UIColor {
        switch self {
        case .light: return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        case .dark: return #colorLiteral(red: 0.12, green: 0.12, blue: 0.12, alpha: 1)
        }
    }
    
    var doneKeyboardButtonColor: UIColor {
        switch self {
        case .light, .dark: return #colorLiteral(red: 0.5388125777, green: 0.4061352313, blue: 0.9692879319, alpha: 1)
        }
    }
    
    var selectedExpenseColor: UIColor {
        switch self {
        case .light: return #colorLiteral(red: 0.46, green: 0.29, blue: 0.96, alpha: 0.2)
        case .dark: return #colorLiteral(red: 0.5388125777, green: 0.4061352313, blue: 0.9692879319, alpha: 1)
        }
    }
    
    var selectedExpenseFontColor: UIColor {
        switch self {
        case .light: return #colorLiteral(red: 0.5388125777, green: 0.4061352313, blue: 0.9692879319, alpha: 1)
        case .dark: return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }
    
    var choosePeriodLabelColor: UIColor {
        switch self {
        case .light: return #colorLiteral(red: 0.12, green: 0.12, blue: 0.12, alpha: 0.4)
        case .dark: return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }
    
    var deleteButtonColor: UIColor {
        switch self {
        case .light: return #colorLiteral(red: 1, green: 0.231, blue: 0.188, alpha: 0.4)
        case .dark: return #colorLiteral(red: 0.99, green: 0.24, blue: 0.22, alpha: 1)
        }
    }
    
    var deleteButtonTextColor: UIColor {
        switch self {
        case .light: return #colorLiteral(red: 0.99, green: 0.24, blue: 0.22, alpha: 1)
        case .dark: return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }
    
    var addBarButtonImage: UIImage{
        switch self {
        case .light: return #imageLiteral(resourceName: "AddIcon")
        case .dark: return #imageLiteral(resourceName: "AddIconWhite")
        }
    }
    
    var textFieldColor: CGColor {
        switch self {
        case .light: return #colorLiteral(red: 0.95, green: 0.96, blue: 0.96, alpha: 1)
        case .dark: return #colorLiteral(red: 0.17, green: 0.17, blue: 0.17, alpha: 1)
        }
    }
    
    var description: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
    
}
