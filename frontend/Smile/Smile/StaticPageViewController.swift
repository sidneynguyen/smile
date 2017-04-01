//
//  StaticPageViewController.swift
//  Smile
//
//  Created by Luke Brody on 4/1/17.
//  Copyright © 2017 Luke Brody. All rights reserved.
//

import UIKit

class StaticPageViewController : UIPageViewController, UIPageViewControllerDataSource {
    
    func loadViewControllers() -> [UIViewController] {
        fatalError()
    }
    
    var initialIndex : Int {
        return -1
    }
    
    lazy var vcs : [UIViewController] = self.loadViewControllers()
    
    
    override func viewDidLoad() {
        
        dataSource = self
        
        setViewControllers([
            
            vcs[initialIndex]
            
            ], direction: .forward, animated: false, completion: nil)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let idx = vcs.index(of: viewController)!
        
        if idx == 0 {
            return nil
        } else {
            return vcs[idx - 1]
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let idx = vcs.index(of: viewController)!
        
        if idx == vcs.count - 1 {
            return nil
        } else {
            return vcs[idx + 1]
        }
        
    }
    
}
