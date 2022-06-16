//
//  UIImage+image.swift
//  LoginAPI
//
//  Created by Sai Hari on 16/06/22.
//

import Foundation
import UIKit

extension UIImage {
    // function to return image with initials based on the first few characters of the given name
    static func image(withLabel name: String?) -> UIImage? {
        
        let frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        let nameLabel = UILabel(frame: frame)
        nameLabel.layer.masksToBounds = true
        nameLabel.layer.cornerRadius = 25.0
        nameLabel.textAlignment = .center
        nameLabel.backgroundColor = .lightGray
        nameLabel.textColor = .darkGray
        nameLabel.font = UIFont.boldSystemFont(ofSize: 20)
      
        var initial : String.SubSequence?
        if name!.count < 3 {
            initial = name?.prefix(through: String.Index(utf16Offset: 1, in: name!))
        }
        else {
            initial = name?.prefix(through: String.Index(utf16Offset: 2, in: name!))
        }
        //print("initial is : \(String(describing: initial?.uppercased()))")
    
        nameLabel.text = initial?.uppercased()
        UIGraphicsBeginImageContext(frame.size)
        if let currentContext = UIGraphicsGetCurrentContext() {
               nameLabel.layer.render(in: currentContext)
               let nameImage = UIGraphicsGetImageFromCurrentImageContext()
               return nameImage
        }
        return nil
    }
}
