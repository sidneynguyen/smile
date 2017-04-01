//
//  CellGenerate.swift
//  Teleprompter
//
//  Created by Luke Brody on 9/27/16.
//  Copyright © 2016 Luke Brody. All rights reserved.
//

import UIKit
import MobileCoreServices

class ImageCell : UITableViewCell {
    
    @IBOutlet weak var contentImageView : UIImageView!
    
    dynamic var value : UIImage! {
        didSet {
            contentImageView.setValue(value, forKey: "image")
        }
    }
}

func generateImageCell() -> ImageCell {
    let cell = UIViewController(nibName: "ImageCell", bundle: nil).view as! ImageCell
    cell.contentImageView.contentMode = .scaleAspectFit
    return cell
}
