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
    func darkenView()
}

class SettingsViewController: UIViewController {

    @IBOutlet weak var settingsView: UIView!
    @IBOutlet weak var interfaceThemeLabel: UILabel!
    @IBOutlet weak var settingsLabel: UILabel!
    @IBOutlet weak var sortExpensesByLabel: UILabel!
    @IBOutlet weak var sortExpensesOptionLabel: UILabel!
    @IBOutlet weak var feedbackButton: UIButton!
    @IBOutlet weak var rateButton: UIButton!
    @IBOutlet weak var xButton: UIButton!
    @IBOutlet weak var panLabel: UILabel!
    @IBOutlet weak var lightDarkSwitchView: UIView!
    
    @IBOutlet var themeButtons: [UIButton]!
    
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
        updateThemeButtons(sender: themeButtons[defaults.integer(forKey: "SelectedTheme")])
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
            if let delegate = self.delegate {
                delegate.darkenView()
            }
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
        panLabel.backgroundColor = theme?.panAndDividerColor
        lightDarkSwitchView.backgroundColor = theme?.buttonColor
    }
    
    func updateThemeButtons(sender: UIButton){
        for index in themeButtons.indices{
            if themeButtons[index] == sender{
                themeButtons[index].backgroundColor = theme?.selectorButtonSelectedColor
                themeButtons[index].setTitleColor(.white, for: .normal)
            } else {
                themeButtons[index].backgroundColor = .clear
                themeButtons[index].setTitleColor(theme?.expensesFontColor, for: .normal)
            }
        }
    }
    
    @IBAction func themeToggleButtonChanged(_ sender: UIButton) {
        theme = Theme.init(rawValue: sender.tag)
        defaults.set(sender.tag, forKey: "SelectedTheme")
        updateTheme()
        updateThemeButtons(sender: sender)
        
        if let delegate = delegate {
            delegate.updateUserTheme()
            delegate.darkenView()
        }
        
        if UIApplication.shared.supportsAlternateIcons {
            if sender.tag == 0 {
                UIApplication.shared.setAlternateIconName(nil)
            } else if sender.tag == 1 {
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
        if let delegate = delegate {
            delegate.updateUserTheme()
        }
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