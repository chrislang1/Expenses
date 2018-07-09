//
//  TotalCostViewController.swift
//  Expenses
//
//  Created by Chris Lang on 5/7/18.
//  Copyright © 2018 Chris Lang. All rights reserved.
//

import UIKit

class TotalCostViewController: UIViewController {

    @IBOutlet weak var totalExpensesPriceLabel: UILabel!
    @IBOutlet weak var expensePeriodLabel: UILabel!
    @IBOutlet weak var expensesView: UIView!
    @IBOutlet weak var periodButtonSettingsView: UIView!
    @IBOutlet weak var buttonSettingStackView: UIStackView!
    @IBOutlet var expensePeriodButtons: [UIButton]!
    
    var expenseArray = [Expense]()
    var startPosition: CGPoint?
    let window = UIApplication.shared.keyWindow
    var bottomPadding: CGFloat?
    var yComponent = CGFloat()
    let defaults = UserDefaults.standard
    
    let textColor = #colorLiteral(red: 0.5377323031, green: 0.4028604627, blue: 0.9699184299, alpha: 1)
    let backgroundColor = #colorLiteral(red: 0.4588235294, green: 0.2862745098, blue: 0.9607843137, alpha: 0.2)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(panGesture))
        view.addGestureRecognizer(gesture)
        expensesViewSetup()
        buttonSettingStackView.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateLabels()
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            let frame = self?.view.frame
            let expenseFrame = self?.expensesView.frame
            let periodFrame = self?.periodButtonSettingsView.frame
            self?.bottomPadding = self?.window?.safeAreaInsets.bottom
            
            if let bottomPadding = self?.bottomPadding {
                self?.yComponent = UIScreen.main.bounds.height - 60 - bottomPadding
            } else {
                self?.yComponent = UIScreen.main.bounds.height - 60
            }
            
            self?.view.frame = CGRect(x: 0, y: (self?.yComponent)!, width: frame!.width, height: expenseFrame!.height + periodFrame!.height)
        }
        
        
    }
    
    @objc func panGesture(recognizer: UIPanGestureRecognizer){
        if recognizer.state == .changed {
            let translation = recognizer.translation(in: self.view)
            let y = self.view.frame.minY
            
            if let parent = parent as? ExpensesViewController, let bottomPadding = bottomPadding {
                let maxHeight = parent.view.frame.height - 246 - bottomPadding
                let maxTranslation = maxHeight - yComponent
                if y+translation.y <= maxHeight {
                    self.view.frame = CGRect(x: 0, y: maxHeight, width: view.frame.width, height: view.frame.height)
                    buttonSettingStackView.alpha = 1
                    buttonSettingStackView.isHidden = false
                } else if y+translation.y >= yComponent {
                    self.view.frame = CGRect(x: 0, y: yComponent, width: view.frame.width, height: view.frame.height)
                    buttonSettingStackView.isHidden = true
                    buttonSettingStackView.alpha = 0
                } else {
                    self.view.frame = CGRect(x: 0, y: y + translation.y, width: view.frame.width, height: view.frame.height)
                    buttonSettingStackView.isHidden = false
                    buttonSettingStackView.alpha = (maxTranslation - (maxHeight - (y + translation.y)))/maxTranslation
                }
            }
            
            recognizer.setTranslation(CGPoint(x: 0, y: 0), in: self.view)
        }
        
    }
    
    //MARK: - Setup Expenses View
    func expensesViewSetup(){
        expensesView.layer.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        expensesView.clipsToBounds = false
        expensesView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        expensesView.layer.shadowPath = UIBezierPath(roundedRect: expensesView.bounds, cornerRadius: 10).cgPath
        expensesView.layer.shadowOpacity = 1
        expensesView.layer.shadowRadius = 2
        expensesView.layer.shadowOffset = CGSize.zero
        
        updateLabels()
    }
    
    func updateLabels(){
        let savedPeriod = defaults.integer(forKey: "SelectedPeriod")
        expencePeriodSelected(expensePeriodButtons[savedPeriod])
    }
    
    func expensesLabelSetup(per timePeriod: Double = 12, with label: String = "per month"){
        //Update Labels in Expense View
        var totalPrice = Double()
        for index in expenseArray.indices {
            totalPrice += expenseArray[index].yearPrice
        }
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        // localize to your grouping and decimal separator
        currencyFormatter.locale = Locale.current
        let price = totalPrice/timePeriod
        totalExpensesPriceLabel.text = currencyFormatter.string(from: NSNumber(value: price))
        expensePeriodLabel.text = label.lowercased()
    }
    
    //MARK: - Expense Time Period Method
    @IBAction func expencePeriodSelected(_ sender: UIButton) {
        for index in expensePeriodButtons.indices {
            if sender == expensePeriodButtons[index]{
                expensePeriodButtons[index].backgroundColor = backgroundColor
                expensePeriodButtons[index].setTitleColor(textColor, for: .normal)
                defaults.set(Int(index), forKey: "SelectedPeriod")
            } else {
                expensePeriodButtons[index].backgroundColor =  #colorLiteral(red: 0.9490196078, green: 0.9568627451, blue: 0.9647058824, alpha: 1)
                expensePeriodButtons[index].setTitleColor( #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
            }
        }
        let expensePeriod = Double(sender.tag)
        expensesLabelSetup(per: expensePeriod, with: sender.title(for: .normal)!)
    }
    
    
    //MARK: - Move View Up and Down in Edit Mode
    func moveDown(){
        UIView.animate(withDuration: 0.3) {
            self.view.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: self.view.frame.width, height: self.view.frame.height)
        }
    }
    
    func moveUp(){
        UIView.animate(withDuration: 0.3) {
            self.view.frame = CGRect(x: 0, y: self.yComponent, width: self.view.frame.width, height: self.view.frame.height)
        }
    }
}
