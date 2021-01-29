//
//  StundenplanDay.swift
//  AMGApp
//
//  Created by Adrian Kathagen on 22.01.21.
//  Copyright © 2021 amg-witten. All rights reserved.
//

import Foundation
import UIKit

class StundenplanDay: UIViewController {
    
    @IBOutlet weak var stackView: UIStackView!
    var stunden = [StundenplanEintragModel]()
    var wochentag = 0
    var vertretungsplanModel: VertretungsplanViewController.VertretungModelArrayModel? = nil
    var editingStundenplan = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = view //force it to load
    }
    
    func create(wochentag: Int, vertretungsplanModel: VertretungsplanViewController.VertretungModelArrayModel?, editingStundenplan: Bool){
        _ = view //force it to load
        self.wochentag = wochentag
        self.vertretungsplanModel = vertretungsplanModel
        self.editingStundenplan = editingStundenplan
        updateView()
    }
    func updateView(){
        let jsonString = UserDefaults.standard.string(forKey: "stundenplan"+StundenplanDay.wochentagToString(wochentag: wochentag)) ?? ""
        do {
            let stundenStrings = try JSONDecoder().decode([String].self, from: (jsonString.data(using: .utf8)!))
            stunden = stundenStrings.map{StundenplanEintragModel(allString: $0)}
            stunden.sort(by: {return $0.stunde < $1.stunde})
            
            stackView.removeAllArrangedSubviews()
            stunden.forEach{stunde in
                let vertretungModel = vertretungsplanModel?.getRightRows().first(where: {vModel in
                    if(vModel.getStunde().contains(" - ")){ //erstreckt sich über mehrere Stunden
                        return vModel.getStunde().components(separatedBy: " - ").contains(where: {stundeNr in
                            return (Int(stundeNr) == stunde.stunde && vModel.getFach() == stunde.fach)
                        })
                    }
                    return (Int(vModel.getStunde()) == stunde.stunde && vModel.getFach() == stunde.fach)
                })
                
                stackView.addArrangedSubview(StundenplanEntry(stunde: stunde.stunde, fach: stunde.fachName, fachId: stunde.fach, lehrer: stunde.lehrer, raum: stunde.raum, moveNeunteStunde: stunden.count >= 10, vertretungModel: vertretungModel, delegate: self, editingStundenplan: editingStundenplan))
            }
            stackView.addHorizontalSeparators(color:.lightGray)
        } catch {
            return
        }
    }
    
    func saveStunden(){
        let jsonString = "["+stunden.map{$0.toJSONString()}.joined(separator:",")+"]"
        UserDefaults.standard.set(jsonString, forKey: "stundenplan"+StundenplanDay.wochentagToString(wochentag: wochentag))
    }
    
    var stunde: StundenplanEintragModel? = nil
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destVC = segue.destination as? StundenplanEntryViewController else{return}
        if let button = (sender as? UIButton) {
            stunde = stunden[button.tag-1]
        }
        destVC.stunde = stunde
        destVC.delegate = self
    }
    
    func addStunde(sender: Any?){
        stunde = StundenplanEintragModel(stunde: stunden.count+1, fachName: "", fachAbk: "", lehrer: "", raum: "")
        stunden.append(stunde!)
        
        self.performSegue(withIdentifier: "editStunde", sender: nil)
    }
    
    func delete(){
        if(stunde!.stunde != stunden.count){
            let stundeNeu = StundenplanEintragModel(stunde: stunde!.stunde, fachName: " ", fachAbk: " ", lehrer: " ", raum: " ")
            override(stundeNeu: stundeNeu)
        } else {
            stunden.remove(at: stunde!.stunde-1)
            saveStunden()
            updateView()
        }
    }
    func override(stundeNeu: StundenplanEintragModel){
        stunden[stunde!.stunde-1] = stundeNeu
        saveStunden()
        updateView()
    }
    
    static func wochentagToString(wochentag: Int) -> String{
        switch(wochentag){
        case 0:
            return "Montag"
        case 1:
            return "Dienstag"
        case 2:
            return "Mittwoch"
        case 3:
            return "Donnerstag"
        case 4:
            return "Freitag"
        default:
            return "ERROR"
        }
    }
    
    class StundenplanEintragModel {
        let stunde: Int
        let fach: String
        let lehrer: String
        let raum: String
        let fachName: String
        
        init(allString: String) {
            let all = allString.components(separatedBy: "||")
            stunde = Int(all[0]) ?? 1
            fach = all[1]
            lehrer = all[2]
            raum = all[3]
            fachName = all[4]
        }
        
        init(stunde: Int, fachName: String, fachAbk: String, lehrer: String, raum: String){
            self.stunde = stunde
            self.fachName = fachName
            self.fach = fachAbk
            self.lehrer = lehrer
            self.raum = raum
        }
        
        func toJSONString() -> String {
            var returns = "\""
            returns += String(stunde)+"||"
            returns += fach+"||"
            returns += lehrer+"||"
            returns += raum+"||"
            returns += fachName+"\""
            return returns
        }
    }
}
