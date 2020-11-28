//
//  TabViewController.swift
//  AMGApp
//
//  Created by Adrian Kathagen on 28.11.20.
//  Copyright © 2020 amg-witten. All rights reserved.
//

import Foundation
import UIKit

class TabViewController:UITabBarController {
    override func viewWillAppear(_ animated: Bool) {
        enableDisableItems()
        super.viewWillAppear(animated)
    }
    
    func enableDisableItems(){
        for item in tabBar.items! {
            item.isEnabled = true
        }
        
        if(UserDefaults.standard.string(forKey: "loginUsername") == nil){
            tabBar.items![1].isEnabled = false
        }
    }
}
