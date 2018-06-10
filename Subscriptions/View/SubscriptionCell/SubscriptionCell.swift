//
//  SubscriptionCell.swift
//  Subscriptions
//
//  Created by Chris Lang on 31/5/18.
//  Copyright © 2018 Chris Lang. All rights reserved.
//

import UIKit

class SubscriptionCell: UITableViewCell {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        backView.layer.cornerRadius = 10
        backView.backgroundColor = .white
    
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        if isEditing != true {
            if selected == true {
                backView.backgroundColor = UIColor(red: 0.61, green: 0.32, blue: 0.88, alpha: 0.2)
                priceLabel.textColor = #colorLiteral(red: 0.6078431373, green: 0.3176470588, blue: 0.8784313725, alpha: 1)
                nameLabel.textColor = #colorLiteral(red: 0.6078431373, green: 0.3176470588, blue: 0.8784313725, alpha: 1)
            } else {
                backView.backgroundColor = .white
                priceLabel.textColor = .black
                nameLabel.textColor = .black
            }
        }
    }
    
    
}
