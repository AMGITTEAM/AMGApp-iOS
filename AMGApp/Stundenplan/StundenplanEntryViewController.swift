//
//  StundenplanEntryViewController.swift
//  AMGApp
//
//  Created by Adrian Kathagen on 12.12.20.
//  Copyright © 2020 amg-witten. All rights reserved.
//

import Foundation
import UIKit

class StundenplanEntryViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var presetPicker: UIPickerView!
    @IBOutlet weak var fachname: UITextField!
    @IBOutlet weak var fachAbk: UITextField!
    @IBOutlet weak var lehrer: UITextField!
    @IBOutlet weak var raum: UITextField!
    @IBOutlet weak var innerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var contentView: UIView!
    
    public var stunde: StundenplanViewController.StundenplanEintragModel? = nil
    public var delegate: StundenplanDay? = nil
    private var newHeightConstraint: NSLayoutConstraint? = nil
    private var stundenPresets = [[String]]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fachname.text = stunde?.fachName.trimmingCharacters(in: .whitespaces)
        fachAbk.text = stunde?.fach.trimmingCharacters(in: .whitespaces)
        lehrer.text = stunde?.lehrer.trimmingCharacters(in: .whitespaces)
        raum.text = stunde?.raum.trimmingCharacters(in: .whitespaces)
        
        fachname.delegate = self
        fachAbk.delegate = self
        lehrer.delegate = self
        raum.delegate = self
        
        self.hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        for i in 0...4 {
            let jsonString = UserDefaults.standard.string(forKey: "stundenplan"+StundenplanDay.wochentagToString(wochentag: i)) ?? ""
            do {
                let stundenStrings = try JSONDecoder().decode([String].self, from: (jsonString.data(using: .utf8)!))
                var stunden = stundenStrings.map{StundenplanViewController.StundenplanEintragModel(allString: $0)}
                stunden.sort(by: {return $0.stunde < $1.stunde})
                stunden.forEach{
                    if(!stundenPresets.map{$0[0]}.contains($0.fachName) && $0.fachName.count>1){
                        stundenPresets.append([$0.fachName, $0.fach, $0.lehrer, $0.raum])
                    }
                }
            } catch {}
            stundenPresets.sort{return $0[0]<$1[0]}
        }
        
        presetPicker.dataSource = self
        presetPicker.delegate = self
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return stundenPresets.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return stundenPresets[row][0]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        fachname.text = stundenPresets[row][0]
        fachAbk.text = stundenPresets[row][1]
        lehrer.text = stundenPresets[row][2]
        raum.text = stundenPresets[row][3]
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            innerViewBottomConstraint.constant = keyboardSize.height
            contentView.layoutIfNeeded()
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        innerViewBottomConstraint.constant = 16
        contentView.layoutIfNeeded()
    }
    
    @IBAction func pressAbbrechen(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func pressDelete(_ sender: Any) {
        self.delegate?.delete()
        dismiss(animated: true, completion: nil)
    }
    @IBAction func pressSpeichern(_ sender: Any) {
        let newStunde = StundenplanViewController.StundenplanEintragModel(stunde: stunde!.stunde, fachName: fachname.text!, fachAbk: fachAbk.text!, lehrer: lehrer.text!, raum: raum.text!)
        print("delegate: "+self.delegate.debugDescription)
        self.delegate?.override(stundeNeu: newStunde)
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case fachname:
            fachAbk.becomeFirstResponder()
        case fachAbk:
            lehrer.becomeFirstResponder()
        case lehrer:
            raum.becomeFirstResponder()
        default:
            dismissKeyboard()
        }
        return false
    }
}
