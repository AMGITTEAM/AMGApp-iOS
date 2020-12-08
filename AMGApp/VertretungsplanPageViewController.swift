//
//  VertretungsplanPageViewController.swift
//  AMGApp
//
//  Created by localadmin on 09.02.19.
//  Copyright © 2019 amg-witten. All rights reserved.
//

import Foundation
import UIKit

class VertretungsplanPageViewController: UIPageViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource=self
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let password = UserDefaults.standard.string(forKey: "loginPassword")
        if(password==nil){
            performSegue(withIdentifier: "vPlanToLogin", sender: self)
            return
        }
    }
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        let UIViewControllers: [UIViewController] = [self.newVertretungsplanViewController(count: 1),
                                                     self.newVertretungsplanViewController(count: 2)]
        return UIViewControllers
    }()
    
    private func newVertretungsplanViewController(count: Int) -> UIViewController {
        let view = UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewController(withIdentifier: "VertretungsplanView") as? VertretungsplanViewController
        if(count==1){
            view!.day = "Heute"
        }
        else if(count==2){
            view!.day = "Folgetag"
        }
        return view!
    }
    
}

extension VertretungsplanPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
                return nil
            }
            
            let nextIndex = viewControllerIndex + 1
            let orderedViewControllersCount = orderedViewControllers.count
            
            guard orderedViewControllersCount != nextIndex else {
                return nil
            }
            
            guard orderedViewControllersCount > nextIndex else {
                return nil
            }
            
            return orderedViewControllers[nextIndex]
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
}
