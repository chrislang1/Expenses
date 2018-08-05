//
//  AppIconViewController.swift
//  Expenses
//
//  Created by Chris Lang on 5/8/18.
//  Copyright © 2018 Chris Lang. All rights reserved.
//

import UIKit

class AppIconViewController: UIViewController {

    @IBOutlet var iconArray: [UIButton]!
    @IBOutlet var tickArray: [UIImageView]!
    
    var theme = Theme.init(rawValue: 0)
    var selectedIcon = Int()
    var defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

        theme = Theme.init(rawValue: defaults.integer(forKey: "SelectedTheme"))
        view.layer.backgroundColor = theme?.totalCostViewColor
        
        selectedIcon = defaults.integer(forKey: "Icon")
        
        buttonSetup()
        setTick()
    }
    
    func buttonSetup(){
        for index in iconArray.indices{
            let button = iconArray[index]
            button.imageView?.layer.cornerRadius = 10
            button.clipsToBounds = false
            button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
            button.layer.shadowPath = UIBezierPath(roundedRect: button.bounds, cornerRadius: 10).cgPath
            button.layer.shadowOpacity = 1
            button.layer.shadowRadius = 5
            button.layer.shadowOffset = CGSize.zero
        }
    }
    
    func setTick(){
        for index in tickArray.indices {
            if index == selectedIcon {
                tickArray[index].isHidden = false
            } else {
                tickArray[index].isHidden = true
            }
        }
    }
    
    @IBAction func iconSelected(_ sender: UIButton) {
        let iconName: String?
        
        switch sender.tag {
        case 0: iconName = nil
        case 1: iconName = "LightWhite"
        case 2: iconName = "DarkPurple"
        case 3: iconName = "AlternateIcon"
        default: iconName = nil
        }
        
        if UIApplication.shared.supportsAlternateIcons {
            UIApplication.shared.setAlternateIconName(iconName){ error in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    print("Done!")
                }
            }
        }
        
        selectedIcon = sender.tag
        defaults.set(sender.tag, forKey: "Icon")
        setTick()
    }
    

}
