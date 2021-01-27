//
//  Info.swift
//  AMGApp
//
//  Created by Adrian Kathagen on 27.01.21.
//  Copyright © 2021 amg-witten. All rights reserved.
//

import Foundation
import UIKit

class Info: UIViewController {
    
    @IBOutlet weak var infoText: UILabel!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        infoText.text = "Diese App wird programmiert, verwaltet und gewartet von Adrian Kathagen  Version: "+(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)+"  Icons: Silk Icons, by Mark James - famfamfam         Apple System Icons  Diese App wurde programmiert für das     Albert-Martmöller-Gymnasium     Oberdorf 9     58456 Witten      Tel: +49 2302 189172     Fax: +49 2302 189059      amg@schule-witten.de"
    }
    
}
