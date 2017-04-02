//
//  CameraPageViewController.swift
//  Smile
//
//  Created by Luke Brody on 4/1/17.
//  Copyright © 2017 Luke Brody. All rights reserved.
//

import UIKit

class CameraPageViewController : StaticPageViewController {
    
    override func loadViewControllers() -> [UIViewController] {
        return [
            self.storyboard!.instantiateViewController(withIdentifier: "CameraViewController"),
            self.storyboard!.instantiateViewController(withIdentifier: "MemoriesViewController")
        ]
    }
    
    override var initialIndex: Int { return 0 }
    
}
