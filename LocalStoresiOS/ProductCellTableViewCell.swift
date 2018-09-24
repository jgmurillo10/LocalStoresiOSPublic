//
//  ProductCellTableViewCell.swift
//  LocalStoresiOS
//
//  Created by Juan Murillo on 9/10/17.
//  Copyright © 2017 Juan Murillo. All rights reserved.
//

import UIKit

class ProductCellTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageProduct: UIImageView!
    @IBOutlet weak var labelName: UILabel?
    @IBOutlet weak var labelStore: UILabel!
    @IBOutlet weak var labelPrice: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
