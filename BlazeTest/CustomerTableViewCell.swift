//
//  CustomerTableViewCell.swift
//  BlazeTest
//
//  Created by Gerardo Valencia on 11/4/20.
//

import UIKit

class CustomerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel  : UILabel!
    @IBOutlet weak var emailLabel : UILabel!
    @IBOutlet weak var phoneLabel : UILabel!
    @IBOutlet weak var informationView : UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.informationView.layer.cornerRadius = 20
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
