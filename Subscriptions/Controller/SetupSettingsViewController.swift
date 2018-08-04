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
    
    var bottomPadding: CGFloat?
    let window = UIApplication.shared.keyWindow
    var delegate: TotalCostViewController?
    var settingsView: SettingsViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let bottomPadding = self.window?.safeAreaInsets.bottom {
            containerViewHeight.constant = containerViewHeight.constant + bottomPadding
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationVC = segue.destination as! UINavigationController
        let destinationVC = navigationVC.topViewController as! SettingsViewController
        destinationVC.delegate = self
    }
    

}
