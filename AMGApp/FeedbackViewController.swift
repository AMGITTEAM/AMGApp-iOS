//
//  FeedbackViewController.swift
//  AMGApp
//
//  Created by Adrian Kathagen on 28.11.20.
//  Copyright © 2020 amg-witten. All rights reserved.
//

import Foundation
import UIKit

class FeedbackViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var typePicker: UIPickerView!
    @IBOutlet weak var beschreibung: UITextField!
    
    var pickerData: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.typePicker.delegate = self
        self.typePicker.dataSource = self
        
        pickerData = ["Bug/Fehler", "Idee/Anregung", "Anderes"]
        
        self.hideKeyboardWhenTappedAround()
        beschreibung.delegate = self
    }
    
    @IBAction func submit(_ sender: Any) {
        let usernameString = UserDefaults.standard.string(forKey: "loginUsername")
        let passwordString = UserDefaults.standard.string(forKey: "loginPassword")
        var url = "https://amgitt.de/AMGAppServlet/amgapp?requestType=Feedback&request=&username="+usernameString!+"&password="+passwordString!
        url += "&datum="+pickerData[typePicker.selectedRow(inComponent: 0)]
        url += "&gebaeude="+beschreibung.text!+"&etage=&raum=&wichtigkeit=&fehler=&beschreibung=&status=&bearbeitetVon="
        
        print("before: "+url)
        url = url.encodeUrl()!
        print("after: "+url)
        
        do {
            try String(contentsOf: URL(string: url)!)
        } catch _ {}
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
