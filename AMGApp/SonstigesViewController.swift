//
//  SonstigesView.swift
//  AMGApp
//
//  Created by Adrian Kathagen on 27.11.20.
//  Copyright © 2020 amg-witten. All rights reserved.
//

import Foundation


import UIKit

class SonstigesViewController: UITableViewController {

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }

}
