//
//  SetupSettingsViewController.swift
//  Expenses
//
//  Created by Chris Lang on 4/8/18.
//  Copyright © 2018 Chris Lang. All rights reserved.
//

import UIKit

class SetupSettingsViewController: UIViewController {

    @IBOutlet weak var containerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var pullLabelView: UIView!
    @IBOutlet weak var pullLabel: UILabel!
    
    var bottomPadding: CGFloat?
    let window = UIApplication.shared.keyWindow
    var delegate: TotalCostViewController?
    var settingsView: SettingsViewController?
    var theme = Theme.init(rawValue: 0)
    var defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let bottomPadding = self.window?.safeAreaInsets.bottom {
            containerViewHeight.constant = containerViewHeight.constant + bottomPadding
        }
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        view.addGestureRecognizer(gesture)
        
        theme = Theme.init(rawValue: defaults.integer(forKey: "SelectedTheme")) ?? Theme.init(rawValue: 0)
        updateTheme()
        
        pullLabelView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationVC = segue.destination as! UINavigationController
        let destinationVC = navigationVC.topViewController as! SettingsViewController
        destinationVC.delegate = self
    }
    
    func updateTheme(){
        theme = Theme.init(rawValue: defaults.integer(forKey: "SelectedTheme"))
        pullLabelView.layer.backgroundColor = theme?.totalCostViewColor
        pullLabel.backgroundColor = theme?.panAndDividerColor
    }
    
    @objc func dismissView(){
        if let delegate = delegate {
            delegate.parent?.navigationController?.view.alpha = 1
        }
        dismiss(animated: true, completion: nil)
    }

}
