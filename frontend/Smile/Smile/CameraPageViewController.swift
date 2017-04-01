//
//  CameraPageViewController.swift
//  Smile
//
//  Created by Luke Brody on 4/1/17.
//  Copyright © 2017 Luke Brody. All rights reserved.
//

import UIKit

class CameraPageViewController : UIPageViewController {
    
    override func viewDidLoad() {
        setViewControllers([
            
            storyboard!.instantiateViewController(withIdentifier: "CameraViewController"),
            storyboard!.instantiateViewController(withIdentifier: "MemoriesViewController")
            
            ], direction: .forward, animated: false, completion: nil)
    }
    
}
