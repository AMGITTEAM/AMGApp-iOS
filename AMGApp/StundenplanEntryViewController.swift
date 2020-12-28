//
//  StundenplanEntryViewController.swift
//  AMGApp
//
//  Created by Adrian Kathagen on 12.12.20.
//  Copyright © 2020 amg-witten. All rights reserved.
//

import Foundation
import UIKit

class StundenplanEntryViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var fachname: UITextField!
    @IBOutlet weak var fachAbk: UITextField!
    @IBOutlet weak var lehrer: UITextField!
    @IBOutlet weak var raum: UITextField!
    
    public var stunde: StundenplanViewController.StundenplanEintragModel? = nil
    public var delegate: StundenplanViewController? = nil
    
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