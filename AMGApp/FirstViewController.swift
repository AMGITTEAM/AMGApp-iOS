//
//  FirstViewController.swift
//  AMGApp
//
//  Created by localadmin on 15.12.18.
//  Copyright © 2018 amg-witten. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if(Variables.shouldShowLoginToast) {
            DispatchQueue(label: "toast").async {
                sleep(UInt32(0.5))
                DispatchQueue.main.async {
                    self.showToast(message: "Du musst dich zuerst einloggen!")
                }
            }
            Variables.shouldShowLoginToast=false
        }
        if(Variables.shouldShowLogoutSuccessToast){
            DispatchQueue(label: "toast").async {
                sleep(UInt32(0.5))
                DispatchQueue.main.async {
                    self.showToast(message: "Logout erfolgreich")
                }
            }
            Variables.shouldShowLogoutSuccessToast=false
        }
        if(Variables.shouldShowLoginSuccessToast){
            DispatchQueue(label: "toast").async {
                sleep(UInt32(0.5))
                DispatchQueue.main.async {
                    self.showToast(message: "Login erfolgreich")
                }
            }
            Variables.shouldShowLoginSuccessToast=false
        }
    }


}

