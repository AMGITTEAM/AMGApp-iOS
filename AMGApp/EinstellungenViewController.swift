//
//  EinstellungenViewController.swift
//  AMGApp
//
//  Created by Adrian Kathagen on 28.11.20.
//  Copyright © 2020 amg-witten. All rights reserved.
//

import Foundation
import UIKit

class EinstellungenViewController: UIViewController, UIColorPickerViewControllerDelegate{
    
    @IBOutlet weak var eigeneKlassePicker: UIPickerView!
    var klassenPicker: KlassenPicker? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        klassenPicker = KlassenPicker(pickerView: eigeneKlassePicker)
        self.eigeneKlassePicker.delegate = klassenPicker
        self.eigeneKlassePicker.dataSource = klassenPicker
        klassenPicker!.refresh()
        
        //let picker = UIColorPickerViewController()
        //picker.supportsAlpha = false
        //present(picker, animated: true, completion: nil)
    }
}
