//
//  StundenplanTextInput.swift
//  AMGApp
//
//  Created by Adrian Kathagen on 22.01.21.
//  Copyright © 2021 amg-witten. All rights reserved.
//

import AVFoundation
import UIKit

class StundenplanTextInput: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var textField: UITextView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideKeyboardWhenTappedAround()
        textField.delegate = self
        textField.text = "Gib hier den Code ein, der über \"Als Text exportieren\" generiert wurde!"
        textField.textColor = UIColor.lightGray
    }
    
    @IBAction func done(_ sender: Any) {
        let code = textField.text ?? ""
        let decoded = NSMutableData(base64Encoded: code, options: .ignoreUnknownCharacters)
        do {
            let decompressed = (try decoded?.decompressed(using: .zlib))!
            let string = String(decoding: decompressed, as: UTF8.self)
            print(string)
            let stundenplan = string.components(separatedBy: "&").map{return $0.decodeUrl()}
            UserDefaults.standard.setValue(stundenplan[0], forKey: "stundenplanMontag")
            UserDefaults.standard.setValue(stundenplan[1], forKey: "stundenplanDienstag")
            UserDefaults.standard.setValue(stundenplan[2], forKey: "stundenplanMittwoch")
            UserDefaults.standard.setValue(stundenplan[3], forKey: "stundenplanDonnerstag")
            UserDefaults.standard.setValue(stundenplan[4], forKey: "stundenplanFreitag")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textField.text = "Gib hier den Code ein, der über \"Als Text exportieren\" generiert wurde!"
            textView.textColor = UIColor.lightGray
        }
    }
}
