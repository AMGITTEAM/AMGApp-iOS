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
    @IBOutlet weak var eigeneKlasseColorPreview: UIView!
    var klassenPicker: KlassenPicker? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        klassenPicker = KlassenPicker(pickerView: eigeneKlassePicker)
        self.eigeneKlassePicker.delegate = klassenPicker
        self.eigeneKlassePicker.dataSource = klassenPicker
        klassenPicker!.refresh()
        
        eigeneKlasseColorPreview.backgroundColor = UIColor.fromHexString(hexString: UserDefaults.standard.string(forKey: "vertretungEigeneKlasseFarbe") ?? "#FF0000")
    }
    
    func pickColor() -> UIColor{
        let picker = UIColorPickerViewController()
        picker.supportsAlpha = false
        present(picker, animated: true, completion: nil)
        while(picker.viewIfLoaded?.window == nil){
            usleep(1000)
        }
        while(picker.viewIfLoaded?.window != nil){
            usleep(1000)
        }
        return picker.selectedColor
    }
    
    @IBAction func changeEigeneKlasseColor(_ sender: Any) {
        DispatchQueue.global(qos: .background).async {
            let pickedColor = self.pickColor()
            DispatchQueue.main.async { [self] in
                UserDefaults.standard.set(UIColor.hexStringFromColor(color: pickedColor), forKey: "vertretungEigeneKlasseFarbe")
                eigeneKlasseColorPreview.backgroundColor = pickedColor
            }
        }
    }
}
