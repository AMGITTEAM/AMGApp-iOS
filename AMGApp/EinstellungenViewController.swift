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
    @IBOutlet weak var unterstufeColorPreview: UIView!
    @IBOutlet weak var mittelstufeColorPreview: UIView!
    @IBOutlet weak var oberstufeColorPreview: UIView!
    var klassenPicker: KlassenPicker? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        klassenPicker = KlassenPicker(pickerView: eigeneKlassePicker)
        self.eigeneKlassePicker.delegate = klassenPicker
        self.eigeneKlassePicker.dataSource = klassenPicker
        klassenPicker!.refresh()
        
        eigeneKlasseColorPreview.backgroundColor = UIColor.fromHexString(hexString: UserDefaults.standard.string(forKey: "vertretungEigeneKlasseFarbe") ?? "#FF0000")
        unterstufeColorPreview.backgroundColor = UIColor.fromHexString(hexString: UserDefaults.standard.string(forKey: "vertretungUnterstufeFarbe") ?? "#4aa3df")
        mittelstufeColorPreview.backgroundColor = UIColor.fromHexString(hexString: UserDefaults.standard.string(forKey: "vertretungMittelstufeFarbe") ?? "#3498db")
        oberstufeColorPreview.backgroundColor = UIColor.fromHexString(hexString: UserDefaults.standard.string(forKey: "vertretungOberstufeFarbe") ?? "#258cd1")
        
        eigeneKlasseColorPreview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.changeEigeneKlasseColor)))
        unterstufeColorPreview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.changeUnterstufeColor)))
        mittelstufeColorPreview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.changeMittelstufeColor)))
        oberstufeColorPreview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.changeOberstufeColor)))
    }
    
    func pickColor(color: UIColor) -> UIColor {
        let picker = UIColorPickerViewController()
        picker.supportsAlpha = false
        picker.selectedColor = color
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
            let pickedColor = self.pickColor(color: self.eigeneKlasseColorPreview.backgroundColor!)
            DispatchQueue.main.async { [self] in
                UserDefaults.standard.set(UIColor.hexStringFromColor(color: pickedColor), forKey: "vertretungEigeneKlasseFarbe")
                eigeneKlasseColorPreview.backgroundColor = pickedColor
            }
        }
    }
    @IBAction func changeUnterstufeColor(_ sender: Any) {
        DispatchQueue.global(qos: .background).async {
            let pickedColor = self.pickColor(color: self.unterstufeColorPreview.backgroundColor!)
            DispatchQueue.main.async { [self] in
                UserDefaults.standard.set(UIColor.hexStringFromColor(color: pickedColor), forKey: "vertretungUnterstufeFarbe")
                unterstufeColorPreview.backgroundColor = pickedColor
            }
        }
    }
    @IBAction func changeMittelstufeColor(_ sender: Any) {
        DispatchQueue.global(qos: .background).async {
            let pickedColor = self.pickColor(color: self.mittelstufeColorPreview.backgroundColor!)
            DispatchQueue.main.async { [self] in
                UserDefaults.standard.set(UIColor.hexStringFromColor(color: pickedColor), forKey: "vertretungMittelstufeFarbe")
                mittelstufeColorPreview.backgroundColor = pickedColor
            }
        }
    }
    @IBAction func changeOberstufeColor(_ sender: Any) {
        DispatchQueue.global(qos: .background).async {
            let pickedColor = self.pickColor(color: self.oberstufeColorPreview.backgroundColor!)
            DispatchQueue.main.async { [self] in
                UserDefaults.standard.set(UIColor.hexStringFromColor(color: pickedColor), forKey: "vertretungOberstufeFarbe")
                oberstufeColorPreview.backgroundColor = pickedColor
            }
        }
    }
}
