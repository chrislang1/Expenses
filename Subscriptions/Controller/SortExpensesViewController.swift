//
//  SortExpensesViewController.swift
//  Expenses
//
//  Created by Chris Lang on 1/8/18.
//  Copyright © 2018 Chris Lang. All rights reserved.
//

import UIKit

protocol SortExpenseDelegate {
    func sortLabelAndExpenses()
}

class SortExpensesViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sortView: UIView!
    @IBOutlet var sortButtons: [UIButton]!
    @IBOutlet var tickImages: [UIImageView]!
    @IBOutlet weak var sortViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var xIconButton: UIButton!
    
    var bottomPadding: CGFloat?
    let window = UIApplication.shared.keyWindow
    var yComponent = CGFloat()
    var theme = Theme.init(rawValue: 0)
    let defaults = UserDefaults.standard
    
    var delegate: SettingsViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        theme = Theme.init(rawValue: defaults.integer(forKey: "SelectedTheme")) ?? Theme.init(rawValue: 0)
        updateTheme()
        if let bottomPadding = self.window?.safeAreaInsets.bottom {
            sortViewHeightConstraint.constant = sortViewHeightConstraint.constant + bottomPadding
        }
        
        sortTypeSelected(sortButtons[defaults.integer(forKey: "Sort")])
    }
    
    func updateTheme(){
        titleLabel.textColor = theme?.expensesFontColor
        for index in sortButtons.indices {
            sortButtons[index].setTitleColor(theme?.expensesFontColor, for: .normal)
        }
        sortView.layer.backgroundColor = theme?.totalCostViewColor
        xIconButton.setImage(theme?.xIconImage, for: .normal)
    }
    
    @IBAction func sortTypeSelected(_ sender: UIButton) {
        for index in sortButtons.indices{
            if sortButtons[index] == sender {
                tickImages[index].isHidden = false
                defaults.set(index, forKey: "Sort")
            } else {
                tickImages[index].isHidden = true
            }
        }
        
        delegate?.sortLabelAndExpenses()
    }
    
    @IBAction func xButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

}
