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
    @IBOutlet weak var iconsImVertretungsplan: UISwitch!
    var klassenPicker: KlassenPicker? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        klassenPicker = KlassenPicker(pickerView: eigeneKlassePicker)
        self.eigeneKlassePicker.delegate = klassenPicker
        self.eigeneKlassePicker.dataSource = klassenPicker
        klassenPicker!.refresh()
        if(UserDefaults.standard.object(forKey: "vertretungsplanIconsEnabled") != nil){
            iconsImVertretungsplan.isOn = UserDefaults.standard.bool(forKey: "vertretungsplanIconsEnabled")
        }
        
        eigeneKlasseColorPreview.backgroundColor = UIColor.fromHexString(hexString: UserDefaults.standard.string(forKey: "vertretungEigeneKlasseFarbe") ?? "#FF0000")
        unterstufeColorPreview.backgroundColor = UIColor.fromHexString(hexString: UserDefaults.standard.string(forKey: "vertretungUnterstufeFarbe") ?? "#4aa3df")
        mittelstufeColorPreview.backgroundColor = UIColor.fromHexString(hexString: UserDefaults.standard.string(forKey: "vertretungMittelstufeFarbe") ?? "#3498db")
        oberstufeColorPreview.backgroundColor = UIColor.fromHexString(hexString: UserDefaults.standard.string(forKey: "vertretungOberstufeFarbe") ?? "#258cd1")
        
        eigeneKlasseColorPreview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.changeEigeneKlasseColor)))
        unterstufeColorPreview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.changeUnterstufeColor)))
        mittelstufeColorPreview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.changeMittelstufeColor)))
        oberstufeColorPreview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.changeOberstufeColor)))
    }
    
    var completionHandler: ((UIColor)->Void)? = nil
    func pickColor(color: UIColor, completion: @escaping ((UIColor)->Void)) {
        completionHandler = completion
        if #available(iOS 14.0, *) {
            let picker: UIColorPickerViewController = UIColorPickerViewController()
            picker.supportsAlpha = false
            picker.selectedColor = color
            picker.delegate = self
            
            self.present(picker, animated: true)
        } else {
            tabBarController?.showToast(message: "Diese Funktion ist erst ab iOS 14 verfügbar!")
        }
    }
    
    @available(iOS 14.0, *)
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        if(completionHandler != nil){
            completionHandler!(viewController.selectedColor)
        }
    }
    
    @IBAction func changeEigeneKlasseColor(_ sender: Any) {
        self.pickColor(color: self.eigeneKlasseColorPreview.backgroundColor!, completion: { [self] (pickedColor) in
            UserDefaults.standard.set(UIColor.hexStringFromColor(color: pickedColor), forKey: "vertretungEigeneKlasseFarbe")
            eigeneKlasseColorPreview.backgroundColor = pickedColor
        })
    }
    @IBAction func changeUnterstufeColor(_ sender: Any) {
        self.pickColor(color: self.unterstufeColorPreview.backgroundColor!, completion: { [self] (pickedColor) in
            UserDefaults.standard.set(UIColor.hexStringFromColor(color: pickedColor), forKey: "vertretungUnterstufeFarbe")
            unterstufeColorPreview.backgroundColor = pickedColor
        })
    }
    @IBAction func changeMittelstufeColor(_ sender: Any) {
        self.pickColor(color: self.mittelstufeColorPreview.backgroundColor!, completion: { [self] (pickedColor) in
            UserDefaults.standard.set(UIColor.hexStringFromColor(color: pickedColor), forKey: "vertretungMittelstufeFarbe")
            mittelstufeColorPreview.backgroundColor = pickedColor
        })
    }
    @IBAction func changeOberstufeColor(_ sender: Any) {
        self.pickColor(color: self.oberstufeColorPreview.backgroundColor!, completion: { [self] (pickedColor) in
            UserDefaults.standard.set(UIColor.hexStringFromColor(color: pickedColor), forKey: "vertretungOberstufeFarbe")
            oberstufeColorPreview.backgroundColor = pickedColor
        })
    }
    
    @IBAction func vertretungsplanIconsChanged(_ sender: UISwitch) {
        UserDefaults.standard.setValue(sender.isOn, forKey: "vertretungsplanIconsEnabled")
    }
}
