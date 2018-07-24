//
//  SettingsViewController.swift
//  Expenses
//
//  Created by Chris Lang on 23/7/18.
//  Copyright © 2018 Chris Lang. All rights reserved.
//

import UIKit

protocol UpdateParentThemeDelegate {
    func updateUserTheme()
}

class SettingsViewController: UIViewController {

    @IBOutlet weak var settingsView: UIView!
    @IBOutlet weak var interfaceThemeLabel: UILabel!
    @IBOutlet weak var settingsLabel: UILabel!
    @IBOutlet weak var themeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var sortExpensesByLabel: UILabel!
    @IBOutlet weak var sortExpensesOptionLabel: UILabel!
    @IBOutlet weak var feedbackButton: UIButton!
    @IBOutlet weak var rateButton: UIButton!
    @IBOutlet weak var xButton: UIButton!
    
    
    var delegate: ExpensesViewController?
    
    var settingsViewFrame = CGRect()
    var bottomPadding: CGFloat?
    let window = UIApplication.shared.keyWindow
    var yComponent = CGFloat()
    var theme = Theme.init(rawValue: 0)
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        settingsViewFrame = settingsView.frame
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        theme = Theme.init(rawValue: defaults.integer(forKey: "SelectedTheme")) ?? Theme.init(rawValue: 0)
        themeSegmentedControl.selectedSegmentIndex = defaults.integer(forKey: "SelectedTheme")
        setupViewShadow()
        updateTheme()
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let `self` = self else {return}
            let frame = self.view.frame
            self.bottomPadding = self.window?.safeAreaInsets.bottom
            
            if let bottomPadding = self.bottomPadding {
                if bottomPadding > CGFloat(0) {
                    self.yComponent = UIScreen.main.bounds.height - self.settingsViewFrame.height
                } else {
                    self.yComponent = UIScreen.main.bounds.height - self.settingsViewFrame.height
                    }
            }
            
            self.view.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: frame.width, height: self.settingsViewFrame.height)
        }
    }
    
    func setupViewShadow(){
        settingsView.clipsToBounds = false
        settingsView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        settingsView.layer.shadowPath = UIBezierPath(roundedRect: settingsView.bounds, cornerRadius: 10).cgPath // alter path to remove shadow from bottom of view
        settingsView.layer.shadowOpacity = 1
        settingsView.layer.shadowRadius = 5
        settingsView.layer.shadowOffset = CGSize.zero
        settingsView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    func moveUp(){
        UIView.animate(withDuration: 0.3) {
            self.view.frame = CGRect(x: 0, y: self.yComponent, width: self.view.frame.width, height: self.view.frame.height)
        }
    }
    
    func moveDown(){
        UIView.animate(withDuration: 0.3) {
            self.view.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: self.view.frame.width, height: self.view.frame.height)
        }
    }
    
    func updateTheme(){
        settingsView.layer.backgroundColor = theme?.totalCostViewColor
        interfaceThemeLabel.textColor = theme?.expensesFontColor
        settingsLabel.textColor = theme?.expensesFontColor
        sortExpensesByLabel.textColor = theme?.expensesFontColor
        sortExpensesOptionLabel.textColor = theme?.expensesFontColor
        feedbackButton.backgroundColor = theme?.buttonColor
        feedbackButton.setTitleColor(theme?.expensesFontColor, for: .normal)
        rateButton.backgroundColor = theme?.buttonColor
        rateButton.setTitleColor(theme?.expensesFontColor, for: .normal)
        xButton.setImage(theme?.xIconImage, for: .normal)
    }
    
    @IBAction func themeToggleChanged(_ sender: UISegmentedControl) {
        theme = Theme.init(rawValue: sender.selectedSegmentIndex)
        defaults.set(sender.selectedSegmentIndex, forKey: "SelectedTheme")
        updateTheme()
        
        if sender.selectedSegmentIndex != 0 {
            
        }
        
        if let delegate = delegate {
            delegate.updateUserTheme()
        }
        
        if UIApplication.shared.supportsAlternateIcons {
            if let alternateIconName = UIApplication.shared.alternateIconName {
                print("current icon is \(alternateIconName), change to primary icon")
                UIApplication.shared.setAlternateIconName(nil)
            } else {
                print("current icon is primary icon, change to alternative icon")
                UIApplication.shared.setAlternateIconName("AlternateIcon"){ error in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        print("Done!")
                    }
                }
            }
        }
    }
    
    @IBAction func exitButtonPressed(_ sender: UIButton) {
        moveDown()
    }
    
    @IBAction func feedbackButtonPressed(_ sender: UIButton) {
        if let url = NSURL(string: "http://www.alexvanderzon.com/expenses/"){
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func rateButtonPressed(_ sender: UIButton) {
        if let url = URL(string: "itms-apps://itunes.apple.com/app/id1401279619"){
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    
}
