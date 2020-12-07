//
//  KlassenPicker.swift
//  AMGApp
//
//  Created by Adrian Kathagen on 30.11.20.
//  Copyright © 2020 amg-witten. All rights reserved.
//

import Foundation
import UIKit

class KlassenPicker: NSObject, UIPickerViewDelegate, UIPickerViewDataSource  {
    
    var picker: UIPickerView
    var klassen = [["05", "06", "07", "08", "09", "EF", "Q1", "Q2"],["a","b","c","d"]]
    var selectedStufe = 0
    var selectedKlasse = 0
    
    init(pickerView: UIPickerView){
        self.picker = pickerView
        
        let gesamtKlasse = UserDefaults.standard.string(forKey: "klasse") ?? ""
        if(gesamtKlasse != ""){
            let stufe = String(gesamtKlasse.prefix(2))
            let klasse = String(gesamtKlasse.suffix(1))
            
            selectedStufe = klassen[0].firstIndex(of: stufe)!
            if(gesamtKlasse.count == 3){ //oberstufe only has two
                selectedKlasse = klassen[1].firstIndex(of: klasse)!
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(selectedStufe > 4 && component == 1){ //oberstufe
            return 0
        }
        return klassen[component].count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return klassen[component][row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(component == 0){
            selectedStufe = row
            refresh()
        } else if(component == 1){
            selectedKlasse = row
        }
        
        print(klassen[0][selectedStufe]+(selectedStufe > 4 ? "" : klassen[1][selectedKlasse]))
        UserDefaults.standard.set(self.klassen[0][self.selectedStufe]+(self.selectedStufe > 4 ? "" : self.klassen[1][self.selectedKlasse]), forKey: "klasse")
    }
    
    func refresh(){
        picker.reloadAllComponents()
        picker.selectRow(selectedStufe, inComponent: 0, animated: false)
        picker.selectRow(selectedKlasse, inComponent: 1, animated: false)
    }
    
}
