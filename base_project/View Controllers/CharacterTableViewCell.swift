//
//  CharacterTableViewCell.swift
//  base_project
//
//  Created by Pranav Singh on 30/08/22.
//

import UIKit

class CharacterTableViewCell: UITableViewCell {
    
    //MARK: - outlets
    @IBOutlet weak var characterIV: UIImageView!
    
    @IBOutlet weak var characterIVWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var characterNameLabel: UILabel!
    
    @IBOutlet weak var characterPortrayedByLabel: UILabel!

    //MARK: - Lifecycle methods
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
