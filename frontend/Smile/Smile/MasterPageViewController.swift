//
//  MasterPageViewController.swift
//  Smile
//
//  Created by Luke Brody on 4/1/17.
//  Copyright © 2017 Luke Brody. All rights reserved.
//

import UIKit

var masterPageViewController : MasterPageViewController!

class MasterPageViewController : StaticPageViewController {
    
    override func loadViewControllers() -> [UIViewController] {
        
        masterPageViewController = self
        
        return [
            storyboard!.instantiateViewController(withIdentifier: "GlobalFeedViewController"),
            storyboard!.instantiateViewController(withIdentifier: "CameraPageViewController")
        ]
    }
    
    override var initialIndex: Int {
        return 1
    }
    
}
