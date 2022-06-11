//
//  CustomCollectionViewCell.swift
//  LoginAPI
//
//  Created by Sai Hari on 18/05/22.
//

import UIKit

class CustomCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var childName: UILabel!
    
    override func prepareForReuse() {
        profileImg.image = nil
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        profileImg.layer.masksToBounds = true
        profileImg.layer.cornerRadius = 25
    }
    
}
