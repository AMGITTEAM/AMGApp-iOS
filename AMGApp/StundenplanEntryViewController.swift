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
    @IBOutlet weak var innerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var contentView: UIView!
    
    public var stunde: StundenplanViewController.StundenplanEintragModel? = nil
    public var delegate: StundenplanDay? = nil
    private var newHeightConstraint: NSLayoutConstraint? = nil
    
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
