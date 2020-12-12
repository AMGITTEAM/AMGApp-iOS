//
//  StundenplanEntryViewController.swift
//  AMGApp
//
//  Created by Adrian Kathagen on 12.12.20.
//  Copyright © 2020 amg-witten. All rights reserved.
//

import Foundation
import UIKit

class StundenplanEntryViewController: UIViewController {
    @IBOutlet weak var fachname: UITextField!
    @IBOutlet weak var fachAbk: UITextField!
    @IBOutlet weak var lehrer: UITextField!
    @IBOutlet weak var raum: UITextField!
    
    @IBAction func pressAbbrechen(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func pressDelete(_ sender: Any) {
    }
    @IBAction func pressSpeichern(_ sender: Any) {
    }
}
