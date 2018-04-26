//
//  FavTableViewCell.swift
//  mapSearch-hw9
//
//  Created by pike on 4/25/18.
//  Copyright © 2018 pike. All rights reserved.
//

import UIKit

class FavTableViewCell: UITableViewCell {
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var vicinityLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
